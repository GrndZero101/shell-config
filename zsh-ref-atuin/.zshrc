# Reference Atuin profile.
# Keeps the shell minimal so Atuin history behavior is easy to observe in isolation.

emulate -L zsh

source "${ZDOTDIR}/profile.zsh"

typeset -gr SHELL_PROFILE_STATE_DIR="${XDG_STATE_HOME:-${HOME}/.local/state}/shell-config/${SHELL_PROFILE_NAME}"
typeset -gr SHELL_PROFILE_CACHE_DIR="${XDG_CACHE_HOME:-${HOME}/.cache}/shell-config/${SHELL_PROFILE_NAME}"
typeset -gr SHELL_PROFILE_DATA_DIR="${XDG_DATA_HOME:-${HOME}/.local/share}/shell-config/${SHELL_PROFILE_NAME}"
typeset -gr SHELL_PROFILE_RUNTIME_BASE="${${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}%/}"
typeset -gr SHELL_PROFILE_RUNTIME_DIR="${SHELL_PROFILE_RUNTIME_BASE}/shell-config-${UID:-$(id -u)}/${SHELL_PROFILE_NAME}"
typeset -g SHELL_REF_ATUIN_FZFTAB_HOME="${SHELL_REF_ATUIN_FZFTAB_HOME:-${SHELL_PROFILE_DATA_DIR}/fzf-tab/fzf-tab}"

mkdir -p -- "${SHELL_PROFILE_STATE_DIR}" "${SHELL_PROFILE_CACHE_DIR}" "${SHELL_PROFILE_DATA_DIR}" "${SHELL_PROFILE_RUNTIME_DIR}"

export HISTFILE="${SHELL_PROFILE_STATE_DIR}/history"
export HISTSIZE=10000
export SAVEHIST=10000
typeset -gi SHELL_REF_ATUIN_DISABLE_CTRL_R="${SHELL_REF_ATUIN_DISABLE_CTRL_R:-0}"
typeset -gi SHELL_REF_ATUIN_DISABLE_UP_ARROW="${SHELL_REF_ATUIN_DISABLE_UP_ARROW:-0}"
typeset -gi SHELL_REF_ATUIN_ENABLE_ZOXIDE="${SHELL_REF_ATUIN_ENABLE_ZOXIDE:-0}"
typeset -gi SHELL_REF_ATUIN_ENABLE_FZF_TAB="${SHELL_REF_ATUIN_ENABLE_FZF_TAB:-0}"

typeset -gU fpath FPATH
fpath=(
  "${ZDOTDIR:h}/shared/completions"
  "${ZDOTDIR}/functions"
  ${fpath}
)

autoload -Uz compinit
zmodload zsh/complist

zstyle ':completion:*' menu select
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

compinit -d "${SHELL_PROFILE_CACHE_DIR}/.zcompdump"
autoload -Uz _csm
compdef _csm csm

if (( SHELL_REF_ATUIN_ENABLE_FZF_TAB )); then
  bindkey -M emacs '^I' complete-word
  bindkey -M viins '^I' complete-word

  if [[ -r "${SHELL_REF_ATUIN_FZFTAB_HOME}/fzf-tab.plugin.zsh" ]]; then
    source "${SHELL_REF_ATUIN_FZFTAB_HOME}/fzf-tab.plugin.zsh"

    zstyle ':fzf-tab:*' switch-group '<' '>'
    zstyle ':fzf-tab:*' fzf-command fzf
    zstyle ':fzf-tab:*' fzf-flags --height=60% --layout=reverse --border
  else
    print -u2 -- "zsh-ref-atuin: fzf-tab enabled but missing at ${SHELL_REF_ATUIN_FZFTAB_HOME}"
  fi
fi

if (( $+commands[atuin] )); then
  typeset -a atuin_init_args
  atuin_init_args=(init zsh)

  if (( SHELL_REF_ATUIN_DISABLE_CTRL_R )); then
    atuin_init_args+=(--disable-ctrl-r)
  fi

  if (( SHELL_REF_ATUIN_DISABLE_UP_ARROW )); then
    atuin_init_args+=(--disable-up-arrow)
  fi

  eval "$(atuin ${atuin_init_args[@]})"
else
  print -u2 -- "zsh-ref-atuin: install 'atuin' to enable reference history testing"
fi

if (( SHELL_REF_ATUIN_ENABLE_ZOXIDE )) && (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh --cmd cd)"
fi

PROMPT='%F{81}%n@%m%f:%F{120}%~%f %# '
RPROMPT=''
