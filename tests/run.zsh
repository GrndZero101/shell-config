#!/usr/bin/env zsh

# Shell-config test runner.
# Uses bats-core for the suite surface and optionally uses gum for human-friendly
# headings. The suite itself must still run when gum is absent.

emulate -LR zsh
setopt errexit nounset pipefail

typeset -gr SCRIPT_DIR="${${(%):-%N}:A:h}"
typeset -gr TEST_ROOT="${SCRIPT_DIR}"
typeset -gr BATS_DIR="${TEST_ROOT}/bats"
typeset -gr DOCKER_DIR="${TEST_ROOT}/docker"

#
# Print a section heading, optionally using gum when available.
# Arguments:
#   $1 - Heading text.
# Returns:
#   0 after writing the heading.
print_heading() {
  local heading_text="${1}"

  if (( $+commands[gum] )); then
    gum style --foreground 212 --bold "${heading_text}"
    return 0
  fi

  print -P -- "%F{212}%B${heading_text}%b%f"
}

#
# Print a short info line.
# Arguments:
#   $1 - Message text.
# Returns:
#   0 after writing the message.
print_info() {
  print -P -- "%F{81}tests:%f ${1}"
}

#
# Ensure bats is available before running the suite.
# Arguments:
#   None.
# Returns:
#   0 when bats exists, non-zero otherwise.
require_bats() {
  if (( ! $+commands[bats] )); then
    print -u2 -P -- "%F{203}tests:%f bats is not installed or not on PATH"
    print -u2 -- "tests: install bats-core to run ${BATS_DIR}"
    return 1
  fi
}

#
# Run the docker-based Ubuntu smoke path.
# Arguments:
#   $@ - Optional arguments forwarded to the docker smoke wrapper.
# Returns:
#   The exit status from the docker smoke wrapper.
run_docker_ubuntu() {
  local docker_runner="${DOCKER_DIR}/ubuntu-smoke.zsh"

  if [[ ! -x "${docker_runner}" ]]; then
    print -u2 -P -- "%F{203}tests:%f docker runner is missing or not executable: ${docker_runner}"
    return 1
  fi

  "${docker_runner}" "$@"
}

#
# Run the bats test suite with optional pass-through arguments.
# Arguments:
#   $@ - Optional arguments forwarded to bats.
# Returns:
#   The exit status from bats.
main() {
  local mode='local'

  if (( $# > 0 )); then
    case "${1}" in
      --docker-ubuntu)
        mode='docker-ubuntu'
        shift
        ;;
    esac
  fi

  if [[ "${mode}" == 'docker-ubuntu' ]]; then
    print_heading 'Shell Config Docker Smoke Harness'
    print_info 'mode: ubuntu clean-room'
    run_docker_ubuntu "$@"
    return $?
  fi

  require_bats || return 1

  print_heading 'Shell Config Test Harness'
  print_info "suite: ${BATS_DIR}"

  bats "${BATS_DIR}" "$@"
}

main "$@"
