# Curated kubectl local module.
# Adds fortress-owned kubectl aliases plus context switching and namespace inventory helpers.
# tags: kubernetes, k8s, cloud
# environments: workstation, container
# requires: kubectl

(( $+commands[kubectl] )) || return 0

autoload -Uz \
  kubectl-contexts \
  kubectl-current-context \
  kubectl-current-namespace \
  kubectl-namespaces \
  kubectl-use-context \
  kubectl-use-namespace

alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kctx='kubectl-current-context'
alias kctxs='kubectl-contexts'
alias kns='kubectl-current-namespace'
alias knss='kubectl-namespaces'
alias kuse-ctx='kubectl-use-context'
alias kuse-ns='kubectl-use-namespace'

compdef k=kubectl kgp=kubectl kgs=kubectl kctx=kubectl kctxs=kubectl kns=kubectl knss=kubectl kuse-ctx=kubectl kuse-ns=kubectl
