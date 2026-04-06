# M2 Fortress Operator Surface

## Status

- [x] Milestone complete
- [ ] Current milestone

## Objective

Turn `zsh-tll-citadel-dev-fortress` into a real operator-heavy developer
profile.

## Exit Criteria

- [x] Fortress has stable usage and design docs
- [x] Fortress exposes HUD, keybind, and debug surfaces
- [x] Fortress includes a meaningful native git helper layer
- [x] Optional tools degrade gracefully when absent

## Non-Goals

- [x] Turning every profile into a fortress-like experience
- [x] Hiding startup behavior behind opaque plugin bundles
- [x] Perfect parity across every terminal emulator

## Issue Drafts

### M2-1 Build fortress runtime visibility

- [x] Problem: a complex developer shell needs fast state inspection
- [x] Scope: add HUD and debug helpers for tools, widgets, and runtime wiring
- [x] Acceptance: fortress users can inspect startup and runtime behavior without manual spelunking

### M2-2 Build fortress-native operator ergonomics

- [x] Problem: common repo and shell-management actions were still too manual
- [x] Scope: add operator keybinds and native git helper surfaces
- [x] Acceptance: fortress exposes high-signal operator shortcuts and helper commands

## Verification Notes

- [x] Fortress profile usage and design docs are aligned
- [x] HUD and debug surfaces are available from the profile
- [x] Fortress-native git helper surface exists

## Branch and Merge Plan

- [x] Historical baseline milestone
