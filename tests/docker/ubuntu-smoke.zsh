#!/usr/bin/env zsh

# Ubuntu clean-room smoke runner for the shell-config bats suite.
# Uses docker to install minimal test prerequisites in a disposable container
# and then runs the repo-owned test harness from the mounted checkout.

emulate -LR zsh
setopt errexit nounset pipefail

typeset -gr SCRIPT_DIR="${${(%):-%N}:A:h}"
typeset -gr TEST_ROOT="${SCRIPT_DIR:h}"
typeset -gr REPO_ROOT="${TEST_ROOT:h}"
typeset -gr DEFAULT_IMAGE='ubuntu:24.04'

#
# Print a short status line for the docker smoke flow.
# Arguments:
#   $1 - Message text.
# Returns:
#   0 after writing the message.
log_info() {
  print -P -- "%F{81}docker-tests:%f ${1}"
}

#
# Ensure docker exists before attempting the clean-room run.
# Arguments:
#   None.
# Returns:
#   0 when docker exists, non-zero otherwise.
require_docker() {
  if (( ! $+commands[docker] )); then
    print -u2 -P -- "%F{203}docker-tests:%f docker is not installed or not on PATH"
    return 1
  fi
}

#
# Run the Ubuntu smoke test inside a disposable docker container.
# Arguments:
#   $@ - Optional arguments forwarded to ./tests/run.zsh inside the container.
# Returns:
#   The exit status from docker run.
main() {
  local image_name="${SHELL_CONFIG_TEST_IMAGE:-${DEFAULT_IMAGE}}"

  require_docker || return 1

  log_info "image: ${image_name}"
  log_info "repo: ${REPO_ROOT}"

  docker run --rm \
    --volume "${REPO_ROOT}:/workspace/shell-config:ro" \
    --workdir /workspace/shell-config \
    "${image_name}" \
    bash -lc "
      set -euo pipefail
      export DEBIAN_FRONTEND=noninteractive
      apt-get update
      apt-get install -y --no-install-recommends bats ca-certificates git zsh
      mkdir -p /tmp/xdg-config /tmp/xdg-state /tmp/xdg-cache /tmp/xdg-data /tmp/xdg-runtime /tmp/home
      export HOME=/tmp/home
      export XDG_CONFIG_HOME=/tmp/xdg-config
      export XDG_STATE_HOME=/tmp/xdg-state
      export XDG_CACHE_HOME=/tmp/xdg-cache
      export XDG_DATA_HOME=/tmp/xdg-data
      export XDG_RUNTIME_DIR=/tmp/xdg-runtime
      zsh ./tests/run.zsh $*
    "
}

main "$@"
