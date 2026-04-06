# Citadel completion and completion cache settings.

zmodload zsh/complist

zstyle ':completion:*' menu no
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${SHELL_PROFILE_CACHE_DIR}/zcompcache"
zstyle ':completion:*' completer _complete _extensions _approximate
zstyle ':completion:*:approximate:*' max-errors 1 numeric
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' special-dirs true
zstyle ':completion:*:*:git:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:warnings' format '%F{203}no matches for:%f %d'

if (( SHELL_FORTRESS_ENABLE_ZSH_AUTOCOMPLETE )) && (( ! SHELL_FORTRESS_ENABLE_ZSH_VI_MODE || SHELL_FORTRESS_ENABLE_ZSH_VI_AUTOCOMPLETE_COMPAT )) && fortress-bootstrap-zinit; then
  if (( SHELL_FORTRESS_ENABLE_ZSH_VI_AUTOCOMPLETE_COMPAT )); then
    # Autocomplete detects vi mode from the active main keymap at load time.
    bindkey -v

    # Bias the experimental compat path toward menu-driven completion and history search.
    zstyle ':autocomplete:*' default-context history-incremental-search-backward
  fi

  SHELL_FORTRESS_LOAD_ZSH_AUTOCOMPLETE=1

  # Let zsh-autocomplete own compinit while still keeping the dump file profile-local.
  zstyle '*:compinit' arguments -d "${SHELL_PROFILE_CACHE_DIR}/.zcompdump"
else
  autoload -Uz compinit
  compinit -d "${SHELL_PROFILE_CACHE_DIR}/.zcompdump"
  autoload -Uz _csm
  compdef _csm csm
  if [[ -f "${SHELL_PROFILE_EXTERNAL_ZSH_COMPLETION_DIR}/_ft" ]] && [[ -z "${SHELL_PROFILE_FT_COMPLETION_LOADED:-}" ]]; then
    source "${SHELL_PROFILE_EXTERNAL_ZSH_COMPLETION_DIR}/_ft"
    typeset -g SHELL_PROFILE_FT_COMPLETION_LOADED=1
  fi
fi
