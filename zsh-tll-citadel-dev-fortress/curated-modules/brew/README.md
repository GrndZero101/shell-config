# 🍺 brew module

Treat a git-tracked Brewfile as the source of truth for what Homebrew installs on this machine. Installs and removals go through the module, so the Brewfile never drifts from the host.

> [!NOTE]
> The module is opt-in and only loads when `brew` is on `PATH`.
> Read this guide in the terminal with `csm docs brew`.
> It works with Homebrew on macOS and Linuxbrew on Linux and WSL2.

> [!NOTE]
> shell-config deliberately ships no default Brewfile; the module manages
> whichever Brewfile you point it at. A recommended Brewfile of the optional
> tools fortress uses for the best experience belongs in the
> [dev-container-fortress](https://github.com/GrndZero101/dev-container-fortress)
> project, so shell-config stays usable on its own.

## Quick start

> [!IMPORTANT]
> Use a Brewfile that describes the **whole machine**. A project-scoped Brewfile,
> such as a dependency list for one tool, makes every other package look undeclared,
> and answering `y` in `brew-sync` would offer to uninstall them.

1. Pick where the machine Brewfile lives, ideally in a dotfiles repository, and point the module at it in `${XDG_CONFIG_HOME:-$HOME/.config}/shell-config.local/zsh-tll-citadel-dev-fortress/env.zsh`:

   ```zsh
   export HOMEBREW_BUNDLE_FILE="$HOME/path/to/dotfiles/brew/Brewfile"
   ```

2. Enable the module and reload the shell so its functions and tab completion load:

   ```zsh
   csm enable-module brew
   exec zsh -l
   ```

3. Seed the Brewfile from what is installed now, then review and trim it:

   ```zsh
   mkdir -p "${HOMEBREW_BUNDLE_FILE:h}"
   brew-dump > "$HOMEBREW_BUNDLE_FILE"
   brew-edit
   ```

4. Confirm the host and the Brewfile agree, then commit the Brewfile:

   ```zsh
   brew-drift
   ```

`fortress-hud` should now show `[tools] brewfile:` with your path.

## Daily workflow

| I want to… | Run |
| --- | --- |
| install something and keep it | `brew-add ripgrep` (or `bra`) |
| install a GUI app | `brew-add --cask firefox` |
| install from a third-party tap | `brew-add owner/tap/formula` (declares the tap too) |
| remove something for good | `brew-rm ripgrep` (or `brr`) |
| drop a declaration for something already gone | `brew-rm ripgrep` (skips the uninstall when it is not installed) |
| see what drifted | `brew-drift` (or `brd`) |
| bring the machine in line and upgrade | `brew-sync` (or `brs`), `brew-sync --greedy` for auto-updating casks |
| edit the Brewfile by hand | `brew-edit` (or `bre`) |
| check which Brewfile is active | `brew-file` (or `brf`) |
| snapshot the machine | `brew-dump`, or `brew-dump --write` to replace the Brewfile |

> [!TIP]
> Plain `brew install` still works, but it skips the Brewfile. `brew-drift` lists
> anything installed that way, and `brew-add <name>` declares it afterwards.
> Homebrew skips the install for a current package but upgrades an outdated one.

## Tab completion

| Type | Tab offers |
| --- | --- |
| `brew-add rip<Tab>` | every matching formula from Homebrew's local name list |
| `brew-add --cask fire<Tab>` | matching casks |
| `brew-rm <Tab>` | only names declared in your Brewfile (`--cask` for casks) |
| `brew-dump --with=<Tab>` | ecosystems, comma-separated: `--with=vscode,uv` |

Names already on the command line are not offered again, and the aliases `bra` and `brr` complete the same way.

## What can remove packages

The module never removes anything silently.

| Command | Removes | Guard |
| --- | --- | --- |
| `brew-rm <name>` | the named package and its Brewfile entry, then orphaned dependencies via `brew autoremove` | you named it |
| `brew-sync` | undeclared formulae, casks, and taps | an explicit `y` at the prompt; no terminal or any other answer keeps them |

> [!WARNING]
> Confirming removal in `brew-sync` runs `brew bundle cleanup --force`, which also
> resets Homebrew's global trust store to the Brewfile's trust declarations.

`brew-drift` and the drift check in `brew-sync` are read-only. Homebrew 7 `brew bundle cleanup` has no dry-run flag, so the module runs it with stdin from `/dev/null`: it can only list, never remove.

## Other ecosystems

Homebrew 7 Brewfiles can also declare `vscode` extensions, `uv` tools, `winget` packages (WSL), `mas` apps (macOS), `go`, `cargo`, `npm`, `flatpak`, and `krew` entries.

- `brew-dump` leaves them out unless asked: `brew-dump --with vscode,uv` or `brew-dump --with all`.
- Types a host cannot use dump nothing rather than failing (verified for `mas` and `flatpak` on WSL2), so `--with all` is safe to try.
- If you declare them, `brew-sync` installs them through `brew bundle install`. On WSL, `winget` entries install Windows applications.
- Drift reports and removal stay limited to formulae, casks, and taps, so the module never uninstalls an editor extension or a Windows app.

## How the Brewfile is found

`brew-file` uses the first match:

1. `HOMEBREW_BUNDLE_FILE`, with no fallback if it points at a missing file
2. `HOMEBREW_BUNDLE_FILE_GLOBAL`
3. `${XDG_CONFIG_HOME}/homebrew/Brewfile`
4. `~/.homebrew/Brewfile`
5. `~/.Brewfile`

The module also sets `HOMEBREW_NO_ANALYTICS=1`, `HOMEBREW_NO_ENV_HINTS=1`, and `HOMEBREW_AUTO_UPDATE_SECS=86400`, but only when you have not set them yourself.

## Brewfile editing rules

- Edits go through Homebrew's own `brew bundle add`, `remove`, and `list`, so entry options, trailing comments, blank lines, and symlinked Brewfiles are preserved.
- `brew-add` checks existing declarations first, because `brew bundle add` itself appends duplicates.
- `brew-rm` removes the description comment Homebrew writes above an entry, but only when it matches exactly and sits directly above it, so your own comments stay.
- `brew-dump --write` replaces the whole file and drops hand-written comments; prefer `brew-dump > file` plus a review when you curate comments.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| `brew-*` commands are missing | `csm describe-module brew` should say `enabled`; then `exec zsh -l` |
| `[tools] brewfile: module-disabled` | the module is not enabled for this profile |
| `[tools] brewfile: missing HOMEBREW_BUNDLE_FILE=…` | the path is wrong or the file does not exist yet; seed it with `brew-dump` |
| `brew-drift` lists dozens of packages | the Brewfile is incomplete or project-scoped; see Quick start |
| Tab completion does nothing | open a fresh shell after enabling; completions register when the module loads |
| a removed entry left a comment behind | the comment was hand-written or Homebrew's description changed; delete it with `brew-edit` |

For deeper startup or module issues, start with `fortress-hud`, `fortress-debug-interactive` (see its `== Homebrew ==` section), and `csm describe-module brew`.

## Customizing

Fork the module when you want different defaults or extra helpers:

```zsh
csm install-module --enable brew
```

The fork lives under `shell-config.local` and shadows the curated version; `csm sync-curated-modules` resets it. See [module-lifecycle.md](../../../docs/module-lifecycle.md).
