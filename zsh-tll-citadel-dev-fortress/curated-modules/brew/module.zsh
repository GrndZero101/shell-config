# Curated Homebrew local module.
# Keeps a git-tracked Brewfile as the source of truth for installed Homebrew packages.
# tags: packages, homebrew, brewfile
# environments: workstation
# requires: brew

(( $+commands[brew] )) || return 0

# Quality-of-life defaults; any value already set by the user wins.
export HOMEBREW_NO_ANALYTICS="${HOMEBREW_NO_ANALYTICS:-1}"
export HOMEBREW_NO_ENV_HINTS="${HOMEBREW_NO_ENV_HINTS:-1}"
export HOMEBREW_AUTO_UPDATE_SECS="${HOMEBREW_AUTO_UPDATE_SECS:-86400}"

autoload -Uz \
  _brew-add \
  _brew-dump \
  _brew-rm \
  brew-add \
  brew-add-tap \
  brew-drift \
  brew-drop-description \
  brew-dump \
  brew-edit \
  brew-file \
  brew-rm \
  brew-sync \
  brew-undeclared

alias bra='brew-add'
alias brd='brew-drift'
alias bre='brew-edit'
alias brf='brew-file'
alias brr='brew-rm'
alias brs='brew-sync'

# Modules load after compinit, so register completions directly.
if (( $+functions[compdef] )); then
  compdef _brew-add brew-add bra
  compdef _brew-rm brew-rm brr
  compdef _brew-dump brew-dump
fi
