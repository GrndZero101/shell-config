# Profile Contract

This repository uses atomic profiles with two explicit shared carve-outs:

- [`shared/path.zsh`](/home/timl/projects/tboss/shell-config/shared/path.zsh)
- [`shared/completions`](/home/timl/projects/tboss/shell-config/shared/completions)

Each profile directory should be treated as a standalone shell product.
To keep that maintainable, every profile follows a small contract.

## Required Files

Each profile should contain:

1. `profile.zsh`
2. `.zprofile`
3. `.zshrc`
4. `.zlogin`
5. `.zlogout`

Each profile should also include:

6. `USAGE.md`
7. `DESIGN.md`

`profile.zsh` is the profile contract file.
It should stay small and contain simple variable assignments only.
`USAGE.md` should follow the shared template at [`docs/templates/profile-usage-template.md`](/home/timl/projects/tboss/shell-config/docs/templates/profile-usage-template.md).
`DESIGN.md` should follow the shared template at [`docs/templates/profile-design-template.md`](/home/timl/projects/tboss/shell-config/docs/templates/profile-design-template.md).

## `profile.zsh`

Current standard variables:

- `SHELL_PROFILE_NAME`
- `SHELL_PROFILE_DESCRIPTION`
- `SHELL_PROFILE_HISTORY_MODE`

Allowed history modes:

- `profile`
- `shared`

Example:

```zsh
SHELL_PROFILE_NAME='zsh-clean'
SHELL_PROFILE_DESCRIPTION='Native zsh with no external plugin dependencies.'
SHELL_PROFILE_HISTORY_MODE='profile'
```

## Storage Layout

The contract distinguishes versioned config from runtime data.

### Config

Versioned files live in the profile directory inside the repo.

Examples:

- `.zshrc`
- `.zprofile`
- `functions/`
- `profile.zsh`
- `USAGE.md`
- `DESIGN.md`

### State

Persistent runtime data belongs under:

`$XDG_STATE_HOME/shell-config/<profile>/`

Fallback:

`${XDG_STATE_HOME:-$HOME/.local/state}/shell-config/<profile>/`

Examples:

- profile-local history
- future session markers

### Shared State

Shared runtime data belongs under:

`${XDG_STATE_HOME:-$HOME/.local/state}/shell-config/shared/`

This is used only when a profile explicitly opts into shared history.

### Cache

Disposable generated data belongs under:

`${XDG_CACHE_HOME:-$HOME/.cache}/shell-config/<profile>/`

Examples:

- `.zcompdump`
- completion caches
- future compiled shell artifacts

### Data

Profile-local managed assets and tool data belong under:

`${XDG_DATA_HOME:-$HOME/.local/share}/shell-config/<profile>/`

Examples:

- plugin manager repositories
- vendored tool data when a profile needs a local install root
- future profile-local shared assets that are not just disposable cache

### Runtime / Temp

Short-lived runtime files belong under:

`${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}/shell-config-${UID:-$(id -u)}/<profile>/`

This gives profiles a standard place for transient files without polluting the repo.

## History Policy

Default:

- `SHELL_PROFILE_HISTORY_MODE='profile'`

That maps history to:

`${XDG_STATE_HOME:-$HOME/.local/state}/shell-config/<profile>/history`

If a profile opts into:

- `SHELL_PROFILE_HISTORY_MODE='shared'`

then history maps to:

`${XDG_STATE_HOME:-$HOME/.local/state}/shell-config/shared/history`

This is a profile policy choice, not a global hidden default.

## Why This Helps

- keeps generated files out of the repo tree
- makes `csm clean` easier to reason about
- makes `csm clear-history` compatible with per-profile and shared history
- gives future plugin managers a standard home for state and cache files

## Shared Carve-outs

Atomic profiles are still the default rule.
The allowed shared carve-outs are intentionally narrow:

- [`shared/path.zsh`](/home/timl/projects/tboss/shell-config/shared/path.zsh) for common executable discovery
- [`shared/completions`](/home/timl/projects/tboss/shell-config/shared/completions) for repo-owned completion functions such as `_csm`

`shared/completions` exists to avoid repeating the same completion definitions across multiple profiles.
It should not become a general shared-function library.

## Plugin Manager Impact

This contract should help future `zinit` or OMZ usage rather than hurt it.

- plugin manager caches can live in profile cache directories
- plugin manager state can live in profile state directories
- shared history remains an explicit profile choice
- the repo tree stays focused on versioned config

The main rule is:
plugin managers should follow the contract, not redefine it.

## Documentation Contract

Each profile should document its real behavior in its own `USAGE.md`.
Each profile should also document its design intent in its own `DESIGN.md`.

Use the shared template:

- [`docs/templates/profile-usage-template.md`](/home/timl/projects/tboss/shell-config/docs/templates/profile-usage-template.md)
- [`docs/templates/profile-design-template.md`](/home/timl/projects/tboss/shell-config/docs/templates/profile-design-template.md)

This keeps profile documentation:

- atomic
- consistent
- easy to compare across profiles
- aligned with actual implementation
