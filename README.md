# Shell Config

## Overview

`shell-config` is a multi-profile `zsh` repository for:

- atomic profile-per-`ZDOTDIR` shell setups
- XDG-aligned bootstrap and profile selection
- a shared shell manager named `csm`
- a flagship operator-heavy developer profile named
  `zsh-tll-citadel-dev-fortress`

The project is intentionally split across layers:

- the root [`.zshenv`](/home/timl/projects/tboss/shell-config/.zshenv) only selects the active profile
- each `zsh-*` directory is a standalone shell product
- `csm` is the operator surface for bootstrap, profile switching, and module management
- profile-specific `USAGE.md` and `DESIGN.md` files carry the operational truth

> [!IMPORTANT]
> This project is still in active buildout.
> The profile and operator surfaces are already useful day to day, while the
> broader curated-module ecosystem and cross-platform polish are still maturing.

> [!NOTE]
> Treat `csm` as the main operator front door.
> The root docs stay high-level; the profile docs carry the concrete behavior.

## Associated Projects

| Project | Role |
| --- | --- |
| [`dev-container-fortress`](https://github.com/GrndZero101/dev-container-fortress) | Host, container, and devcontainer orchestration that consumes `shell-config` as its shell UX layer |

## Quick Start

The fastest way to get running locally is the one-line installer.

> [!IMPORTANT]
> Baseline prerequisites:
> `git` and `zsh`.
> The installer clones the repo, then hands off to `csm bootstrap`.

**Install with the one-liner**

```sh
curl -fsSL https://raw.githubusercontent.com/GrndZero101/shell-config/main/install.sh | zsh
```

This clones the repo into `${XDG_CONFIG_HOME:-$HOME/.config}/shell-config`,
installs the shared `~/.zshenv` selector and `csm` command link, and leaves the
profiles ready to select.
The selected profile itself is stored under XDG state rather than inside the
checkout.

> [!NOTE]
> `install.sh` supports a few environment variables for common onboarding
> overrides.

| Variable | Purpose |
| --- | --- |
| `SHELL_CONFIG_INSTALL_DIR` | Choose the local checkout destination |
| `SHELL_CONFIG_REPO_URL` | Use an alternate Git repository URL |
| `SHELL_CONFIG_BRANCH` | Pin a branch for installation |
| `SHELL_CONFIG_BOOTSTRAP` | Set to `0` to skip the `csm bootstrap` handoff |

Full example with all installer overrides:

```sh
curl -fsSL https://raw.githubusercontent.com/GrndZero101/shell-config/main/install.sh | \
  SHELL_CONFIG_INSTALL_DIR="$HOME/.config/shell-config" \
  SHELL_CONFIG_REPO_URL="https://github.com/GrndZero101/shell-config.git" \
  SHELL_CONFIG_BRANCH="main" \
  SHELL_CONFIG_BOOTSTRAP="1" \
  zsh
```

**Manual clone fallback**

```sh
git clone https://github.com/GrndZero101/shell-config.git "${XDG_CONFIG_HOME:-$HOME/.config}/shell-config"
"${XDG_CONFIG_HOME:-$HOME/.config}/shell-config/scripts/csm" bootstrap
```

Use the manual path when you want to inspect or edit the checkout before
running the bootstrap.

**Validate the first local loop**

```sh
csm select zsh-tll-citadel-dev-fortress
exec zsh
fortress-hud --pretty
csm list-modules
```

> [!NOTE]
> For the fuller day-to-day shell guidance, see
> [USAGE.md](/home/timl/projects/tboss/shell-config/USAGE.md) and the active
> profile docs such as
> [zsh-tll-citadel-dev-fortress/USAGE.md](/home/timl/projects/tboss/shell-config/zsh-tll-citadel-dev-fortress/USAGE.md).

## Status

| Area | Status | Notes |
| --- | --- | --- |
| Atomic profile model | Working | Profile-per-`ZDOTDIR` structure is in place |
| Root bootstrap and selector | Working | `install.sh`, `csm bootstrap`, and shared `.zshenv` path are available |
| `csm` operator surface | Working foundation | Bootstrap, selection, settings, and module lifecycle are implemented |
| `zsh-clean` | Working | Native-first baseline profile |
| Reference profiles | Working | Atuin and `fzf-tab` comparison profiles exist |
| Fortress profile | Working foundation | Daily-use shell with stronger operator ergonomics |
| Curated module lifecycle | Working foundation | Curated-live plus local-fork model exists |
| Planning and roadmap flow | Working foundation | Roadmap and milestone workflow now exist and the active milestone is `M6 Cross-Platform and Module Ecosystem Expansion` |
| Test harness | Working | `bats-core` suite, repo-owned runner, and Ubuntu Docker smoke path cover the main `csm` lifecycle flows |

## :wrench: Operator Surface

| Interface | Role | Current guidance |
| --- | --- | --- |
| `csm` | Primary human and agent operator surface | Use this first |
| `install.sh` | Onboarding entrypoint | Use for clone-and-bootstrap installation |
| root `.zshenv` | Shared selector | Keep it minimal and auditable |
| profile `USAGE.md` files | Operational truth | Use these for real profile behavior |
| profile `DESIGN.md` files | Design and UX rules | Use these for intent and philosophy |

## :world_map: Profile Matrix

| Profile | Current state | Primary docs |
| --- | --- | --- |
| `zsh-zero` | Supported minimal baseline | [zsh-zero/USAGE.md](/home/timl/projects/tboss/shell-config/zsh-zero/USAGE.md) |
| `zsh-clean` | Supported native baseline | [zsh-clean/USAGE.md](/home/timl/projects/tboss/shell-config/zsh-clean/USAGE.md) |
| `zsh-ref-atuin` | Supported reference profile | [zsh-ref-atuin/USAGE.md](/home/timl/projects/tboss/shell-config/zsh-ref-atuin/USAGE.md) |
| `zsh-ref-fzftab` | Supported reference profile | [zsh-ref-fzftab/USAGE.md](/home/timl/projects/tboss/shell-config/zsh-ref-fzftab/USAGE.md) |
| `zsh-tll-citadel-dev-fortress` | Supported flagship profile | [zsh-tll-citadel-dev-fortress/USAGE.md](/home/timl/projects/tboss/shell-config/zsh-tll-citadel-dev-fortress/USAGE.md) |
| `zsh-tll-test` | Experimental / internal | [zsh-tll-test/USAGE.md](/home/timl/projects/tboss/shell-config/zsh-tll-test/USAGE.md) |

## :compass: Documentation Map

| Document | Audience | Purpose |
| --- | --- | --- |
| [README.md](/home/timl/projects/tboss/shell-config/README.md) | Everyone | Project overview and quick entry points |
| [USAGE.md](/home/timl/projects/tboss/shell-config/USAGE.md) | Operators | Shared shell usage guidance across the repo |
| [docs/profile-contract.md](/home/timl/projects/tboss/shell-config/docs/profile-contract.md) | Maintainers | Atomic profile structure and XDG contract |
| [docs/zshenv.md](/home/timl/projects/tboss/shell-config/docs/zshenv.md) | Maintainers | Shared selector design and `.zshenv` behavior |
| [docs/module-lifecycle.md](/home/timl/projects/tboss/shell-config/docs/module-lifecycle.md) | Maintainers | Curated-versus-local module model |
| [docs/curated-modules.md](/home/timl/projects/tboss/shell-config/docs/curated-modules.md) | Maintainers | Curated module catalog, host expectations, and enable-versus-fork guidance |
| [docs/platform-support.md](/home/timl/projects/tboss/shell-config/docs/platform-support.md) | Maintainers | Current Linux, WSL2, and macOS support reality |
| [docs/ROADMAP.md](/home/timl/projects/tboss/shell-config/docs/ROADMAP.md) | Maintainers | Milestone ordering and strategic direction |
| [docs/milestones/README.md](/home/timl/projects/tboss/shell-config/docs/milestones/README.md) | Maintainers | Active milestone workflow and draft format |
| [tests/README.md](/home/timl/projects/tboss/shell-config/tests/README.md) | Contributors | Test harness layout and runner usage |

## :building_construction: Repository Layout

| Path | Purpose |
| --- | --- |
| `scripts/` | `csm` and other repo-owned operator entrypoints |
| `shared/` | Narrow shared carve-outs such as common `PATH` discovery and repo-owned completions |
| `zsh-clean/` | Native-first baseline profile |
| `zsh-ref-*/` | Reference and comparison profiles |
| `zsh-tll-citadel-dev-fortress/` | Flagship operator-heavy developer profile |
| `tests/` | Repo-native bats suite, shell helpers, and test runner |
| `docs/` | Contracts, roadmap, templates, and milestone drafts |

## :dart: Design Direction

- Keep atomic profiles as the default architectural rule
- Keep the shared root selector small, explicit, and auditable
- Prefer XDG-aligned state and user-local extension points
- Treat `csm` as the stable operator front door for both humans and agents
- Prefer curated modules as live defaults and local installs as explicit forks
- Use profile docs for operational truth rather than overloading the top-level README

## :zap: Current Working Surface

Working today:

- root selector and bootstrap flow
- profile selection and active-profile persistence
- native and reference `zsh` profiles
- fortress HUD, debug, operator prefix, and git helper surfaces
- curated module lifecycle with direct enable, local fork install, and sync
- live module-resolution visibility in `fortress-hud` and `fortress-debug-interactive`
- `csm reset-profile` for clean-state testing and recovery
- Television-backed branch management and cleanup helpers in the fortress profile

In progress:

- continued operator UX hardening through dogfooding
- deeper branch-management and debug-surface refinement

> [!TIP]
> When shell startup, module, or helper behavior looks wrong, start with the
> built-in operator surfaces first:
> `fortress-hud`, `fortress-debug-interactive`, `csm list-modules`, and
> `csm describe-module <name>`.

## :rocket: Startup Model

| Flow | Shape today |
| --- | --- |
| Fresh install | `install.sh` clones the repo and runs `csm bootstrap` |
| Shared selector | root `.zshenv` picks the active profile and exports `ZDOTDIR` |
| Profile switching | `csm select` writes `active-profile` under XDG state and re-enters `zsh` |
| Profile customization | user-owned settings, aliases, functions, and modules live under `shell-config.local` |
| Module management | `csm` enables curated modules directly and installs local forks only when requested |

## :calendar: Current Milestone

The current implementation focus is
[M6 Cross-Platform and Module Ecosystem Expansion](/home/timl/projects/tboss/shell-config/docs/milestones/M6-cross-platform-and-module-ecosystem.md).

Use these planning docs together:

- [docs/ROADMAP.md](/home/timl/projects/tboss/shell-config/docs/ROADMAP.md) for strategy and milestone ordering
- [docs/milestones/README.md](/home/timl/projects/tboss/shell-config/docs/milestones/README.md) for the execution workflow
- the active milestone draft under [docs/milestones](/home/timl/projects/tboss/shell-config/docs/milestones)

## Collaboration Model

> [!NOTE]
> This repository is developed through human-and-AI collaboration.
> Project direction, design intent, and acceptance decisions are human-led,
> while much of the implementation, iteration, and documentation work is
> carried out with agentic coding agents.

## License

Released under the MIT License.
See [LICENSE](/home/timl/projects/tboss/shell-config/LICENSE).
