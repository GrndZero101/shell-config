# zsh-ref-fzftab Design

`zsh-ref-fzftab` exists to validate the official `fzf-tab` integration path with as little surrounding shell behavior as possible.

> [!NOTE]
> This file captures design intent.
> Operational truth lives in [`USAGE.md`](/home/timl/projects/tboss/shell-config/zsh-ref-fzftab/USAGE.md).

## Identity

- Profile directory: `zsh-ref-fzftab`
- Theme direction: minimal and secondary to behavior validation
- Experience goal: isolate `fzf-tab` behavior from unrelated shell features

## Visual Direction

- Preferred theme: none required
- Font assumptions: standard terminal support is sufficient
- Prompt style: deliberately simple
- Icon usage: avoid unless it directly helps reference testing

## Tooling Principles

- Follow the official `fzf-tab` setup guidance as closely as practical.
- Keep completion configuration minimal and easy to audit.
- Avoid plugin managers in this profile unless upstream guidance requires one.
- Use the official upstream repository clone as the plugin source.

## Cross-Platform Notes

- Linux notes: should work anywhere zsh and `fzf` are available.
- macOS notes: should work anywhere zsh and `fzf` are available.
- Shared expectations across hosts: behavior should be as close as possible because the profile is intentionally sparse.

## Carve Outs

- This profile is allowed to remain intentionally under-featured because its purpose is reference validation rather than daily use.

## Change Guidance

- Update this file when the reference profile’s official-integration strategy changes.
