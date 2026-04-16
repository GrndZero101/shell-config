# M6 Cross-Platform and Module Ecosystem Expansion

## Status

- [x] Milestone complete
- [ ] Current milestone

## Objective

Broaden the curated module set and platform polish without losing the
inspectable shell architecture.

## Exit Criteria

- [x] High-value curated modules have clear enable/fork guidance
- [x] Linux, macOS, and WSL differences are documented where they matter
- [x] Tool-specific operator surfaces remain compact and debuggable
- [x] New modules respect the curated-live and local-fork lifecycle model
- [x] Git operator workflows cover the real milestone-branch rewrite and
  squash-publication path without manual branch renaming or ad hoc force-push
  guesswork

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

### M6-3 Close the branch rewrite and squash-publication gap

- [x] Problem: `greframe` still makes operators manually rename already-pushed
  feature branches before they can produce a final squash branch with the same
  canonical name
- [x] Scope: add a first-class workflow for rewriting an existing milestone
  branch into its final squash branch, publishing it safely, and handling the
  final merge-to-primary step where that is part of the repo workflow
- [x] Acceptance: the helper handles an existing local final-branch name
  intentionally
- [x] Acceptance: the helper makes the required `git push --force-with-lease`
  step explicit when the remote branch already exists
- [x] Acceptance: the helper can either perform or clearly stage the final
  merge into the primary branch for repos that use a local merge flow such as
  `git merge --no-ff <branch>`
- [x] Acceptance: follow-on cleanup of any temporary source branch naming is
  either automated or clearly surfaced

### M6-4 Separate ensure-versus-update command semantics for profile assets

- [ ] Problem: some direct operator commands still conflate "install if
  missing" with "update existing state", which is reasonable for manual use but
  makes external convergent callers compensate for imperative behavior
- [ ] Scope: introduce clearer command semantics for profile-local assets,
  starting with the fortress `zinit` workflow
- [ ] Acceptance: `shell-config` exposes an explicit ensure-present path,
  or a no-update flag, so callers do not need to infer declarative behavior
  from an imperative maintenance command

## Verification Notes

- [ ] Run startup and profile-selection checks on the intended platforms
- [ ] Confirm curated-module docs match actual behavior

## Progress Notes

- [x] Added a curated module catalog and enable-versus-fork guidance in [docs/curated-modules.md](/home/timl/projects/tboss/shell-config/docs/curated-modules.md)
- [x] Added an explicit platform support matrix and current verification status in [docs/platform-support.md](/home/timl/projects/tboss/shell-config/docs/platform-support.md)
- [x] Documented the current honest support stance: strongest on Linux and WSL2, macOS expected but not yet sufficiently verified
- [x] Documented the current code-level host assumptions around Homebrew/Linuxbrew discovery, opener behavior, and safest-first profile validation
- [x] Tightened fortress profile guidance so host-sensitive modules and fallback validation order are obvious in operator-facing docs
- [x] Dogfooding exposed a remaining git-helper gap around rewriting an already
  pushed milestone branch into a final squash branch with the same canonical
  name
- [x] Consolidated the git lifecycle around `gbm` so fresh temp branches,
  published-branch rewrites, finish/publish handoff, and cleanup all live
  behind one operator surface
- [ ] Dev Fortress dogfooding exposed that `csm install-zinit` currently has
  operator-friendly but imperative semantics (`clone or update`), which is fine
  for direct use but should be separated from a future ensure-present command

## Branch and Merge Plan

- [ ] Branch from `main` as `feat/m0006-cross-platform-and-module-ecosystem`
- [ ] Commit freely at verified checkpoints
- [ ] Squash merge when the expanded module and platform story is coherent
