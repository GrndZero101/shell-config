# Citadel line editor bindings and zle widgets.

autoload -Uz \
  fortress-hud \
  fortress-debug-interactive \
  fzf-cd-widget \
  fzf-find-dir \
  fzf-find-file \
  fzf-file-widget \
  zle-history-fzf \
  zle-keymap-select \
  zle-line-finish \
  zle-line-init \
  zsh-profile-select

# Apply the fortress fzf widget bindings in the requested keymaps.
# Arguments:
#   None.
# Returns:
#   0 after binding the widgets.
# Side effects:
#   Updates keybindings for file, directory, and history fzf widgets.
fortress-apply-fzf-widget-bindings() {
  bindkey -M emacs '^T' fzf-file-widget
  bindkey -M viins '^T' fzf-file-widget
  bindkey -M emacs '^[c' fzf-cd-widget
  bindkey -M viins '^[c' fzf-cd-widget
  bindkey -M emacs '^X^R' zle-history-fzf
  bindkey -M viins '^X^R' zle-history-fzf
}

# Apply fortress's preferred autocomplete bindings after the plugin loads.
# Arguments:
#   None.
# Returns:
#   0 after binding autocomplete-related keys.
# Side effects:
#   Updates Tab and menu-selection bindings for the experimental compat path.
fortress-apply-autocomplete-compat-bindings() {
  bindkey -M emacs '^I' menu-select
  bindkey -M viins '^I' menu-select
  bindkey -M menuselect '^I' menu-complete

  if [[ -n "${terminfo[kcbt]:-}" ]]; then
    bindkey -M emacs "${terminfo[kcbt]}" reverse-menu-complete
    bindkey -M viins "${terminfo[kcbt]}" reverse-menu-complete
    bindkey -M menuselect "${terminfo[kcbt]}" reverse-menu-complete
  fi

  bindkey -M menuselect '^[[C' .forward-char
  bindkey -M menuselect '^[OC' .forward-char
  bindkey -M menuselect '^[[D' .backward-char
  bindkey -M menuselect '^[OD' .backward-char
  bindkey -M menuselect '^M' .accept-line
}

# Register Atuin using the zsh-vi-mode-recommended hook when vi mode is active.
# Arguments:
#   None.
# Returns:
#   0 after registering the Atuin init command.
# Side effects:
#   Appends an Atuin initialization command to zvm_after_init_commands.
fortress-register-zvm-atuin-init() {
  zvm_after_init_commands+=(
    'eval "$(atuin init zsh)"'
  )
}

if (( SHELL_FORTRESS_ENABLE_ZSH_VI_MODE )); then
  ZVM_CONFIG_FUNC='fortress_zvm_config'

  # Configure zsh-vi-mode so fortress keeps its insert-first startup behavior.
  # Arguments:
  #   None.
  # Returns:
  #   0 after setting plugin options.
  # Side effects:
  #   Sets zsh-vi-mode initialization options before the plugin loads.
  fortress_zvm_config() {
    ZVM_READKEY_ENGINE=$ZVM_READKEY_ENGINE_ZLE
    ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT

    if (( SHELL_FORTRESS_ENABLE_ZSH_VI_AUTOCOMPLETE_COMPAT )); then
      ZVM_INIT_MODE=sourcing
      ZVM_LAZY_KEYBINDINGS=false
    fi
  }

  # Reapply widgets that should win after zsh-vi-mode installs lazy keybindings.
  # Arguments:
  #   None.
  # Returns:
  #   0 after restoring compatible widgets.
  # Side effects:
  #   Re-enables fzf-tab and fortress fzf widgets after zsh-vi-mode rebinding.
  zvm_after_lazy_keybindings() {
    if (( SHELL_FORTRESS_ENABLE_FZF_TAB )) && (( $+functions[enable-fzf-tab] )); then
      enable-fzf-tab
    fi

    if (( $+commands[fzf] )); then
      fortress-apply-fzf-widget-bindings
    fi
  }

  if (( SHELL_FORTRESS_ENABLE_ZSH_VI_AUTOCOMPLETE_COMPAT )) && fortress-bootstrap-zinit; then
    zinit ice lucid
    zinit light jeffreytse/zsh-vi-mode

    if (( SHELL_FORTRESS_ENABLE_ATUIN )) && (( $+commands[atuin] )); then
      eval "$(atuin init zsh)"
    fi
  fi
else
  bindkey -v
fi

bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^[[A' up-line-or-search
bindkey '^[[B' down-line-or-search
bindkey '^[OA' up-line-or-search
bindkey '^[OB' down-line-or-search
bindkey '^P' up-line-or-search
bindkey '^N' down-line-or-search
bindkey '^R' history-incremental-search-backward
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
if (( ! SHELL_FORTRESS_ENABLE_ZSH_AUTOCOMPLETE )); then
  bindkey -M emacs '^I' complete-word
  bindkey -M viins '^I' complete-word
fi

if (( ! SHELL_FORTRESS_ENABLE_ZSH_VI_MODE )); then
  zle -N zle-keymap-select
  zle -N zle-line-init
  zle -N zle-line-finish
fi

if (( $+commands[fzf] )); then
  zle -N fzf-file-widget
  zle -N fzf-cd-widget
  zle -N zle-history-fzf

  fortress-apply-fzf-widget-bindings
fi

if (( SHELL_FORTRESS_LOAD_ZSH_AUTOCOMPLETE )) && (( $+functions[zinit] )); then
  zinit ice lucid
  zinit light marlonrichert/zsh-autocomplete

  # Keep fortress cursor-navigation helpers without overriding Autocomplete's menu-entry widgets.
  bindkey '^A' beginning-of-line
  bindkey '^E' end-of-line
  bindkey '^[[H' beginning-of-line
  bindkey '^[[F' end-of-line

  if (( SHELL_FORTRESS_ENABLE_ZSH_VI_AUTOCOMPLETE_COMPAT )); then
    fortress-apply-autocomplete-compat-bindings
  fi

  autoload -Uz _csm
  compdef _csm csm
fi
