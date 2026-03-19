# Reference fzf-tab profile.
# Keeps the shell minimal and follows the official fzf-tab setup guidance closely.

emulate -L zsh

source "${ZDOTDIR}/profile.zsh"

typeset -gr SHELL_PROFILE_STATE_DIR="${XDG_STATE_HOME:-${HOME}/.local/state}/shell-config/${SHELL_PROFILE_NAME}"
typeset -gr SHELL_PROFILE_CACHE_DIR="${XDG_CACHE_HOME:-${HOME}/.cache}/shell-config/${SHELL_PROFILE_NAME}"
typeset -gr SHELL_PROFILE_DATA_DIR="${XDG_DATA_HOME:-${HOME}/.local/share}/shell-config/${SHELL_PROFILE_NAME}"
typeset -gr SHELL_PROFILE_RUNTIME_BASE="${${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}%/}"
typeset -gr SHELL_PROFILE_RUNTIME_DIR="${SHELL_PROFILE_RUNTIME_BASE}/shell-config-${UID:-$(id -u)}/${SHELL_PROFILE_NAME}"
typeset -gr SHELL_PROFILE_FZFTAB_HOME="${SHELL_PROFILE_DATA_DIR}/fzf-tab/fzf-tab"

mkdir -p -- "${SHELL_PROFILE_STATE_DIR}" "${SHELL_PROFILE_CACHE_DIR}" "${SHELL_PROFILE_DATA_DIR}" "${SHELL_PROFILE_RUNTIME_DIR}"

export HISTFILE="${SHELL_PROFILE_STATE_DIR}/history"
export HISTSIZE=10000
export SAVEHIST=10000

typeset -gU fpath FPATH
fpath=(
  "${ZDOTDIR:h}/shared/completions"
  "${ZDOTDIR}/functions"
  ${fpath}
)

autoload -Uz compinit
zmodload zsh/complist

zstyle ':completion:*' menu no
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

compinit -d "${SHELL_PROFILE_CACHE_DIR}/.zcompdump"
autoload -Uz _csm
compdef _csm csm

bindkey -M emacs '^I' complete-word
bindkey -M viins '^I' complete-word

if [[ -r "${SHELL_PROFILE_FZFTAB_HOME}/fzf-tab.plugin.zsh" ]]; then
  source "${SHELL_PROFILE_FZFTAB_HOME}/fzf-tab.plugin.zsh"

  zstyle ':fzf-tab:*' switch-group '<' '>'
  zstyle ':fzf-tab:*' fzf-command fzf
  zstyle ':fzf-tab:*' fzf-flags --height=60% --layout=reverse --border
else
  print -u2 -- "zsh-ref-fzftab: install the plugin with 'csm install-fzf-tab'"
fi

PROMPT='%F{81}%n@%m%f:%F{120}%~%f %# '
RPROMPT=''
