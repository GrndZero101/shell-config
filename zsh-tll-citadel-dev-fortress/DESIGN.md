# zsh-tll-citadel-dev-fortress Design

`zsh-tll-citadel-dev-fortress` is the developer-heavy profile in this repository.
It should feel capable, polished, and information-rich without becoming an opaque shell stack.

> [!NOTE]
> This file captures profile design intent and aesthetic rules.
> Operational truth for actual behavior lives in [`USAGE.md`](/home/timl/projects/tboss/shell-config/zsh-tll-citadel-dev-fortress/USAGE.md).

## Identity

- Profile directory: `zsh-tll-citadel-dev-fortress`
- Theme direction: Catppuccin Mocha wherever the underlying tool supports it cleanly
- Experience goal: a high-signal developer shell that feels cohesive, deliberate, and fast

## Visual Direction

- Preferred theme: Catppuccin Mocha
- Font assumptions: Nerd Fonts are available
- Prompt style: configurable between `oh-my-posh`, `starship`, and native fallback, with `auto` preferring `oh-my-posh` first; the fortress `oh-my-posh` theme should use `powerlevel10k_modern` as the structural base and Catppuccin Mocha as the palette
- Icon usage: icons are allowed when the terminal and font support them, but should not reduce clarity
- Status surfaces such as `fortress-hud --pretty` may use Catppuccin-tinted headings and Nerd Font icons, but should keep the standard renderer as the operational source of truth

## Tooling Principles

- Prefer tools that materially improve developer throughput and shell ergonomics.
- When a tool supports Catppuccin Mocha cleanly and without fragile setup, prefer enabling that theme.
- Prefer official Catppuccin ports and guidance from the Catppuccin organization first:
  - use the Catppuccin ports index as the discovery source
  - use the tool-specific Catppuccin repository when one exists
  - keep the implementation as native to the tool as possible
- Keep native zsh behavior understandable even when richer tools are layered in.
- Favor graceful degradation when optional tools are missing.
- Keep plugin adoption selective and value-driven.
- Prefer a persistent, user-owned fortress settings file for default startup behavior instead of requiring login-time environment injection.
- Treat prompt engine choice as a deliberate profile setting: `auto`, `oh-my-posh`, `starship`, and `native` should remain understandable and debuggable as explicit operating modes.
- Use `zinit` as the fortress plugin manager, but keep installation explicit and profile-local.
- Treat completion frontends as deliberate choices: native zsh, `fzf-tab`, and `zsh-autocomplete` should be understandable as separate operating modes rather than a pile-on stack.
- Treat vi-mode as swappable: `zsh-vi-mode` is the current fortress default, while the native `bindkey -v` path remains available as a lower-complexity fallback.
- Prefer low-drama comfort plugins first, such as autosuggestions and syntax highlighting, before adding larger OMZ plugin bundles.
- When `zsh-vi-mode` is enabled, let it own vi-mode widgets and cursor behavior instead of layering fortress's native vi-mode hooks on top.
- When `zsh-vi-mode` is enabled, skip `zsh-autocomplete` by default but allow an explicit experimental compatibility mode when both toggles are enabled.
- Treat `zsh-vi-mode` plus `zsh-autocomplete` as an experimental pairing that requires eager vi-mode initialization and careful plugin ordering.
- When Atuin is enabled with `zsh-vi-mode`, follow Atuin's documented `zvm_after_init_commands` integration pattern instead of initializing it blindly ahead of vi-mode setup.
- For Atuin theming, vendor the exact official Catppuccin Mocha asset and use Atuin's native theme loading mechanism through `ATUIN_THEME_DIR`.
- Use a profile-local `ATUIN_CONFIG_DIR` and `ATUIN_THEME_DIR` together for fortress when Atuin is enabled; prioritize observed shell behavior over potentially misleading output from auxiliary Atuin info commands.
- Keep fortress persistent settings outside the repo tree so a default clone at `${XDG_CONFIG_HOME:-$HOME/.config}/shell-config` does not mix user preferences with tracked files.
- When `zsh-autocomplete` is enabled, let it own `compinit` and primary completion flow instead of trying to blend it with `fzf-tab`.
- When OMZ plugins are added, fortress may selectively override overlapping aliases, but those opinionated overrides can remain opt-in when the baseline OMZ behavior is valuable on its own.
- Favor low-risk operator helpers like OMZ `sudo` when they improve muscle memory without adding much conceptual overhead.
- Prefer lightweight utility plugins like OMZ `web-search` when they add capability without distorting core shell behavior.
- Use command-aware OMZ plugins like `aws`, and completion-only OMZ assets like `pass`, when the underlying tool exists locally and the behavior is a net productivity gain.

## Theme Implementation Policy

- First choice: use the tool's native theming mechanism with the official Catppuccin port or palette data.
- Second choice: vendor the exact upstream Catppuccin theme file into the profile when the tool expects a local config file.
- Third choice: use a small profile-local translation based on Catppuccin palette values only when no official port is directly consumable.
- Avoid ad hoc one-off color mappings when an official Catppuccin port already exists.
- If upstream assets need preprocessing or generation, a pinned fetch or sync step is acceptable as part of the build-out.
- Keep imported theme assets profile-local unless there is a deliberate repo-wide carve-out later.

## Cross-Platform Notes

- Linux notes: support Linuxbrew and standard distro completion paths.
- macOS notes: support both Intel and Apple Silicon Homebrew layouts.
- Shared expectations across hosts: the profile should preserve the same overall look and interaction model where practical, even if exact terminal behavior differs.

## Carve Outs

- This profile is allowed to use `oh-my-posh` and `starship` as richer prompt engines while keeping a native fallback path.
- This profile is allowed to use a small `zinit` plugin layer when it adds clear operator value.
- Catppuccin Mocha is a profile-level design preference, not a global repository requirement for every profile.

## Recommended Approach

1. Check the official Catppuccin ports catalog first.
2. If the tool has an official Catppuccin repository, prefer vendoring the exact Mocha asset or configuration shape from there.
3. Use the tool's native config path or native environment variables before inventing wrapper logic.
4. If vendoring upstream assets, keep them pinned and easy to diff so updates remain auditable.
5. Only consider cloning or syncing upstream repositories when the tool's official Catppuccin integration is generated or too large to maintain by hand.
6. When cloning is needed, keep it as an explicit sync/build step rather than an implicit shell-startup dependency.

## Change Guidance

- Update this file when the profile's theme direction, prompt strategy, tooling philosophy, or other major design rules change.
