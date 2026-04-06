# General Implementation Guidance

* Use KISS, DRY and YAGNI principles
* Keep code clean, well documented and human maintanable.
* When configuration files are needed follow XDG standards.
* Review and update `README.md` whenever there is functionality change int the project.
* Review and update any profile HUD or debug surfaces whenever profile-visible behavior changes. For `zsh-tll-citadel-dev-fortress`, keep `fortress-hud` and related debug helpers accurate when toggles, tools, helpers, startup wiring, or runtime paths change.

# Markdown Documents

* Make use of Github / Gitlab admonitions callouts where it makes sense (e.g. carve outs / exceptions)
* Make use of emoticons that are supported by Github / Gitlab where it makes sense but maintain conciseness.
* `docs/ROADMAP.md` is the strategy and milestone-ordering document for this repository.
* `docs/milestones/` is the execution-planning surface for active and draft milestone work.
* Each profile should have its own `USAGE.md` and the operational truth for profile behavior should live there rather than only in top-level docs.
* Each profile should also have its own `DESIGN.md` for design intent, visual direction, prompt strategy, and profile-specific philosophy.
* Profile usage documents should follow the shared template at `docs/templates/profile-usage-template.md`.
* Profile design documents should follow the shared template at `docs/templates/profile-design-template.md`.
* Update a profile's `USAGE.md` whenever the profile behavior, hotkeys, helpers, prompt, or caveats change.
* Update a profile's `DESIGN.md` whenever the profile's visual direction, prompt strategy, theme policy, tool-selection philosophy, or major design rules change.
* When a profile exposes a HUD or status surface, update the profile's `USAGE.md` whenever its sections, flags, renderer modes, or expected debugging workflow change.
* For profiles that adopt Catppuccin, prefer official Catppuccin ports and use the tool's native theming mechanism where possible. Vendor exact upstream assets when practical, and avoid ad hoc theme rewrites when an official port exists.
* Keep top-level docs high-level and comparative. Keep per-profile docs concrete and operational.
* When milestone or roadmap work changes, update `docs/ROADMAP.md` and the matching file under `docs/milestones/` in the same pass.

# Shell implementation

* `.zshenv` is the only shared component. This will ultimately set the `$ZDOTDIR` variable to determine which shell configuration touse.
* Each shell configuration will be atomic outside of the use of the shared `.zshenv`.
* Allowed shared carve-outs should stay rare and explicit. Right now the intended narrow carve-outs are common executable discovery in `shared/path.zsh` and repo-owned command completion in `shared/completions/`.
* Do not introduce a general shared shell-function library across profiles unless explicitly asked. If a shared completion or helper is added, keep it tightly scoped, audit-friendly, and limited to repo-owned infrastructure.
* Assume all shell code is for ZSH shell even things like bootstrap scripts. Make use of ZSH specific functionality. It does not have to be bash/sh/posix compatible. This will only be used on systems that are already using ZSH.
* For zsh shell scripts use a lightweight shell docblock standard instead of Python-style docstrings.
* Add a short file header describing purpose and constraints.
* Add a concise comment block above each function covering:
  purpose
  arguments
  returns
  side effects when relevant
* Keep inline comments rare and only use them for non-obvious zsh behavior, safety checks, parser quirks, or important invariants.
* Keep comments intent-focused and audit-friendly. Avoid noisy line-by-line narration.
* Review and Update comments anytime the script is updated in e.g. update function comments if the function is modified.
* Assume Nerd Fonts are being used and terminates that can support things like catppuccin themes. Make use of them to make pretty itnerfaces but maintainc conciseness.

**Muti OS and CPU Architecture**:

* Build detective logic into any scripts to cater for installation on Mac OS, Ubuntu Linux, Alpine Linux for both Intel and ARM platforms.

# Bootstrapping

* Please develop a source based zsh script to bootstrap as `.zshenv` ultimately needs to be placed in the user's `$HOME` directory.
* The project will be cloned usually into `$HOME/.config/shell-config` following XDG standards but it should allow for user customization if they want to change location during deployment.

# Dogfooding

* Prefer using the shell helpers, workflows, and operator surfaces from this repository to develop and operate the repository itself whenever those capabilities already exist.
* If a workflow still requires a taxing manual sequence, treat that as a feature gap and suggest it as a candidate milestone or extension in the relevant roadmap/planning docs.
* For shell startup, module-loading, keybinding, or profile-behavior debugging, use the established operator and debug surfaces first before ad hoc probing. Start with `fortress-hud`, `fortress-debug-interactive`, `csm list-modules`, and `csm describe-module <name>` unless there is a clear reason they are insufficient.
