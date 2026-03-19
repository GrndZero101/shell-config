# zsh-ref-atuin Design

`zsh-ref-atuin` exists to validate Atuin history integration with as little surrounding shell behavior as possible, while still allowing a few explicit comparison toggles for adjacent tools.

> [!NOTE]
> This file captures design intent.
> Operational truth lives in [`USAGE.md`](/home/timl/projects/tboss/shell-config/zsh-ref-atuin/USAGE.md).

## Identity

- Profile directory: `zsh-ref-atuin`
- Theme direction: minimal and secondary to behavior validation
- Experience goal: isolate Atuin history search behavior from unrelated shell features

## Visual Direction

- Preferred theme: none required
- Font assumptions: standard terminal support is sufficient
- Prompt style: deliberately simple
- Icon usage: avoid unless it directly helps reference testing

## Tooling Principles

- Follow Atuin's native shell integration as closely as practical.
- Keep keybinding setup minimal and easy to audit.
- Avoid plugin managers in this profile unless Atuin itself requires one later.
- Use Atuin as the primary history-search layer and avoid unrelated shell convenience features.
- Allow small opt-in comparison toggles for adjacent tools such as `fzf-tab` and `zoxide`, but keep them disabled by default so the reference behavior stays obvious.

## Cross-Platform Notes

- Linux notes: should work anywhere zsh and `atuin` are available.
- macOS notes: should work anywhere zsh and `atuin` are available.
- Shared expectations across hosts: behavior should be as close as possible because the profile is intentionally sparse.

## Carve Outs

- This profile is allowed to remain intentionally under-featured because its purpose is reference validation rather than daily use.
- This profile is allowed to expose small env toggles for Atuin's default key ownership because those toggles make comparison testing easier.
- This profile is allowed to expose opt-in env toggles for `fzf-tab` and `zoxide` as long as the default startup path remains minimal and Atuin-focused.

## Change Guidance

- Update this file when the reference profile's Atuin integration strategy changes.
