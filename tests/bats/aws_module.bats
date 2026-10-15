#!/usr/bin/env bats

load test_helper

setup() {
  setup_isolated_shell_config_env
}

teardown() {
  teardown_isolated_shell_config_env
}

@test "aws-login-mode defaults to browser on native-style shells" {
  local repo_root
  repo_root="$(shell_config_repo_root)"

  mkdir -p "$TEST_ROOT/bin"
  cat > "$TEST_ROOT/bin/aws" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
  chmod +x "$TEST_ROOT/bin/aws"

  run env \
    PATH="$TEST_ROOT/bin:$PATH" \
    HOME="$HOME" \
    XDG_CONFIG_HOME="$XDG_CONFIG_HOME" \
    XDG_STATE_HOME="$XDG_STATE_HOME" \
    XDG_CACHE_HOME="$XDG_CACHE_HOME" \
    XDG_DATA_HOME="$XDG_DATA_HOME" \
    XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
    /bin/zsh -lc "fpath=(\"$repo_root/zsh-tll-citadel-dev-fortress/curated-modules/aws/functions\" \$fpath); source \"$repo_root/zsh-tll-citadel-dev-fortress/curated-modules/aws/module.zsh\"; aws-login-mode"
  [ "$status" -eq 0 ]
  [ "$output" = "browser" ]
}

@test "aws-login-mode defaults to device-code in a Dev Fortress workspace shell" {
  local repo_root
  repo_root="$(shell_config_repo_root)"

  mkdir -p "$TEST_ROOT/bin"
  cat > "$TEST_ROOT/bin/aws" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
  chmod +x "$TEST_ROOT/bin/aws"

  run env \
    PATH="$TEST_ROOT/bin:$PATH" \
    DEV_FORTRESS_WORKSPACE=1 \
    HOME="$HOME" \
    XDG_CONFIG_HOME="$XDG_CONFIG_HOME" \
    XDG_STATE_HOME="$XDG_STATE_HOME" \
    XDG_CACHE_HOME="$XDG_CACHE_HOME" \
    XDG_DATA_HOME="$XDG_DATA_HOME" \
    XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
    /bin/zsh -lc "fpath=(\"$repo_root/zsh-tll-citadel-dev-fortress/curated-modules/aws/functions\" \$fpath); source \"$repo_root/zsh-tll-citadel-dev-fortress/curated-modules/aws/module.zsh\"; aws-login-mode"
  [ "$status" -eq 0 ]
  [ "$output" = "device-code" ]
}

@test "aws-login prefers device-code in a Dev Fortress workspace shell" {
  local repo_root
  repo_root="$(shell_config_repo_root)"

  mkdir -p "$TEST_ROOT/bin"
  cat > "$TEST_ROOT/bin/aws" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" > "${TEST_AWS_ARGS_FILE}"
EOF
  chmod +x "$TEST_ROOT/bin/aws"

  run env \
    PATH="$TEST_ROOT/bin:$PATH" \
    DEV_FORTRESS_WORKSPACE=1 \
    TEST_AWS_ARGS_FILE="$TEST_ROOT/aws.args" \
    HOME="$HOME" \
    XDG_CONFIG_HOME="$XDG_CONFIG_HOME" \
    XDG_STATE_HOME="$XDG_STATE_HOME" \
    XDG_CACHE_HOME="$XDG_CACHE_HOME" \
    XDG_DATA_HOME="$XDG_DATA_HOME" \
    XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
    /bin/zsh -lc "fpath=(\"$repo_root/zsh-tll-citadel-dev-fortress/curated-modules/aws/functions\" \$fpath); source \"$repo_root/zsh-tll-citadel-dev-fortress/curated-modules/aws/module.zsh\"; aws-login TBOSS"
  [ "$status" -eq 0 ]
  [ "$(cat "$TEST_ROOT/aws.args")" = "sso login --use-device-code --profile TBOSS" ]
}

@test "aws-login explicit browser mode overrides the workspace default" {
  local repo_root
  repo_root="$(shell_config_repo_root)"

  mkdir -p "$TEST_ROOT/bin"
  cat > "$TEST_ROOT/bin/aws" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" > "${TEST_AWS_ARGS_FILE}"
EOF
  chmod +x "$TEST_ROOT/bin/aws"

  run env \
    PATH="$TEST_ROOT/bin:$PATH" \
    DEV_FORTRESS_WORKSPACE=1 \
    TEST_AWS_ARGS_FILE="$TEST_ROOT/aws.args" \
    HOME="$HOME" \
    XDG_CONFIG_HOME="$XDG_CONFIG_HOME" \
    XDG_STATE_HOME="$XDG_STATE_HOME" \
    XDG_CACHE_HOME="$XDG_CACHE_HOME" \
    XDG_DATA_HOME="$XDG_DATA_HOME" \
    XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
    /bin/zsh -lc "fpath=(\"$repo_root/zsh-tll-citadel-dev-fortress/curated-modules/aws/functions\" \$fpath); source \"$repo_root/zsh-tll-citadel-dev-fortress/curated-modules/aws/module.zsh\"; aws-login --browser TBOSS"
  [ "$status" -eq 0 ]
  [ "$(cat "$TEST_ROOT/aws.args")" = "sso login --profile TBOSS" ]
}
