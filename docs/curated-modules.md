# Curated Modules

This document is the catalog and contract for curated modules in
`shell-config`.

Use it to answer:

- what each curated module owns
- when it should be enabled directly
- when it should be forked locally
- what host or tool assumptions it carries

Curated modules are the live default path.
Use `csm enable-module <name>` when you want the repo-owned module as-is.
Use `csm install-module <name>` only when you want a user-local fork.

For the lifecycle model behind that rule, see
[module-lifecycle.md](module-lifecycle.md).

## Module Catalog

| Module | Purpose | Requires | Host expectations | Recommended default |
| --- | --- | --- | --- | --- |
| `aws` | AWS profile, identity, login-mode, and login helpers | `aws` | Best on workstation-style hosts with AWS CLI configured; should work anywhere the AWS CLI is present | opt-in |
| `brew` | Declarative Homebrew: install, remove, drift, and sync against a git-tracked Brewfile | `brew` | Best on workstation hosts with Homebrew or Linuxbrew; set `HOMEBREW_BUNDLE_FILE` to your Brewfile | opt-in |
| `docker` | Docker aliases, context switching, and compact container inventory | `docker` | Best on hosts with a reachable Docker runtime; useful on Linux, WSL2, and macOS workstations | opt-in |
| `git` | Extra git helpers for primary branch, reframe, cleanup, and compact repo workflows | `git` | General-purpose and host-light; good across Linux, WSL2, macOS, and containers | fortress default |
| `kubectl` | Kubernetes aliases, context switching, and namespace helpers | `kubectl` | Best on workstation and cluster-admin hosts with kubeconfig access | opt-in |
| `pass` | Password-store aliases and small helper functions | `pass` | Best on personal workstation hosts with GPG/password-store already set up | opt-in |
| `television` | Television-backed picker helpers and git-branch channels | `tv` | Best on interactive workstation hosts; useful but still somewhat experimental | opt-in |
| `web_search` | Extra fortress `web_search` engines for GitHub, MDN, and Terraform docs | browser integration | Best on hosts with working browser-opening behavior | opt-in |

## Module Guides

Modules with more than a handful of helpers, or with workflows that can change
host state, ship a usage guide as `README.md` next to their `module.zsh`.
`csm describe-module <name>` prints its path on a `docs:` line, and
`csm docs <name>` renders it in the terminal. Small modules
stay documented by their catalog row and the fortress `USAGE.md`.

| Module | Guide |
| --- | --- |
| `brew` | [README.md](../zsh-tll-citadel-dev-fortress/curated-modules/brew/README.md) |

## Enable Versus Fork Guidance

### Enable Directly

Prefer `csm enable-module <name>` when:

- the repo-owned behavior already matches your intent
- the module only wraps an external CLI you already trust
- you want future curated improvements automatically
- you are still evaluating whether the module belongs in your everyday shell

Good direct-enable candidates:

- `git`
- `docker`
- `kubectl`
- `web_search`

> [!NOTE]
> `git` is now enabled by default in `zsh-tll-citadel-dev-fortress`. Use
> `csm disable-module git` only when you explicitly want to opt out of the
> default fortress git workflow layer.

### Fork Locally

Prefer `csm install-module <name>` when:

- you want to change aliases, defaults, or helper behavior
- you need host-specific or employer-specific customization
- you want to experiment without editing the curated module directly
- you are intentionally creating a user-owned override

Good fork candidates:

- `aws` with organization-specific login patterns
- `pass` with personal secret-store conventions
- `television` if you want different picker channels, keybindings, or previews

Brew specific note:

- shell-config ships no default Brewfile; a recommended Brewfile of the
  optional tools fortress benefits from belongs in dev-container-fortress, so
  shell-config stays usable on its own
- full setup and workflow guide:
  [curated-modules/brew/README.md](../zsh-tll-citadel-dev-fortress/curated-modules/brew/README.md)
- the module reads the Brewfile from `HOMEBREW_BUNDLE_FILE`, else Homebrew's
  own `--global` locations; it never hardcodes a personal path
- set `HOMEBREW_BUNDLE_FILE` in `shell-config.local` `env.zsh`, typically to a
  Brewfile tracked in a dotfiles repository
- point it at a whole-machine Brewfile, not a project-scoped dependency list:
  `brew-drift` and `brew-sync` treat everything outside it as undeclared
- seed a new machine Brewfile with `brew-dump > "$HOMEBREW_BUNDLE_FILE"`; it
  dumps formulae, casks, and taps by default, with `--with vscode,uv,winget`
  (or `--with all`) for extra ecosystems
- drift and sync removal only ever cover formulae, casks, and taps
- `brew-add`, `brew-rm`, and `brew-dump` have tab completion for package names
  and options
- `brew-sync` removes undeclared packages only after an explicit `y`, and that
  removal also resets Homebrew's global trust store to the Brewfile

AWS specific note:

- the curated `aws-login` helper defaults to normal browser login on native hosts
- inside a Dev Fortress workspace container, it defaults to device-code login
  because localhost callback OAuth is not guaranteed there
- use `aws-login --browser` when you explicitly want the browser flow

## Host Notes

### Linux and WSL2

Current strongest support surface:

- `git`
- `docker`
- `kubectl`
- `television`
- `web_search`

These have either been used directly in development or exercised through the
fortress operator workflows on Linux/WSL2.

### macOS

Expected strongest candidates once verified:

- `git`
- `docker`
- `kubectl`
- `web_search`

`television` should also work on macOS where `tv` is installed, but the module
should still be treated as an active validation target there rather than fully
proven.

### Containers and Minimal Hosts

Most curated modules are not meant to be universal defaults in minimal hosts or
container shells.
The main exceptions are:

- `git` when the CLI is present
- `docker` or `kubectl` only when those tools are intentionally installed

## Operator Rule

When a curated module starts accreting too many host-specific exceptions, prefer
one of these outcomes:

- document the host expectation clearly
- keep it opt-in
- fork it locally
- split it into a narrower curated module

Do not hide host assumptions behind opaque runtime heuristics unless they are
well documented and easy to debug.
