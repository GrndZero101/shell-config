# Curated Docker local module.
# Adds fortress-owned Docker aliases plus context switching and compact container inventory helpers.
# tags: containers, docker, runtime
# environments: workstation, container
# requires: docker

(( $+commands[docker] )) || return 0

autoload -Uz \
  docker-context-name \
  docker-contexts \
  docker-ps-all \
  docker-ps-running \
  docker-use-context

alias d='docker'
alias dc='docker compose'
alias dctx='docker-context-name'
alias dctxs='docker-contexts'
alias dps='docker-ps-running'
alias dpsa='docker-ps-all'
alias ductx='docker-use-context'

compdef d=docker dc=docker dctx=docker dctxs=docker dps=docker dpsa=docker ductx=docker
