# Citadel prompt, vcs, and editor hooks.

autoload -Uz add-zsh-hook promptinit vcs_info
autoload -Uz precmd-git-extra precmd-terminal-title precmd-vcs-info

add-zsh-hook precmd precmd-terminal-title

if [[ "${SHELL_FORTRESS_ACTIVE_PROMPT_ENGINE:-native}" == 'oh-my-posh' ]]; then
  eval "$(oh-my-posh init zsh --config "${ZDOTDIR}/oh-my-posh.toml")"
elif [[ "${SHELL_FORTRESS_ACTIVE_PROMPT_ENGINE:-native}" == 'starship' ]]; then
  export STARSHIP_CONFIG="${ZDOTDIR}/starship.toml"
  eval "$(starship init zsh)"
else
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
fi
