# Curated pass local module.
# Adds a small fortress-owned password-store helper layer.
# tags: secrets, password-store, security
# environments: workstation, local
# requires: pass

(( $+commands[pass] )) || return 0

autoload -Uz pass-copy-first-line pass-open-entry

alias p='pass'
alias pc='pass-copy-first-line'
alias po='pass-open-entry'
