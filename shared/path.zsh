# Shared executable discovery only.
# Keep this file limited to universally useful PATH entries.

typeset -gU path PATH
typeset -ga shell_config_path_candidates

shell_config_path_candidates=(
  "${HOME}/.local/bin"
  "${HOME}/bin"
  "${XDG_BIN_HOME:-${HOME}/.local/bin}"
  /home/linuxbrew/.linuxbrew/bin
  /home/linuxbrew/.linuxbrew/sbin
  /opt/homebrew/bin
  /opt/homebrew/sbin
  /usr/local/bin
  /usr/local/sbin
  /usr/bin
  /bin
  /usr/sbin
  /sbin
)

path=(
  ${^shell_config_path_candidates}(N-/)
  ${path}
)
