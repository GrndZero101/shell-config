# M5 Interactive Operator Workflows

## Status

- [x] Milestone complete
- [ ] Current milestone
- [ ] Next candidate milestone

## Objective

Reduce taxing manual shell and git sequences by turning them into first-class
operator workflows.

## Exit Criteria

- [x] Branch reframe, cleanup, and management helpers feel stable in real repos
- [x] Television and `fzf` operator paths cover the common branch-management loops
- [x] `csm` and fortress debug surfaces make module-source problems obvious
- [x] `csm` provides a configuration-reset workflow for testing and clean-state recovery
- [x] Workflow docs explain the preferred human and agent operator paths

## Non-Goals

- [ ] Full TUI replacement for raw git
- [ ] Solving every shell management task with Television first
- [ ] Removing low-level git commands from operator use entirely

## Issue Drafts

### M5-1 Harden branch reframe and cleanup workflows

- [x] Problem: branch cleanup and squash-prep workflows are still young despite already reducing manual toil
- [x] Scope: keep dogfooding the fortress branch lifecycle and cleanup flows
- [x] Acceptance: the common milestone branch lifecycle is reliable in daily use

### M5-2 Improve interactive branch management

- [x] Problem: branch selection and cleanup still involve too much remembering and typing
- [x] Scope: deepen Television and `fzf` flows for checkout, cleanup, and operator feedback
- [x] Acceptance: interactive branch management covers the common human cleanup loops safely

### M5-3 Improve module debugging surfaces

- [x] Problem: module shadowing and startup-resolution issues still require too much manual diagnosis
- [x] Scope: improve `csm`, `fortress-hud`, and debug output around curated versus local module resolution
- [x] Acceptance: module source and shadowing are obvious from the built-in debug surfaces

### M5-4 Add configuration reset workflow

- [x] Problem: testing and debugging still required too much manual cleanup across state, cache, runtime files, history, and local mutable config
- [x] Scope: add a `csm` reset command that can remove fortress-managed mutable files without touching the tracked repo checkout
- [x] Acceptance: operators can reset one profile or all profiles back to a clean mutable-state baseline
- [x] Acceptance: destructive reset behavior confirms by default and supports `--force` for agentic and scripted use
- [x] Acceptance: docs clearly distinguish `clean`, `clear-history`, and the stronger reset workflow

## Verification Notes

- [x] Dogfood branch reframe and cleanup in real repositories
- [x] Verify Television branch workflows in disposable repos and live repos
- [x] Confirm debug surfaces expose module source clearly
- [x] Dogfood the configuration reset flow in a disposable XDG home

## Follow-on Priority

This milestone originally left a gap around published-branch rewrites and final
squash publication. That follow-on work was completed in `M6` by consolidating
the branch lifecycle behind `gbm`.

## Branch and Merge Plan

- [ ] Branch from `main` as `feat/m0005-interactive-operator-workflows`
- [ ] Commit freely at verified checkpoints
- [ ] Squash merge once the operator flows hold up in daily use
