# Curated television local module.
# Adds fortress-owned helpers around the television operator picker.
# tags: picker, ui, experimental
# environments: workstation, local
# requires: tv

autoload -Uz \
  tv-fortress-run \
  tv-env \
  tv-files \
  tv-git-branches-cleanup \
  tv-git-branches-manage \
  tv-git-repos \
  tv-text

alias tve='tv-env'
alias tvf='tv-files'
alias tvgbc='tv-git-branches-cleanup'
alias tvgbm='tv-git-branches-manage'
alias tvgr='tv-git-repos'
alias tvt='tv-text'

if [[ -o interactive ]] && [[ -z "${SHELL_FORTRESS_TELEVISION_INIT_LOADED:-}" ]]; then
  eval "$(tv init zsh)"
  typeset -g SHELL_FORTRESS_TELEVISION_INIT_LOADED=1
fi
