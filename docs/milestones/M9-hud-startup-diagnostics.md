# M9 HUD Startup and Module Diagnostics

## Status

- [x] Milestone complete
- [ ] Current milestone
- [ ] Next candidate milestone

## Objective

Make `fortress-hud` explain how the shell actually started: where time went,
which modules really loaded, and what went wrong, without re-running startup
by hand.

## Exit Criteria

- [x] `fortress-hud` shows `.zshrc` total and per-stage startup timing
- [x] each enabled module reports load status, load time, and what it added
- [x] modules that bail out through a `requires` guard read as `skipped`, not
  `loaded`
- [x] startup problems (missing or failing modules, missing zinit) are
  collected as warnings instead of only scrolling past on stderr
- [x] `fortress-debug-interactive` exposes the same raw recorded state
- [x] the HUD still renders in shells that did not start through the fortress
  `.zshrc`
- [x] bats coverage exists for every load outcome and the startup section
- [x] `fortress-hud --human` gives a condensed highlights view for people,
  bound to `Ctrl-G u`, while plain `fortress-hud` stays the full agent view
- [x] fortress `USAGE.md`, `DESIGN.md`, `README.md`, and the roadmap reflect the new surface

## Non-Goals

- [ ] Full startup profiling with `zprof` or xtrace; the HUD shows where to
  look, not every line
- [ ] Timing `.zshenv`, `.zprofile`, or zinit turbo plugins loaded with `wait`
- [ ] Capturing module stderr during startup
- [ ] Changing module load order or startup behavior beyond recording it
- [ ] Optimizing startup time; findings go to the idea pool

## Design Notes

- `.zshrc` sources each `config/*.zsh` stage from a top-level loop rather than
  a wrapper function, so `typeset` calls inside the stages keep global scope.
- Timing uses `zsh/datetime` `EPOCHREALTIME`, stored as one-decimal
  millisecond strings in `SHELL_FORTRESS_STARTUP_STAGE_MS` and
  `SHELL_FORTRESS_STARTUP_TOTAL_MS`.
- `fortress-source-local-module` now has a single source path for local and
  curated modules and records `SHELL_FORTRESS_MODULE_LOAD_STATUS`,
  `_LOAD_MS`, `_ADDED_FUNCTIONS`, and `_ADDED_ALIASES`.
- Skip detection is inferred at HUD time, not at startup: a module that
  returned 0, added no functions or aliases, and names an absent command in
  its `# requires:` header is `skipped`. Both signals are required, so a
  logical requirement such as `requires: browser` never mislabels a module
  that loaded.
- Failures are recorded through `fortress-record-startup-warning` without new
  stderr output; the existing missing-module stderr message is unchanged.

## Issue Drafts

### M9-1 Record startup stage timing

- [x] Problem: there was no way to see which startup stage was slow
- [x] Scope: timed stage loop in `.zshrc`; `[startup]` HUD section
- [x] Acceptance: every stage and `zshrc_total` print as `<n>.<n>ms`

### M9-2 Record module load outcomes

- [x] Problem: the HUD showed module source but not whether it loaded, failed,
  or silently skipped itself
- [x] Scope: loader bookkeeping, `status=`, `load=`, `adds=`, `requires=` on
  each `[module_resolution]` line, and `slowest_module`
- [x] Acceptance: fixtures for loaded, `failed:3`, `skipped(missing:…)`, and
  `missing` render exactly

### M9-3 Startup warnings

- [x] Problem: missing modules, failing modules, and a missing zinit install
  were easy to miss
- [x] Scope: `SHELL_FORTRESS_STARTUP_WARNINGS`, HUD `warnings` and `warning`
  lines, and a `== Startup ==` debug section
- [x] Acceptance: a clean test home without zinit reports exactly one warning
  pointing at `csm install-zinit`

### M9-4 Human and agent HUD views

- [x] Problem: the full HUD is dense; that suits agents but is busy for a
  person checking the shell at a glance
- [x] Scope: `fortress-hud --human` condensed renderer; `Ctrl-G u` switches
  from `--pretty` to it; `--human --env` is rejected
- [x] Acceptance: the human view shows startup, warnings, module glyphs,
  non-default settings, missing tools, branch, and Brewfile, and never prints
  full-view section lines

## Verification Notes

- [x] `zsh -n` passes on `.zshrc`, `00-environment.zsh`, `70-plugins.zsh`,
  `fortress-hud`, and `fortress-debug-interactive`
- [x] bats suite (47 tests) passes locally and in `./tests/run.zsh --docker-ubuntu`
- [x] Live HUD on the WSL2 workstation shows all four enabled modules as
  `loaded` with zero warnings
- [x] Dogfooding finding: `00-environment` takes about 110ms of a roughly
  240ms `.zshrc` because the first `$commands` lookup hashes a `PATH` holding
  40 WSL `/mnt/c` entries (99ms, versus 2.5ms without them); assessed as
  acceptable for the current workstation and recorded in the roadmap idea
  pool for revisiting only if startup time becomes a problem

## Branch and Merge Plan

- [x] Branch from `main` as `feat/m0009-hud-startup-diagnostics`
- [x] Commit freely at verified checkpoints
- [x] Squash merge when the exit criteria are met
