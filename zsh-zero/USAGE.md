# zsh-zero Usage

`zsh-zero` is the bare-minimum profile in this repository.
It is for testing startup, validating selector behavior, or working from a nearly unmodified shell without ergonomic extras.

> [!NOTE]
> This profile is intentionally minimal.
> If you want stronger history, completion, or helper behavior, use `zsh-clean` or `zsh-tll-citadel-dev-fortress`.

## Identity

- Profile directory: `zsh-zero`
- Intended user: someone who wants the smallest possible profile in this repo
- Design goal: prove the profile-selection model with almost no shell behavior added

## Editing Mode

- Default line editor mode: terminal and zsh defaults
- How to enter command mode: not configured by this profile
- How to return to insert mode: not configured by this profile

## Hotkeys

This profile does not define line editor hotkeys beyond normal zsh defaults.

| Key | Behavior | Notes |
| --- | --- | --- |
| `Ctrl-A` | terminal/zsh default | not explicitly bound here |
| `Ctrl-E` | terminal/zsh default | not explicitly bound here |
| `Ctrl-R` | terminal/zsh default | not explicitly bound here |

## History

- History mode: profile
- History file location: zsh default unless you add your own config later
- Prefix search behavior: not configured by this profile
- Incremental search behavior: zsh default behavior only

## Prompt

- Prompt style: `%n@%m:%~ %# `
- Right prompt: none
- Git or repo context: none

## Helpers

This profile does not define helper functions.

| Function | Purpose |
| --- | --- |
| none | intentionally minimal |

## Aliases

This profile does not define aliases.

| Alias | Expands to | Notes |
| --- | --- | --- |
| none | n/a | intentionally minimal |

## External Tools

This profile does not integrate optional tools.

| Tool | How it is used |
| --- | --- |
| none | no tool-specific integrations are configured |

## Profile Switching

- Interactive switch command: `csm select`
- Clean switch command: `csm select --clean`
- Notes about environment isolation: use `csm` directly because this profile does not autoload `zsh-profile-select`

## Terminal Notes

Because this profile does not add compatibility bindings, terminal behavior depends mostly on the underlying zsh defaults and your terminal emulator.

## Caveats

- this profile is intentionally sparse
- it is best used as a control or recovery profile rather than a comfort profile
