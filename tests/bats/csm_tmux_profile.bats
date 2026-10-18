#!/usr/bin/env bats

# csm tmux-profile tests.
# Dev Fortress installs the real profiles; these tests seed small stand-ins
# in the same directory layout. Each test gets its own tmux socket directory
# and no inherited $TMUX, so a reload can never reach the operator's server.

load test_helper
bats_require_minimum_version 1.5.0

setup() {
  setup_isolated_shell_config_env
  unset TMUX TMUX_PANE
  export TMUX_TMPDIR="$TEST_ROOT/tmux"
  mkdir -p "$TMUX_TMPDIR"

  PROFILES_DIR="$XDG_DATA_HOME/dev-container-fortress/tmux-profiles"
  TMUX_CONF="$XDG_CONFIG_HOME/tmux/tmux.conf"
  for profile in minimal full; do
    mkdir -p "$PROFILES_DIR/$profile"
    printf 'set -g @csm_test_profile %s\n' "$profile" > "$PROFILES_DIR/$profile/tmux.conf"
  done
}

teardown() {
  if [[ -n "${TMUX_BIN:-}" ]]; then
    "$TMUX_BIN" kill-server 2>/dev/null || true
  fi
  teardown_isolated_shell_config_env
}

# Run csm tmux-profile with the given arguments.
run_tmux_profile() {
  run /bin/zsh "$(shell_config_repo_root)/scripts/csm" tmux-profile "$@"
}

@test "csm tmux-profile lists none and the installed profiles, marking the active one" {
  run_tmux_profile
  [ "$status" -eq 0 ]
  output="$(strip_ansi "$output")"
  [[ "$output" == *"● none"* ]]
  [[ "$output" == *"○ full"* ]]
  [[ "$output" == *"○ minimal"* ]]
}

@test "csm tmux-profile links a profile, switches it, and goes back to none" {
  run_tmux_profile full
  [ "$status" -eq 0 ]
  [ "$(readlink "$TMUX_CONF")" = "$PROFILES_DIR/full/tmux.conf" ]

  run_tmux_profile minimal
  [ "$status" -eq 0 ]
  [ "$(readlink "$TMUX_CONF")" = "$PROFILES_DIR/minimal/tmux.conf" ]

  run_tmux_profile none
  [ "$status" -eq 0 ]
  assert_path_not_exists "$TMUX_CONF"
}

@test "csm tmux-profile rejects unknown profiles and a missing profiles directory" {
  run_tmux_profile bogus
  [ "$status" -ne 0 ]
  [[ "$output" == *"unknown profile: bogus"* ]]

  rm -rf "$PROFILES_DIR"
  run_tmux_profile full
  [ "$status" -ne 0 ]
  [[ "$output" == *"no Dev Fortress tmux profiles"* ]]
}

@test "csm tmux-profile never replaces a tmux config it does not own" {
  mkdir -p "${TMUX_CONF%/*}"
  printf 'set -g mouse off\n' > "$TMUX_CONF"
  run_tmux_profile full
  [ "$status" -ne 0 ]
  [[ "$output" == *"is not a Dev Fortress link"* ]]
  [ "$(cat "$TMUX_CONF")" = "set -g mouse off" ]

  rm "$TMUX_CONF"
  printf 'set -g mouse off\n' > "$HOME/.tmux.conf"
  run_tmux_profile full
  [ "$status" -ne 0 ]
  [[ "$output" == *".tmux.conf exists"* ]]
  assert_path_not_exists "$TMUX_CONF"
}

@test "csm tmux-profile reloads a running tmux server" {
  TMUX_BIN="/home/linuxbrew/.linuxbrew/bin/tmux"
  [[ -x "$TMUX_BIN" ]] || TMUX_BIN="$(command -v tmux || true)"
  [[ -n "$TMUX_BIN" ]] || skip "tmux is not installed"
  export HOMEBREW_PREFIX="${TMUX_BIN%/bin/tmux}"

  "$TMUX_BIN" -f /dev/null new-session -d -s csm-test
  run_tmux_profile full
  [ "$status" -eq 0 ]
  [[ "$output" == *"reloaded the running tmux server"* ]]
  [ "$("$TMUX_BIN" show -gv @csm_test_profile)" = "full" ]
}

@test "Tab completes csm tmux-profile with none and the installed profiles" {
  local repo_root
  repo_root="$(shell_config_repo_root)"
  printf 'ZDOTDIR=%q\nfpath=(%q $fpath)\nautoload -Uz _csm\ncompdef _csm csm\n' \
    "$repo_root/zsh-clean" "$repo_root/shared/completions" > "$TEST_ROOT/complete-setup.zsh"

  run /bin/zsh "$repo_root/tests/support/capture-completion.zsh" "$TEST_ROOT/complete-setup.zsh" 'csm tmux-profile '
  [ "$status" -eq 0 ]
  [[ "$output" == *$'\nnone'* ]]
  [[ "$output" == *$'\nfull\n'* ]]
  [[ "$output" == *'minimal'* ]]
}
