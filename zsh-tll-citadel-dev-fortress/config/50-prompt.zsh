# Citadel prompt, vcs, and editor hooks.

# Load the fortress native prompt with vcs_info and title hooks.
# Arguments:
#   None.
# Returns:
#   0 after configuring the native prompt.
# Side effects:
#   Autoloads prompt helpers, registers precmd hooks, and sets PROMPT/RPROMPT.
fortress-load-native-prompt() {
  autoload -Uz add-zsh-hook promptinit vcs_info
  autoload -Uz precmd-git-extra precmd-terminal-title precmd-vcs-info

  add-zsh-hook precmd precmd-terminal-title

  zstyle ':vcs_info:*' enable git
  zstyle ':vcs_info:git:*' formats ' %F{245}[%b%f%c%u]'
  zstyle ':vcs_info:git:*' actionformats ' %F{203}[%b|%a%f%c%u]'
  zstyle ':vcs_info:git:*' stagedstr '+'
  zstyle ':vcs_info:git:*' unstagedstr '*'

  add-zsh-hook precmd precmd-vcs-info
  add-zsh-hook precmd precmd-git-extra

  promptinit
  prompt off

  PROMPT='%F{81}%n@%m%f:%F{120}%~%f${vcs_info_msg_0_}${SHELL_GIT_PROMPT_EXTRA} %# '
  RPROMPT='%F{221}${SHELL_PROMPT_MODE}%f %F{245}%D{%H:%M}%f'

  if [[ -n "${SSH_CONNECTION:-}" ]]; then
    PROMPT='%F{221}%n@%m%f:%F{120}%~%f${vcs_info_msg_0_}${SHELL_GIT_PROMPT_EXTRA} %# '
  fi
}

# Load the fortress starship prompt.
# Arguments:
#   None.
# Returns:
#   0 after configuring starship.
# Side effects:
#   Exports STARSHIP_CONFIG and evaluates starship init output.
fortress-load-starship-prompt() {
  export STARSHIP_CONFIG="${ZDOTDIR}/starship.toml"
  eval "$(starship init zsh)"
}

# Load the resolved fortress prompt engine.
# Arguments:
#   None.
# Returns:
#   0 after loading the selected prompt implementation.
# Side effects:
#   Dispatches to the selected prompt loader and keeps native fallback available.
fortress-load-prompt-engine() {
  case "${SHELL_FORTRESS_ACTIVE_PROMPT_ENGINE:-native}" in
    starship)
      fortress-load-starship-prompt
      ;;
    native)
      fortress-load-native-prompt
      ;;
    *)
      fortress-load-native-prompt
      ;;
  esac
}

fortress-load-prompt-engine
