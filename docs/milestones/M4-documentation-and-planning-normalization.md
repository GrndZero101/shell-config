# M4 Documentation and Planning Normalization

## Status

- [x] Milestone complete
- [ ] Current milestone

## Objective

Bring `shell-config` documentation and planning into the same structured shape
as Dev Fortress while keeping shell-config-specific detail intact.

## Exit Criteria

- [x] Top-level `README.md` is a clear OSS front door
- [x] `docs/ROADMAP.md` exists and defines milestone ordering
- [x] `docs/milestones/` exists with one draft per roadmap milestone
- [x] README, usage docs, and agent guidance point at the new planning surface cleanly
- [x] Active profile selector state lives under XDG state rather than inside the checkout

## Non-Goals

- [ ] Rewriting every profile document in one pass
- [ ] Forcing shell-config content to match Dev Fortress line-for-line
- [ ] Treating the README as the full manual

## Issue Drafts

### M4-1 Normalize the top-level README

- [ ] Problem: the current README is too wordy at the top and mixes front-door content with implementation detail
- [ ] Scope: rebuild the README around overview, quick start, status, docs map, layout, and milestone framing
- [ ] Acceptance: the README looks and feels consistent with Dev Fortress while staying truthful to shell-config

### M4-2 Add roadmap and milestone drafts

- [ ] Problem: shell-config lacks the roadmap and milestone planning split now used successfully in Dev Fortress
- [ ] Scope: add `docs/ROADMAP.md` and `docs/milestones/`
- [ ] Acceptance: strategy and execution planning are clearly separated

### M4-3 Retarget the documentation links

- [x] Problem: planning, usage, and profile docs did not yet cross-link through a shared structure
- [x] Scope: update top-level docs and guidance files to reference the new roadmap and milestone workflow
- [x] Acceptance: README, AGENTS, and usage docs point to the correct planning surfaces

### M4-4 Move selector state out of the checkout

- [x] Problem: storing `active-profile` under `${XDG_CONFIG_HOME}/shell-config` mixes live mutable state with the tracked repo checkout
- [x] Scope: move the persisted selector state to XDG state and keep a compatibility read path for older installs
- [x] Acceptance: new profile selections are written under `${XDG_STATE_HOME:-$HOME/.local/state}/shell-config/active-profile`
- [x] Acceptance: the selector still honors the legacy config-path state file during transition

## Verification Notes

- [x] Review the rendered README for scanability
- [x] Confirm roadmap and milestone links resolve
- [x] Confirm planning guidance is consistent across README, AGENTS, and milestone docs
- [x] Confirm `.zshenv` and `csm select` use XDG state for `active-profile`

## Branch and Merge Plan

- [x] Branch from `main` as `docs/m0004-documentation-and-planning-normalization`
- [x] Commit freely at verified checkpoints
- [ ] Squash merge once the normalized planning and README surface are in place
