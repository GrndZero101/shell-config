# Zinit installation
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# Load OMZ libs
zinit snippet OMZL::git.zsh
zinit snippet OMZL::directories.zsh
zinit snippet OMZL::theme-and-appearance.zsh
zinit snippet OMZL::async_prompt.zsh

# eza config - must be set BEFORE loading the plugin
zstyle ':omz:plugins:eza' 'dirs-first' yes
zstyle ':omz:plugins:eza' 'git-status' yes
zstyle ':omz:plugins:eza' 'header' yes
zstyle ':omz:plugins:eza' 'icons' yes

# Load OMZ plugins
zinit snippet OMZP::git
zinit snippet OMZP::brew
zinit snippet OMZP::direnv
zinit snippet OMZP::eza

# Zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Load completions efficiently (after prompt is ready)
autoload -Uz compinit
compinit

# Initialize tools
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

export HOMEBREW_AUTO_UPDATE_SECS="86400"

# history setup
HISTFILE=$HOME/.zhistory
SAVEHIST=10000
HISTSIZE=10000
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

# Atuin - synced shell history (load last)
# . "$HOME/.atuin/bin/env"
#

zinit light jeffreytse/zsh-vi-mode
zvm_after_init_commands+=(
  'eval "$(atuin init zsh)"'
)


# Deliberately minimal interactive shell.
# PROMPT='%n@%m:%~ %# '