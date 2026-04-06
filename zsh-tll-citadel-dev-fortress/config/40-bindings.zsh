# Citadel line editor bindings and zle widgets.

autoload -Uz \
  fortress-debug-interactive-widget \
  fortress-hud \
  fortress-hud-widget \
  fortress-debug-interactive \
  fortress-alias-find-widget \
  fortress-alias-list-widget \
  fortress-csm-help-widget \
  fortress-csm-select-widget \
  fortress-csm-widget \
  fortress-keybinds \
  fortress-keybinds-widget \
  fortress-operator-binding-specs \
  fortress-zle-insert-command \
  fortress-zle-run-command \
  fzf-cd-widget \
  fzf-find-dir \
  fzf-find-file \
  fzf-file-widget \
  sudo-command-line \
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

# Apply the fortress operator prefix bindings in the requested keymaps.
# Arguments:
#   None.
# Returns:
#   0 after binding the operator widgets.
# Side effects:
#   Updates multi-key operator shortcuts under the Ctrl-G prefix.
fortress-apply-operator-bindings() {
  local keymap binding_row key_sequence display_text widget_name action_text note_text
  local -a binding_rows

  binding_rows=(${(f)"$(fortress-operator-binding-specs)"})
  for keymap in emacs viins vicmd; do
    for binding_row in "${binding_rows[@]}"; do
      IFS=$'\t' read -r key_sequence display_text widget_name action_text note_text <<< "${binding_row}"
      bindkey -M "${keymap}" "${key_sequence}" "${widget_name}"
    done
  done
}

# Register the fortress operator widgets declared in the binding registry.
# Arguments:
#   None.
# Returns:
#   0 after registering the required widgets with zle.
# Side effects:
#   Calls zle -N for each unique operator widget in the registry.
fortress-register-operator-widgets() {
  local binding_row key_sequence display_text widget_name action_text note_text
  local -a binding_rows widget_names

  binding_rows=(${(f)"$(fortress-operator-binding-specs)"})
  for binding_row in "${binding_rows[@]}"; do
    IFS=$'\t' read -r key_sequence display_text widget_name action_text note_text <<< "${binding_row}"
    widget_names+=("${widget_name}")
  done

  widget_names=(${(u)widget_names})
  for widget_name in "${widget_names[@]}"; do
    zle -N "${widget_name}"
  done
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

zle -N sudo-command-line
fortress-register-operator-widgets

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
bindkey -M emacs '^[^[' sudo-command-line
bindkey -M viins '^[^[' sudo-command-line
fortress-apply-operator-bindings
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
  if [[ -f "${SHELL_PROFILE_EXTERNAL_ZSH_COMPLETION_DIR}/_ft" ]] && [[ -z "${SHELL_PROFILE_FT_COMPLETION_LOADED:-}" ]]; then
    source "${SHELL_PROFILE_EXTERNAL_ZSH_COMPLETION_DIR}/_ft"
    typeset -g SHELL_PROFILE_FT_COMPLETION_LOADED=1
  fi
fi
