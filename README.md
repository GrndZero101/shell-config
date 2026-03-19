# Shell Config

> [!NOTE]
> * 20260313: This is in early development, consider it ALPHA.
> * Built with AI Assistance

## Overview

Repository with different atomic zsh configurations.

See [`USAGE.md`](/home/timl/projects/tboss/shell-config/USAGE.md) for practical usage notes, line editor modes, and terminal hotkey guidance across Linux and macOS.

Each profile is self-contained after startup selects its `ZDOTDIR`.
The shared layer is intentionally tiny:
the root [`.zshenv`](/home/timl/projects/tboss/shell-config/.zshenv) resolves the active profile directory and sources a minimal shared [`path.zsh`](/home/timl/projects/tboss/shell-config/shared/path.zsh) for common executable discovery, while completion-capable profiles may opt into [`shared/completions`](/home/timl/projects/tboss/shell-config/shared/completions) for repo-owned command completion only.

| ZDOTDIR Directory            | Description                                                            |
| ---------------------------- | ---------------------------------------------------------------------- |
| zsh-ref-atuin               | Minimal reference implementation of Atuin history integration          |
| zsh-ref-fzftab              | Minimal reference implementation of official `fzf-tab` integration     |
| zsh-zero                     | Zero additional configuration zsh setup                                |
| zsh-clean                    | Zsh configuration using no additional plugins. Completely native `zsh` with XDG state and Homebrew-aware completion discovery |
| zsh-tll-citadel-dev-fortress | Developer shell with switchable `oh-my-posh` / `starship` / native prompt paths, Catppuccin Mocha theming for rich prompt engines and `eza`, stronger repo ergonomics, tool-aware alias completion, Homebrew-aware completion discovery, and a small `zinit` plugin layer |

## Profile Selection

Set `SHELL_CONFIG_PROFILE` before launching `zsh`.

```shell
export SHELL_CONFIG_PROFILE=zsh-zero
zsh
```

Available values:

1. `zsh-zero`
2. `zsh-clean`
3. `zsh-ref-atuin`
4. `zsh-ref-fzftab`
5. `zsh-tll-citadel-dev-fortress`

If `SHELL_CONFIG_PROFILE` is unset, the selector checks `${XDG_CONFIG_HOME:-$HOME/.config}/shell-config/active-profile`.
If neither produces a valid profile, the selector falls back to `zsh-clean`.

## Bootstrap

For a default XDG install, you can use the one-shot installer:

```shell
curl -fsSL https://raw.githubusercontent.com/GrndZero101/shell-config/main/install.sh | zsh
```

This clones the repo into `${XDG_CONFIG_HOME:-$HOME/.config}/shell-config` and then runs `csm bootstrap`.

> [!NOTE]
> Override the default install target with `SHELL_CONFIG_INSTALL_DIR`, for example:
> `curl -fsSL https://raw.githubusercontent.com/GrndZero101/shell-config/main/install.sh | SHELL_CONFIG_INSTALL_DIR="$HOME/.config/custom-shell-config" zsh`

> [!TIP]
> To test a feature branch, override the clone branch:
> `curl -fsSL https://raw.githubusercontent.com/GrndZero101/shell-config/main/install.sh | SHELL_CONFIG_BRANCH="feature/my-branch" zsh`
>
> Or pass installer flags directly to `zsh`:
> `curl -fsSL https://raw.githubusercontent.com/GrndZero101/shell-config/main/install.sh | zsh -s -- --branch feature/my-branch`

If you prefer a manual clone-first workflow, the existing assumption still works:
the repository has already been cloned into its final install location, for example `$HOME/.config/shell-config`.

Manual install flow:

```shell
git clone https://github.com/GrndZero101/shell-config.git "${XDG_CONFIG_HOME:-$HOME/.config}/shell-config"
"${XDG_CONFIG_HOME:-$HOME/.config}/shell-config/scripts/csm" bootstrap
```

For a feature branch:

```shell
git clone --branch feature/my-branch https://github.com/GrndZero101/shell-config.git \
  "${XDG_CONFIG_HOME:-$HOME/.config}/shell-config"
"${XDG_CONFIG_HOME:-$HOME/.config}/shell-config/scripts/csm" bootstrap
```

For a private-repo test using SSH:

```shell
git clone git@github.com:GrndZero101/shell-config.git "${XDG_CONFIG_HOME:-$HOME/.config}/shell-config"
"${XDG_CONFIG_HOME:-$HOME/.config}/shell-config/scripts/csm" bootstrap
```

Use the config shell manager:

```shell
./scripts/csm
```

Install the root `~/.zshenv` selector and `csm` command symlinks with:

```shell
./scripts/csm bootstrap
```

The `bootstrap` command:

1. Detects the repository root from the script location
2. Verifies that the selector [`.zshenv`](/home/timl/projects/tboss/shell-config/.zshenv) exists
3. Backs up any existing `~/.zshenv` and `~/.local/bin/csm`
4. Creates `~/.zshenv` as a symlink to the repository selector
5. Creates `~/.local/bin/csm` as a symlink to [`scripts/csm`](/home/timl/projects/tboss/shell-config/scripts/csm)
6. Warns if `~/.local/bin` is not currently on `PATH`

After bootstrapping, choose a profile with `SHELL_CONFIG_PROFILE`, use `zsh-profile-select` from compatible profiles, or let it default to `zsh-clean`.

After a successful bootstrap, `csm` should be directly available if `~/.local/bin` is on your `PATH`.

Install the fortress plugin manager with:

```shell
csm install-zinit
```

This installs `zinit` into the fortress profile-local data directory so plugin management stays explicit and atomic to that profile.

Install the official `fzf-tab` clone used by the reference profile with:

```shell
csm install-fzf-tab
```

Use the Atuin reference profile with:

```shell
csm select zsh-ref-atuin
```

When `atuin` is installed, that profile keeps the shell intentionally small so `Ctrl-R` and Up-arrow history behavior are easier to compare with other profiles.
It also supports opt-in comparison toggles for `fzf-tab` and `zoxide` via environment variables documented in its [`USAGE.md`](/home/timl/projects/tboss/shell-config/zsh-ref-atuin/USAGE.md).

## Atomic Profiles

Each profile directory owns its own startup files and runtime behavior.
There is no shared sourcing between profiles.

Allowed carve-outs:
[`shared/path.zsh`](/home/timl/projects/tboss/shell-config/shared/path.zsh) is shared across profiles for common `PATH` entries only.
It is intentionally limited to machine-level executable discovery such as `~/.local/bin`, `~/bin`, and common Homebrew locations.

[`shared/completions`](/home/timl/projects/tboss/shell-config/shared/completions) is the narrow shared home for repo-owned completion functions such as `_csm`.
It exists to avoid duplicating command completion across multiple profiles, and it should not be used for general shell behavior or third-party tool completions.

Profile structure and storage conventions are documented in [`docs/profile-contract.md`](/home/timl/projects/tboss/shell-config/docs/profile-contract.md).
This includes `profile.zsh`, `USAGE.md`, `DESIGN.md`, XDG-aligned state/cache/runtime directories, and the optional shared-history policy.

## Interactive Profile Switching

`zsh-clean` provides an autoloaded `zsh-profile-select` function.

- If `fzf` is installed, it uses `fzf`
- If `fzf` is not installed, it falls back to native zsh `select`
- The chosen profile is saved in `${XDG_CONFIG_HOME:-$HOME/.config}/shell-config/active-profile`
- The function supports two switch modes:
  normal mode keeps the convenient inherited environment
  clean mode re-enters `zsh` with a curated minimal environment

This keeps the shared [`.zshenv`](/home/timl/projects/tboss/shell-config/.zshenv) non-interactive while still allowing ergonomic profile switching in interactive shells.

The same behavior is available from the manager command:

```shell
csm select
```

This is useful in profiles such as `zsh-zero` where the autoloaded helper is intentionally absent.

You can also select a profile directly without opening the interactive picker:

```shell
csm select zsh-tll-citadel-dev-fortress
```

For stronger environment isolation, use clean mode:

```shell
csm select --clean
```

Direct selection also works with clean mode:

```shell
csm select --clean zsh-clean
```

The autoloaded helper also forwards arguments, so `zsh-profile-select --clean` works from `zsh-clean`.

## Profile Settings

Profiles that ship a settings template can initialize a user-owned settings file in XDG config with:

```shell
csm init-settings zsh-tll-citadel-dev-fortress
```

Open that file in your configured editor with:

```shell
csm edit-settings zsh-tll-citadel-dev-fortress
```

For fortress, this manages:

- `${XDG_CONFIG_HOME:-$HOME/.config}/shell-config.local/zsh-tll-citadel-dev-fortress/settings.zsh`

This keeps user preferences outside the repo checkout while still making login-time and container-startup behavior persistent.

## Command Completion

Profiles with native completion support also register completion for `csm`.
Right now that includes:

- `zsh-clean`
- `zsh-ref-atuin`
- `zsh-ref-fzftab`
- `zsh-tll-citadel-dev-fortress`

This gives you subcommand completion plus flags and values such as `select --clean`, direct profile completion for `csm select`, `init-settings`, `edit-settings`, `clear-history --all`, `sync-catppuccin`, and `describe-profile`.
The completion definition itself lives once in [`shared/completions/_csm`](/home/timl/projects/tboss/shell-config/shared/completions/_csm).

## Cleanup

Remove generated cache files with:

```shell
csm clean
```

Right now this removes generated completion artifacts such as `.zcompdump`, `.zcompdump-*`, `.zcompcache`, and `.zwc` files inside profile directories.

## Validation

Run a lightweight repository validation with:

```shell
csm check
```

This checks:

- required root and profile files exist
- `profile.zsh` contract values are valid
- profile contract names are unique
- zsh syntax passes for shared files, startup files, and profile functions

For `fzf-tab` troubleshooting across hosts or terminals, print a focused debug report with:

```shell
csm debug-fzf-tab
```

This reports the active profile, `zsh` and `fzf` versions, `TERM`, the current `Tab` widget binding, completion-related zstyles, and the presence of global `/etc/zsh*` files so you can compare environments like macOS and WSL2 side by side.

Inside the fortress profile, you can also print a shell-local HUD with:

```shell
fortress-hud
fortress-hud --pretty
fortress-hud --env
fortress-hud --pretty --env
```

Standard mode is line-oriented for debugging and copy/paste into issues or AI-assisted troubleshooting.
Pretty mode renders the same resolved data with Catppuccin-tinted headings and Nerd Font icons.
The optional `--env` mode adds exact environment-variable names, persistent settings-variable names, raw values, resolved values, and source attribution.

## History

Clear history for the current profile with:

```shell
csm clear-history
```

Clear history for all profiles with:

```shell
csm clear-history --all
```

The default mode is conservative.
If `csm` cannot confidently determine the current active profile from `ZDOTDIR` or `SHELL_CONFIG_PROFILE`, it stops instead of clearing the wrong history file.
If a profile opts into shared history, clearing the current profile clears that shared history file because it is the active history backend for that profile.

## Theme Sync

Refresh vendored Catppuccin assets with:

```shell
csm sync-catppuccin
```

Right now this refreshes the fortress `eza` theme from its pinned upstream source into:

- [`zsh-tll-citadel-dev-fortress/config/eza/theme.yml`](/home/timl/projects/tboss/shell-config/zsh-tll-citadel-dev-fortress/config/eza/theme.yml)
- [`zsh-tll-citadel-dev-fortress/config/atuin/themes/catppuccin-mocha-mauve.toml`](/home/timl/projects/tboss/shell-config/zsh-tll-citadel-dev-fortress/config/atuin/themes/catppuccin-mocha-mauve.toml)

This is an explicit maintenance step, not a shell-startup dependency.

## Plugin Manager

zinit (https://github.com/zdharma-continuum/zinit)

## Plugins

### OMZ Built In

1. aws
2. git
3. colored-man-pages
4. fzf
5. pass
6. sudo
7. web-search

Fortress currently uses OMZ `git`, `sudo`, `web-search`, and `colored-man-pages` through `zinit`, and it also enables OMZ `aws` plus OMZ `pass` completion when those commands are installed locally.
Its extra fortress-native git helper and alias layer is opt-in via `SHELL_FORTRESS_ENABLE_NATIVE_GIT=1`.
Fortress can also switch between native vi mode and `zsh-vi-mode`, plus native completion, `fzf-tab`, and `zsh-autocomplete`, via persistent profile settings with environment-variable overrides for one-off sessions.

    Add the following envionment variable to allow ServiceNow searching

    ```shell
    ZSH_WEB_SEARCH_ENGINES=(
        snow "https://instance.service-now.com/nav_to.do?uri=task.do?sysparm_query=number="
    )
    ```

### OMZ Custom plugins

1. fzf-tab
2. zsh-autocomplete
3. zsh-autosuggestions
4. zsh-syntax-highlighting
5. zsh-vi-mode

Fortress now defaults to `jeffreytse/zsh-vi-mode`.
Set `SHELL_FORTRESS_ENABLE_ZSH_VI_MODE=0` to fall back to native `bindkey -v` vi mode for a single session.
Set `SHELL_FORTRESS_ENABLE_ZSH_AUTOCOMPLETE=1` to enable `marlonrichert/zsh-autocomplete` for a single session.
Set `SHELL_FORTRESS_ENABLE_FZF_TAB=0` to disable `fzf-tab` when you want plain completion behavior for a single session.
Set `SHELL_FORTRESS_ENABLE_ZSH_AUTOSUGGESTIONS=0` to disable inline suggestions when `zinit` is available for a single session.
Set `SHELL_FORTRESS_ENABLE_ATUIN=0` to disable Atuin history integration for a single session.
When `SHELL_FORTRESS_ENABLE_ZSH_VI_MODE=1`, fortress skips `zsh-autocomplete` but still allows `fzf-tab`.
When `zsh-autocomplete` actually loads, fortress skips `fzf-tab` and lets `zsh-autocomplete` own completion.

> [!NOTE]
> The current default modal-editing path is `zsh-vi-mode`, with `fzf-tab` and Atuin enabled by default and `zsh-autosuggestions` still optional.
> `zsh-vi-mode` plus `zsh-autocomplete` is now treated as an experimental compatibility path rather than a default-supported combination.
> When Atuin is enabled alongside `zsh-vi-mode`, fortress follows Atuin's documented `zvm_after_init_commands` integration pattern.
> Fortress also vendors the official Catppuccin Mocha Atuin theme and exports both `ATUIN_CONFIG_DIR` and `ATUIN_THEME_DIR` to the profile-local Atuin config directory.
> In live-shell testing, this correctly activated the profile-local Atuin config even though `atuin info` still reported the default config path.

Fortress now also supports a persistent user settings file at `${XDG_CONFIG_HOME:-$HOME/.config}/shell-config.local/zsh-tll-citadel-dev-fortress/settings.zsh`.
That file is the preferred place to set default fortress toggles such as vi mode, `fzf-tab`, `zsh-autocomplete`, autosuggestions, Atuin, and native git so they apply on login or initial container shell startup without re-invoking `zsh`.
Use [`zsh-tll-citadel-dev-fortress/config/settings.example.zsh`](/home/timl/projects/tboss/shell-config/zsh-tll-citadel-dev-fortress/config/settings.example.zsh) as the template.
Use `csm init-settings zsh-tll-citadel-dev-fortress` to create it and `csm edit-settings zsh-tll-citadel-dev-fortress` to open it in your configured editor.

## Configuration

### History

### Autocompletion

### vi-mode

Use VI 

### Testing 123
