# Citadel tool integrations and aliases.

autoload -Uz \
  alias-find \
  alias-list \
  croot \
  ff \
  fcd \
  fh \
  mkcd \
  omz_urlencode \
  open_command \
  rcd \
  repo-find \
  take \
  up \
  vf \
  web_search

if (( SHELL_FORTRESS_ENABLE_NATIVE_GIT )); then
  autoload -Uz \
    fortress-apply-git-aliases \
    gbdf \
    gcd \
    gcof \
    git-current-branch \
    git-root \
    glg \
    gst \
    gstashf \
    gshowf \
    gwt \
    gwtcd
fi

export LESS_TERMCAP_mb=$'\E[1;38;5;221m'
export LESS_TERMCAP_md=$'\E[1;38;5;81m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_so=$'\E[48;5;236;38;5;223m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_us=$'\E[4;38;5;114m'
export LESS_TERMCAP_ue=$'\E[0m'

typeset -ga ZSH_WEB_SEARCH_ENGINES
ZSH_WEB_SEARCH_ENGINES+=(
  google 'https://www.google.com/search?q='
  duckduckgo 'https://duckduckgo.com/?q='
)

if (( $+commands[eza] )); then
  export EZA_CONFIG_DIR="${ZDOTDIR}/config/eza"
  alias ls='eza --group-directories-first --icons=auto'
  alias ll='eza -lag --group-directories-first --icons=auto --header --git'
  alias tree='eza --tree --icons=auto'
  fortress-register-alias-source core ls ll tree

  compdef _gnu_generic eza
  compdef ls=eza ll=eza tree=eza
else
  alias ll='ls -lah'
  fortress-register-alias-source core ll
fi

if (( $+commands[bat] )); then
  alias cat='bat --paging=never'
  fortress-register-alias-source core cat

  compdef _gnu_generic bat
  compdef cat=bat
fi

if (( $+commands[rg] )); then
  alias grep='rg'
  fortress-register-alias-source core grep

  compdef _gnu_generic rg
  compdef grep=rg
fi

if (( $+commands[fd] )); then
  alias find='fd'
  fortress-register-alias-source core find

  compdef _gnu_generic fd
  compdef find=fd
fi

if (( $+commands[jq] )); then
  alias jqp='jq .'
  fortress-register-alias-source core jqp

  compdef jqp=jq
fi

if (( SHELL_FORTRESS_ENABLE_NATIVE_GIT )); then
  fortress-apply-git-aliases
fi

if (( $+commands[git] )); then
  alias ga='git add'
  alias gc='git commit'
  alias gd='git diff'
  alias gs='git status'
  alias gsw='git switch'
  fortress-register-alias-source core ga gc gd gs gsw

  compdef ga=git gc=git gd=git gs=git gsw=git
fi

if (( $+commands[zoxide] )); then
  # Let zoxide back the cd command directly so normal navigation habits keep working.
  eval "$(zoxide init zsh --cmd cd)"
fi

if (( $+commands[direnv] )); then
  eval "$(direnv hook zsh)"
fi

fortress-source-local-modules
fortress-source-user-aliases
