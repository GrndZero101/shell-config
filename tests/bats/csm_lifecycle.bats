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

@test "fortress git module is enabled by default and can be explicitly disabled" {
  local repo_root
  repo_root="$(shell_config_repo_root)"

  run_zsh_in_test_env "$repo_root/scripts/csm list-modules zsh-tll-citadel-dev-fortress"
  [ "$status" -eq 0 ]
  local clean_output
  clean_output="$(strip_ansi "$output")"
  [[ "$clean_output" == *"git                 git, scm, productivity"* ]]
  [[ "$clean_output" == *"enabled"* ]]

  run_zsh_in_test_env "$repo_root/scripts/csm disable-module git zsh-tll-citadel-dev-fortress"
  [ "$status" -eq 0 ]
  [[ "$output" == *"disable-module: ensured 'git' is disabled"* ]]

  run_zsh_in_test_env "$repo_root/scripts/csm list-modules zsh-tll-citadel-dev-fortress"
  [ "$status" -eq 0 ]
  clean_output="$(strip_ansi "$output")"
  [[ "$clean_output" == *"git                 git, scm, productivity"* ]]
  [[ "$clean_output" == *"disabled"* ]]
  assert_path_exists "$XDG_CONFIG_HOME/shell-config.local/zsh-tll-citadel-dev-fortress/env.zsh"
  [[ "$(cat "$XDG_CONFIG_HOME/shell-config.local/zsh-tll-citadel-dev-fortress/env.zsh")" == *"SHELL_FORTRESS_DISABLED_MODULES=(git)"* ]]
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
  [[ "$clean_output" == *"[module_resolution] enabled_count: 2"* ]]
  [[ "$clean_output" == *"[module_resolution] git: active=curated shadowing=no"* ]]
  [[ "$clean_output" == *"[module_resolution] television: active=local-fork shadowing=curated"* ]]
  [[ "$clean_output" == *"[tools] branch_lifecycle: not-in-repo"* ]]

  run_interactive_zsh_in_test_env "fortress-debug-interactive"
  [ "$status" -eq 0 ]
  clean_output="$(strip_ansi "$output")"
  [[ "$clean_output" == *"== Module Resolution =="* ]]
  [[ "$clean_output" == *"== Branch Lifecycle =="* ]]
  [[ "$clean_output" == *"repo: not inside a git repository"* ]]
  [[ "$clean_output" == *"default modules: git"* ]]
  [[ "$clean_output" == *"enabled modules: git, television"* ]]
  [[ "$clean_output" == *"git: active=curated shadowing=no"* ]]
  [[ "$clean_output" == *"television: active=local-fork shadowing=curated"* ]]
}

@test "gbm rewrite reframes an already-pushed branch and stages force-push guidance" {
  local branch_name="feat/m0006-git-flow"
  local source_branch_pattern

  setup_git_rewrite_repo
  seed_published_feature_branch "$branch_name"

  run_fortress_git_module_in_repo \
    "$TEST_GIT_REPO" \
    "gbm rewrite --message 'feat(git): rewrite published branch'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"greframe final: $branch_name"* ]]
  [[ "$output" == *"gbm publish: git push --force-with-lease -u origin $branch_name"* ]]
  [[ "$output" == *"greframe preserved_source: ${branch_name}--src-"* ]]

  [ "$(git -C "$TEST_GIT_REPO" branch --show-current)" = "$branch_name" ]
  [ "$(git -C "$TEST_GIT_REPO" log --format=%s -1 "$branch_name")" = "feat(git): rewrite published branch" ]
  [ "$(git -C "$TEST_GIT_REPO" rev-list --count main..$branch_name)" -eq 1 ]

  source_branch_pattern="$(git -C "$TEST_GIT_REPO" for-each-ref --format='%(refname:short)' "refs/heads/${branch_name}--src-*")"
  [[ -n "$source_branch_pattern" ]]
  [ -z "$(git -C "$TEST_GIT_REPO" for-each-ref --format='%(refname:short)' "refs/heads/${branch_name}--wip-*")" ]
}

@test "gbm list and status classify temp branches and fortress hud surfaces the lifecycle state" {
  local final_branch="feat/m0006-status"

  setup_git_rewrite_repo

  run_fortress_git_module_in_repo \
    "$TEST_GIT_REPO" \
    "gbm start $final_branch"
  [ "$status" -eq 0 ]

  run_fortress_git_module_in_repo \
    "$TEST_GIT_REPO" \
    "gbm list"
  [ "$status" -eq 0 ]
  [[ "$output" == *"gbm primary: main"* ]]
  [[ "$output" == *"${final_branch}--wip-"*" :: temp ${final_branch}"* ]]

  run_fortress_git_module_in_repo \
    "$TEST_GIT_REPO" \
    "gbm status"
  [ "$status" -eq 0 ]
  [[ "$output" == *"gbm status: temp $final_branch"* ]]

  run_fortress_sourced_in_repo \
    "$TEST_GIT_REPO" \
    "source \"$(shell_config_repo_root)/zsh-tll-citadel-dev-fortress/functions/fortress-hud\"" \
    "fortress-hud --standard"
  [ "$status" -eq 0 ]
  [[ "$(strip_ansi "$output")" == *"[tools] branch_lifecycle: ${final_branch}--wip-"*" state=temp ${final_branch}"* ]]
}

@test "gbm start opens a fresh temp branch and gbm finish squashes it into the final branch" {
  local final_branch="feat/m0006-fresh-start"

  setup_git_rewrite_repo

  run_fortress_git_module_in_repo \
    "$TEST_GIT_REPO" \
    "gbm start $final_branch"
  [ "$status" -eq 0 ]
  [[ "$output" == *"greframe temp: ${final_branch}--wip-"* ]]
  [ -n "$(git -C "$TEST_GIT_REPO" branch --show-current | grep -- "${final_branch}--wip-")" ]

  printf 'fresh start\n' >> "$TEST_GIT_REPO/README.md"
  git -C "$TEST_GIT_REPO" add README.md
  git -C "$TEST_GIT_REPO" commit -m "feat: fresh temp work"

  run_fortress_git_module_in_repo \
    "$TEST_GIT_REPO" \
    "gbm finish --message 'feat(git): finish fresh temp branch'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"greframe final: $final_branch"* ]]
  [[ "$output" == *"gbm publish: git push -u origin $final_branch"* ]]
  [ "$(git -C "$TEST_GIT_REPO" branch --show-current)" = "$final_branch" ]
  [ "$(git -C "$TEST_GIT_REPO" log --format=%s -1 "$final_branch")" = "feat(git): finish fresh temp branch" ]
  [ -z "$(git -C "$TEST_GIT_REPO" for-each-ref --format='%(refname:short)' "refs/heads/${final_branch}--wip-*")" ]
}

@test "gbm publish pushes the final branch and gbm land can publish main" {
  local final_branch="feat/m0006-publish"

  setup_git_rewrite_repo

  run_fortress_git_module_in_repo \
    "$TEST_GIT_REPO" \
    "gbm start $final_branch"
  [ "$status" -eq 0 ]

  printf 'publish me\n' >> "$TEST_GIT_REPO/README.md"
  git -C "$TEST_GIT_REPO" add README.md
  git -C "$TEST_GIT_REPO" commit -m "feat: publish flow"

  run_fortress_git_module_in_repo \
    "$TEST_GIT_REPO" \
    "gbm finish --message 'feat(git): publish final branch'"
  [ "$status" -eq 0 ]

  run_fortress_git_module_in_repo \
    "$TEST_GIT_REPO" \
    "gbm publish"
  [ "$status" -eq 0 ]
  [[ "$output" == *"greframe published: origin/$final_branch"* ]]
  [ -n "$(git -C "$TEST_GIT_REPO" for-each-ref --format='%(refname:short)' "refs/remotes/origin/${final_branch}")" ]

  run_fortress_git_module_in_repo \
    "$TEST_GIT_REPO" \
    "gbm land $final_branch --publish"
  [ "$status" -eq 0 ]
  [[ "$output" == *"greframe landed: main"* ]]
  [[ "$output" == *"greframe published: origin/main"* ]]
  [ "$(git -C "$TEST_GIT_REPO" branch --show-current)" = "main" ]
}

@test "gbm rewrite can publish land and drop the renamed source branch" {
  local branch_name="feat/m0006-land"

  setup_git_rewrite_repo
  seed_published_feature_branch "$branch_name"

  run_fortress_git_module_in_repo \
    "$TEST_GIT_REPO" \
    "gbm rewrite --message 'feat(git): land rewritten branch' --publish --land --drop-source"
  [ "$status" -eq 0 ]
  [[ "$output" == *"greframe published_force: origin/$branch_name"* ]]
  [[ "$output" == *"greframe landed: main"* ]]
  [[ "$output" == *"gbm removed local branch: ${branch_name}--src-"* ]]
  [[ "$output" == *"gbm next: git push origin main"* ]]

  [ "$(git -C "$TEST_GIT_REPO" branch --show-current)" = "main" ]
  [[ "$(git -C "$TEST_GIT_REPO" log --format=%s -1 main)" == "Merge branch '$branch_name'"* ]]
  [ -n "$(git -C "$TEST_GIT_REPO" for-each-ref --format='%(refname:short)' "refs/remotes/origin/${branch_name}")" ]
  [ -z "$(git -C "$TEST_GIT_REPO" for-each-ref --format='%(refname:short)' "refs/heads/${branch_name}--src-*")" ]
  [ -z "$(git -C "$TEST_GIT_REPO" for-each-ref --format='%(refname:short)' "refs/heads/${branch_name}--wip-*")" ]
}
