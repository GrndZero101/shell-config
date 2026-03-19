# Citadel interactive profile.
# Native-first developer shell with stronger repo, completion, and history ergonomics.

emulate -L zsh

source "${ZDOTDIR}/profile.zsh"
source "${ZDOTDIR}/config/00-environment.zsh"
source "${ZDOTDIR}/config/10-options.zsh"
source "${ZDOTDIR}/config/20-history.zsh"
source "${ZDOTDIR}/config/30-completion.zsh"
source "${ZDOTDIR}/config/40-bindings.zsh"
source "${ZDOTDIR}/config/50-prompt.zsh"
source "${ZDOTDIR}/config/60-tools.zsh"
source "${ZDOTDIR}/config/70-plugins.zsh"
