#!/usr/bin/env zsh

# Shell Config installer.
# Supports curl-to-zsh style installation by cloning this repo into an XDG
# config location and then delegating to scripts/csm bootstrap.

emulate -LR zsh
setopt errexit nounset pipefail

typeset -gr DEFAULT_REPO_URL='https://github.com/GrndZero101/shell-config.git'
typeset -gr DEFAULT_BRANCH='main'
typeset -gr DEFAULT_INSTALL_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/shell-config"

#
# Print installer usage and environment overrides.
# Arguments:
#   None.
# Returns:
#   0 after writing help text to stdout.
usage() {
  cat <<'EOF'
Usage: install.sh [--dir PATH] [--repo URL] [--branch NAME] [--no-bootstrap]

Environment overrides:
  SHELL_CONFIG_INSTALL_DIR   Clone destination (default: ~/.config/shell-config)
  SHELL_CONFIG_REPO_URL      Git repository URL
  SHELL_CONFIG_BRANCH        Git branch to clone
  SHELL_CONFIG_BOOTSTRAP     Set to 0 to skip csm bootstrap

Examples:
  curl -fsSL https://raw.githubusercontent.com/GrndZero101/shell-config/main/install.sh | zsh
  curl -fsSL https://raw.githubusercontent.com/GrndZero101/shell-config/main/install.sh | \
    SHELL_CONFIG_INSTALL_DIR="$HOME/.config/custom-shell-config" zsh
  curl -fsSL https://raw.githubusercontent.com/GrndZero101/shell-config/main/install.sh | \
    SHELL_CONFIG_BRANCH="feature/my-branch" zsh
  curl -fsSL https://raw.githubusercontent.com/GrndZero101/shell-config/main/install.sh | \
    zsh -s -- --branch feature/my-branch
EOF
}

#
# Print a short status line for the installer.
# Arguments:
#   $1 - Message to display.
# Returns:
#   0 after writing the message to stdout.
log_info() {
  print -P -- "%F{81}install:%f ${1}"
}

#
# Print an error line and terminate the installer.
# Arguments:
#   $1 - Error message to display.
# Returns:
#   Does not return.
# Side effects:
#   Writes to stderr and exits with status 1.
die() {
  print -u2 -P -- "%F{203}install:%f ${1}"
  exit 1
}

#
# Verify that a required executable is available.
# Arguments:
#   $1 - Command name to check.
# Returns:
#   0 when the command exists, non-zero otherwise.
require_command() {
  local command_name="${1}"

  (( $+commands[${command_name}] )) || die "required command not found: ${command_name}"
}

#
# Detect the current operating system for user-facing install logs.
# Arguments:
#   None.
# Returns:
#   0 after writing a normalized OS label to stdout.
detect_os() {
  case "${OSTYPE:-}" in
    darwin*)
      print -r -- 'macOS'
      ;;
    linux-gnu*|linux-musl*)
      if [[ -r /etc/alpine-release ]]; then
        print -r -- 'Alpine Linux'
      elif [[ -r /etc/os-release ]]; then
        local os_name=''
        os_name="$(sed -n 's/^NAME=//p' /etc/os-release | head -n 1)"
        os_name="${os_name#\"}"
        os_name="${os_name%\"}"
        print -r -- "${os_name:-Linux}"
      else
        print -r -- 'Linux'
      fi
      ;;
    *)
      print -r -- "${OSTYPE:-unknown}"
      ;;
  esac
}

#
# Detect the current CPU architecture for user-facing install logs.
# Arguments:
#   None.
# Returns:
#   0 after writing a normalized architecture label to stdout.
detect_arch() {
  case "$(uname -m)" in
    arm64|aarch64)
      print -r -- 'arm64'
      ;;
    x86_64|amd64)
      print -r -- 'x86_64'
      ;;
    *)
      uname -m
      ;;
  esac
}

#
# Return success when the target directory already looks like this repo.
# Arguments:
#   $1 - Candidate install directory.
# Returns:
#   0 when the directory contains the expected repo files, non-zero otherwise.
is_shell_config_clone() {
  local install_dir="${1}"

  [[ -d "${install_dir}/.git" ]] || return 1
  [[ -f "${install_dir}/.zshenv" ]] || return 1
  [[ -x "${install_dir}/scripts/csm" ]] || return 1
}

#
# Clone the repo when missing, reuse it when it already looks valid, and abort
# if the target directory contains unrelated files.
# Arguments:
#   $1 - Repository URL.
#   $2 - Branch name.
#   $3 - Install directory.
# Returns:
#   0 on success, non-zero on git failures or unsafe directory state.
# Side effects:
#   Creates the parent directory and may clone git content.
ensure_clone() {
  local repo_url="${1}"
  local branch_name="${2}"
  local install_dir="${3}"
  local parent_dir="${install_dir:h}"

  if [[ ! -e "${install_dir}" ]]; then
    mkdir -p -- "${parent_dir}"
    log_info "cloning ${repo_url} into ${install_dir}"
    git clone --branch "${branch_name}" --depth 1 "${repo_url}" "${install_dir}"
    return 0
  fi

  if is_shell_config_clone "${install_dir}"; then
    log_info "reusing existing clone at ${install_dir}"
    return 0
  fi

  die "install directory exists but does not look like a shell-config clone: ${install_dir}"
}

#
# Run the repository bootstrap step unless it was explicitly disabled.
# Arguments:
#   $1 - Install directory containing scripts/csm.
#   $2 - Bootstrap flag: 1 to run, 0 to skip.
# Returns:
#   0 on success, non-zero if bootstrap fails.
run_bootstrap() {
  local install_dir="${1}"
  local bootstrap_enabled="${2}"

  if [[ "${bootstrap_enabled}" == '0' ]]; then
    log_info 'skipping bootstrap because SHELL_CONFIG_BOOTSTRAP=0 or --no-bootstrap was used'
    return 0
  fi

  log_info 'running csm bootstrap'
  "${install_dir}/scripts/csm" bootstrap
}

#
# Parse installer flags and execute the install workflow.
# Arguments:
#   $@ - Optional installer flags.
# Returns:
#   0 on success, non-zero on invalid flags or install failures.
main() {
  local install_dir="${SHELL_CONFIG_INSTALL_DIR:-${DEFAULT_INSTALL_DIR}}"
  local repo_url="${SHELL_CONFIG_REPO_URL:-${DEFAULT_REPO_URL}}"
  local branch_name="${SHELL_CONFIG_BRANCH:-${DEFAULT_BRANCH}}"
  local bootstrap_enabled="${SHELL_CONFIG_BOOTSTRAP:-1}"
  local -a opt_help opt_no_bootstrap opt_dir opt_repo opt_branch

  zparseopts -D -E -K -- \
    h=opt_help \
    -help=opt_help \
    -no-bootstrap=opt_no_bootstrap \
    -dir:=opt_dir \
    -repo:=opt_repo \
    -branch:=opt_branch || return 1

  if (( ${#opt_help} > 0 )); then
    usage
    return 0
  fi

  if (( ${#opt_dir} > 0 )); then
    install_dir="${opt_dir[-1]}"
  fi

  if (( ${#opt_repo} > 0 )); then
    repo_url="${opt_repo[-1]}"
  fi

  if (( ${#opt_branch} > 0 )); then
    branch_name="${opt_branch[-1]}"
  fi

  if (( ${#opt_no_bootstrap} > 0 )); then
    bootstrap_enabled='0'
  fi

  if (( $# != 0 )); then
    die "unexpected arguments: $*"
  fi

  require_command git
  require_command zsh

  log_info "detected $(detect_os) on $(detect_arch)"
  log_info "install dir: ${install_dir}"
  log_info "branch: ${branch_name}"

  ensure_clone "${repo_url}" "${branch_name}" "${install_dir}"
  run_bootstrap "${install_dir}" "${bootstrap_enabled}"

  log_info 'installation complete'
  log_info "launch zsh or run 'csm select' to choose a profile"
}

main "$@"
