# zsh-clean Usage

`zsh-clean` is the native-zsh reference profile in this repository.
It keeps the shell understandable and close to stock zsh while still adding practical history, completion, and navigation improvements.

> [!NOTE]
> This profile avoids external plugin dependencies.
> It is the best baseline if you want a solid shell without a lot of moving parts.

## Identity

- Profile directory: `zsh-clean`
- Intended user: someone who wants a capable shell with native zsh behavior and low operational drama
- Design goal: a clean, readable, no-plugin daily-driver profile

## Editing Mode

- Default line editor mode: vi mode via `bindkey -v`
- How to enter command mode: press `Esc`
- How to return to insert mode: press `i`, `a`, `A`, or start a new prompt

## Hotkeys

| Key | Behavior | Notes |
| --- | --- | --- |
| `Ctrl-A` | beginning of line | explicitly bound |
| `Ctrl-E` | end of line | explicitly bound |
| `Ctrl-P` | previous history entry by prefix | type a prefix first for best results |
| `Ctrl-N` | next history entry by prefix | type a prefix first for best results |
| `Ctrl-R` | incremental backward history search | native zsh search |
| `Home` | beginning of line | `^[[H` bound |
| `End` | end of line | `^[[F` bound |

## History

- History mode: profile
- History file location: `${XDG_STATE_HOME:-$HOME/.local/state}/shell-config/zsh-clean/history`
- Prefix search behavior: `Ctrl-P` and `Ctrl-N` use `up-line-or-search` and `down-line-or-search`
- Incremental search behavior: `Ctrl-R` uses `history-incremental-search-backward`

## Prompt

- Prompt style: `user@host:path %` with color
- Right prompt: none
- Git or repo context: none

## Helpers

| Function | Purpose |
| --- | --- |
| `mkcd` | create a directory and `cd` into it |
| `take` | same convenience behavior as `mkcd` |
| `zsh-profile-select` | open the interactive profile selector via `csm` |

## Command Completion

- `csm` has native zsh completion in this profile
- completed areas include subcommands plus flags and values such as `select --clean`, direct profile completion for `csm select`, `clear-history --all`, `sync-catppuccin`, and `describe-profile`

## Aliases

This profile keeps aliases intentionally light.

| Alias | Expands to | Notes |
| --- | --- | --- |
| none | n/a | no daily-use aliases defined here yet |

## External Tools

| Tool | How it is used |
| --- | --- |
| `brew` | `brew shellenv` is evaluated when Homebrew is discoverable on `PATH` |
| `rg` | useful for inspecting bindings and history, but not directly configured as an alias |

## Profile Switching

- Interactive switch command: `zsh-profile-select`
- Direct switch command: `csm select zsh-clean` or another profile name
- Clean switch command: `zsh-profile-select --clean` or `csm select --clean`
- Notes about environment isolation: normal mode preserves the convenient inherited environment; clean mode re-enters zsh through a curated minimal environment

## Terminal Notes

- `Ctrl-P` and `Ctrl-N` are the most portable prefix-history keys in this profile
- Home and End are explicitly bound for common terminal sequences
- Up and Down arrows are not remapped here as aggressively as fortress, so terminal defaults may vary more between emulators

## Caveats

- this profile does not include git prompt context
- arrow-key history behavior may differ more across terminals than in fortress
