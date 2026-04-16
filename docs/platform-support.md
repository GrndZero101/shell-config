# Platform Support

This document captures the current host-platform support story for
`shell-config`.

It is intentionally practical:

- what has been actively developed or verified
- what is expected to work from code and path layout
- what still needs real-host validation

Use this file as the cross-platform truth source for `M6`.

## Current Matrix

| Host type | Current status                        | Notes                                                                                 |
| --------- | ------------------------------------- | ------------------------------------------------------------------------------------- |
| Linux     | Working foundation                    | Native XDG model, shell bootstrap, and test harness align well with Linux assumptions |
| WSL2      | Working foundation                    | This is the primary development environment so far                                    |
| macOS     | Expected but not yet validated enough | Homebrew path handling exists, but the repo still needs real-host verification        |

## What Has Actually Been Verified

### Linux / WSL2

Verified in real day-to-day use:

- `install.sh`
- `csm bootstrap`
- `csm select`
- active profile persistence under XDG state
- fortress operator surfaces such as `fortress-hud` and `fortress-debug-interactive`
- curated module lifecycle commands
- git operator workflows such as `gbm` and Television-backed branch flows

Verified in isolated clean-room paths:

- repo-native bats suite
- isolated XDG-home integration tests
- Ubuntu Docker smoke path for the shell-config harness

### macOS

The codebase already anticipates common macOS realities:

- `/opt/homebrew/bin` and `/opt/homebrew/sbin`
- `/usr/local/bin` and `/usr/local/sbin`
- Homebrew completion directories
- terminal differences called out in the shared usage guidance

But the following are still not treated as fully verified:

- bootstrap on a real macOS host
- profile switching on a real macOS host
- Homebrew discovery and completion loading on a real macOS host
- terminal-specific Meta / Option behavior in real macOS terminals

## Cross-Platform Rules

These are the intended portability rules going forward:

- keep the root selector XDG-aligned and host-lightweight
- keep mutable profile state out of the tracked checkout
- prefer explicit path discovery over undocumented host heuristics
- support both Linuxbrew and Homebrew layouts where relevant
- document host-specific caveats in profile `USAGE.md` or `DESIGN.md` files
- do not claim support beyond what has been tested or clearly scoped as expected behavior

## Known Platform-Sensitive Areas

The following areas deserve explicit attention whenever they change:

- terminal escape sequences for arrows, Home, End, and Meta/Alt behavior
- Homebrew and Linuxbrew path discovery
- completion directory discovery
- clipboard and URL-opening helpers
- optional tool integrations that depend on host-native binaries
- shell integration behavior in tmux, SSH, VS Code, and WSL2

## Code-Level Assumptions Already Present

These host assumptions already exist in the codebase today and should be
treated as part of the support contract:

### Homebrew and Linuxbrew Discovery

The repo already checks or prefers these common locations:

- `/home/linuxbrew/.linuxbrew/bin`
- `/home/linuxbrew/.linuxbrew/sbin`
- `/opt/homebrew/bin`
- `/opt/homebrew/sbin`
- `/usr/local/bin`
- `/usr/local/sbin`

That means:

- Linuxbrew and Homebrew are already first-class assumptions in startup and tool discovery
- macOS support is not blocked on path layout design so much as real-host verification

### Browser and URL Opening

The fortress opener currently tries, in order:

1. `open`
2. `wslview`
3. `xdg-open`

This is a sensible cross-platform baseline for:

- macOS
- WSL2 with `wslview`
- Linux desktops with `xdg-open`

But it also means browser-oriented helpers such as `web_search` are only as
portable as that opener stack on the current host.

### Optional Module Risk by Host

Lower-risk curated modules on a new host:

- `git`
- `aws`, once the AWS CLI is already present

Higher-risk curated modules on a new host:

- `television`, because it depends on the `tv` binary plus interactive terminal behavior
- `web_search`, because it depends on working browser opening
- `docker`, because it assumes a reachable Docker runtime
- `kubectl`, because it assumes a useful kubeconfig and cluster access
- `pass`, because it assumes a working GPG and password-store setup

### Profile Risk by Host

Current lowest-risk profile choices by host type:

- Linux: `zsh-clean`, then `zsh-tll-citadel-dev-fortress`
- WSL2: `zsh-clean`, then `zsh-tll-citadel-dev-fortress`
- macOS: `zsh-clean` should be the first validation target, then fortress once Homebrew and terminal behavior are confirmed

## Practical M6 Approach

`M6` should progress in this order:

1. audit and document platform assumptions from the current Linux/WSL2 base
2. tighten module docs so they state host expectations clearly
3. validate on additional real hosts, especially macOS
4. only then promote broader platform claims in the top-level docs

## Current Honest Summary

Today, `shell-config` is strongest on:

- Linux
- WSL2

It is plausibly portable to macOS and already contains useful path and terminal
awareness for it, but that support should still be treated as an active
verification target rather than a fully proven claim.
