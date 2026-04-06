# zsh-tll-citadel-dev-fortress Usage

`zsh-tll-citadel-dev-fortress` is the stronger native-first developer profile in this repository.
It adds richer completion, repo-awareness, a configurable rich prompt layer, and a small `zinit`-managed plugin layer while keeping the shell understandable.

> [!NOTE]
> This is the most feature-rich profile currently implemented.
> It can use `starship` or native zsh prompting.
> The default prompt-engine policy is `auto`: prefer `starship`, then native zsh fallback.
> It also supports a small fortress-only `zinit` plugin layer when `zinit` has been installed with `csm install-zinit`.
> Fortress maintenance should keep `fortress-hud` and `fortress-debug-interactive` aligned with any new or changed toggles, helpers, tools, startup wiring, or runtime paths.

## Identity

- Profile directory: `zsh-tll-citadel-dev-fortress`
- Intended user: someone living in repositories and terminal workflows all day
- Design goal: stronger developer ergonomics without collapsing into an opaque shell stack

## Host Expectations

This profile is strongest today on:

- Linux
- WSL2

It is expected to work on macOS, but that support is still less proven on a
real host than the Linux and WSL2 path.

Recommended first-use order on a new host:

1. Start with `zsh-clean`
2. Confirm bootstrap, profile selection, and basic line editing
3. Move to `zsh-tll-citadel-dev-fortress`
4. Only then enable host-sensitive optional modules such as `television`, `docker`, `kubectl`, or `web_search`

Use the shared platform support guide for the current truth source:

- [docs/platform-support.md](/home/timl/projects/tboss/shell-config/docs/platform-support.md)

## Editing Mode

- Default line editor mode: `jeffreytse/zsh-vi-mode`
- Native fallback mode: `bindkey -v` when `SHELL_FORTRESS_ENABLE_ZSH_VI_MODE=0`
- How to enter command mode: press `Esc`
- How to return to insert mode: press `i`, `a`, `A`, `o`, or start a new prompt

> [!NOTE]
> The verified and default modal-editing path in fortress is `zsh-vi-mode` with `fzf-tab` and Atuin enabled by default and `zsh-autosuggestions` remaining optional.
> `zsh-vi-mode` plus `zsh-autocomplete` is available as an experimental compatibility path and is not treated as equally stable as the other verified combinations.
> In that compat path, fortress biases `Tab` toward menu selection and uses autocomplete's history-search context by default.

## Hotkeys

| Key             | Behavior                                  | Notes                            |
| --------------- | ----------------------------------------- | -------------------------------- |
| `Ctrl-A`        | beginning of line                         | explicitly bound                 |
| `Ctrl-E`        | end of line                               | explicitly bound                 |
| `Ctrl-P`        | previous history entry by prefix          | works well after typing a prefix |
| `Ctrl-N`        | next history entry by prefix              | works well after typing a prefix |
| `Ctrl-R`        | incremental backward history search       | native zsh search                |
| `Tab`           | completion insert or selection movement   | handled by native completion, `fzf-tab`, or `zsh-autocomplete` depending on env toggles |
| `Ctrl-T`        | insert a selected file path with `fzf`    | only when `fzf` is installed     |
| `Alt-C`         | fuzzy-select a directory and `cd` into it | only when `fzf` is installed     |
| `Ctrl-X Ctrl-R` | fuzzy-select a history entry              | only when `fzf` is installed     |
| `Ctrl-G h`      | run `fortress-keybinds`                   | instant keybind cheat sheet; requires an empty command line |
| `Ctrl-G c`      | insert `csm ` into the command line       | fortress operator prefix; safe to use mid-edit |
| `Ctrl-G ?`      | run `csm`                                 | requires an empty command line to avoid clobbering typed input |
| `Ctrl-G p`      | run `csm select -i`                       | requires an empty command line to avoid clobbering typed input |
| `Ctrl-G a`      | run `alias-list -i`                       | requires an empty command line to avoid clobbering typed input |
| `Ctrl-G f`      | insert `alias-find ` into the command line | fortress operator prefix; type a query after the chord |
| `Ctrl-G u`      | run `fortress-hud --pretty`               | fast runtime overview; requires an empty command line |
| `Ctrl-G d`      | run `fortress-debug-interactive`          | fast widget and keybind debug view; requires an empty command line |
| `vv`            | edit the current command line in `$EDITOR` | only when `SHELL_FORTRESS_ENABLE_ZSH_VI_MODE=1` |
| `gx`            | open the URL or file path under cursor    | only when `SHELL_FORTRESS_ENABLE_ZSH_VI_MODE=1` |
| `Esc Esc`       | prepend `sudo` to the current command line | provided by the fortress native `sudo-command-line` widget |
| `web_search`    | open a search query in your browser        | provided by the fortress native web-search helper |
| Up arrow        | previous history entry by prefix          | `^[[A` and `^[OA` are bound      |
| Down arrow      | next history entry by prefix              | `^[[B` and `^[OB` are bound      |
| `Home`          | beginning of line                         | `^[[H` bound                     |
| `End`           | end of line                               | `^[[F` bound                     |

> [!TIP]
> Aliases such as `ls`, `ll`, `tree`, `cat`, `grep`, `find`, and the git shorthand aliases keep command-aware completion wired to their underlying tools when those tools are installed.

> [!TIP]
> Fortress supports multi-key zle chords. The current operator namespace uses `Ctrl-G` as a compact prefix for high-signal shell-management actions.

Fortress also supports user-local extensions under `${XDG_CONFIG_HOME:-$HOME/.config}/shell-config.local/zsh-tll-citadel-dev-fortress` for:

- `env.zsh` for user-owned exports and startup variables
- `aliases.zsh` for personal aliases that should win over profile defaults
- `functions/` for personal autoload functions
- `modules/` for optional tool-specific local modules

## History

- History mode: profile
- History file location: `${XDG_STATE_HOME:-$HOME/.local/state}/shell-config/zsh-tll-citadel-dev-fortress/history`
- Prefix search behavior: Up/Down arrows and `Ctrl-P` / `Ctrl-N` use prefix-search widgets in insert mode
- Incremental search behavior: `Ctrl-R` uses `history-incremental-search-backward`

## Prompt

- Prompt style: configurable prompt engine with `auto`, `starship`, and `native` modes; `auto` prefers `starship`, then native zsh fallback
- Prompt layout: fortress prefers a two-line layout with always-on path and prompt status, while git appears in repositories and AWS, Docker, Kubernetes, and Python segments appear only when active in richer prompt engines
- Git or repo context: yes, via the selected prompt engine when available and via `vcs_info` plus upstream ahead/behind counts in native fallback mode

## Helpers

### Navigation

| Function | Purpose |
| --- | --- |
| `cd` | handled by `zoxide` when it is installed |
| `mkcd` | create a directory and `cd` into it |
| `take` | same convenience behavior as `mkcd` |
| `up` | move up one or more directories |
| `croot` | `cd` to the current repository root |
| `gcd` | jump to the current git repository root |
| `repo-find` | list repos discovered under common project roots |
| `rcd` | fuzzy-select a repo and `cd` into it |
| `gwtcd` | fuzzy-select a worktree and `cd` into it |

### Git

> [!NOTE]
> Fortress-native git helpers are now the default path.
> Set `SHELL_FORTRESS_ENABLE_NATIVE_GIT=0` only when you want to trim the extra git helper layer back to the minimal built-in aliases.

| Function | Purpose |
| --- | --- |
| `git-root` | print the current repository root |
| `git-current-branch` | print the current branch name |
| `gst` | concise git status with branch information |
| `glg` | graph-style one-line git log |
| `gwt` | list git worktrees |
| `gdone` | delete a branch that is already merged into the primary branch, auto-detect the paired temp branch when possible, and confirm before cleanup |
| `greframe-start` | create a timestamped temporary reframe branch from the primary branch and merge the current branch into it |
| `greframe-finish` | create the final PR branch from the primary branch and squash the temp branch into it |
| `greframe-rollback` | abandon a temporary reframe branch without touching the original source branch |
| `tv-git-branches-manage` | television-powered branch manager with fortress-owned channels, previews, and source cycling |
| `tv-git-branches-cleanup` | television-powered cleanup picker backed by a fortress-owned cleanup channel |
| `gcof` | fuzzy-select a branch and check it out |
| `gbdf` | fuzzy-select local branches to delete safely |
| `gstashf` | fuzzy-select a stash and inspect it |
| `gshowf` | fuzzy-select a commit and inspect it |

`greframe` workflow:

```zsh
greframe-start feat/bootstrap-onboarding
# keep working on feat/bootstrap-onboarding--wip-YYYYMMDD-HHMM
greframe-finish feat/bootstrap-onboarding --message "feat(bootstrap): add installer and harden onboarding workflow"
```

Use `greframe-rollback` while checked out on the temp branch when you want to
discard the reframe branch and keep the original source branch intact.

Post-merge cleanup:

```zsh
gdone feat/m0003a-installer-onramp
```

If a matching temp branch such as
`feat/m0003a-installer-onramp--wip-YYYYMMDD-HHMM` exists, `gdone` detects it
automatically and offers to remove it in the same pass.

Explicit temp-branch cleanup:

```zsh
gdone feat/m0003a-installer-onramp --temp feat/m0003a-installer-onramp--wip-YYYYMMDD-HHMM
```

Use `--force` for non-interactive or agentic cleanup. Use `--keep-remote` when
you only want to delete local branches and keep any matching remote branches.

Television cleanup picker:

```zsh
tv-git-branches-cleanup
```

This picker now runs through a fortress-owned Television channel and lists
actionable local branches only:

- `merged` branches route through `gdone`
- `temp` branches route through `greframe-rollback`
- `squash` branches are treated as squash-equivalent to the primary branch and are dropped with `git branch -D`
- preview content comes from the repo-owned Television cable instead of inline shell strings

Use `Tab` inside Television to multi-select several cleanup candidates before
pressing `Enter`. Use `--keep-remote` to preserve any matching `origin/*`
branches. Use `--force` for non-interactive or agentic runs, for example:

```zsh
tv-git-branches-cleanup --force -- --input 'wip' --take-1
```

Television branch manager:

```zsh
tv-git-branches-manage
```

This broader manager now uses a fortress-owned Television config and cable set.
It gives you:

- a real Television branch-management channel rather than a one-off inline picker
- `ctrl-s` source cycling between all branches and cleanup candidates
- repo-owned preview content for branch state, cleanup classification, and recent history
- one restrained Television-native cleanup action without overloading the keymap
- the same deterministic `--action` path for agentic and scripted use

After selection, fortress still applies the actual action safely:

- `checkout` switches to a selected branch
- `delete` runs a safe `git branch -d`
- `force-delete` runs `git branch -D`
- `cleanup` routes cleanup-safe branches through the stronger fortress logic

Useful in-channel key:

- `ctrl-k` cleanup

The more destructive or ambiguous actions such as `delete` and `force-delete`
stay in the wrapper/operator flow instead of competing with Television's native
keybindings.

Use `--delete-remote` when you also want to remove matching `origin/*` branches
for delete or cleanup actions. For deterministic or agentic runs, provide the
action up front:

```zsh
tv-git-branches-manage --action delete --delete-remote --force -- --input 'feature/' --take-1
tv-git-branches-manage --action checkout --force -- --input 'main' --take-1
```

> [!NOTE]
> Fortress now registers the Television helper autoloads even when `tv` becomes
> available later in startup. If the binary is still missing when you invoke a
> helper, the wrapper prints a clear `tv is not installed or not yet on PATH`
> message instead of disappearing from the shell entirely.
>
> Fortress also ships a repo-owned Television `config.toml` and custom cable
> channels for the git branch flows, so the picker layout, source cycling, and
> preview behavior stay consistent across environments instead of living only in
> wrapper CLI flags.

### Fuzzy Workflows

| Function | Purpose |
| --- | --- |
| `ff` | fuzzy-select and print a file path |
| `fcd` | fuzzy-select a directory and `cd` into it |
| `fh` | fuzzy-select a history entry |
| `vf` | fuzzy-select a file and open it in `$VISUAL` / `$EDITOR` |

### Shell Management

| Function | Purpose |
| --- | --- |
| `alias-list` | print the live alias table for the current shell, with optional interactive selection |
| `alias-find` | search the live alias table by alias name or expansion text |
| `zsh-profile-select` | open the interactive profile selector via `csm` |
| `fortress-keybinds` | print the fortress keybinding cheat sheet |
| `fortress-hud` | print a profile HUD with resolved settings, feature state, tools, runtime wiring, key paths, and optional env-variable mapping details |
| `fortress-debug-interactive` | print live widget and keybinding state for troubleshooting `Tab`, `fzf-tab`, `zsh-vi-mode`, and autosuggestion behavior |
| `web_search` | search the web through fortress-managed search engines |

## Troubleshooting

When startup, module, helper, or keybinding behavior looks wrong, prefer the
fortress debugging surfaces before manual shell spelunking:

```zsh
fortress-hud
fortress-debug-interactive
csm list-modules
csm describe-module television
```

Recommended first-response flow:

- `fortress-hud` to confirm tool detection, enabled local modules, module resolution, paths, and runtime state
- `fortress-debug-interactive` to inspect keybindings, widgets, and interactive shell wiring
- `csm list-modules` to see curated versus local module state at a glance
- `csm describe-module <name>` to check whether a user-local override is shadowing a curated module

> [!TIP]
> If a helper exists in the repository but not in your live shell, check module
> shadowing before assuming the helper implementation is broken. A user-local
> module under `${XDG_CONFIG_HOME:-$HOME/.config}/shell-config.local/.../modules`
> takes precedence over the repo-curated module of the same name.

### Default Aliases

When the backing tools are installed, fortress provides a small baseline alias set:

| Alias | Purpose |
| --- | --- |
| `ls` | `eza --group-directories-first --icons=auto` |
| `ll` | `eza -lag --group-directories-first --icons=auto --header --git` |
| `tree` | `eza --tree --icons=auto` |
| `cat` | `bat --paging=never` |
| `grep` | `rg` |
| `find` | `fd` |
| `ga` | `git add` |
| `gc` | `git commit` |
| `gd` | `git diff` |
| `gs` | `git status` |
| `gsw` | `git switch` |

### Alias Discovery

Use the live alias helpers when you want to inspect or search the current shell state:

```zsh
alias-list
alias-find git
alias-find -i git
alias-list -i
```

`alias-list` and `alias-find` inspect the aliases that are actually active in the current shell, so they naturally reflect fortress defaults, enabled modules, and user-local overrides from `aliases.zsh`.
They also show a `source` column so you can quickly see whether an alias came from the fortress core, a module, or user-local overrides.

## Aliases

### File and Search

| Alias | Expands to | Notes |
| --- | --- | --- |
| `ls` | `eza --group-directories-first --icons=auto` | uses a profile-local Catppuccin Mocha `theme.yml` when `eza` is installed |
| `ll` | `eza -lag --group-directories-first --icons=auto --header --git` or `ls -lah` | richer long view with header row and git status; falls back to `ls -lah` when `eza` is missing |
| `tree` | `eza --tree --icons=auto` | uses the same Catppuccin Mocha `eza` theme |
| `cat` | `bat --paging=never` | only when `bat` is installed |
| `grep` | `rg` | only when `rg` is installed |
| `find` | `fd` | only when `fd` is installed |
| `jqp` | `jq .` | only when `jq` is installed |

### Git

> [!NOTE]
> These aliases are part of the fortress-native git layer and are enabled by default.
> Set `SHELL_FORTRESS_ENABLE_NATIVE_GIT=0` if you want to fall back to the smaller always-on git alias set.

| Alias | Expands to | Notes |
| --- | --- | --- |
| `g` | `git` | short git entrypoint |
| `ga` | `git add` | |
| `gb` | `git branch` | |
| `gc` | `git commit` | |
| `gca` | `git commit --amend` | |
| `gcam` | `git commit -am` | |
| `gco` | `git checkout` | |
| `gd` | `git diff` | |
| `gds` | `git diff --staged` | |
| `gf` | `git fetch` | |
| `gl` | `git pull` | |
| `gp` | `git push` | |
| `gpf` | `git push --force-with-lease` | safer force-push default |
| `gr` | `git rebase` | |
| `gs` | `git status --short --branch` | concise repo view |
| `gsw` | `git switch` | |
| `gwtl` | `git worktree list` | |

## External Tools

| Tool     | How it is used                                                       |
| -------- | -------------------------------------------------------------------- |
| `eza`    | richer directory listing and tree output with a vendored Catppuccin Mocha theme in [`config/eza/theme.yml`](/home/timl/projects/tboss/shell-config/zsh-tll-citadel-dev-fortress/config/eza/theme.yml); fortress uses icons by default and enables header plus git status in `ll`; refreshable with `csm sync-catppuccin eza` |
| `bat`    | better file viewing through `cat` alias                              |
| `fzf`    | fuzzy file, directory, and history selection via widgets and helpers |
| `rg`     | used as the `grep` alias when installed                              |
| `fd`     | used as the `find` alias when installed                              |
| `jq`     | pretty-print JSON through `jqp`                                      |
| `starship` | richer fortress prompt engine using the profile-local Catppuccin preset in [`starship.toml`](/home/timl/projects/tboss/shell-config/zsh-tll-citadel-dev-fortress/starship.toml) |
| `zinit` | fortress-only plugin manager for the optional plugin layer, installed explicitly with `csm install-zinit` |
| `zoxide` | replaces `cd` with smarter directory jumping while preserving `cd` muscle memory |
| `direnv` | automatic per-directory environment loading through its zsh hook     |
| `git`    | fortress-native git workflow helpers, aliases, and `fzf` selectors; enabled by default and reducible via `SHELL_FORTRESS_ENABLE_NATIVE_GIT=0` |
| `web_search` | fortress-native search helper with configurable engines through `ZSH_WEB_SEARCH_ENGINES` |
| `sudo-command-line` | fortress-native widget that prepends `sudo` when you press `Esc Esc` |
| `fzf-tab` | fuzzy completion chooser for `Tab` when `fzf` is installed and `SHELL_FORTRESS_ENABLE_FZF_TAB=1` |
| `zsh-autocomplete` | alternate completion frontend and type-ahead menu when `SHELL_FORTRESS_ENABLE_ZSH_AUTOCOMPLETE=1` |
| `zsh-autosuggestions` | inline command suggestions from history and prior usage when `zinit` is installed and `SHELL_FORTRESS_ENABLE_ZSH_AUTOSUGGESTIONS=1` |
| `atuin` | optional history search integration when `SHELL_FORTRESS_ENABLE_ATUIN=1`; follows Atuin's documented `zsh-vi-mode` hook pattern when vi mode is active and uses a vendored official Catppuccin Mocha theme |
| `zsh-syntax-highlighting` | command-line syntax highlighting loaded late in the plugin stack when `zinit` is installed |

## Command Completion

- `csm` has native zsh completion in this profile
- `ft` completion is loaded when the `dev-container-fortress` CLI has installed its XDG-managed zsh completion artifact under `${XDG_DATA_HOME:-$HOME/.local/share}/dev-container-fortress/completions/zsh`
- completed areas include subcommands plus flags and values such as `select --clean`, direct profile completion for `csm select`, `clear-history --all`, `sync-catppuccin`, and `describe-profile`

## Profile Switching

- Interactive switch command: `zsh-profile-select`
- Direct switch command: `csm select zsh-tll-citadel-dev-fortress` or another profile name
- Clean switch command: `zsh-profile-select --clean` or `csm select --clean`
- HUD command: `fortress-hud` for standard mode, `fortress-hud --pretty` for the Catppuccin/Nerd Font renderer, and `fortress-hud --env` to include exact env and persistent variable mappings
- Interactive debug command: `fortress-debug-interactive`
- Notes about environment isolation: normal mode is fast and preserves most inherited environment; clean mode resets into a curated minimal environment and is better when you want to avoid variable bleed from another profile

## Persistent Settings

Fortress can now load persistent startup preferences from:

- `${XDG_CONFIG_HOME:-$HOME/.config}/shell-config.local/zsh-tll-citadel-dev-fortress/settings.zsh`

This is the preferred way to make login-time or container-startup defaults stick for this profile without re-invoking `zsh` with extra environment variables.

Bootstrap a local settings file with:

```zsh
csm init-settings zsh-tll-citadel-dev-fortress
```

Open the same file in your configured editor with:

```zsh
csm edit-settings zsh-tll-citadel-dev-fortress
```

Settings file variables:

- `SHELL_FORTRESS_SETTING_HISTSIZE`
- `SHELL_FORTRESS_SETTING_SAVEHIST`
- `SHELL_FORTRESS_SETTING_KEYTIMEOUT`
- `SHELL_FORTRESS_SETTING_EDITOR`
- `SHELL_FORTRESS_SETTING_PROMPT_ENGINE`
- `SHELL_FORTRESS_SETTING_ENABLE_NATIVE_GIT`
- `SHELL_FORTRESS_SETTING_ENABLE_ZSH_VI_MODE`
- `SHELL_FORTRESS_SETTING_ENABLE_ZSH_AUTOCOMPLETE`
- `SHELL_FORTRESS_SETTING_ENABLE_ZSH_AUTOSUGGESTIONS`
- `SHELL_FORTRESS_SETTING_ENABLE_FZF_TAB`
- `SHELL_FORTRESS_SETTING_ENABLE_ATUIN`

Startup precedence:

- `SHELL_FORTRESS_ENABLE_*` environment overrides win for one-off sessions
- `EDITOR` wins for one-off editor overrides
- fortress persistent settings are used next
- built-in fortress defaults apply last

> [!TIP]
> `csm init-settings` and `csm edit-settings` also accept no profile argument when run from a shell that already started inside fortress.

Fortress also supports curated optional modules that can be installed into the same local config tree:

```zsh
csm list-modules zsh-tll-citadel-dev-fortress
csm describe-module git zsh-tll-citadel-dev-fortress
csm install-module git zsh-tll-citadel-dev-fortress
csm install-module web_search zsh-tll-citadel-dev-fortress
csm install-module --enable git zsh-tll-citadel-dev-fortress
csm enable-module git zsh-tll-citadel-dev-fortress
csm disable-module git zsh-tll-citadel-dev-fortress
csm remove-module git zsh-tll-citadel-dev-fortress
csm init-module aws_local zsh-tll-citadel-dev-fortress
```

Interactive picker mode is now opt-in by flag and can also be enabled by default for human operators with:

```zsh
export CSM_INTERACTIVE=1
```

Command precedence is:

1. `-i` or `--interactive`, or `--no-interactive`
2. `CSM_INTERACTIVE`
3. command default

When already inside fortress, the profile argument can be omitted:

```zsh
csm list-modules
csm install-module git
csm help
```

## User Extensions

Fortress treats the following XDG-local paths as user-owned extension points:

- `${XDG_CONFIG_HOME:-$HOME/.config}/shell-config.local/zsh-tll-citadel-dev-fortress/env.zsh`
- `${XDG_CONFIG_HOME:-$HOME/.config}/shell-config.local/zsh-tll-citadel-dev-fortress/aliases.zsh`
- `${XDG_CONFIG_HOME:-$HOME/.config}/shell-config.local/zsh-tll-citadel-dev-fortress/functions/`
- `${XDG_CONFIG_HOME:-$HOME/.config}/shell-config.local/zsh-tll-citadel-dev-fortress/modules/`

Recommended usage:

- put user-specific exports such as `EDITOR`, `VISUAL`, cloud defaults, or custom paths in `env.zsh`
- put personal aliases in `aliases.zsh`
- put user-owned autoload functions in `functions/`
- put optional tool-specific local modules in `modules/` as light wiring files that enable aliases and `autoload -Uz` the real function implementations

Example `env.zsh`:

```zsh
export AWS_REGION=ap-southeast-1
SHELL_FORTRESS_LOCAL_MODULES=(aws kube)
```

Example `aliases.zsh`:

```zsh
alias k='kubectl'
alias tf='terraform'
```

Example local autoload function path:

```zsh
print -r -- "${XDG_CONFIG_HOME:-$HOME/.config}/shell-config.local/zsh-tll-citadel-dev-fortress/functions/aws-profile"
```

Place a normal zsh autoload function in that file and then call `autoload -Uz aws-profile` from your local module or alias flow when you want it loaded eagerly.

Example local module file:

```zsh
print -r -- "${XDG_CONFIG_HOME:-$HOME/.config}/shell-config.local/zsh-tll-citadel-dev-fortress/modules/aws.zsh"
```

Recommended module pattern:

```zsh
autoload -Uz aws-profile aws-region aws-use-profile aws-use-region aws-whoami
alias awsp='aws-profile'
alias awsr='aws-region'
alias awsc='aws configure list-profiles'
```

Then place the actual function bodies under `functions/`, for example:

```zsh
print -r -- "${XDG_CONFIG_HOME:-$HOME/.config}/shell-config.local/zsh-tll-citadel-dev-fortress/functions/aws-profile"
```

Enable the module by naming it in `SHELL_FORTRESS_LOCAL_MODULES`, for example:

```zsh
SHELL_FORTRESS_LOCAL_MODULES=(aws)
```

Load order is:

1. fortress settings
2. user `env.zsh`
3. fortress built-in tools and aliases
4. enabled local modules
5. user `aliases.zsh`

That means user aliases remain the final word, while local modules can still add tool-specific helpers cleanly.

> [!TIP]
> Treat local modules as the orchestration layer and `functions/` as the implementation layer. That keeps the model close to native zsh autoloading instead of turning modules into a second function system.

### Curated Modules

Fortress currently ships these curated optional modules:

| Module | Purpose |
| --- | --- |
| `aws` | fortress-owned AWS aliases plus profile inventory, identity, and login helpers |
| `docker` | fortress-owned Docker aliases plus context switching and compact container inventory helpers |
| `git` | adds a few extra git aliases plus autoloaded helpers for primary-branch switching and recent-branch inspection |
| `kubectl` | fortress-owned kubectl aliases plus context switching and namespace inventory helpers |
| `pass` | fortress-owned password-store aliases and simple open or copy helpers |
| `television` | television-powered picker helpers plus optional `tv init zsh` integration when the tool is installed |
| `web_search` | adds extra developer-oriented fortress `web_search` engines and helper aliases for GitHub, MDN, and Terraform docs |

The fuller catalog and host guidance now live in:

- [docs/curated-modules.md](/home/timl/projects/tboss/shell-config/docs/curated-modules.md)

Host-sensitive module notes:

- `television` is best treated as an interactive workstation module and still somewhat experimental compared with the fortress core
- `web_search` depends on working browser-opening behavior through `open`, `wslview`, or `xdg-open`
- `docker` and `kubectl` are best enabled on hosts where the backing runtime or kubeconfig is intentionally present
- `pass` is best enabled only after the host already has a working GPG and password-store baseline
- `aws` is most useful on workstation-style hosts that already have AWS CLI login and profile setup

Typical flow:

1. enable the curated module with `csm enable-module <name>`
2. open a fresh shell
3. only use `csm install-module <name>` when you want to create a user-local fork

Fortress default:

- `git` is enabled by default in `zsh-tll-citadel-dev-fortress`
- `csm enable-module git` is still safe and mainly clears any explicit local opt-out
- `csm disable-module git` is the operator path when you want to turn the default git module off

Current and target module-lifecycle design is described in:

- [module-lifecycle.md](/home/timl/projects/tboss/shell-config/docs/module-lifecycle.md)
- [curated-modules.md](/home/timl/projects/tboss/shell-config/docs/curated-modules.md)

Recommended curated-module flow:

```zsh
csm enable-module git
zsh -il
```

Fork a curated module only when you want a user-local override:

```zsh
csm install-module --enable television
zsh -il
```

> [!IMPORTANT]
> Fortress now treats curated modules as the live default path. `enable-module`
> enables a curated module directly, while `install-module` creates a deliberate
> user-local fork. If a local module file exists for the same name, it shadows
> the curated module until removed or synced.

Disable a module without removing its files:

```zsh
csm disable-module git
zsh -il
```

Remove a local module file and its matching local functions after confirmation:

```zsh
csm remove-module git
```

`remove-module` is intentionally interactive. In a non-interactive context it refuses to proceed rather than deleting local files silently.

Recovery flow for local forks:

```zsh
csm sync-curated-modules
```

That command resets all local forks of curated modules back to the current
curated version, with confirmation by default and `--force` for agentic or
scripted use.

For agentic or scripted use, bypass the prompt explicitly:

```zsh
csm remove-module --force git
```

When you want picker-driven selection instead of naming the module directly:

```zsh
csm enable-module -i
csm disable-module -i
csm remove-module -i
```

`csm list-modules` now shows a small operator table with per-module state:

- `curated` means fortress ships a repo-owned optional module for that name
- `local` means the name only exists in the user-local module tree
- `available` means fortress ships a curated module for that name
- `installed` means a local fork or local-only module file exists in your local XDG config tree
- `missing` means a local-only module name is referenced but no local module file is present
- `enabled` means the module name appears in `SHELL_FORTRESS_LOCAL_MODULES`
- `tags` gives a quick module category hint such as `cloud`, `containers`, `k8s`, `picker`, or `security`

For a single module, inspect the current summary and state with:

```zsh
csm describe-module docker
csm describe-module kubectl
```

`csm describe-module` now also shows lightweight module metadata when the module provides it:

- `tags`
- `envs`
- `requires`

Quick curated-module examples:

```zsh
awsp
awsps
awsl my-sso-profile
awsi
aws-use-profile my-sso-profile
aws-use-region ap-southeast-2

dctx
dctxs
ductx my-context
dps
dpsa

kctx
kctxs
kuse-ctx my-cluster-context
kns
knss
kuse-ns observability
```

For user-authored modules, bootstrap a scaffold with:

```zsh
csm init-module aws_local
```

That creates:

- a starter module file under `modules/`
- a sample autoload function under `functions/`

You can then tailor the scaffold and enable it with:

```zsh
csm enable-module aws_local
zsh -il
```

## Environment Overrides

- `SHELL_FORTRESS_PROMPT_ENGINE=auto` prefers `starship`, then native zsh fallback
- `SHELL_FORTRESS_PROMPT_ENGINE=starship` selects `starship` when available and otherwise falls back to native zsh
- `SHELL_FORTRESS_PROMPT_ENGINE=native` forces the native zsh prompt path
- `SHELL_FORTRESS_ENABLE_NATIVE_GIT=1` keeps the default fortress-native git helper and alias layer enabled
- `SHELL_FORTRESS_ENABLE_NATIVE_GIT=0` trims fortress back to the smaller always-on git alias set
- `SHELL_FORTRESS_ENABLE_ZSH_VI_MODE=1` keeps the default `jeffreytse/zsh-vi-mode` path active
- `SHELL_FORTRESS_ENABLE_ZSH_VI_MODE=0` switches the profile back to native `bindkey -v` vi mode
- `SHELL_FORTRESS_ENABLE_ZSH_AUTOCOMPLETE=1` enables `marlonrichert/zsh-autocomplete` and lets it own `compinit` plus the primary completion flow; default behavior is off
- `SHELL_FORTRESS_ENABLE_FZF_TAB=1` keeps the default `fzf-tab` path active when `zinit` and `fzf` are available
- `SHELL_FORTRESS_ENABLE_FZF_TAB=0` disables `fzf-tab` and falls back to non-`fzf-tab` completion behavior
- `SHELL_FORTRESS_ENABLE_ZSH_AUTOSUGGESTIONS=1` enables `zsh-autosuggestions` when `zinit` is available; default behavior is on
- `SHELL_FORTRESS_ENABLE_ATUIN=1` keeps the default Atuin integration active when the `atuin` command is installed; when vi mode is active, fortress follows Atuin's documented `zvm_after_init_commands` integration pattern
- `SHELL_FORTRESS_ENABLE_ATUIN=0` disables Atuin integration entirely
- when Atuin is enabled, fortress exports `ATUIN_CONFIG_DIR` to [`config/atuin`](/home/timl/projects/tboss/shell-config/zsh-tll-citadel-dev-fortress/config/atuin) and `ATUIN_THEME_DIR` to [`config/atuin/themes`](/home/timl/projects/tboss/shell-config/zsh-tll-citadel-dev-fortress/config/atuin/themes)
- when Atuin is enabled, fortress exports `ATUIN_THEME_DIR` to [`config/atuin/themes`](/home/timl/projects/tboss/shell-config/zsh-tll-citadel-dev-fortress/config/atuin/themes) and vendors the official `catppuccin-mocha-mauve` theme
- fortress ships a profile-local Atuin config in [`config/atuin/config.toml`](/home/timl/projects/tboss/shell-config/zsh-tll-citadel-dev-fortress/config/atuin/config.toml) that selects the vendored `catppuccin-mocha-mauve` theme
- in live-shell testing, Atuin respected the exported `ATUIN_CONFIG_DIR` and used the profile-local config even though `atuin info` still reported the default config path
- Atuin may still create `~/.config/atuin/` as a directory, but the active config and theme can still come from the exported profile-local config directory
- refresh the vendored Atuin Catppuccin theme with `csm sync-catppuccin atuin` or refresh all supported Catppuccin assets with `csm sync-catppuccin`
- if `SHELL_FORTRESS_ENABLE_ZSH_VI_MODE=1` is set on its own, fortress skips `zsh-autocomplete` so `zsh-vi-mode` can own widget handling; `fzf-tab` may still be enabled alongside it
- if both `SHELL_FORTRESS_ENABLE_ZSH_VI_MODE=1` and `SHELL_FORTRESS_ENABLE_ZSH_AUTOCOMPLETE=1` are set, fortress enters an experimental compatibility mode that initializes `zsh-vi-mode` eagerly before loading `zsh-autocomplete`
- if `zsh-autocomplete` actually loads, fortress skips `fzf-tab` and lets `zsh-autocomplete` win
- in the experimental vi-mode plus autocomplete path, fortress rebinds `Tab` to `menu-select` after plugin load and sets autocomplete's default context to `history-incremental-search-backward`
- `ZSH_WEB_SEARCH_ENGINES` can extend fortress-managed search engines, for example a ServiceNow shortcut

Supported combinations:

- native vi mode plus `zsh-autocomplete`
- native vi mode plus `fzf-tab`
- `zsh-vi-mode` plus `fzf-tab`
- `zsh-vi-mode` plus `zsh-autosuggestions`
- `zsh-vi-mode` plus `fzf-tab` plus `zsh-autosuggestions`

Currently unsupported combination:

- none currently hard-blocked, but `zsh-vi-mode` plus `zsh-autocomplete` should still be treated as experimental

```zsh
ZSH_WEB_SEARCH_ENGINES=(
  snow "https://instance.service-now.com/nav_to.do?uri=task.do?sysparm_query=number="
)
```

## Plugin Layer

- Plugin manager: `zinit`
- Install command: `csm install-zinit`
- Current managed plugins:
  - `jeffreytse/zsh-vi-mode`, enabled by default and replaceable with native `bindkey -v` when `SHELL_FORTRESS_ENABLE_ZSH_VI_MODE=0`
  - `marlonrichert/zsh-autocomplete` when `SHELL_FORTRESS_ENABLE_ZSH_AUTOCOMPLETE=1`, loaded before tool-level `compdef` usage so it can own `compinit`
  - `Aloxaf/fzf-tab` when `fzf` is installed and `SHELL_FORTRESS_ENABLE_FZF_TAB=1`, loaded synchronously so `Tab` is intercepted on first use
  - `zsh-users/zsh-autosuggestions`, enabled by default when `SHELL_FORTRESS_ENABLE_ZSH_AUTOSUGGESTIONS=1`
  - `atuin` when `SHELL_FORTRESS_ENABLE_ATUIN=1`; if vi mode is active, fortress defers its init through `zvm_after_init_commands` as recommended by Atuin, and uses the vendored official Catppuccin Mocha theme file in [`config/atuin/themes/catppuccin-mocha-mauve.toml`](/home/timl/projects/tboss/shell-config/zsh-tll-citadel-dev-fortress/config/atuin/themes/catppuccin-mocha-mauve.toml)
  - `zsh-users/zsh-syntax-highlighting`, loaded late so it remains the last highlighter in the interactive stack
  - `zsh-vi-mode` normally takes precedence over `zsh-autocomplete`, but fortress can enter an experimental eager-init compatibility mode when both are enabled
  - `fzf-tab` and `zsh-autocomplete` are treated as alternative completion frontends; fortress skips `fzf-tab` whenever `zsh-autocomplete` actually loads
- Behavior when unavailable: fortress falls back to its native shell behavior if `zinit` has not been installed yet

## Terminal Notes

- this profile binds both `^[[A` / `^[[B` and `^[OA` / `^[OB` for better arrow-key behavior across Linux, macOS, Windows Terminal, WSL2, SSH, and some tmux setups
- VS Code integrated terminal may still behave differently from standalone terminals if it emits different sequences
- `j` / `k` in `vicmd` still use normal history movement; the stronger prefix-search behavior is primarily in insert mode
- `zsh-vi-mode` adds extra vi-style helpers such as `vv` and `gx`, but fortress still keeps its explicit `Ctrl-A`, `Ctrl-E`, arrow, and `fzf` widget bindings
- `Alt-C` depends on your terminal sending Meta/Alt escape sequences consistently; macOS terminals may need Option-key configuration
- `gx` and `web_search` depend on a working opener stack; fortress prefers `open`, then `wslview`, then `xdg-open`
- `television` helpers are only as portable as the installed `tv` binary plus the current terminal's interactive key behavior
- when `zoxide` is installed, `cd` becomes smarter rather than purely literal path traversal
- `gcof`, `gshowf`, and `gwtcd` are most useful when `fzf` is installed
- the prompt changes cursor shape in both prompt modes; the native fallback also shows `I` or `N` in the right prompt for insert and normal mode

## Caveats

- this profile can switch between `starship` and native prompt paths and uses a small explicit `zinit` plugin layer when installed
- terminal differences can still affect key behavior even when the bindings are correct
- `fzf`, `zoxide`, `direnv`, `starship`, and `zinit` integrations activate only when those tools are installed or bootstrapped
- `zsh-vi-mode`, `zsh-autocomplete`, `fzf-tab`, autosuggestions, and syntax highlighting depend on `zinit` being installed for fortress
- `zsh-autocomplete` and `fzf-tab` should be treated as mutually exclusive in normal use; fortress gives priority to `zsh-autocomplete`
- fortress-native git helpers and aliases are now the default path
