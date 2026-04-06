#!/usr/bin/env bats

load test_helper

setup() {
  setup_isolated_shell_config_env
}

teardown() {
  teardown_isolated_shell_config_env
}

@test "csm bootstrap installs selector and csm entrypoint into the isolated home" {
  local repo_root
  repo_root="$(shell_config_repo_root)"

  run_zsh_in_test_env "$repo_root/scripts/csm bootstrap"
  [ "$status" -eq 0 ]

  assert_path_exists "$HOME/.zshenv"
  assert_path_exists "$HOME/.local/bin/csm"
  [ "$(readlink "$HOME/.zshenv")" = "$repo_root/.zshenv" ]
  [ "$(readlink "$HOME/.local/bin/csm")" = "$repo_root/scripts/csm" ]
}

@test "csm select writes the active profile into XDG state instead of the checkout config path" {
  local repo_root
  repo_root="$(shell_config_repo_root)"

  run_zsh_in_test_env "$repo_root/scripts/csm select zsh-zero"
  [ "$status" -eq 0 ]

  assert_path_exists "$XDG_STATE_HOME/shell-config/active-profile"
  assert_path_not_exists "$XDG_CONFIG_HOME/shell-config/active-profile"
  [ "$(cat "$XDG_STATE_HOME/shell-config/active-profile")" = "zsh-zero" ]
}

@test "module lifecycle covers curated enable, local fork install, sync, and removal" {
  local repo_root
  repo_root="$(shell_config_repo_root)"

  run_zsh_in_test_env "$repo_root/scripts/csm enable-module television zsh-tll-citadel-dev-fortress"
  [ "$status" -eq 0 ]
  [[ "$output" == *"enable-module: ensured 'television' is enabled"* ]]

  run_zsh_in_test_env "$repo_root/scripts/csm describe-module television zsh-tll-citadel-dev-fortress"
  [ "$status" -eq 0 ]
  local clean_output
  clean_output="$(strip_ansi "$output")"
  [[ "$clean_output" == *"active:    curated"* ]]

  run_zsh_in_test_env "$repo_root/scripts/csm install-module --force television zsh-tll-citadel-dev-fortress"
  [ "$status" -eq 0 ]
  assert_path_exists "$XDG_CONFIG_HOME/shell-config.local/zsh-tll-citadel-dev-fortress/modules/television.zsh"

  run_zsh_in_test_env "$repo_root/scripts/csm describe-module television zsh-tll-citadel-dev-fortress"
  [ "$status" -eq 0 ]
  clean_output="$(strip_ansi "$output")"
  [[ "$clean_output" == *"active:    local-fork"* ]]
  [[ "$clean_output" == *"shadowing: curated"* ]]

  run_zsh_in_test_env "$repo_root/scripts/csm sync-curated-modules --force zsh-tll-citadel-dev-fortress"
  [ "$status" -eq 0 ]
  [[ "$output" == *"sync-curated-modules: synced module"* ]]

  run_zsh_in_test_env "$repo_root/scripts/csm remove-module --force television zsh-tll-citadel-dev-fortress"
  [ "$status" -eq 0 ]
  assert_path_not_exists "$XDG_CONFIG_HOME/shell-config.local/zsh-tll-citadel-dev-fortress/modules/television.zsh"

  run_zsh_in_test_env "$repo_root/scripts/csm describe-module television zsh-tll-citadel-dev-fortress"
  [ "$status" -eq 0 ]
  clean_output="$(strip_ansi "$output")"
  [[ "$clean_output" == *"active:    curated"* ]]
}

@test "reset-profile preserves shell-config.local by default but removes mutable state" {
  local repo_root
  local profile="zsh-tll-citadel-dev-fortress"
  repo_root="$(shell_config_repo_root)"

  seed_profile_mutable_state "$profile"

  run_zsh_in_test_env "$repo_root/scripts/csm reset-profile --force $profile"
  [ "$status" -eq 0 ]

  assert_path_not_exists "$XDG_STATE_HOME/shell-config/$profile"
  assert_path_not_exists "$XDG_CACHE_HOME/shell-config/$profile"
  assert_path_not_exists "$XDG_DATA_HOME/shell-config/$profile"
  assert_path_exists "$XDG_CONFIG_HOME/shell-config.local/$profile"
  assert_path_exists "$XDG_STATE_HOME/shell-config/shared/history"
}

@test "reset-profile --all --include-local removes selector, shared history, and local overrides" {
  local repo_root
  repo_root="$(shell_config_repo_root)"

  mkdir -p "$XDG_STATE_HOME/shell-config/shared" "$XDG_CONFIG_HOME/shell-config.local/zsh-clean"
  printf 'zsh-clean\n' > "$XDG_STATE_HOME/shell-config/active-profile"
  printf 'shared\n' > "$XDG_STATE_HOME/shell-config/shared/history"
  printf 'settings\n' > "$XDG_CONFIG_HOME/shell-config.local/zsh-clean/settings.zsh"

  run_zsh_in_test_env "$repo_root/scripts/csm reset-profile --all --include-local --force"
  [ "$status" -eq 0 ]

  assert_path_not_exists "$XDG_STATE_HOME/shell-config/active-profile"
  assert_path_not_exists "$XDG_STATE_HOME/shell-config/shared/history"
  assert_path_not_exists "$XDG_CONFIG_HOME/shell-config.local/zsh-clean"
}

@test "fortress debug surfaces show enabled module source and curated shadowing" {
  local repo_root
  local clean_output
  repo_root="$(shell_config_repo_root)"

  run_zsh_in_test_env "$repo_root/scripts/csm bootstrap"
  [ "$status" -eq 0 ]

  mkdir -p "$XDG_STATE_HOME/shell-config"
  printf 'zsh-tll-citadel-dev-fortress\n' > "$XDG_STATE_HOME/shell-config/active-profile"

  run_zsh_in_test_env "$repo_root/scripts/csm enable-module television zsh-tll-citadel-dev-fortress"
  [ "$status" -eq 0 ]

  run_zsh_in_test_env "$repo_root/scripts/csm install-module --force television zsh-tll-citadel-dev-fortress"
  [ "$status" -eq 0 ]

  run_interactive_zsh_in_test_env "fortress-hud"
  [ "$status" -eq 0 ]
  clean_output="$(strip_ansi "$output")"
  [[ "$clean_output" == *"[module_resolution] enabled_count: 1"* ]]
  [[ "$clean_output" == *"[module_resolution] television: active=local-fork shadowing=curated"* ]]

  run_interactive_zsh_in_test_env "fortress-debug-interactive"
  [ "$status" -eq 0 ]
  clean_output="$(strip_ansi "$output")"
  [[ "$clean_output" == *"== Module Resolution =="* ]]
  [[ "$clean_output" == *"television: active=local-fork shadowing=curated"* ]]
}
