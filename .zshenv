# Select the active ZDOTDIR profile for this repository.
typeset -gr SHELL_CONFIG_ROOT="${${(%):-%N}:A:h}"
typeset -gr SHELL_CONFIG_STATE_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/shell-config"
typeset -gr SHELL_CONFIG_STATE_FILE="${SHELL_CONFIG_STATE_DIR}/active-profile"
typeset -gr SHELL_CONFIG_SHARED_PATH="${SHELL_CONFIG_ROOT}/shared/path.zsh"

if [[ -r "${SHELL_CONFIG_SHARED_PATH}" ]]; then
  source "${SHELL_CONFIG_SHARED_PATH}"
fi

if [[ -z "${SHELL_CONFIG_PROFILE:-}" && -r "${SHELL_CONFIG_STATE_FILE}" ]]; then
  read -r SHELL_CONFIG_PROFILE < "${SHELL_CONFIG_STATE_FILE}"
fi

: "${SHELL_CONFIG_PROFILE:=zsh-clean}"

case "${SHELL_CONFIG_PROFILE}" in
  zsh-zero|zsh-clean|zsh-ref-atuin|zsh-ref-fzftab|zsh-tll-citadel-dev-fortress|zsh-tll-test)
    export ZDOTDIR="${SHELL_CONFIG_ROOT}/${SHELL_CONFIG_PROFILE}"
    ;;
  *)
    export ZDOTDIR="${SHELL_CONFIG_ROOT}/zsh-clean"
    ;;
esac
