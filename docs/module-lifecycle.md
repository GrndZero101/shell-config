# Module Lifecycle

This document captures the intended `csm` module model for `shell-config`.

## Goals

- curated modules should be usable directly without creating user-local copies
- local module files should represent explicit forks or user-owned modules
- enablement should be persistent regardless of whether a module is curated or local
- drift between curated modules and local forks should be visible and recoverable

## Desired Model

For any given module name:

- if the module is disabled, do not load it
- if the module is enabled and a local fork exists, load the local fork
- if the module is enabled and only a curated module exists, load the curated module directly
- if the module is enabled and neither source exists, warn clearly

This means curated modules are the normal path and local module files are deliberate overrides.

## Defaults

Curated modules can be either:

- default-on for a profile baseline
- opt-in

Examples:

- `git` is a good default-on curated module
- `television` is a good opt-in curated module

Default-on versus opt-in is separate from whether a module is curated or local.

## Command Semantics

### `csm enable-module <name>`

- persistently enable the module
- if only a curated module exists, use the curated module directly
- if a local fork exists, use the local fork
- do not create a local copy just to enable a curated module

### `csm disable-module <name>`

- persistently disable the module
- do not delete any local files

### `csm install-module <curated-name>`

- create a user-local fork from the curated module
- treat the new local copy as an explicit override
- start using the fork after install

### `csm remove-module <name>`

- remove the local module file and matching local function files
- if the module remains enabled and a curated source exists, startup should fall back to curated
- if no curated source exists, the module becomes absent until re-created

### `csm sync-curated-modules`

- reset all local forks that originated from curated modules
- do nothing for modules that do not have local forks
- confirm before overwriting local files
- support `--force` for agentic or scripted use

Potential future companion:

- `csm sync-module <name>`

## Visibility Requirements

`csm list-modules` and `csm describe-module` should make the active source easy to understand.

Useful state labels include:

- `curated`
- `local-fork`
- `local-only`
- `enabled`
- `disabled`
- `shadowing curated`

At minimum, the module views should answer:

- is this module available as curated?
- does a local fork exist?
- which source will startup actually load?
- is the module enabled?

## Why This Model

This avoids accidental point-in-time freezes of curated module behavior.

Bad outcome:

- install curated module once
- forget local copy exists
- keep using a stale fork without realizing it

Desired outcome:

- enabling curated modules stays live by default
- local installs are explicit forks
- syncing or resetting forks is an intentional operator action
