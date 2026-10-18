# Shell Config

## Overview

`shell-config` is a multi-profile `zsh` repository for:

- atomic profile-per-`ZDOTDIR` shell setups
- XDG-aligned bootstrap and profile selection
- a shared shell manager named `csm`
- a flagship operator-heavy developer profile named
  `zsh-tll-citadel-dev-fortress`

The project is intentionally split across layers:

- the root [`.zshenv`](.zshenv) only selects the active profile
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
fortress-hud --human
csm list-modules
```

> [!NOTE]
> For the fuller day-to-day shell guidance, see
> [USAGE.md](USAGE.md) and the active
> profile docs such as
> [zsh-tll-citadel-dev-fortress/USAGE.md](zsh-tll-citadel-dev-fortress/USAGE.md).

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
| Planning and roadmap flow | Working foundation | Roadmap and milestone workflow exist; `M0`–`M8` are done and the next milestone is not yet chosen |
| Test harness | Working | `bats-core` suite, repo-owned runner, and Ubuntu Docker smoke path cover the main `csm` lifecycle flows |

## :wrench: Operator Surface

| Interface | Role | Current guidance |
| --- | --- | --- |
| `csm` | Primary human and agent operator surface | Use this first |
| `csm docs [profile\|module]` | In-terminal docs reader | Renders a profile `USAGE.md` or module guide with `glow`, falling back to `$PAGER`, `less`, or raw markdown |
| `csm tmux-profile [name\|none]` | tmux profile switch | Flips between the tmux profiles Dev Fortress installs, or back to stock tmux; `-i` opens a picker |
| `install.sh` | Onboarding entrypoint | Use for clone-and-bootstrap installation |
| root `.zshenv` | Shared selector | Keep it minimal and auditable |
| profile `USAGE.md` files | Operational truth | Use these for real profile behavior |
| profile `DESIGN.md` files | Design and UX rules | Use these for intent and philosophy |

## :world_map: Profile Matrix

| Profile | Current state | Primary docs |
| --- | --- | --- |
| `zsh-zero` | Supported minimal baseline | [USAGE.md](zsh-zero/USAGE.md) · [DESIGN.md](zsh-zero/DESIGN.md) |
| `zsh-clean` | Supported native baseline | [USAGE.md](zsh-clean/USAGE.md) · [DESIGN.md](zsh-clean/DESIGN.md) |
| `zsh-ref-atuin` | Supported reference profile | [USAGE.md](zsh-ref-atuin/USAGE.md) · [DESIGN.md](zsh-ref-atuin/DESIGN.md) |
| `zsh-ref-fzftab` | Supported reference profile | [USAGE.md](zsh-ref-fzftab/USAGE.md) · [DESIGN.md](zsh-ref-fzftab/DESIGN.md) |
| `zsh-tll-citadel-dev-fortress` | Supported flagship profile | [USAGE.md](zsh-tll-citadel-dev-fortress/USAGE.md) · [DESIGN.md](zsh-tll-citadel-dev-fortress/DESIGN.md) |
| `zsh-tll-test` | Experimental / internal | [USAGE.md](zsh-tll-test/USAGE.md) · [DESIGN.md](zsh-tll-test/DESIGN.md) |

## :compass: Documentation Map

| Document | Audience | Purpose |
| --- | --- | --- |
| [README.md](README.md) | Everyone | Project overview and quick entry points |
| [USAGE.md](USAGE.md) | Operators | Shared shell usage guidance across the repo |
| [docs/profile-contract.md](docs/profile-contract.md) | Maintainers | Atomic profile structure and XDG contract |
| [docs/zshenv.md](docs/zshenv.md) | Maintainers | Shared selector design and `.zshenv` behavior |
| [docs/module-lifecycle.md](docs/module-lifecycle.md) | Maintainers | Curated-versus-local module model |
| [docs/curated-modules.md](docs/curated-modules.md) | Maintainers | Curated module catalog, host expectations, and enable-versus-fork guidance |
| [docs/platform-support.md](docs/platform-support.md) | Maintainers | Current Linux, WSL2, and macOS support reality |
| [docs/ROADMAP.md](docs/ROADMAP.md) | Maintainers | Milestone ordering and strategic direction |
| [docs/milestones/README.md](docs/milestones/README.md) | Maintainers | Active milestone workflow and draft format |
| [tests/README.md](tests/README.md) | Contributors | Test harness layout and runner usage |

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
- live module-resolution, module load-status, and startup-timing visibility in `fortress-hud` and `fortress-debug-interactive`
- `csm reset-profile` for clean-state testing and recovery
- `csm docs` for reading profile and module docs in the terminal, rendered with `glow` when installed
- an opt-in curated `brew` module that keeps a git-tracked Brewfile as the source of truth, with tab completion
- Television-backed branch management and cleanup helpers in the fortress profile
- `gbm` for temp-branch, rewrite, squash, publish, and land git workflows
- `csm tmux-profile` for switching the Dev Fortress tmux profiles

In progress:

- continued operator UX hardening through dogfooding
- forward fixes for the `brew` module as day-to-day use surfaces issues

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

The most recently completed milestone is
[M8 Curated Homebrew Module](docs/milestones/M8-curated-brew-module.md).
The next milestone is not yet chosen; [docs/ROADMAP.md](docs/ROADMAP.md) shows
which milestone is `now` once one is.

Use these planning docs together:

- [docs/ROADMAP.md](docs/ROADMAP.md) for strategy and milestone ordering
- [docs/milestones/README.md](docs/milestones/README.md) for the execution workflow
- the active milestone draft under [docs/milestones](docs/milestones)

## Collaboration Model

> [!NOTE]
> This repository is developed through human-and-AI collaboration.
> Project direction, design intent, and acceptance decisions are human-led,
> while much of the implementation, iteration, and documentation work is
> carried out with agentic coding agents.

## License

Released under the MIT License.
See [LICENSE](LICENSE).
