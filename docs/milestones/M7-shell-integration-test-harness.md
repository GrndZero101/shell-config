# M7 Shell Integration Test Harness

## Status

- [x] Milestone complete
- [ ] Current milestone
- [ ] Next candidate milestone

## Objective

Create a repo-native clean-room test harness for `shell-config` so the shell can
be validated in isolation without depending on Dev Fortress.

## Exit Criteria

- [x] Isolated XDG-home integration tests exist for the main `csm` lifecycle flows
- [x] A clean-room container test path exists for at least one Linux target
- [x] The harness covers bootstrap, profile selection, module lifecycle, and reset workflows
- [x] `bats-core` provides the main human-readable suite surface
- [x] Optional `gum` polish exists for human-friendly runner output without becoming a required dependency of the tests themselves
- [x] The development docs explain how to run the harness locally and how it fits into the agentic loop

## Non-Goals

- [ ] Full TTY automation for every keybinding, widget, and modal-editing path
- [ ] Replacing low-level shell debugging or operator dogfooding entirely
- [ ] Making Dev Fortress the dependency or source of truth for `shell-config` tests
- [ ] Making `gum` or other presentation tools mandatory for the actual assertion layer

## Issue Drafts

### M7-1 Create a repo-native test runner

- [x] Problem: shell-config regressions currently require too much manual testing and agentic rediscovery
- [x] Scope: add a repo-native test runner and assertion helpers inside this repo, with `bats-core` as the main suite surface
- [x] Acceptance: tests can be run from `shell-config` directly without external orchestration
- [x] Acceptance: the fixture and assertion layer remains shell-native and agent-friendly under the `bats-core` wrapper

### M7-2 Add isolated XDG-home integration tests

- [x] Problem: many shell-config behaviors depend on mutable XDG state and user-local config layout
- [x] Scope: run tests with isolated `HOME`, `XDG_CONFIG_HOME`, `XDG_STATE_HOME`, `XDG_CACHE_HOME`, `XDG_DATA_HOME`, and `XDG_RUNTIME_DIR`
- [x] Acceptance: tests cover bootstrap, `csm select`, module enable/install/remove/sync, and `reset-profile`

### M7-3 Add a clean-room Docker smoke path

- [x] Problem: we need one realistic clean-room Linux path that is independent of the host shell state
- [x] Scope: add a Docker-based Ubuntu smoke test path owned by `shell-config`
- [x] Acceptance: the harness can bring up a disposable Linux environment and run the main integration suite there

### M7-4 Add optional human-friendly runner polish

- [x] Problem: humans benefit from nicer headings, prompts, and summaries than raw shell output alone
- [x] Scope: use `gum` only for optional local runner polish around the harness
- [x] Acceptance: human-focused runner output is nicer when `gum` is present
- [x] Acceptance: the actual test suite still runs correctly without `gum`

### M7-5 Document the test strategy

- [x] Problem: shell-config currently lacks a written testing model for humans and agents
- [x] Scope: document test layers, what is covered, and what still requires manual/operator verification
- [x] Acceptance: top-level docs explain when to use syntax checks, isolated XDG-home tests, Docker smoke tests, and manual dogfooding
- [x] Acceptance: docs explain the split between agent-first test execution and optional human-friendly runner polish

## Verification Notes

- [x] Run the syntax and static test layer locally
- [x] Run the isolated XDG-home integration suite locally
- [x] Run the clean-room Docker smoke suite locally
- [x] Confirm the suite runs cleanly without `gum`
- [x] Confirm the optional human-friendly runner path works when `gum` is installed
- [x] Confirm the docs accurately describe the supported test workflow

## Branch and Merge Plan

- [ ] Branch from `main` as `feat/m0007-shell-integration-test-harness`
- [ ] Commit freely at verified checkpoints
- [ ] Squash merge once the test harness is stable enough to become part of the development loop
