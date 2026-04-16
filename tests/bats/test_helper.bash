#!/usr/bin/env bash

# Shared helpers for shell-config bats integration tests.

shell_config_repo_root() {
  cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd
}

setup_isolated_shell_config_env() {
  export TEST_ROOT
  TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/shell-config-test.XXXXXX")"

  export HOME="$TEST_ROOT/home"
  export XDG_CONFIG_HOME="$TEST_ROOT/config"
  export XDG_STATE_HOME="$TEST_ROOT/state"
  export XDG_CACHE_HOME="$TEST_ROOT/cache"
  export XDG_DATA_HOME="$TEST_ROOT/data"
  export XDG_RUNTIME_DIR="$TEST_ROOT/runtime"

  mkdir -p \
    "$HOME" \
    "$XDG_CONFIG_HOME" \
    "$XDG_STATE_HOME" \
    "$XDG_CACHE_HOME" \
    "$XDG_DATA_HOME" \
    "$XDG_RUNTIME_DIR"
}

teardown_isolated_shell_config_env() {
  if [[ -n "${TEST_ROOT:-}" && -d "${TEST_ROOT}" ]]; then
    rm -rf -- "${TEST_ROOT}"
  fi
}

run_zsh_in_test_env() {
  local repo_root
  repo_root="$(shell_config_repo_root)"

  run env \
    HOME="$HOME" \
    XDG_CONFIG_HOME="$XDG_CONFIG_HOME" \
    XDG_STATE_HOME="$XDG_STATE_HOME" \
    XDG_CACHE_HOME="$XDG_CACHE_HOME" \
    XDG_DATA_HOME="$XDG_DATA_HOME" \
    XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
    /bin/zsh -lc "$1"
}

run_interactive_zsh_in_test_env() {
  run env \
    HOME="$HOME" \
    TERM="${TERM:-xterm-256color}" \
    XDG_CONFIG_HOME="$XDG_CONFIG_HOME" \
    XDG_STATE_HOME="$XDG_STATE_HOME" \
    XDG_CACHE_HOME="$XDG_CACHE_HOME" \
    XDG_DATA_HOME="$XDG_DATA_HOME" \
    XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
    /bin/zsh -ic "$1"
}

strip_ansi() {
  printf '%s' "$1" | sed -E $'s/\x1B\\[[0-9;]*[A-Za-z]//g'
}

seed_profile_mutable_state() {
  local profile="$1"

  mkdir -p \
    "$XDG_STATE_HOME/shell-config/$profile" \
    "$XDG_CACHE_HOME/shell-config/$profile" \
    "$XDG_DATA_HOME/shell-config/$profile" \
    "$XDG_RUNTIME_DIR/shell-config-$(id -u)/$profile" \
    "$XDG_CONFIG_HOME/shell-config.local/$profile/functions" \
    "$XDG_CONFIG_HOME/shell-config.local/$profile/modules" \
    "$XDG_STATE_HOME/shell-config/shared"

  printf 'history\n' > "$XDG_STATE_HOME/shell-config/$profile/history"
  printf 'shared\n' > "$XDG_STATE_HOME/shell-config/shared/history"
  printf 'cache\n' > "$XDG_CACHE_HOME/shell-config/$profile/test.txt"
  printf 'data\n' > "$XDG_DATA_HOME/shell-config/$profile/test.txt"
  printf 'runtime\n' > "$XDG_RUNTIME_DIR/shell-config-$(id -u)/$profile/test.txt"
  printf 'settings\n' > "$XDG_CONFIG_HOME/shell-config.local/$profile/settings.zsh"
}

assert_path_exists() {
  local path="$1"
  [[ -e "$path" ]] || fail "expected path to exist: $path"
}

assert_path_not_exists() {
  local path="$1"
  [[ ! -e "$path" ]] || fail "expected path to be absent: $path"
}

setup_git_rewrite_repo() {
  export TEST_GIT_REMOTE="$TEST_ROOT/remote.git"
  export TEST_GIT_REPO="$TEST_ROOT/repo"

  git init --bare "$TEST_GIT_REMOTE"
  git clone "$TEST_GIT_REMOTE" "$TEST_GIT_REPO"
  git -C "$TEST_GIT_REPO" config user.name "Shell Config Test"
  git -C "$TEST_GIT_REPO" config user.email "shell-config@example.test"
  git -C "$TEST_GIT_REPO" checkout -b main
  printf 'base\n' > "$TEST_GIT_REPO/README.md"
  git -C "$TEST_GIT_REPO" add README.md
  git -C "$TEST_GIT_REPO" commit -m "chore: initial commit"
  git -C "$TEST_GIT_REMOTE" symbolic-ref HEAD refs/heads/main
  git -C "$TEST_GIT_REPO" push -u origin main
}

seed_published_feature_branch() {
  local branch_name="$1"

  git -C "$TEST_GIT_REPO" checkout -b "$branch_name"
  printf 'feature one\n' >> "$TEST_GIT_REPO/README.md"
  git -C "$TEST_GIT_REPO" add README.md
  git -C "$TEST_GIT_REPO" commit -m "feat: first branch commit"
  printf 'feature two\n' >> "$TEST_GIT_REPO/README.md"
  git -C "$TEST_GIT_REPO" add README.md
  git -C "$TEST_GIT_REPO" commit -m "feat: second branch commit"
  git -C "$TEST_GIT_REPO" push -u origin "$branch_name"
}

run_fortress_git_module_in_repo() {
  local repo_path="$1"
  local command_string="$2"
  local repo_root
  local git_module_root

  repo_root="$(shell_config_repo_root)"
  git_module_root="$repo_root/zsh-tll-citadel-dev-fortress/curated-modules/git"

  run env \
    HOME="$HOME" \
    XDG_CONFIG_HOME="$XDG_CONFIG_HOME" \
    XDG_STATE_HOME="$XDG_STATE_HOME" \
    XDG_CACHE_HOME="$XDG_CACHE_HOME" \
    XDG_DATA_HOME="$XDG_DATA_HOME" \
    XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
    /bin/zsh -lc "fpath=(\"$git_module_root/functions\" \$fpath); source \"$git_module_root/module.zsh\"; cd \"$repo_path\"; $command_string"
}

run_fortress_sourced_in_repo() {
  local repo_path="$1"
  local source_files="$2"
  local command_string="$3"
  local repo_root
  local git_module_root

  repo_root="$(shell_config_repo_root)"
  git_module_root="$repo_root/zsh-tll-citadel-dev-fortress/curated-modules/git"

  run env \
    HOME="$HOME" \
    XDG_CONFIG_HOME="$XDG_CONFIG_HOME" \
    XDG_STATE_HOME="$XDG_STATE_HOME" \
    XDG_CACHE_HOME="$XDG_CACHE_HOME" \
    XDG_DATA_HOME="$XDG_DATA_HOME" \
    XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
    /bin/zsh -lc "fpath=(\"$git_module_root/functions\" \$fpath); source \"$git_module_root/module.zsh\"; cd \"$repo_path\"; ${source_files}; $command_string"
}
