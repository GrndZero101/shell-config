#!/usr/bin/env zsh
# Run a command with a pseudo-terminal as its stdout and print what it wrote.
#
# Lets tests exercise code paths gated on `[[ -t 1 ]]`, such as terminal
# rendering in `csm docs`. Carriage returns added by the terminal are removed.
# Set PTY_INPUT to type keys into the terminal, for example `q` to quit a pager.
#
# Usage: run-in-pty.zsh <command> [args...]
# Exit status: 0 when the command finished, 1 when it ran longer than 15s.

emulate -LR zsh
zmodload zsh/zpty zsh/zselect

# Run the command in a pty, collect its output, and print it.
# Arguments:
#   $@ - Command and arguments.
# Returns:
#   0 after printing the output, 1 on timeout.
run_in_pty() {
  local output='' chunk
  typeset -F SECONDS=0

  zpty -b pty "${(j: :)${(q)@}}"
  [[ -n "${PTY_INPUT:-}" ]] && zpty -w -n pty "${PTY_INPUT}"

  while (( SECONDS < 15 )); do
    if zpty -r -t pty chunk; then
      output+="${chunk}"
    elif ! zpty -t pty; then
      # The command exited; drain anything still buffered.
      while zpty -r -t pty chunk; do output+="${chunk}"; done
      break
    else
      zselect -t 5
    fi
  done

  if zpty -t pty 2>/dev/null; then
    zpty -d pty
    print -u2 -- 'run-in-pty: timed out waiting for the command'
    return 1
  fi
  zpty -d pty 2>/dev/null

  print -rn -- "${output//$'\r'/}"
}

run_in_pty "$@"
