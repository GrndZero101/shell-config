# Citadel tool integrations and aliases.

autoload -Uz \
  croot \
  ff \
  fcd \
  fh \
  mkcd \
  rcd \
  repo-find \
  take \
  up \
  vf

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

if (( $+commands[eza] )); then
  export EZA_CONFIG_DIR="${ZDOTDIR}/config/eza"
  alias ls='eza --group-directories-first --icons=auto'
  alias ll='eza -lag --group-directories-first --icons=auto --header --git'
  alias tree='eza --tree --icons=auto'

  compdef _gnu_generic eza
  compdef ls=eza ll=eza tree=eza
else
  alias ll='ls -lah'
fi

if (( $+commands[bat] )); then
  alias cat='bat --paging=never'

  compdef _gnu_generic bat
  compdef cat=bat
fi

if (( $+commands[rg] )); then
  alias grep='rg'

  compdef _gnu_generic rg
  compdef grep=rg
fi

if (( $+commands[fd] )); then
  alias find='fd'

  compdef _gnu_generic fd
  compdef find=fd
fi

if (( $+commands[jq] )); then
  alias jqp='jq .'

  compdef jqp=jq
fi

if (( SHELL_FORTRESS_ENABLE_NATIVE_GIT )); then
  fortress-apply-git-aliases
fi

if (( $+commands[zoxide] )); then
  # Let zoxide back the cd command directly so normal navigation habits keep working.
  eval "$(zoxide init zsh --cmd cd)"
fi

if (( $+commands[direnv] )); then
  eval "$(direnv hook zsh)"
fi
