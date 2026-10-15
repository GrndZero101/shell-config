# zsh-zero Design

`zsh-zero` is the control profile: it proves the `.zshenv` selector and `ZDOTDIR` model work while adding almost nothing on top of stock zsh.

> [!NOTE]
> This file captures design intent.
> Operational truth lives in [`USAGE.md`](USAGE.md).

## Identity

- Profile directory: `zsh-zero`
- Theme direction: none
- Experience goal: a shell that behaves like plain zsh, so selector or startup problems can be isolated from profile behavior

## Visual Direction

- Preferred theme: none
- Font assumptions: none; works in any terminal
- Prompt style: a single static `%n@%m:%~ %# ` prompt
- Icon usage: none

## Tooling Principles

- Preferred tools or integrations: none
- Fallback rules when tools are unavailable: not applicable; the profile depends on nothing beyond zsh
- Plugin philosophy: no plugins, no plugin managers, no helper functions

## Cross-Platform Notes

- Linux notes: identical to stock zsh on the host
- macOS notes: identical to stock zsh on the host
- Shared expectations across hosts: any behavior difference comes from the host's zsh build or terminal, not this profile

## Carve Outs

- This profile is allowed to skip the XDG history and helper conventions the other profiles follow, because adding them would weaken its value as a control.

## Change Guidance

- Resist additions. If a change makes `zsh-zero` more comfortable, it probably belongs in `zsh-clean`.
- Update this file if the profile's role as the control or recovery profile changes.
