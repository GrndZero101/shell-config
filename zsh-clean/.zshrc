# Native interactive profile with no external plugin dependencies.

emulate -L zsh

source "${ZDOTDIR}/profile.zsh"

typeset -gr SHELL_PROFILE_STATE_DIR="${XDG_STATE_HOME:-${HOME}/.local/state}/shell-config/${SHELL_PROFILE_NAME}"
typeset -gr SHELL_PROFILE_CACHE_DIR="${XDG_CACHE_HOME:-${HOME}/.cache}/shell-config/${SHELL_PROFILE_NAME}"
typeset -gr SHELL_PROFILE_RUNTIME_BASE="${${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}%/}"
typeset -gr SHELL_PROFILE_RUNTIME_DIR="${SHELL_PROFILE_RUNTIME_BASE}/shell-config-${UID:-$(id -u)}/${SHELL_PROFILE_NAME}"
typeset -gr SHELL_SHARED_STATE_DIR="${XDG_STATE_HOME:-${HOME}/.local/state}/shell-config/shared"

mkdir -p -- "${SHELL_PROFILE_STATE_DIR}" "${SHELL_PROFILE_CACHE_DIR}" "${SHELL_PROFILE_RUNTIME_DIR}"

setopt AUTO_CD
setopt AUTO_PUSHD
setopt EXTENDED_GLOB
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FCNTL_LOCK
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt INTERACTIVE_COMMENTS
setopt NO_BEEP
setopt NO_FLOW_CONTROL
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt SHARE_HISTORY

unsetopt MAIL_WARNING

case "${SHELL_PROFILE_HISTORY_MODE:-profile}" in
  shared)
    mkdir -p -- "${SHELL_SHARED_STATE_DIR}"
    export HISTFILE="${SHELL_SHARED_STATE_DIR}/history"
    ;;
  *)
    export HISTFILE="${SHELL_PROFILE_STATE_DIR}/history"
    ;;
esac

export HISTSIZE=50000
export SAVEHIST=50000

autoload -Uz add-zsh-hook
autoload -Uz compinit
autoload -Uz promptinit

zmodload zsh/complist

typeset -gU path PATH cdpath CDPATH fpath FPATH

fpath=(
  "${ZDOTDIR:h}/shared/completions"
  "${ZDOTDIR}/functions"
  ${fpath}
)

typeset -a shell_brew_completion_candidates shell_brew_completion_dirs

if (( $+commands[brew] )); then
  shell_brew_completion_candidates=(
    "${commands[brew]:h:h}/share/zsh/site-functions"
    "${commands[brew]:h:h}/share/zsh-completions"
  )
else
  shell_brew_completion_candidates=(
    /opt/homebrew/share/zsh/site-functions
    /opt/homebrew/share/zsh-completions
    /usr/local/share/zsh/site-functions
    /usr/local/share/zsh-completions
    /home/linuxbrew/.linuxbrew/share/zsh/site-functions
    /home/linuxbrew/.linuxbrew/share/zsh-completions
  )
fi

for shell_brew_completion_dir in ${shell_brew_completion_candidates}; do
  [[ -d "${shell_brew_completion_dir}" ]] || continue
  shell_brew_completion_dirs+=("${shell_brew_completion_dir}")
done

fpath=(
  ${shell_brew_completion_dirs}
  ${fpath}
)

unset shell_brew_completion_candidates shell_brew_completion_dir shell_brew_completion_dirs

cdpath=(
  .
  "${HOME}"
  "${HOME}/projects"
)

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${SHELL_PROFILE_CACHE_DIR}/zcompcache"
zstyle ':completion:*' completer _extensions _complete _approximate
zstyle ':completion:*:approximate:*' max-errors 1 numeric
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' special-dirs true

autoload -Uz zsh-profile-select

compinit -d "${SHELL_PROFILE_CACHE_DIR}/.zcompdump"
autoload -Uz _csm
compdef _csm csm

bindkey -v
export KEYTIMEOUT=1

bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^P' up-line-or-search
bindkey '^N' down-line-or-search
bindkey '^R' history-incremental-search-backward
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line

HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1

promptinit
prompt off
PROMPT='%F{blue}%n@%m%f:%F{green}%~%f %# '
RPROMPT=''

if [[ -n "${SSH_CONNECTION:-}" ]]; then
  PROMPT='%F{yellow}%n@%m%f:%F{green}%~%f %# '
fi

mkcd() {
  mkdir -p -- "$1" && builtin cd -- "$1"
}

take() {
  mkdir -p -- "$1" && builtin cd -- "$1"
}

set-title-precmd() {
  print -Pn '\e]0;%n@%m: %~\a'
}

add-zsh-hook precmd set-title-precmd

if (( $+commands[brew] )); then
  eval "$(brew shellenv)"
fi
