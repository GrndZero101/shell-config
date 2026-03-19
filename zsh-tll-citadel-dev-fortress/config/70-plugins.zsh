# Citadel plugin manager bootstrap and selected plugins.

if fortress-bootstrap-zinit; then
  zinit ice wait lucid
  zinit snippet OMZP::colored-man-pages

  zinit ice wait lucid
  zinit snippet OMZP::sudo

  # web-search expects OMZ helper functions such as omz_urlencode and open_command.
  zinit ice wait lucid
  zinit snippet OMZL::functions.zsh

  zinit ice wait lucid atload'unfunction open_command 2>/dev/null || true; autoload -Uz open_command'
  zinit snippet OMZP::web-search

  # Load OMZ git for its broader git workflow helpers.
  zinit ice wait lucid
  zinit snippet OMZP::git
  if (( SHELL_FORTRESS_ENABLE_NATIVE_GIT )) && (( $+functions[fortress-apply-git-aliases] )); then
    fortress-apply-git-aliases
  fi

  # Cloud and completion-only helpers are worth loading when their backing tools exist.
  if (( $+commands[aws] )); then
    zinit ice wait lucid
    zinit snippet OMZP::aws
  fi

  if (( $+commands[pass] )); then
    zinit ice wait lucid as'completion'
    zinit snippet OMZ::plugins/pass/_pass
  fi

  if (( SHELL_FORTRESS_ENABLE_ZSH_VI_MODE )) && (( ! $+functions[zvm_widget_wrapper] )); then
    # Load vi-mode synchronously so it owns modal widgets from the first prompt.
    zinit ice lucid
    zinit light jeffreytse/zsh-vi-mode

    if (( SHELL_FORTRESS_ENABLE_ATUIN )) && (( $+commands[atuin] )); then
      fortress-register-zvm-atuin-init
    fi
  fi

  if (( ! SHELL_FORTRESS_LOAD_ZSH_AUTOCOMPLETE )) && (( SHELL_FORTRESS_ENABLE_FZF_TAB )) && (( $+commands[fzf] )); then
    # Load fzf-tab synchronously so it becomes the active Tab widget immediately.
    zinit ice lucid
    zinit light Aloxaf/fzf-tab

    zstyle ':fzf-tab:*' switch-group '<' '>'
    zstyle ':fzf-tab:*' fzf-command fzf
    zstyle ':fzf-tab:*' fzf-flags --height=60% --layout=reverse --border
    zstyle ':fzf-tab:*' use-fzf-default-opts yes
    zstyle ':fzf-tab:*' show-group full
    zstyle ':fzf-tab:*' prefix ''
  fi

  if (( SHELL_FORTRESS_ENABLE_ZSH_AUTOSUGGESTIONS )); then
    # Autosuggestions remain optional because zsh-autocomplete already covers similar ground.
    zinit ice wait lucid
    zinit light zsh-users/zsh-autosuggestions
  fi

  # Syntax highlighting should load after the rest of the interactive stack.
  zinit ice wait lucid
  zinit light zsh-users/zsh-syntax-highlighting
fi

if (( ! SHELL_FORTRESS_ENABLE_ZSH_VI_MODE )) && (( SHELL_FORTRESS_ENABLE_ATUIN )) && (( $+commands[atuin] )); then
  eval "$(atuin init zsh)"
fi

if (( ! $+functions[omz_urlencode] )); then
  autoload -Uz omz_urlencode
fi

# Prefer the fortress opener wrapper even when OMZ defines open_command.
if (( ! $+functions[open_command] )); then
  autoload -Uz open_command
fi
