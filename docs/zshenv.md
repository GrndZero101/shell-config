# `.zshenv` Explained

This repository uses a single shared root [`.zshenv`](/home/timl/projects/tboss/shell-config/.zshenv) to select which atomic zsh profile should handle the rest of shell startup.
It also allows one tightly scoped shared exception for executable discovery via [`shared/path.zsh`](/home/timl/projects/tboss/shell-config/shared/path.zsh).

That file is intentionally small:

```zsh
# Select the active ZDOTDIR profile for this repository.
typeset -gr SHELL_CONFIG_ROOT="${${(%):-%N}:A:h}"
typeset -gr SHELL_CONFIG_STATE_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/shell-config"
typeset -gr SHELL_CONFIG_STATE_FILE="${SHELL_CONFIG_STATE_DIR}/active-profile"
typeset -gr SHELL_CONFIG_SHARED_PATH="${SHELL_CONFIG_ROOT}/shared/path.zsh"

if [[ -r "${SHELL_CONFIG_SHARED_PATH}" ]]; then
  source "${SHELL_CONFIG_SHARED_PATH}"
fi

if [[ -z "${SHELL_CONFIG_PROFILE:-}" && -r "${SHELL_CONFIG_STATE_FILE}" ]]; then
  read -r SHELL_CONFIG_PROFILE < "${SHELL_CONFIG_STATE_FILE}"
fi

: "${SHELL_CONFIG_PROFILE:=zsh-clean}"

case "${SHELL_CONFIG_PROFILE}" in
  zsh-zero|zsh-clean|zsh-ref-atuin|zsh-ref-fzftab|zsh-tll-citadel-dev-fortress)
    export ZDOTDIR="${SHELL_CONFIG_ROOT}/${SHELL_CONFIG_PROFILE}"
    ;;
  *)
    export ZDOTDIR="${SHELL_CONFIG_ROOT}/zsh-clean"
    ;;
esac
```

## Why This File Exists

`zsh` reads `.zshenv` first during startup.
That makes it the only safe place to decide which `ZDOTDIR` should be active for the rest of the shell session.

In this repository, that is the whole job of the shared `.zshenv`:

1. Find the repository root
2. Source the minimal shared `PATH` layer
3. Read the desired profile name
4. Export `ZDOTDIR` to that profile directory

After that, startup continues inside the selected profile.

## Design Principle

This repo uses atomic profiles.
That means `zsh-zero`, `zsh-clean`, `zsh-ref-atuin`, `zsh-ref-fzftab`, and `zsh-tll-citadel-dev-fortress` should each be understandable and operable on their own.

The root `.zshenv` is the only shared startup component because `zsh` needs one entry point before profile selection can happen.

So the boundary is:

- Shared: profile selection and minimal common executable discovery
- Profile-local: everything else

The shared `.zshenv` must not become a hidden config layer.

## Line-by-Line

### `typeset -gr SHELL_CONFIG_ROOT="${${(%):-%N}:A:h}"`

This computes the absolute directory containing the currently executing `.zshenv`.

Why it matters:

- It avoids hardcoding a path like `$HOME/.config/shell-config`
- It still works if `~/.zshenv` is a symlink to the repository selector
- It allows the repository to live in any install location

Breakdown:

- `${(%):-%N}` gets the current file name in zsh
- `:A` resolves it to an absolute path
- `:h` takes the directory name
- `typeset -gr` creates a global readonly parameter

The result is the repository root.

### `typeset -gr SHELL_CONFIG_SHARED_PATH=...`

This points to the only shared helper file currently allowed:

- [`shared/path.zsh`](/home/timl/projects/tboss/shell-config/shared/path.zsh)

That file exists to populate a conservative baseline `PATH` for all shells, including non-interactive shells.

### `if [[ -r "${SHELL_CONFIG_SHARED_PATH}" ]]; then`

This sources the shared path file only if it is readable.

That keeps the root selector tolerant of a missing file while making the shared carve-out explicit and easy to audit.

### `typeset -gr SHELL_CONFIG_STATE_DIR=...`

This defines where the last interactively selected profile is stored.

Default location:

- `${XDG_CONFIG_HOME:-$HOME/.config}/shell-config/active-profile`

### `if [[ -z "${SHELL_CONFIG_PROFILE:-}" && -r "${SHELL_CONFIG_STATE_FILE}" ]]; then`

This loads a saved profile only when the environment has not already selected one.

Selection priority is:

1. `SHELL_CONFIG_PROFILE` from the environment
2. saved `active-profile`
3. default fallback

### `: "${SHELL_CONFIG_PROFILE:=zsh-clean}"`

This sets a default profile if `SHELL_CONFIG_PROFILE` is still unset or empty.

Current default:

- `zsh-clean`

Why `zsh-clean` is the default:

- It is more useful than a bare shell
- It stays native and understandable
- It is a safer everyday baseline than a more complex profile

The `:` builtin is a common shell pattern for assigning defaults without producing output.

### `case "${SHELL_CONFIG_PROFILE}" in`

This validates the requested profile name before exporting `ZDOTDIR`.

Allowed values right now:

1. `zsh-zero`
2. `zsh-clean`
3. `zsh-ref-atuin`
4. `zsh-ref-fzftab`
5. `zsh-tll-citadel-dev-fortress`

If the value matches one of those, the selector points `ZDOTDIR` at that profile directory.

If it does not match, the selector falls back to `zsh-clean`.

That fallback helps avoid a broken shell startup caused by typos or stale environment values.

## What Happens After `ZDOTDIR` Is Set

Once `ZDOTDIR` points at a profile directory, zsh will continue startup from there.

In practice, that means profile-local files such as:

- `.zprofile`
- `.zshrc`
- `.zlogin`
- `.zlogout`

will be resolved from the selected profile directory instead of the default home directory location.

That is what makes the profiles atomic.

## What `.zshenv` Should Not Do

To keep the architecture clean, the root selector should stay minimal.

It should not:

- define aliases
- set interactive keybindings
- configure completion
- load plugins
- mutate prompts
- add tool-specific shell behavior
- source general shared helper files

Those things belong inside the selected profile.

If the shared `.zshenv` starts doing real runtime configuration, then the profiles are no longer truly atomic.

The one current exception is [`shared/path.zsh`](/home/timl/projects/tboss/shell-config/shared/path.zsh), which is restricted to common `PATH` entries only.

## How It Gets Installed

The manager command [`scripts/csm`](/home/timl/projects/tboss/shell-config/scripts/csm) installs `~/.zshenv` as a symlink to the repository root selector when run as `./scripts/csm bootstrap`.
That same bootstrap step also links `~/.local/bin/csm` to the repository manager command so profile management is easy to access from the command line.

That approach keeps the source of truth in the repo while still letting zsh discover `.zshenv` during normal startup.

## Example Flow

Assume:

- the repo is cloned at `$HOME/.config/shell-config`
- `~/.zshenv` is symlinked to the repo root `.zshenv`
- `SHELL_CONFIG_PROFILE=zsh-zero`

Startup flow:

1. `zsh` reads `~/.zshenv`
2. That symlink resolves to the repo root selector
3. The selector computes the repo root
4. The selector sets `ZDOTDIR` to `$HOME/.config/shell-config/zsh-zero`
5. `zsh` continues startup using files from the `zsh-zero` profile

If `SHELL_CONFIG_PROFILE` is unset, step 4 resolves from the saved `active-profile` file when present, or falls back to `zsh-clean`.

## Interactive Selection

The shared selector stays non-interactive by design.

Interactive switching belongs inside compatible profiles, not in the root `.zshenv`.
For example, [`zsh-clean/functions/zsh-profile-select`](/home/timl/projects/tboss/shell-config/zsh-clean/functions/zsh-profile-select) delegates to [`scripts/csm`](/home/timl/projects/tboss/shell-config/scripts/csm), which can:

1. discover available `zsh-*` profile directories
2. use `fzf` if available
3. fall back to native zsh `select` if `fzf` is missing
4. save the choice to `active-profile`
5. unset `ZDOTDIR`
6. `exec zsh`

That keeps normal shell startup silent and predictable while still supporting interactive switching.

## Operational Notes

- Keep this file fast because it runs on every shell startup
- Keep it deterministic because startup bugs here affect every profile
- Keep it tiny because complexity belongs in the profile directories
- Treat changes here as architecture changes, not just config tweaks
