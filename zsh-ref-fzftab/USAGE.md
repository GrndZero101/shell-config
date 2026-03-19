# zsh-ref-fzftab Usage

`zsh-ref-fzftab` is the smallest profile in this repository that exists specifically to validate the official `fzf-tab` integration path.

> [!NOTE]
> This profile is intentionally narrow.
> It should stay close to the upstream `fzf-tab` guidance and avoid unrelated shell ergonomics.

## Identity

- Profile directory: `zsh-ref-fzftab`
- Intended user: someone validating `fzf-tab` behavior in isolation
- Design goal: minimal official `fzf-tab` reference implementation

## Editing Mode

- Default line editor mode: default zsh editing mode
- How to enter command mode: not applicable unless you enable vi mode yourself
- How to return to insert mode: not applicable in the default setup

## Hotkeys

Document only profile-specific or profile-relevant bindings.

| Key | Behavior | Notes |
| --- | --- | --- |
| `Tab` | triggers `fzf-tab` completion when installed | bound through `complete-word` before loading the plugin |

## History

- History mode: profile
- History file location: `${XDG_STATE_HOME:-$HOME/.local/state}/shell-config/zsh-ref-fzftab/history`
- Prefix search behavior: default zsh behavior
- Incremental search behavior: default zsh behavior

## Prompt

- Prompt style: minimal colored `user@host:path`
- Right prompt: none
- Git or repo context: no

## Helpers

### Shell Management

| Function | Purpose |
| --- | --- |
| `csm install-fzf-tab` | install or update the official `fzf-tab` clone used by this profile |

## Aliases

### File and Search

| Alias | Expands to | Notes |
| --- | --- | --- |
| `None` | | this profile intentionally avoids alias ergonomics |

## External Tools

| Tool | How it is used |
| --- | --- |
| `fzf` | required by `fzf-tab` for the fuzzy completion UI |
| `fzf-tab` | sourced directly from an official clone installed with `csm install-fzf-tab` |

## Command Completion

- `csm` has native zsh completion in this profile
- completed areas include subcommands plus flags and values such as `select --clean`, direct profile completion for `csm select`, `clear-history --all`, `sync-catppuccin`, and `describe-profile`

## Profile Switching

- Interactive switch command: `csm select`
- Direct switch command: `csm select zsh-ref-fzftab` or another profile name
- Clean switch command: `csm select --clean`
- Notes about environment isolation: this profile is useful for isolated `fzf-tab` testing because it avoids most unrelated shell behavior

## Terminal Notes

- this profile keeps completion setup intentionally small to make `fzf-tab` behavior easier to observe
- if `fzf-tab` is missing, the profile prints a one-line install hint on startup

## Caveats

- this profile is intentionally sparse and is not meant to be a daily-driver shell
- `fzf-tab` behavior still depends on terminal input handling and the installed `fzf` binary
