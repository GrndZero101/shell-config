# zsh-clean Design

`zsh-clean` is the native-first daily-driver baseline: practical history, completion, and navigation built only from zsh itself, with no plugin dependencies. It is also the selector's default fallback and the first profile to validate on a new host.

> [!NOTE]
> This file captures design intent.
> Operational truth lives in [`USAGE.md`](USAGE.md).

## Identity

- Profile directory: `zsh-clean`
- Theme direction: restrained; color only where it aids readability
- Experience goal: a capable shell with low operational drama that behaves the same wherever zsh runs

## Visual Direction

- Preferred theme: terminal defaults plus a lightly colored native prompt
- Font assumptions: no Nerd Font requirement
- Prompt style: native `user@host:path %` with color, no git context
- Icon usage: none

## Tooling Principles

- Preferred tools or integrations: native zsh modules such as `compinit`, `complist`, and `add-zsh-hook`
- Fallback rules when tools are unavailable: the profile never requires an external tool; optional completion paths such as Homebrew site-functions are added only when present
- Plugin philosophy: no plugins and no plugin managers

## Cross-Platform Notes

- Linux notes: strongest exercised environment, including WSL2
- macOS notes: expected to work with the system or Homebrew zsh; Homebrew completion paths are discovered for both `/opt/homebrew` and `/usr/local`
- Shared expectations across hosts: state, cache, and runtime files follow XDG paths under `shell-config/zsh-clean`

## Carve Outs

- None beyond the shared selector and the repo-wide `shared/` carve-outs.

## Change Guidance

- Add behavior here only when it is native zsh and broadly useful; tool-dependent ergonomics belong in `zsh-tll-citadel-dev-fortress`.
- Keep this profile safe as the default fallback: a change must not break startup on a host with only zsh installed.
- Update this file when the native-only rule, the default-fallback role, or the prompt strategy changes.
