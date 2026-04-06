# Curated AWS local module.
# Adds fortress-owned AWS aliases plus profile inventory, identity, and login helpers.
# tags: cloud, aws, identity
# environments: workstation, local
# requires: aws

(( $+commands[aws] )) || return 0

autoload -Uz \
  aws-account-id \
  aws-identity \
  aws-login \
  aws-profile \
  aws-profiles \
  aws-region \
  aws-use-profile \
  aws-use-region \
  aws-whoami

alias awsa='aws-account-id'
alias awsc='aws configure list-profiles'
alias awsi='aws-identity'
alias awsl='aws-login'
alias awsp='aws-profile'
alias awsps='aws-profiles'
alias awsr='aws-region'
alias awsw='aws-whoami'
