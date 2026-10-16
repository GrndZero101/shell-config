#!/usr/bin/env bats

# Curated brew module tests.
# A stub `brew` records every call so the module's own logic (argument
# handling, Brewfile resolution, call order, the cleanup confirmation gate)
# is tested without touching the host's Homebrew. Completion tests drive a
# real zsh completion session via tests/support/capture-completion.zsh. The
# real-Homebrew tests at the end are opt-in via SHELL_CONFIG_TEST_REAL_BREW=1.

load test_helper
bats_require_minimum_version 1.5.0

setup() {
  setup_isolated_shell_config_env

  export FAKE_BREW_LOG="$TEST_ROOT/brew.log"
  export BREWFILE="$TEST_ROOT/Brewfile"
  : > "$FAKE_BREW_LOG"
  : > "$BREWFILE"

  mkdir -p "$HOME/.local/bin"
  cat > "$HOME/.local/bin/brew" <<'EOF'
#!/usr/bin/env bash
# Stub brew: log the call, emulate the few behaviors the module depends on.
printf '%s\n' "$*" >> "$FAKE_BREW_LOG"

file='' kind='brew' name=''
for arg in "$@"; do
  case "$arg" in
    --file=*) file="${arg#--file=}" ;;
    --cask) kind='cask' ;;
    --tap) kind='tap' ;;
    -*) ;;
    *) name="$arg" ;;
  esac
done

case "$1 ${2:-}" in
  "install "*)
    [[ -z "${FAKE_BREW_FAIL_INSTALL:-}" ]] || exit 1
    ;;
  "list "*)
    [[ " ${FAKE_BREW_NOT_INSTALLED:-} " != *" $name "* ]] || exit 1
    ;;
  "formulae "*)
    printf '%s\n' jq jqx python@3.12 ripgrep
    ;;
  "casks "*)
    printf '%s\n' firefox firefox@beta
    ;;
  "bundle add")
    # Like real Homebrew 7: write a description comment, never dedupe.
    [[ "$kind" == tap ]] || printf '# %s description\n' "$name" >> "$file"
    printf '%s "%s"\n' "$kind" "$name" >> "$file"
    ;;
  "bundle remove")
    kept="$(grep -v "^$kind \"$name\"" "$file")"
    printf '%s\n' "$kept" > "$file"
    ;;
  "bundle list")
    sed -n "s/^$kind \"\\([^\"]*\\)\".*/\\1/p" "$file"
    ;;
  "bundle cleanup")
    [[ " $* " == *" --force "* ]] && exit 0
    [[ -n "${FAKE_BREW_UNDECLARED:-}" ]] || exit 0
    printf 'Would uninstall formulae:\n%s\nRun `brew bundle cleanup --force` to make these changes.\n' "$FAKE_BREW_UNDECLARED"
    exit 1
    ;;
  "bundle dump")
    [[ -z "${FAKE_BREW_FAIL_DUMP:-}" ]] || exit 1
    for arg in "$@"; do
      [[ "$arg" == --file=* || "$arg" != --* ]] || printf '%s "dumped"\n' "${arg#--}"
    done
    ;;
  "bundle check")
    echo "The Brewfile's dependencies are satisfied."
    ;;
esac
exit 0
EOF
  chmod +x "$HOME/.local/bin/brew"
}

teardown() {
  teardown_isolated_shell_config_env
}

# Run a command in a login zsh with the curated brew module sourced.
# Arguments:
#   $1 - zsh command string.
#   $2 - Optional text fed to stdin (default: none, i.e. EOF).
run_brew_module() {
  local repo_root module_root
  repo_root="$(shell_config_repo_root)"
  module_root="$repo_root/zsh-tll-citadel-dev-fortress/curated-modules/brew"

  run env \
    PATH="$HOME/.local/bin:$PATH" \
    HOME="$HOME" \
    XDG_CONFIG_HOME="$XDG_CONFIG_HOME" \
    XDG_STATE_HOME="$XDG_STATE_HOME" \
    XDG_CACHE_HOME="$XDG_CACHE_HOME" \
    XDG_DATA_HOME="$XDG_DATA_HOME" \
    XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
    FAKE_BREW_LOG="$FAKE_BREW_LOG" \
    FAKE_BREW_FAIL_INSTALL="${FAKE_BREW_FAIL_INSTALL:-}" \
    FAKE_BREW_UNDECLARED="${FAKE_BREW_UNDECLARED:-}" \
    FAKE_BREW_FAIL_DUMP="${FAKE_BREW_FAIL_DUMP:-}" \
    FAKE_BREW_NOT_INSTALLED="${FAKE_BREW_NOT_INSTALLED:-}" \
    HOMEBREW_BUNDLE_FILE="${HOMEBREW_BUNDLE_FILE-$BREWFILE}" \
    /bin/zsh -lc "fpath=(\"$module_root/functions\" \$fpath); source \"$module_root/module.zsh\"; $1" <<< "${2:-}"
}

@test "brew-file honors HOMEBREW_BUNDLE_FILE and fails clearly when it is missing" {
  run_brew_module "brew-file"
  [ "$status" -eq 0 ]
  [ "$output" = "$BREWFILE" ]

  HOMEBREW_BUNDLE_FILE="$TEST_ROOT/nope" run_brew_module "brew-file"
  [ "$status" -eq 1 ]
  [[ "$output" == *"HOMEBREW_BUNDLE_FILE points to a missing file"* ]]
}

@test "brew-file falls back to the XDG homebrew Brewfile when HOMEBREW_BUNDLE_FILE is unset" {
  mkdir -p "$XDG_CONFIG_HOME/homebrew"
  : > "$XDG_CONFIG_HOME/homebrew/Brewfile"

  HOMEBREW_BUNDLE_FILE='' run_brew_module "unset HOMEBREW_BUNDLE_FILE; brew-file"
  [ "$status" -eq 0 ]
  [ "$output" = "$XDG_CONFIG_HOME/homebrew/Brewfile" ]
}

@test "brew-add installs then declares once and reports an existing declaration" {
  run_brew_module "brew-add"
  [ "$status" -eq 2 ]
  [[ "$output" == *"usage: brew-add"* ]]

  run_brew_module "brew-add jq && brew-add jq"
  [ "$status" -eq 0 ]
  [[ "$output" == *'declared: brew "jq"'* ]]
  [[ "$output" == *'already declared: brew "jq"'* ]]
  [ "$(grep -c '^brew "jq"$' "$BREWFILE")" -eq 1 ]
  grep -qxF 'install -- jq' "$FAKE_BREW_LOG"
  [ "$(grep -cxF "bundle add --file=$BREWFILE -- jq" "$FAKE_BREW_LOG")" -eq 1 ]
}

@test "brew-add --cask passes the cask flag and declares nothing when install fails" {
  run_brew_module "brew-add --cask firefox"
  [ "$status" -eq 0 ]
  grep -qxF 'install --cask -- firefox' "$FAKE_BREW_LOG"
  grep -qxF 'cask "firefox"' "$BREWFILE"

  FAKE_BREW_FAIL_INSTALL=1 run_brew_module "brew-add broken"
  [ "$status" -eq 1 ]
  run ! grep -q 'broken' "$BREWFILE"
  run ! grep -q 'bundle add.*broken' "$FAKE_BREW_LOG"
}

@test "brew-rm uninstalls, removes each declaration by type, then autoremoves once" {
  run_brew_module "brew-rm jq yq"
  [ "$status" -eq 0 ]
  # Ignore the installed checks and the scratch-file description lookups.
  [ "$(grep -v -e '^list ' -e 'brew-drop-description\.' "$FAKE_BREW_LOG")" = "uninstall --formula -- jq
bundle remove --file=$BREWFILE --formula -- jq
uninstall --formula -- yq
bundle remove --file=$BREWFILE --formula -- yq
autoremove" ]

  : > "$FAKE_BREW_LOG"
  run_brew_module "brew-rm --cask firefox"
  [ "$status" -eq 0 ]
  grep -qxF 'list --cask --versions -- firefox' "$FAKE_BREW_LOG"
  grep -qxF 'uninstall --cask -- firefox' "$FAKE_BREW_LOG"
  grep -qxF "bundle remove --file=$BREWFILE --cask -- firefox" "$FAKE_BREW_LOG"
}

@test "brew-rm drops only the Homebrew description above the entry and keeps hand-written comments" {
  printf '# Hand-written header\n# jq description\nbrew "jq"\n\n# keep: pinned for work\nbrew "ripgrep"\n# jqx description\nbrew "jqx"\n' > "$TEST_ROOT/real.Brewfile"
  ln -s "$TEST_ROOT/real.Brewfile" "$TEST_ROOT/link.Brewfile"

  HOMEBREW_BUNDLE_FILE="$TEST_ROOT/link.Brewfile" run_brew_module "brew-rm jq ripgrep"
  [ "$status" -eq 0 ]
  [ -L "$TEST_ROOT/link.Brewfile" ]
  [ "$(cat "$TEST_ROOT/real.Brewfile")" = '# Hand-written header

# keep: pinned for work
# jqx description
brew "jqx"' ]
}

@test "brew-rm removes a declared but not installed package without uninstalling" {
  printf '# jq description\nbrew "jq"\n' > "$BREWFILE"

  FAKE_BREW_NOT_INSTALLED='jq' run_brew_module "brew-rm jq"
  [ "$status" -eq 0 ]
  [[ "$output" == *"not installed: jq; removing the declaration only"* ]]
  run ! grep -q '^uninstall' "$FAKE_BREW_LOG"
  [ "$(cat "$BREWFILE")" = '' ]
}

@test "brew-add declares the tap for tap-qualified names exactly once" {
  run_brew_module "brew-add owner/tap/thing && brew-add owner/tap/other && brew-add jq"
  [ "$status" -eq 0 ]
  [ "$(grep -cxF 'tap "owner/tap"' "$BREWFILE")" -eq 1 ]
  grep -qxF 'brew "owner/tap/thing"' "$BREWFILE"
  grep -qxF 'brew "owner/tap/other"' "$BREWFILE"
  [[ "$output" == *'declared: tap "owner/tap"'* ]]
  [ "$(grep -c 'bundle list --file=.* --tap' "$FAKE_BREW_LOG")" -eq 2 ]
}

# Capture what Tab offers for a command line with the brew module loaded.
# Arguments:
#   $1 - Command-line buffer to complete.
complete_brew() {
  local repo_root module_root
  repo_root="$(shell_config_repo_root)"
  module_root="$repo_root/zsh-tll-citadel-dev-fortress/curated-modules/brew"
  printf 'fpath=(%q $fpath)\nsource %q\n' "$module_root/functions" "$module_root/module.zsh" > "$TEST_ROOT/complete-setup.zsh"

  run env \
    PATH="$HOME/.local/bin:$PATH" \
    HOME="$HOME" \
    XDG_CONFIG_HOME="$XDG_CONFIG_HOME" \
    FAKE_BREW_LOG="$FAKE_BREW_LOG" \
    HOMEBREW_BUNDLE_FILE="$BREWFILE" \
    /bin/zsh "$repo_root/tests/support/capture-completion.zsh" "$TEST_ROOT/complete-setup.zsh" "$1"
}

@test "Tab completes brew-add formulae, casks, and options while skipping names already typed" {
  complete_brew 'brew-add '
  [ "$status" -eq 0 ]
  [ "$output" = 'jq
jqx
python@3.12
ripgrep' ]

  complete_brew 'brew-add jq '
  [ "$output" = 'jqx
python@3.12
ripgrep' ]

  complete_brew 'brew-add --cask '
  [ "$output" = 'firefox
firefox@beta' ]

  complete_brew 'brew-add -'
  [ "$output" = '--cask' ]

  complete_brew 'bra rip'
  [ "$output" = 'ripgrep' ]
}

@test "Tab completes brew-rm from declared Brewfile entries of the requested kind" {
  printf '# jq description\nbrew "jq"\nbrew "python@3.12", restart_service: true # pinned\ncask "firefox"\ntap "owner/tap"\n' > "$BREWFILE"

  complete_brew 'brew-rm '
  [ "$status" -eq 0 ]
  [ "$output" = 'jq
python@3.12' ]

  complete_brew 'brew-rm --cask '
  [ "$output" = 'firefox' ]

  complete_brew 'brr jq '
  [ "$output" = 'python@3.12' ]
  run ! grep -q 'bundle list' "$FAKE_BREW_LOG"
}

@test "Tab completes brew-dump options and comma-separated --with ecosystems" {
  complete_brew 'brew-dump --w'
  [ "$status" -eq 0 ]
  [ "$output" = '--with
--write' ]

  complete_brew 'brew-dump --with='
  [[ "$output" == *'vscode'* && "$output" == *'winget'* && "$output" == *'all'* ]]

  complete_brew 'brew-dump --with=vscode,'
  [[ "$output" != *'vscode'* && "$output" == *'uv'* ]]
}

@test "brew-drift lists undeclared packages read-only and checks declared ones" {
  FAKE_BREW_UNDECLARED='htop' run_brew_module "brew-drift"
  [ "$status" -eq 0 ]
  [[ "$output" == *"==> Installed but not in Brewfile:"*"htop"* ]]
  [[ "$output" != *"--force"* ]]
  [[ "$output" == *"==> Declared but missing:"* ]]
  run ! grep -q -- '--force' "$FAKE_BREW_LOG"

  run_brew_module "brew-drift"
  [[ "$output" == *"==> Nothing undeclared"* ]]
}

@test "brew-sync without drift runs every step in order and never prompts" {
  run_brew_module "brew-sync --greedy"
  [ "$status" -eq 0 ]
  [[ "$output" != *"Remove undeclared packages"* ]]
  [ "$(cat "$FAKE_BREW_LOG")" = "update
bundle install --file=$BREWFILE --no-upgrade
bundle cleanup --file=$BREWFILE --formula --cask --tap
upgrade --greedy
autoremove
cleanup --prune=all" ]
}

@test "brew-sync only removes undeclared packages after an explicit yes" {
  FAKE_BREW_UNDECLARED='htop' run_brew_module "brew-sync"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Kept undeclared packages"* ]]
  run ! grep -q -- 'cleanup.*--force' "$FAKE_BREW_LOG"

  : > "$FAKE_BREW_LOG"
  FAKE_BREW_UNDECLARED='htop' run_brew_module "brew-sync" "n"
  run ! grep -q -- 'cleanup.*--force' "$FAKE_BREW_LOG"

  : > "$FAKE_BREW_LOG"
  FAKE_BREW_UNDECLARED='htop' run_brew_module "brew-sync" "y"
  [ "$status" -eq 0 ]
  grep -qxF "bundle cleanup --file=$BREWFILE --formula --cask --tap --force" "$FAKE_BREW_LOG"
}

@test "brew-dump prints traditional Homebrew types by default and leaves the Brewfile alone" {
  printf 'brew "keep"\n' > "$BREWFILE"

  run_brew_module "brew-dump"
  [ "$status" -eq 0 ]
  [ "$output" = 'formula "dumped"
cask "dumped"
tap "dumped"' ]
  grep -qxF -- 'bundle dump --file=- --formula --cask --tap' "$FAKE_BREW_LOG"
  [ "$(cat "$BREWFILE")" = 'brew "keep"' ]
}

@test "brew-dump --with adds opt-in ecosystems and rejects unknown types" {
  run_brew_module "brew-dump --with vscode,uv --with=winget"
  [ "$status" -eq 0 ]
  grep -qxF -- 'bundle dump --file=- --formula --cask --tap --vscode --uv --winget' "$FAKE_BREW_LOG"

  : > "$FAKE_BREW_LOG"
  run_brew_module "brew-dump --with all --with uv"
  [ "$status" -eq 0 ]
  grep -qxF -- 'bundle dump --file=- --formula --cask --tap --mas --vscode --go --cargo --uv --flatpak --winget --krew --npm' "$FAKE_BREW_LOG"

  run_brew_module "brew-dump --with pip"
  [ "$status" -eq 2 ]
  [[ "$output" == *"unknown type: pip"* ]]
}

@test "brew-dump --write replaces a symlinked Brewfile in place and survives a failed dump" {
  printf 'brew "old"\n' > "$TEST_ROOT/real.Brewfile"
  ln -s "$TEST_ROOT/real.Brewfile" "$TEST_ROOT/link.Brewfile"

  FAKE_BREW_FAIL_DUMP=1 HOMEBREW_BUNDLE_FILE="$TEST_ROOT/link.Brewfile" run_brew_module "brew-dump --write"
  [ "$status" -eq 1 ]
  [ "$(cat "$TEST_ROOT/real.Brewfile")" = 'brew "old"' ]

  HOMEBREW_BUNDLE_FILE="$TEST_ROOT/link.Brewfile" run_brew_module "brew-dump --write"
  [ "$status" -eq 0 ]
  [ -L "$TEST_ROOT/link.Brewfile" ]
  grep -qxF 'formula "dumped"' "$TEST_ROOT/real.Brewfile"
  run ! grep -q 'old' "$TEST_ROOT/real.Brewfile"
}

@test "brew module is opt-in, points to its guide, and the fortress HUD shows the resolved Brewfile" {
  local repo_root
  repo_root="$(shell_config_repo_root)"

  run_zsh_in_test_env "$repo_root/scripts/csm bootstrap"
  [ "$status" -eq 0 ]
  mkdir -p "$XDG_STATE_HOME/shell-config"
  printf 'zsh-tll-citadel-dev-fortress\n' > "$XDG_STATE_HOME/shell-config/active-profile"

  export HOMEBREW_BUNDLE_FILE="$BREWFILE"
  run_interactive_zsh_in_test_env "fortress-hud"
  [ "$status" -eq 0 ]
  [[ "$(strip_ansi "$output")" == *"[tools] brewfile: module-disabled"* ]]

  run_zsh_in_test_env "$repo_root/scripts/csm enable-module brew zsh-tll-citadel-dev-fortress"
  [ "$status" -eq 0 ]

  run_zsh_in_test_env "$repo_root/scripts/csm describe-module brew zsh-tll-citadel-dev-fortress"
  [ "$status" -eq 0 ]
  [[ "$(strip_ansi "$output")" == *"docs:      $repo_root/zsh-tll-citadel-dev-fortress/curated-modules/brew/README.md"* ]]

  run_zsh_in_test_env "$repo_root/scripts/csm describe-module docker zsh-tll-citadel-dev-fortress"
  [[ "$(strip_ansi "$output")" != *"docs:"* ]]

  run_interactive_zsh_in_test_env "fortress-hud"
  [ "$status" -eq 0 ]
  [[ "$(strip_ansi "$output")" == *"[tools] brewfile: $BREWFILE"* ]]

  run_interactive_zsh_in_test_env "fortress-debug-interactive"
  [ "$status" -eq 0 ]
  [[ "$output" == *"== Homebrew =="*"brewfile: $BREWFILE"* ]]
}

@test "brew-add and brew-rm keep a real Brewfile exact, deduped, and symlinked (opt-in)" {
  [[ "${SHELL_CONFIG_TEST_REAL_BREW:-}" == 1 ]] || skip 'set SHELL_CONFIG_TEST_REAL_BREW=1 to run against real Homebrew'
  local real_brew
  real_brew="$(PATH="${PATH//$HOME\/.local\/bin:/}" command -v brew)" || skip 'brew is not installed'

  # Real `brew bundle` edits the Brewfile; package installs stay faked.
  cat > "$HOME/.local/bin/brew" <<EOF
#!/usr/bin/env bash
[[ "\$1" == bundle ]] && HOMEBREW_NO_AUTO_UPDATE=1 exec "$real_brew" "\$@"
exit 0
EOF

  printf '# JSON processor\n# Lightweight and flexible command-line JSON processor\nbrew "jq"\nbrew "jqx"\nbrew "python@3.12", restart_service: true # pinned\ncask "jq"\n' > "$TEST_ROOT/real.Brewfile"
  ln -s "$TEST_ROOT/real.Brewfile" "$TEST_ROOT/link.Brewfile"

  HOMEBREW_BUNDLE_FILE="$TEST_ROOT/link.Brewfile" run_brew_module "brew-add jq && brew-add jq"
  [ "$status" -eq 0 ]
  [[ "$output" == *'already declared: brew "jq"'* ]]
  [ "$(grep -c '^brew "jq"$' "$TEST_ROOT/real.Brewfile")" -eq 1 ]

  HOMEBREW_BUNDLE_FILE="$TEST_ROOT/link.Brewfile" run_brew_module "brew-rm jq python@3.12"
  [ "$status" -eq 0 ]

  [ -L "$TEST_ROOT/link.Brewfile" ]
  run ! grep -q '^brew "jq"' "$TEST_ROOT/real.Brewfile"
  run ! grep -q 'python@3.12' "$TEST_ROOT/real.Brewfile"
  grep -qxF 'brew "jqx"' "$TEST_ROOT/real.Brewfile"
  grep -qxF 'cask "jq"' "$TEST_ROOT/real.Brewfile"
  grep -qxF '# JSON processor' "$TEST_ROOT/real.Brewfile"
  run ! grep -q 'Lightweight and flexible' "$TEST_ROOT/real.Brewfile"
}

@test "brew-dump against real Homebrew emits only formula, cask, and tap entries by default (opt-in)" {
  [[ "${SHELL_CONFIG_TEST_REAL_BREW:-}" == 1 ]] || skip 'set SHELL_CONFIG_TEST_REAL_BREW=1 to run against real Homebrew'
  local real_brew
  real_brew="$(PATH="${PATH//$HOME\/.local\/bin:/}" command -v brew)" || skip 'brew is not installed'

  cat > "$HOME/.local/bin/brew" <<STUB
#!/usr/bin/env bash
# Real stdout only; Homebrew progress lines go to stderr, which run merges.
[[ "\$1" == bundle && "\$2" == dump ]] && HOMEBREW_NO_AUTO_UPDATE=1 exec "$real_brew" "\$@" 2>/dev/null
exit 1
STUB

  run_brew_module "brew-dump"
  [ "$status" -eq 0 ]
  run ! grep -Ev '^(brew|cask|tap) "|^#|^$' <<< "$output"
}
