# Citadel interactive profile.
# Native-first developer shell with stronger repo, completion, and history ergonomics.
# Each config stage is timed so fortress-hud can report startup cost; stages are
# sourced at top level rather than through a function so their typeset calls stay global.

emulate -L zsh

zmodload zsh/datetime

typeset -gF SHELL_FORTRESS_STARTUP_BEGIN="${EPOCHREALTIME}"
typeset -ga SHELL_FORTRESS_STARTUP_STAGES=(
  00-environment
  10-options
  20-history
  30-completion
  40-bindings
  50-prompt
  60-tools
  70-plugins
)
typeset -gA SHELL_FORTRESS_STARTUP_STAGE_MS
typeset -ga SHELL_FORTRESS_STARTUP_WARNINGS

source "${ZDOTDIR}/profile.zsh"

for fortress_startup_stage in "${SHELL_FORTRESS_STARTUP_STAGES[@]}"; do
  fortress_startup_stage_begin="${EPOCHREALTIME}"
  source "${ZDOTDIR}/config/${fortress_startup_stage}.zsh"
  printf -v fortress_startup_stage_ms '%.1f' "$(( (EPOCHREALTIME - fortress_startup_stage_begin) * 1000 ))"
  SHELL_FORTRESS_STARTUP_STAGE_MS[${fortress_startup_stage}]="${fortress_startup_stage_ms}"
done
unset fortress_startup_stage fortress_startup_stage_begin fortress_startup_stage_ms

typeset -g SHELL_FORTRESS_STARTUP_TOTAL_MS
printf -v SHELL_FORTRESS_STARTUP_TOTAL_MS '%.1f' "$(( (EPOCHREALTIME - SHELL_FORTRESS_STARTUP_BEGIN) * 1000 ))"
