# M3 Curated Module Lifecycle

## Status

- [x] Milestone complete
- [ ] Current milestone

## Objective

Make curated modules live by default, local installs explicit, and module
shadowing recoverable.

## Exit Criteria

- [x] `csm enable-module` enables curated modules directly without forcing local install
- [x] `csm install-module` creates a local fork of a curated module
- [x] `csm list-modules` and `csm describe-module` show active source and shadowing clearly
- [x] `csm sync-curated-modules` resets local curated forks safely

## Non-Goals

- [x] Full module marketplace support
- [x] Eliminating all optional local overrides
- [x] Solving every curated-module UX issue in one pass

## Issue Drafts

### M3-1 Separate enablement from forking

- [x] Problem: curated modules were too easy to freeze into stale point-in-time local copies
- [x] Scope: let curated modules be enabled directly and reserve local install for explicit forks
- [x] Acceptance: module lifecycle semantics are documented and implemented

### M3-2 Make module source and shadowing visible

- [x] Problem: stale local overrides were too hard to spot during debugging
- [x] Scope: show active source, install state, and curated shadowing in `csm`
- [x] Acceptance: operators can identify curated versus local-fork behavior quickly

## Verification Notes

- [x] Module lifecycle documentation exists
- [x] `csm` supports direct curated enable, fork install, and sync
- [x] module shadowing is visible in `list-modules` and `describe-module`

## Branch and Merge Plan

- [x] Historical baseline milestone
