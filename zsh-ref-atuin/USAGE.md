# zsh-ref-atuin Usage

`zsh-ref-atuin` is the smallest profile in this repository that exists specifically to validate Atuin history integration in isolation, while still allowing a few adjacent tools to be enabled explicitly for comparison testing.

> [!NOTE]
> This profile is intentionally narrow.
> It should stay close to Atuin's native shell integration and avoid unrelated shell ergonomics.

## Identity

- Profile directory: `zsh-ref-atuin`
- Intended user: someone validating Atuin keybinding and history-search behavior in isolation
- Design goal: minimal Atuin reference implementation for human-level shell testing

## Editing Mode

- Default line editor mode: default zsh editing mode
- How to enter command mode: not applicable unless you enable vi mode yourself
- How to return to insert mode: not applicable in the default setup

## Hotkeys

Document only profile-specific or profile-relevant bindings.

| Key | Behavior | Notes |
| --- | --- | --- |
| `Ctrl-R` | opens Atuin history search by default | disable with `SHELL_REF_ATUIN_DISABLE_CTRL_R=1` |
| Up arrow | opens Atuin up-arrow search by default | disable with `SHELL_REF_ATUIN_DISABLE_UP_ARROW=1` |
| `Tab` | triggers `fzf-tab` completion when enabled | requires `SHELL_REF_ATUIN_ENABLE_FZF_TAB=1` and a readable plugin path |

## History

- History mode: profile
- History file location: `${XDG_STATE_HOME:-$HOME/.local/state}/shell-config/zsh-ref-atuin/history`
- Prefix search behavior: owned by Atuin when its up-arrow binding is enabled, otherwise default zsh behavior
- Incremental search behavior: owned by Atuin when its `Ctrl-R` binding is enabled, otherwise default zsh behavior

## Prompt

- Prompt style: minimal colored `user@host:path`
- Right prompt: none
- Git or repo context: no

## Helpers

### Shell Management

| Function | Purpose |
| --- | --- |
| `csm select` | switch to or from the reference profile during comparison testing |

## Aliases

### File and Search

| Alias | Expands to | Notes |
| --- | --- | --- |
| `None` | | this profile intentionally avoids alias ergonomics |

## External Tools

| Tool | How it is used |
| --- | --- |
| `atuin` | provides history capture plus `Ctrl-R` and Up-arrow search widgets when installed |
| `fzf-tab` | optionally replaces zsh's completion selection UI when `SHELL_REF_ATUIN_ENABLE_FZF_TAB=1` |
| `zoxide` | optionally replaces `cd` with smarter directory jumping when `SHELL_REF_ATUIN_ENABLE_ZOXIDE=1` |

## Command Completion

- `csm` has native zsh completion in this profile
- completed areas include subcommands plus flags and values such as `select --clean`, direct profile completion for `csm select`, `clear-history --all`, `sync-catppuccin`, and `describe-profile`

## Profile Switching

- Interactive switch command: `csm select`
- Direct switch command: `csm select zsh-ref-atuin` or another profile name
- Clean switch command: `csm select --clean`
- Notes about environment isolation: this profile is useful for isolated Atuin testing because it keeps the shell small and avoids unrelated plugin layers

## Environment Toggles

- `SHELL_REF_ATUIN_DISABLE_CTRL_R=1` keeps Atuin loaded but leaves `Ctrl-R` unbound so you can test custom bindings
- `SHELL_REF_ATUIN_DISABLE_UP_ARROW=1` keeps Atuin loaded but leaves the Up arrow unbound so native shell history behavior is easier to compare
- `SHELL_REF_ATUIN_ENABLE_FZF_TAB=1` enables `fzf-tab` from `SHELL_REF_ATUIN_FZFTAB_HOME`
- `SHELL_REF_ATUIN_FZFTAB_HOME=/path/to/fzf-tab` overrides the profile-local `fzf-tab` clone path, which defaults to `${XDG_DATA_HOME:-$HOME/.local/share}/shell-config/zsh-ref-atuin/fzf-tab/fzf-tab`
- `SHELL_REF_ATUIN_ENABLE_ZOXIDE=1` enables `zoxide` and lets it back the `cd` command

## Terminal Notes

- this profile keeps keybinding setup intentionally small to make Atuin behavior easier to observe
- enabling `fzf-tab` changes `Tab` behavior and is best treated as a comparison mode rather than part of the default reference setup
- Atuin behavior may still vary across terminal emulators, tmux, SSH sessions, and IDE terminals
- if Atuin is missing, the profile prints a one-line install hint on startup

## Caveats

- this profile is intentionally sparse and is not meant to be a daily-driver shell
- Atuin keybinding behavior depends on the installed `atuin` binary version and terminal input handling
- `fzf-tab` and Atuin affect adjacent interactive behavior, so mixed-mode testing is useful but should be treated as experimental rather than canonical
