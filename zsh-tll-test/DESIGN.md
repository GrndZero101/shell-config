# zsh-tll-test Design

`zsh-tll-test` is an experimental sandbox for trying plugin and tool combinations quickly before anything is promoted into a supported profile. It deliberately trades the repo's usual structure for speed of experimentation.

> [!WARNING]
> This profile is experimental and internal.
> It is not held to the same stability, XDG, or documentation bar as the supported profiles.

> [!NOTE]
> This file captures design intent.
> Operational truth lives in [`USAGE.md`](USAGE.md).

## Identity

- Profile directory: `zsh-tll-test`
- Theme direction: whatever the current experiment needs
- Experience goal: a throwaway place to evaluate plugins, Oh My Zsh snippets, and tool init orders

## Visual Direction

- Preferred theme: currently Starship's own configuration
- Font assumptions: Nerd Fonts, for `eza` icons
- Prompt style: Starship when installed
- Icon usage: allowed freely

## Tooling Principles

- Preferred tools or integrations: `zinit` with Oh My Zsh libraries and plugins, `starship`, `zoxide`, `atuin`, `fzf-tab`
- Fallback rules when tools are unavailable: tool init lines are guarded so a missing tool is skipped rather than erroring at startup
- Plugin philosophy: anything goes; this is where plugin ideas are tried

## Cross-Platform Notes

- Linux notes: exercised on Linux and WSL2 only
- macOS notes: not verified
- Shared expectations across hosts: first startup needs network access to clone `zinit`

## Carve Outs

- This profile may clone `zinit` automatically at startup; supported profiles require an explicit `csm install-zinit` instead.
- This profile may write history to `$HOME/.zhistory` rather than XDG state.
- This profile does not need to follow the fortress module, HUD, or helper conventions.

## Change Guidance

- When an experiment proves out, move it into a supported profile with that profile's docs and tests rather than growing this one.
- Update this file and [`USAGE.md`](USAGE.md) when the experiment stack changes materially.
