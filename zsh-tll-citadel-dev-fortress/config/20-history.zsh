# Citadel history backend selection.

case "${SHELL_PROFILE_HISTORY_MODE:-profile}" in
  shared)
    mkdir -p -- "${SHELL_SHARED_STATE_DIR}"
    export HISTFILE="${SHELL_SHARED_STATE_DIR}/history"
    ;;
  *)
    export HISTFILE="${SHELL_PROFILE_STATE_DIR}/history"
    ;;
esac
