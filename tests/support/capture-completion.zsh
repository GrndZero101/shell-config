#!/usr/bin/env zsh
# Capture the candidates zsh's completion system offers for a command line.
#
# Drives a real `zsh -f -i` in a pseudo-terminal, runs compinit, sources a
# caller-supplied setup file (fpath, autoloads, compdef), types the buffer,
# presses Tab, and prints every candidate passed to compadd, sorted, one per
# line. A control-byte marker separates real output from terminal echo.
#
# Usage: capture-completion.zsh <setup-file> <buffer>
# Exit status: 0 on success, 1 when the shell does not answer within 15s.

emulate -LR zsh
zmodload zsh/zpty zsh/zselect

# Run one completion round trip and print the captured candidates.
# Arguments:
#   $1 - Setup file sourced after compinit.
#   $2 - Command-line buffer to complete.
# Returns:
#   0 after printing candidates, 1 on timeout.
capture_completion() {
  local setup_file="$1" buffer="$2"
  local output='' chunk line
  local -a candidates
  typeset -F SECONDS=0

  zpty capture zsh -f -i
  zpty -w capture 'stty -echo'
  zpty -w capture 'autoload -Uz compinit && compinit -u -D'
  zpty -w capture "source ${(q)setup_file}"
  zpty -w capture 'zstyle ":completion:*" list-grouped false; zstyle ":completion:*" insert-tab false'
  # Record final candidates; internal compadd calls (-O/-A/-D) pass through.
  zpty -w capture 'compadd() { if [[ ${@[1,(i)(-|--)]} == *-(O|A|D)\ * ]]; then builtin compadd "$@"; return; fi; local -a __hits; builtin compadd -A __hits "$@"; (( $#__hits )) && builtin print -rl -- $'\''\x01'\''${^__hits}; }'
  zpty -w capture 'capture-done() { builtin print -r -- $'\''\x02'\'' }; zle -N capture-done; bindkey "^X" capture-done'
  zpty -w capture "PROMPT=; ${buffer}"$'\t\C-x'

  while (( SECONDS < 15 )); do
    if zpty -r -t capture chunk; then
      output+="${chunk}"
      [[ "${output}" == *$'\x02'* ]] && break
    else
      zselect -t 5
    fi
  done
  zpty -d capture

  [[ "${output}" == *$'\x02'* ]] || {
    print -u2 -- 'capture-completion: timed out waiting for the shell'
    return 1
  }

  for line in "${(@f)output}"; do
    [[ "${line}" == *$'\x01'* ]] && candidates+=("${${line##*$'\x01'}%%$'\r'}")
  done
  (( ${#candidates} )) && print -rl -- "${(@ou)candidates}"
  return 0
}

capture_completion "$@"
