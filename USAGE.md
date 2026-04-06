# Usage Guide

Practical usage notes for the shell profiles in this repository, with emphasis on line editor modes and hotkeys across Linux and macOS terminals.

> [!NOTE]
> This guide describes the current `zsh-clean` and `zsh-tll-citadel-dev-fortress` behavior.
> `zsh-zero` is intentionally minimal and does not provide the same hotkey ergonomics.
> Cross-platform support status itself lives in
> [`docs/platform-support.md`](/home/timl/projects/tboss/shell-config/docs/platform-support.md).
> Planning and milestone tracking live in [`docs/ROADMAP.md`](/home/timl/projects/tboss/shell-config/docs/ROADMAP.md)
> and [`docs/milestones/README.md`](/home/timl/projects/tboss/shell-config/docs/milestones/README.md).
> This file is for operational shell behavior only.

## Line Editor Modes

These profiles use:

```zsh
bindkey -v
```

That means zsh uses vi-style editing.

### Insert Mode

This is the mode where you type normally.

Common ways to enter or stay in insert mode:

- start a new prompt
- press `i`
- press `a`
- press `A`
- press `o`

### Command Mode

Press `Esc` to enter command mode.

In command mode, keys are interpreted more like vi motions than literal text input.

Examples:

- `h` / `l` move left and right
- `0` moves to the beginning of the line
- `$` moves to the end of the line
- `w` / `b` move by word
- `x` deletes a character
- `dd` deletes the line

## Shared Hotkeys

These work in both `zsh-clean` and `zsh-tll-citadel-dev-fortress`.

| Key | Behavior |
| --- | --- |
| `Ctrl-A` | Move to beginning of line |
| `Ctrl-E` | Move to end of line |
| `Ctrl-P` | Previous history item, using prefix search |
| `Ctrl-N` | Next history item, using prefix search |
| `Ctrl-R` | Incremental backward history search |
| `Home` | Move to beginning of line |
| `End` | Move to end of line |

### Prefix History Search

If you type part of a command first and then press:

- `Ctrl-P`
- `Ctrl-N`
- Up arrow
- Down arrow

zsh can search history entries that begin with that prefix.

Example:

```shell
git
```

Then press Up to walk backward through commands that start with `git`.

## Fortress-Specific Notes

`zsh-tll-citadel-dev-fortress` binds more terminal arrow-key variants than `zsh-clean`, because terminals do not always send the same escape sequence.

Fortress currently binds:

- `^[[A` and `^[OA` for Up
- `^[[B` and `^[OB` for Down

Both are mapped to prefix history search in insert mode.

This makes behavior more consistent across:

- Linux terminals
- macOS Terminal
- iTerm2
- Windows Terminal
- WSL2
- many SSH and tmux situations

## Why the Same Key Can Behave Differently

Terminals do not send “Up Arrow” as an abstract event.
They send escape sequences.

Examples:

- `^[[A` means `ESC [ A`
- `^[OA` means `ESC O A`

Different terminals or terminal modes may send different sequences for the same physical key.

That is why some profiles bind both.

## Linux and macOS Differences

### Option / Alt Key

On Linux terminals, `Alt` often behaves as Meta by default.

On macOS:

- Terminal.app may require settings changes for Option/Meta behavior
- iTerm2 often needs “Left/Right Option key acts as Esc+” if you want Meta-style shortcuts

If Option is not configured as Meta, word-movement shortcuts may not behave the way shell users expect.

### Home / End Keys

Home and End are not always sent consistently across terminals.

Common sequences include:

- `^[[H`
- `^[[F`
- `^[OH`
- `^[OF`

This repository currently binds the common `^[[H` and `^[[F` variants directly.
Some terminals may still send a different sequence depending on emulator, SSH, tmux, or OS.

### VS Code Integrated Terminal

VS Code can behave differently from standalone terminals.

You may see different results between:

- VS Code integrated terminal
- Windows Terminal
- macOS Terminal
- iTerm2

If a key works in one terminal and not another, the shell config may still be correct.
The difference is often the escape sequence being emitted by the terminal.

## Host Recommendations

If you are validating `shell-config` on a new host for the first time:

- start with `zsh-clean`
- confirm bootstrap, profile selection, and basic line-editing behavior first
- only then move to `zsh-tll-citadel-dev-fortress`

This is especially relevant on:

- macOS
- fresh Linux hosts
- WSL2 installs with a new terminal stack

If you are unsure whether a failure is host-specific or profile-specific:

1. reset the current mutable shell state with `csm reset-profile`
2. switch back to `zsh-clean`
3. verify the simpler profile first
4. only then retry `zsh-tll-citadel-dev-fortress` and any opt-in modules

## Inspecting Current Bindings

Show the active bindings:

```shell
bindkey
```

Show insert-mode bindings only:

```shell
bindkey -M viins
```

Show command-mode bindings only:

```shell
bindkey -M vicmd
```

Search for a particular sequence or widget:

```shell
bindkey | rg 'up-line-or-search|down-line-or-search|history-incremental-search-backward'
```

## Operator Cleanup Commands

The repo now has three different cleanup layers:

| Command | Purpose |
| --- | --- |
| `csm clean` | Remove generated cache and runtime artifacts |
| `csm clear-history` | Truncate history for the current profile or all profiles |
| `csm reset-profile` | Reset mutable profile state for testing and clean-state recovery |

`csm reset-profile` is the strong operator path when you want to reproduce a
fresh mutable-state baseline without touching the tracked checkout.

Examples:

```shell
csm reset-profile
csm reset-profile zsh-tll-citadel-dev-fortress
csm reset-profile --all
csm reset-profile --include-local --force zsh-tll-citadel-dev-fortress
```

By default, `reset-profile` removes profile state, cache, runtime files, data,
and non-shared history.
Use `--include-local` only when you also want to remove user-owned
`shell-config.local/<profile>` overrides.

## Troubleshooting Key Sequences

If a hotkey is behaving strangely:

1. Compare behavior in two terminals.
2. Check the active binding tables with `bindkey -M viins` or `bindkey -M vicmd`.
3. Verify whether the problem occurs only in VS Code, only in tmux, only over SSH, or only on macOS.

If needed, you can inspect what the terminal is sending with:

```shell
cat
```

Then press the key and look at the raw output.
Use `Ctrl-C` to exit.

> [!TIP]
> If a key only fails in one terminal emulator, it is often better to add the missing escape-sequence binding than to redesign the shell behavior.

## History Navigation Primer

Fastest path for recent repeated commands:

1. Type a prefix such as `git`.
2. Press Up or `Ctrl-P`.

Fastest path for older fuzzy recall:

1. Press `Ctrl-R`.
2. Type part of the command.
3. Press `Ctrl-R` again to continue walking backward through matches.

Useful built-ins:

```shell
history
fc -l -50
!!
!git
```

## Profile Switching

If you are using:

- `zsh-clean`
- `zsh-tll-citadel-dev-fortress`

you can switch interactively with:

```shell
zsh-profile-select
```

or:

```shell
csm select
```

For a cleaner environment reset:

```shell
csm select --clean
```

## Current Caveats

- `vicmd` mode still uses normal history movement for `j` / `k`; prefix history search is primarily available in insert mode.
- terminal differences can still affect arrow keys even when the shell config is correct.
- `zsh-zero` intentionally does not carry the same ergonomic bindings as the richer profiles.
