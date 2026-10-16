# M8 Curated Homebrew Module

## Status

- [x] Milestone complete
- [ ] Current milestone
- [ ] Next candidate milestone

## Objective

Add a first-class curated `brew` module that treats a git-tracked Brewfile as
the source of truth for installed Homebrew packages, so installs and removals
never drift from the declared state.

## Exit Criteria

- [x] A curated `brew` module exists, is opt-in, and follows the curated-live
  and local-fork lifecycle
- [x] `brew-add` and `brew-rm` keep the Brewfile in step with installs and
  removals
- [x] `brew-drift` reports undeclared and missing packages without changing
  anything
- [x] `brew-sync` converges the host on the Brewfile and never removes
  undeclared packages without explicit confirmation
- [x] The fortress HUD shows the resolved Brewfile so path problems are
  obvious
- [x] bats coverage exists for argument handling, Brewfile resolution, call
  ordering, and the confirmation gate

## Non-Goals

- [ ] Enabling the module by default
- [ ] Hardcoding a personal Brewfile path in the repository
- [ ] Shipping a default Brewfile; a recommended tool Brewfile for the full
  fortress experience belongs in dev-container-fortress, keeping shell-config
  usable on its own
- [ ] Re-implementing Brewfile parsing that `brew bundle` already provides
- [ ] Managing non-Homebrew Brewfile entry types such as `mas`, `vscode`, or `go`
  beyond what `brew bundle` does natively

## Design Notes

- Origin: a Cowork design spec for zsh autoload Brewfile helpers, adapted to
  the curated-module structure and Homebrew 7 behavior.
- Brewfile resolution: `HOMEBREW_BUNDLE_FILE`, then Homebrew's own `--global`
  order (`HOMEBREW_BUNDLE_FILE_GLOBAL`, `${XDG_CONFIG_HOME}/homebrew/Brewfile`,
  `~/.homebrew/Brewfile`, `~/.Brewfile`). Users point `HOMEBREW_BUNDLE_FILE` at
  their dotfiles Brewfile from `shell-config.local`.
- Brewfile edits delegate to native `brew bundle add`, `brew bundle remove`,
  and `brew bundle list`, replacing the spec's hand-rolled `_brewfile_match`
  matcher. `remove` matches names exactly (`jq` vs `jqx`, `brew` vs `cask`),
  handles options and trailing comments, preserves other lines, and keeps a
  symlinked Brewfile a symlink.
- `brew bundle add` appends unconditionally (no dedupe), so `brew-add` reads
  declared names once via `brew bundle list --formula|--cask` and skips exact
  matches before appending.
- Homebrew 7 `brew bundle cleanup` prompts and removes unless declined; it has
  no dry-run flag. Drift detection runs it with stdin from `/dev/null` so the
  prompt cannot be answered, which prints the `Would uninstall` list and exits
  1 without changing anything.
- `brew-sync` installs with `brew bundle install --no-upgrade` so its explicit
  `brew upgrade "$@"` step owns upgrades and forwards flags such as `--greedy`.
- Drift and sync removal pass `--formula --cask --tap` to `brew bundle cleanup`
  explicitly, so winget, vscode, uv, and other ecosystem entries are never
  reported or removed even if Homebrew's defaults widen.
- `brew bundle cleanup --force` also resets Homebrew's global trust store to
  the Brewfile's declarations; the confirmation prompt says so.

## Issue Drafts

### M8-1 Add the curated brew module skeleton

- [x] Problem: Homebrew is a first-class host assumption, but package state is
  managed by hand and drifts from any Brewfile
- [x] Scope: `curated-modules/brew/module.zsh` with metadata, a `brew` guard,
  overridable `HOMEBREW_*` quality-of-life defaults, autoloads, and aliases
- [x] Acceptance: `csm list-modules` and `csm describe-module brew` show it and
  it stays disabled until `csm enable-module brew`

### M8-2 Declarative install and removal helpers

- [x] Problem: `brew install` and `brew uninstall` never update the Brewfile
- [x] Scope: `brew-file`, `brew-add [--cask]`, `brew-rm [--cask]`, `brew-edit`
- [x] Acceptance: adding the same name twice yields one Brewfile line and
  reports `already declared`
- [x] Acceptance: a failed install declares nothing; usage errors return 2 and
  a missing Brewfile returns 1

### M8-3 Drift report and convergent sync

- [x] Problem: there is no quick way to see or fix drift between host and Brewfile
- [x] Scope: `brew-drift` (read-only) and `brew-sync [upgrade-flags...]`
- [x] Acceptance: `brew-sync` with no drift does not prompt
- [x] Acceptance: `brew-sync` only runs `cleanup --force` after an explicit `y`

### M8-4 Operator surfaces and docs

- [x] Problem: a Brewfile path mistake is silent until a command fails
- [x] Scope: HUD `brew` and `brewfile` lines, curated module catalog, fortress
  usage docs, and platform notes
- [x] Acceptance: `fortress-hud` shows the resolved Brewfile or why it is missing

### M8-5 Snapshot the host into a Brewfile

- [x] Problem: Homebrew 7 `brew bundle dump` includes every ecosystem it knows
  (winget, vscode, uv, ...), which is noisy for a traditional Brewfile
- [x] Scope: `brew-dump [--with <types>]... [--write]` defaulting to formulae,
  casks, and taps with opt-in extras
- [x] Acceptance: prints to stdout by default; `--write` replaces the active
  Brewfile in place, keeps symlinks, and leaves it untouched on failure
- [x] Acceptance: unknown types are rejected with usage status 2

### M8-6 Feature-complete polish

- [x] Problem: Homebrew 7 writes a description comment above every entry, so
  `brew-rm` left orphans; declared but uninstalled packages could not be
  removed; tap-qualified names did not declare their tap; no tab completion
- [x] Scope: `brew-drop-description`, not-installed handling in `brew-rm`,
  `brew-add-tap`, and `_brew-add`, `_brew-rm`, `_brew-dump` completions
- [x] Acceptance: only the exact Homebrew description directly above the
  entry is removed; hand-written comments stay
- [x] Acceptance: completion is covered by real zsh completion sessions in
  bats, and `brew-rm` completion never shells out to `brew bundle`

### M8-7 Module usage guide

- [x] Problem: brew setup and safe daily use were spread across reference
  tables in the fortress `USAGE.md`
- [x] Scope: a module-local `README.md` guide, a `docs:` line in
  `csm describe-module`, and a Module Guides convention in the catalog
- [x] Acceptance: `csm describe-module brew` points to the guide; modules
  without a guide are unchanged
- [x] Acceptance: `csm docs [profile|module]` renders a profile `USAGE.md` or
  module guide with `glow` when installed, falling back to `$PAGER`, `less`,
  `more`, or raw markdown; non-terminal output is always raw

## Verification Notes

- [x] `zsh -n` passes on every module and function file
- [x] bats suite (44 tests; 2 real-Homebrew checks opt-in) passes locally and in `./tests/run.zsh --docker-ubuntu`
- [x] Opt-in real-Homebrew checks pass with `SHELL_CONFIG_TEST_REAL_BREW=1`
- [x] Read-only `brew-drift` against the dotfiles Brewfile works on this workstation
- [x] Merged ahead of extended dogfooding by decision; day-to-day use of
  `brew-add`, `brew-rm`, and `brew-sync` continues on `main` with forward fixes

## Branch and Merge Plan

- [x] Branch from `main` as `feat/m0008-curated-brew-module`
- [x] Commit freely at verified checkpoints
- [x] Squash merge when the exit criteria are met
