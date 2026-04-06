# Curated web-search local module.
# Extend fortress-native web_search with a few developer-oriented engines and aliases.
# tags: search, browser, docs
# environments: workstation, local
# requires: browser

typeset -gaU ZSH_WEB_SEARCH_ENGINES
ZSH_WEB_SEARCH_ENGINES+=(
  gh 'https://github.com/search?q='
  mdn 'https://developer.mozilla.org/search?q='
  tfdocs 'https://developer.hashicorp.com/terraform/search?q='
)

autoload -Uz web-search-github web-search-mdn web-search-terraform-docs

alias ghs='web-search-github'
alias mdns='web-search-mdn'
alias tfds='web-search-terraform-docs'
