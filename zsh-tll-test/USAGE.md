# zsh-tll-test Usage

`zsh-tll-test` is an experimental sandbox profile for trying plugin and tool combinations in isolation from the supported profiles.

> [!WARNING]
> This profile is experimental and internal.
> Its contents change with whatever is being evaluated; use `zsh-clean` or `zsh-tll-citadel-dev-fortress` for daily work.

## Identity

- Profile directory: `zsh-tll-test`
- Intended user: a maintainer evaluating plugins or tool init orders
- Design goal: fast experimentation with minimal ceremony

## Editing Mode

- Default line editor mode: vi mode via `jeffreytse/zsh-vi-mode`
- How to enter command mode: press `Esc`
- How to return to insert mode: press `i`, `a`, or `A`

## Hotkeys

| Key | Behavior | Notes |
| --- | --- | --- |
| `Ctrl-R` | Atuin history search when `atuin` is installed | initialized after `zsh-vi-mode` via `zvm_after_init_commands` |
| `Tab` | `fzf-tab` completion menu | requires `fzf` |

## History

- History mode: profile
- History file location: `$HOME/.zhistory` (not XDG; see Caveats)
- Prefix search behavior: plugin defaults
- Incremental search behavior: Atuin when installed

## Prompt

- Prompt style: Starship when installed; otherwise the zsh default
- Right prompt: Starship's configuration
- Git or repo context: via Starship

## Plugins

Loaded through `zinit`, which is cloned automatically into `${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git` on first start.

| Source | Items |
| --- | --- |
| Oh My Zsh libraries | `git`, `directories`, `theme-and-appearance`, `async_prompt` |
| Oh My Zsh plugins | `git`, `brew`, `direnv`, `eza` (dirs first, git status, header, icons) |
| zsh plugins | `zsh-syntax-highlighting`, `zsh-autosuggestions`, `fzf-tab`, `zsh-vi-mode` |

## External Tools

| Tool | How it is used |
| --- | --- |
| `starship` | prompt, initialized only when installed |
| `zoxide` | directory jumping, initialized only when installed |
| `atuin` | history search, initialized after vi mode only when installed |
| `eza` | listing aliases from the Oh My Zsh `eza` plugin |

## Profile Switching

- Interactive switch command: `csm select`
- Clean switch command: `csm select --clean`
- Notes about environment isolation: use `csm` directly because this profile does not autoload `zsh-profile-select`

## Caveats

- first startup requires network access to clone `zinit` and fetch plugins
- history is written to `$HOME/.zhistory`, which is shared with any non-repo zsh setup using the same path
- `HOMEBREW_AUTO_UPDATE_SECS` is set to one day for the session
- contents change without notice as experiments come and go
