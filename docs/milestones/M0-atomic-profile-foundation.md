# M0 Atomic Profile Foundation

## Status

- [x] Milestone complete
- [ ] Current milestone

## Objective

Establish the atomic profile model, the shared selector, and the basic profile
contract.

## Exit Criteria

- [x] The repo uses a shared root `.zshenv` only for profile selection and narrow shared carve-outs
- [x] Profiles are structured as standalone `ZDOTDIR` products
- [x] XDG state, cache, data, and runtime conventions are documented
- [x] Per-profile `USAGE.md` and `DESIGN.md` expectations exist

## Non-Goals

- [x] Rich operator workflows
- [x] Large shared helper libraries across profiles
- [x] Tool-specific module management

## Issue Drafts

### M0-1 Define the atomic profile contract

- [x] Problem: profile boundaries were too easy to blur without a written contract
- [x] Scope: define required profile files, profile variables, and storage layout
- [x] Acceptance: `docs/profile-contract.md` captures the baseline rules

### M0-2 Keep the shared layer intentionally small

- [x] Problem: profile startup can become opaque if too much logic lives above `ZDOTDIR`
- [x] Scope: keep shared startup limited to profile selection and narrow carve-outs
- [x] Acceptance: `.zshenv` and the shared-path model are documented and auditable

## Verification Notes

- [x] Root `.zshenv` selects valid profiles and falls back safely
- [x] The repo documents allowed shared carve-outs explicitly

## Branch and Merge Plan

- [x] Historical baseline milestone
