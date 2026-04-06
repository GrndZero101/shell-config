# M1 Bootstrap and Profile Selection

## Status

- [x] Milestone complete
- [ ] Current milestone

## Objective

Make `shell-config` installable, selectable, and practical as a real shell
bootstrap.

## Exit Criteria

- [x] `install.sh` exists as a repo-owned installer entrypoint
- [x] `csm bootstrap` installs `~/.zshenv` and the `csm` entrypoint
- [x] `csm select` can persist and switch profiles
- [x] `zsh-clean` acts as the safe default fallback

## Non-Goals

- [x] Full workstation provisioning
- [x] Package-manager installation of every optional shell dependency
- [x] Heavy GUI onboarding

## Issue Drafts

### M1-1 Add a repo-owned installer

- [x] Problem: the repo needed a repeatable install path instead of assuming a hand-managed clone
- [x] Scope: add `install.sh` with clone and bootstrap behavior
- [x] Acceptance: one-line install path exists and is documented

### M1-2 Add persistent profile selection

- [x] Problem: switching profiles manually through environment edits was too awkward
- [x] Scope: support saved profile selection and direct switching
- [x] Acceptance: `csm select` persists the active profile and re-enters `zsh`

## Verification Notes

- [x] `install.sh` supports clone-and-bootstrap flow
- [x] `csm bootstrap` links the selector and manager entrypoint
- [x] saved `active-profile` state is honored

## Branch and Merge Plan

- [x] Historical baseline milestone
