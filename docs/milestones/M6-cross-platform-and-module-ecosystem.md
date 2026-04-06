# M6 Cross-Platform and Module Ecosystem Expansion

## Status

- [ ] Milestone complete
- [x] Current milestone

## Objective

Broaden the curated module set and platform polish without losing the
inspectable shell architecture.

## Exit Criteria

- [ ] High-value curated modules have clear enable/fork guidance
- [ ] Linux, macOS, and WSL differences are documented where they matter
- [ ] Tool-specific operator surfaces remain compact and debuggable
- [ ] New modules respect the curated-live and local-fork lifecycle model

## Non-Goals

- [ ] Turning shell-config into a plugin free-for-all
- [ ] Hiding platform differences behind undocumented heuristics
- [ ] Letting curated modules become opaque black boxes

## Issue Drafts

### M6-1 Expand curated modules intentionally

- [x] Problem: the module surface should grow without becoming noisy or unstructured
- [x] Scope: add or deepen curated modules only where operator value is clear
- [x] Acceptance: each curated module has crisp ownership, docs, and lifecycle guidance

### M6-2 Polish cross-platform startup and tool behavior

- [x] Problem: Linux, macOS, and WSL differences can undermine a supposedly portable shell model
- [x] Scope: document and smooth the meaningful platform differences
- [x] Acceptance: profile and module docs stay truthful across the supported host types

## Verification Notes

- [ ] Run startup and profile-selection checks on the intended platforms
- [ ] Confirm curated-module docs match actual behavior

## Progress Notes

- [x] Added a curated module catalog and enable-versus-fork guidance in [docs/curated-modules.md](/home/timl/projects/tboss/shell-config/docs/curated-modules.md)
- [x] Added an explicit platform support matrix and current verification status in [docs/platform-support.md](/home/timl/projects/tboss/shell-config/docs/platform-support.md)
- [x] Documented the current honest support stance: strongest on Linux and WSL2, macOS expected but not yet sufficiently verified
- [x] Documented the current code-level host assumptions around Homebrew/Linuxbrew discovery, opener behavior, and safest-first profile validation
- [x] Tightened fortress profile guidance so host-sensitive modules and fallback validation order are obvious in operator-facing docs

## Branch and Merge Plan

- [ ] Branch from `main` as `feat/m0006-cross-platform-and-module-ecosystem`
- [ ] Commit freely at verified checkpoints
- [ ] Squash merge when the expanded module and platform story is coherent
