# Shell Config Roadmap

## Overview

This document is the roadmap for `shell-config`.
It is intentionally milestone-oriented rather than task-exhaustive.

Use it to track:

- strategic direction
- milestone scope
- milestone exit criteria
- ordering and dependencies
- ideas that are not yet ready to become implementation work

Do not use this file as the main execution checklist.
Concrete implementation work should live in the matching milestone draft under
`docs/milestones/`, then be copied into GitHub milestones and issues later when
that workflow becomes worth the overhead.

> [!NOTE]
> Operational truth belongs in the relevant README, usage documents, and
> profile-specific `USAGE.md` files once work is implemented.

## Workflow Standard

Recommended planning model for this repository:

1. Roadmap document for strategy and milestone framing
2. Milestone draft files under `docs/milestones/`
3. GitHub milestones and issues copied from those drafts when desired
4. Feature branches for milestone implementation
5. Squash merge into the main branch once milestone exit criteria are met

Recommended branch naming:

- Use milestone-aligned branch names by default: `feat/<sortable-milestone-id>-<short-name>`
- Convert roadmap milestone IDs into zero-padded sortable branch IDs
- Keep milestone letter suffixes when present
- Prefer hyphens over underscores in the descriptive suffix
- Examples:
  - `feat/m0004-documentation-and-planning-normalization`
  - `feat/m0005-interactive-operator-workflows`
  - `docs/m0004-documentation-and-planning-normalization`

Sortable branch ID examples:

- `M4` -> `m0004`
- `M5` -> `m0005`
- `M6` -> `m0006`

Recommended issue types:

- `epic`
- `feature`
- `task`
- `spike`
- `bug`
- `docs`

Recommended milestone states inside this document:

- `done`
- `now`
- `next`
- `later`
- `icebox`

Each milestone should have:

- one-sentence objective
- clear exit criteria
- explicit non-goals
- a matching markdown file under `docs/milestones/`

## Planning Principles

- Prefer small, mergeable milestones over broad multi-month “phases.”
- Keep milestones outcome-shaped rather than directory-shaped.
- Treat `csm` as the main operator surface.
- Keep top-level docs comparative and profile docs operational.
- Prefer curated modules as the default live path and local installs as
  explicit forks.
- Keep atomic-profile boundaries understandable and debuggable.
- Keep “done” meaningful: code, docs, and operator workflow should move
  together.

## Current Direction

- Build a shell environment that feels intentional, inspectable, and
  operator-heavy without becoming an opaque snippet pile.
- Keep the shared layer deliberately small: profile selection plus narrow,
  auditable carve-outs.
- Prefer XDG-aligned state, cache, runtime, and user-local extension points.
- Favor fortress-owned helpers and workflows when they reduce manual toil and
  preserve clarity.
- Build toward milestone-based squash merges rather than long-lived branch
  drift.

## Milestones

### `M0` Atomic Profile Foundation

Status: `done`

Objective:
Establish the atomic profile model, the shared root selector, and the profile
contract.

Delivered:

- shared root `.zshenv` selector
- profile-per-`ZDOTDIR` layout
- XDG storage contract
- top-level and per-profile usage/design documentation templates
- narrow shared carve-outs for `PATH` and repo-owned completions

Details:
[M0 draft](/home/timl/projects/tboss/shell-config/docs/milestones/M0-atomic-profile-foundation.md)

### `M1` Bootstrap and Profile Selection

Status: `done`

Objective:
Make the repository installable, selectable, and usable as a real shell
bootstrap.

Exit criteria:

- repo-owned installer exists
- `csm bootstrap` installs the root selector and command entrypoint
- `csm select` persists profile choice and re-enters `zsh`
- a default baseline profile exists when no explicit choice is made

Delivered:

- `install.sh`
- `csm bootstrap`
- interactive and direct profile selection
- active-profile persistence
- default fallback to `zsh-clean`

Details:
[M1 draft](/home/timl/projects/tboss/shell-config/docs/milestones/M1-bootstrap-and-profile-selection.md)

### `M2` Fortress Operator Surface

Status: `done`

Objective:
Turn `zsh-tll-citadel-dev-fortress` into a useful, operator-heavy developer
profile rather than just a themed shell experiment.

Exit criteria:

- fortress profile has stable identity, usage, and design docs
- fortress exposes HUD and debug surfaces
- key operator shortcuts and native git helpers exist
- optional tool integrations degrade gracefully when absent

Delivered:

- fortress profile usage and design contract
- `fortress-hud`, `fortress-keybinds`, and `fortress-debug-interactive`
- native git helper surface
- richer prompt handling and curated tool-module pattern

Details:
[M2 draft](/home/timl/projects/tboss/shell-config/docs/milestones/M2-fortress-operator-surface.md)

### `M3` Curated Module Lifecycle

Status: `done`

Objective:
Make curated modules understandable, live by default, and recoverable when
forked locally.

Exit criteria:

- curated modules can be enabled directly
- local installs are treated as explicit forks
- `csm list-modules` and `csm describe-module` show active source clearly
- local curated forks can be reset safely

Delivered:

- curated-vs-local-fork lifecycle model
- persistent enable and disable behavior across module types
- `csm sync-curated-modules`
- better module shadowing visibility

Details:
[M3 draft](/home/timl/projects/tboss/shell-config/docs/milestones/M3-curated-module-lifecycle.md)

### `M4` Documentation and Planning Normalization

Status: `done`

Objective:
Bring `shell-config` documentation and planning into the same structured shape
as Dev Fortress without flattening the profile-specific detail.

Exit criteria:

- top-level README is a clear OSS front door
- roadmap and milestone drafts exist under `docs/`
- planning docs distinguish strategy from execution
- docs link cleanly across README, profile docs, and planning docs
- active profile selector state lives under XDG state instead of inside the checkout

Non-goals:

- full shell-config content freeze
- rewriting every profile document at once
- forcing shell-config into the exact same project shape as Dev Fortress

Details:
[M4 draft](/home/timl/projects/tboss/shell-config/docs/milestones/M4-documentation-and-planning-normalization.md)

### `M5` Interactive Operator Workflows

Status: `done`

Objective:
Reduce manual operator sequences by turning high-friction shell and git tasks
into first-class workflows.

Exit criteria:

- branch reframe and cleanup workflows feel stable in daily use
- Television and `fzf` operator paths cover the most common branch-management
  loops
- `csm` surfaces curated/local shadowing clearly enough to debug without
  spelunking
- `csm` provides a configuration-reset workflow for testing and clean-state
  recovery without manual cache and state spelunking
- docs explain the preferred operator workflow for humans and agents

Details:
[M5 draft](/home/timl/projects/tboss/shell-config/docs/milestones/M5-interactive-operator-workflows.md)

### `M6` Cross-Platform and Module Ecosystem Expansion

Status: `now`

Objective:
Broaden the curated module set and platform polish without losing the
inspectable shell architecture.

Exit criteria:

- high-value curated modules have clear enable/fork guidance
- Linux, macOS, and WSL behavior are documented where they diverge
- module-specific operator surfaces remain discoverable and debuggable

Details:
[M6 draft](/home/timl/projects/tboss/shell-config/docs/milestones/M6-cross-platform-and-module-ecosystem.md)

### `M7` Shell Integration Test Harness

Status: `done`

Objective:
Create a repo-native clean-room test harness for `shell-config` so the shell can
be validated in isolation without depending on Dev Fortress.

Exit criteria:

- isolated XDG-home integration tests exist for the main `csm` lifecycle flows
- a clean-room container test path exists for at least one Linux target
- the harness covers bootstrap, profile selection, module lifecycle, and reset workflows
- `bats-core` provides the main human-readable suite surface
- optional `gum` polish exists for human-friendly runner output without becoming a required dependency
- development docs explain how to run the harness and how it fits into the agentic loop

Delivered:

- repo-owned `tests/run.zsh` runner
- `bats-core` lifecycle suite with shell-native helper fixtures
- Ubuntu Docker smoke path under `tests/docker/`
- test harness docs under `tests/README.md`

Details:
[M7 draft](/home/timl/projects/tboss/shell-config/docs/milestones/M7-shell-integration-test-harness.md)

## Idea Pool

These ideas matter, but are not yet shaped enough to promote into active
milestones:

- secrets-management-aware shell workflows
- stronger tmux integration
- richer module-source and startup diagnostics in the HUD
- interactive cleanup and recovery surfaces beyond git branches
- profile-specific bootstrap shortcuts for ephemeral development environments

## Definition of Done

A milestone is ready to merge when:

- implementation is complete for the scoped slice
- README and relevant usage/design docs are updated
- roadmap and milestone docs reflect reality
- verification has been run and recorded where relevant
- the branch is coherent enough to squash-merge as one milestone outcome
