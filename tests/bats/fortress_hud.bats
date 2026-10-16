#!/usr/bin/env bats

# Fortress HUD startup and module diagnostics tests.
# Local fixture modules cover each recorded load outcome (loaded, failed,
# skipped by a requires guard, missing) without depending on host tools.

load test_helper

setup() {
  setup_isolated_shell_config_env

  local repo_root
  repo_root="$(shell_config_repo_root)"

  run_zsh_in_test_env "$repo_root/scripts/csm bootstrap"
  [ "$status" -eq 0 ]
  mkdir -p "$XDG_STATE_HOME/shell-config"
  printf 'zsh-tll-citadel-dev-fortress\n' > "$XDG_STATE_HOME/shell-config/active-profile"

  export FORTRESS_LOCAL_DIR="$XDG_CONFIG_HOME/shell-config.local/zsh-tll-citadel-dev-fortress"
  mkdir -p "$FORTRESS_LOCAL_DIR/modules"
}

teardown() {
  teardown_isolated_shell_config_env
}

# Write the fixture modules and enable them alongside the default git module.
seed_fixture_modules() {
  cat > "$FORTRESS_LOCAL_DIR/modules/ok.zsh" <<'EOF'
# Fixture module that loads cleanly.
# requires: zsh
ok-hello() { print hello; }
alias okh='ok-hello'
EOF

  cat > "$FORTRESS_LOCAL_DIR/modules/broken.zsh" <<'EOF'
# Fixture module that fails while loading.
return 3
EOF

  cat > "$FORTRESS_LOCAL_DIR/modules/needs.zsh" <<'EOF'
# Fixture module guarded by an absent command, like the curated modules.
# requires: shell-config-absent-tool
(( $+commands[shell-config-absent-tool] )) || return 0
alias needs-tool='shell-config-absent-tool'
EOF

  printf 'SHELL_FORTRESS_LOCAL_MODULES=(ok broken needs ghost)\n' > "$FORTRESS_LOCAL_DIR/env.zsh"
}

@test "fortress-hud reports startup stage timings and the missing-zinit warning" {
  run_interactive_zsh_in_test_env "fortress-hud"
  [ "$status" -eq 0 ]

  local clean_output stage
  clean_output="$(strip_ansi "$output")"
  [[ "$clean_output" =~ \[startup\]\ zshrc_total:\ [0-9]+\.[0-9]ms ]]
  for stage in 00-environment 10-options 20-history 30-completion 40-bindings 50-prompt 60-tools 70-plugins; do
    [[ "$clean_output" =~ \[startup\]\ ${stage}:\ [0-9]+\.[0-9]ms ]]
  done
  [[ "$clean_output" =~ \[startup\]\ slowest_module:\ git\ \([0-9]+\.[0-9]ms\) ]]
  [[ "$clean_output" == *"[startup] warnings: 1"* ]]
  [[ "$clean_output" == *"[startup] warning: zinit missing at "*"plugins skipped (run: csm install-zinit)"* ]]

  run_interactive_zsh_in_test_env "fortress-hud --pretty"
  [ "$status" -eq 0 ]
  [[ "$(strip_ansi "$output")" == *"Startup"*"zshrc_total: "*"warnings: 1"* ]]
}

@test "fortress-hud --human condenses the HUD to highlights and rejects --env" {
  run_interactive_zsh_in_test_env "fortress-hud --human"
  [ "$status" -eq 0 ]

  local clean_output
  clean_output="$(strip_ansi "$output")"
  [[ "$clean_output" == *"zsh-tll-citadel-dev-fortress"* ]]
  [[ "$clean_output" =~ startup:\ [0-9]+\.[0-9]ms\ \(slowest:\ [0-9a-z-]+\ [0-9]+\.[0-9]ms,\ [0-9a-z-]+\ [0-9]+\.[0-9]ms\) ]]
  [[ "$clean_output" == *"warnings: 1"*"• zinit missing at "* ]]
  [[ "$clean_output" == *"modules: ✓ git"* ]]
  [[ "$clean_output" == *"settings: "* ]]
  [[ "$clean_output" == *"full detail: fortress-hud"* ]]
  # The human view must stay condensed: no full-view section lines.
  [[ "$clean_output" != *"[module_resolution]"* ]]
  [[ "$clean_output" != *"Module Resolution"* ]]
  [[ "$clean_output" != *"history_file"* ]]

  SHELL_FORTRESS_ENABLE_ATUIN=0 run_interactive_zsh_in_test_env "fortress-hud --human"
  [[ "$(strip_ansi "$output")" == *"settings: atuin=off (env)"* ]]

  run_interactive_zsh_in_test_env "fortress-hud --human --env"
  [ "$status" -eq 1 ]
  [[ "$output" == *"--env needs a full view"* ]]
}

@test "fortress-hud and fortress-debug-interactive report each module load outcome" {
  seed_fixture_modules

  run_interactive_zsh_in_test_env "fortress-hud"
  [ "$status" -eq 0 ]

  local clean_output
  clean_output="$(strip_ansi "$output")"
  [[ "$clean_output" == *"[module_resolution] ok: active=local-only shadowing=no local=present curated=absent status=loaded load="*"ms adds=1fn/1alias requires=zsh"* ]]
  [[ "$clean_output" == *"[module_resolution] broken: active=local-only "*" status=failed:3 "*" requires=none"* ]]
  [[ "$clean_output" == *"[module_resolution] needs: active=local-only "*" status=skipped(missing:shell-config-absent-tool) "*"adds=0fn/0alias requires=shell-config-absent-tool"* ]]
  [[ "$clean_output" == *"[module_resolution] ghost: active=missing "*" status=missing load=?ms"* ]]
  [[ "$clean_output" == *"[module_resolution] git: active=curated "*" status=loaded "* ]]
  [[ "$clean_output" == *"[startup] warnings: 3"* ]]
  [[ "$clean_output" == *"[startup] warning: module broken: $FORTRESS_LOCAL_DIR/modules/broken.zsh exited with status 3"* ]]
  [[ "$clean_output" == *"[startup] warning: module ghost: not found at $FORTRESS_LOCAL_DIR/modules/ghost.zsh"* ]]

  run_interactive_zsh_in_test_env "fortress-debug-interactive"
  [ "$status" -eq 0 ]
  [[ "$output" == *"== Startup =="*"zshrc_total_ms: "*"warnings: 3"* ]]
  [[ "$output" == *"broken: active=local-only"*"load_status: failed:3"* ]]
  [[ "$output" == *"ok: active=local-only"*"added: 1 functions, 1 aliases"* ]]

  run_interactive_zsh_in_test_env "fortress-hud --human"
  [ "$status" -eq 0 ]
  clean_output="$(strip_ansi "$output")"
  [[ "$clean_output" == *"✓ ok (local)"*"✗ broken (local) failed:3"*"⊘ needs (local) (missing:shell-config-absent-tool)"*"✗ ghost missing"* ]]
  [[ "$clean_output" == *"warnings: 3"* ]]
}
