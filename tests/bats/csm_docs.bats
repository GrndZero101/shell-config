#!/usr/bin/env bats

# csm docs tests.
# Terminal rendering is gated on stdout being a TTY, so those cases run
# through tests/support/run-in-pty.zsh. csm puts /usr/bin and /bin first on
# its PATH, so stub glow and pager commands come from a test directory while
# the less fallback is exercised with the real system less.

load test_helper
bats_require_minimum_version 1.5.0

setup() {
  setup_isolated_shell_config_env
  # A caller-exported theme would change which glow arguments csm builds.
  unset GLAMOUR_STYLE

  STUB_BIN="$TEST_ROOT/stub-bin"
  mkdir -p "$STUB_BIN"
  for stub in glow fakepager; do
    printf '#!/bin/sh\necho "%s:$*"\n' "$stub" > "$STUB_BIN/$stub"
    chmod +x "$STUB_BIN/$stub"
  done
  # Real commands the renderer may need, without the host's glow or pager.
  BASE_PATH="/usr/bin:/bin"
}

teardown() {
  teardown_isolated_shell_config_env
}

# Run csm docs with a pseudo-terminal as stdout.
# Arguments:
#   $1 - PATH to use.
#   $@ - Arguments after `csm docs`.
run_docs_in_pty() {
  local test_path="$1"
  local repo_root
  shift
  repo_root="$(shell_config_repo_root)"

  run env -u PAGER -u GLAMOUR_STYLE \
    PATH="$test_path" \
    TERM="${DOCS_TERM:-xterm-256color}" \
    HOME="$HOME" \
    ${DOCS_PAGER:+PAGER="$DOCS_PAGER"} \
    ${PTY_INPUT:+PTY_INPUT="$PTY_INPUT"} \
    ${DOCS_GLAMOUR_STYLE:+GLAMOUR_STYLE="$DOCS_GLAMOUR_STYLE"} \
    SHELL_CONFIG_PROFILE=zsh-clean \
    /bin/zsh "$repo_root/tests/support/run-in-pty.zsh" "$repo_root/scripts/csm" docs "$@"
}

@test "csm docs prints raw markdown when stdout is not a terminal" {
  local repo_root
  repo_root="$(shell_config_repo_root)"

  run env PATH="$STUB_BIN:$BASE_PATH" HOME="$HOME" SHELL_CONFIG_PROFILE=zsh-clean "$repo_root/scripts/csm" docs brew
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = '# 🍺 brew module' ]
  [[ "$output" != *"glow:"* ]]

  run env PATH="$STUB_BIN:$BASE_PATH" HOME="$HOME" SHELL_CONFIG_PROFILE=zsh-clean "$repo_root/scripts/csm" docs
  [ "${lines[0]}" = '# zsh-clean Usage' ]

  run env PATH="$STUB_BIN:$BASE_PATH" HOME="$HOME" "$repo_root/scripts/csm" docs zsh-zero
  [ "${lines[0]}" = '# zsh-zero Usage' ]
}

@test "csm docs rejects unknown targets and lists what is available" {
  local repo_root
  repo_root="$(shell_config_repo_root)"

  run "$repo_root/scripts/csm" docs nope
  [ "$status" -eq 1 ]
  [[ "$output" == *"no docs for 'nope'"* ]]
  [[ "$output" == *"module guides: brew"* ]]

  run "$repo_root/scripts/csm" docs --bogus
  [ "$status" -eq 1 ]
}

@test "csm docs renders with glow -p on a terminal when glow is installed" {
  local repo_root
  repo_root="$(shell_config_repo_root)"

  run_docs_in_pty "$STUB_BIN:$BASE_PATH" brew
  [ "$status" -eq 0 ]
  [ "$output" = "glow:-p -- $repo_root/zsh-tll-citadel-dev-fortress/curated-modules/brew/README.md" ]

  # glow's CLI ignores GLAMOUR_STYLE, so csm passes it as --style.
  DOCS_GLAMOUR_STYLE=/themes/mocha.json run_docs_in_pty "$STUB_BIN:$BASE_PATH" brew
  [ "$output" = "glow:-p --style /themes/mocha.json -- $repo_root/zsh-tll-citadel-dev-fortress/curated-modules/brew/README.md" ]

  run_docs_in_pty "$STUB_BIN:$BASE_PATH" --plain brew
  [ "${lines[0]}" = '# 🍺 brew module' ]

  # Dumb terminals (editor shells, some CI) get raw markdown, not a pager prompt.
  DOCS_TERM=dumb run_docs_in_pty "$STUB_BIN:$BASE_PATH" brew
  [ "${lines[0]}" = '# 🍺 brew module' ]
}

@test "csm docs falls back to PAGER, then less, without glow" {
  local repo_root no_glow_bin
  [[ ! -x /usr/bin/glow && ! -x /bin/glow ]] || skip 'a system glow is on the base PATH'
  command -v less >/dev/null || skip 'less is not installed'
  repo_root="$(shell_config_repo_root)"
  no_glow_bin="$TEST_ROOT/no-glow-bin"
  mkdir -p "$no_glow_bin"
  cp "$STUB_BIN/fakepager" "$no_glow_bin/"

  DOCS_PAGER='fakepager --flag' run_docs_in_pty "$no_glow_bin:$BASE_PATH" zsh-zero
  [ "$status" -eq 0 ]
  [ "$output" = "fakepager:--flag $repo_root/zsh-zero/USAGE.md" ]

  # Real less shows the raw markdown; `q` quits it so the pty run ends.
  PTY_INPUT=q run_docs_in_pty "$no_glow_bin:$BASE_PATH" zsh-zero
  [ "$status" -eq 0 ]
  [[ "$(strip_ansi "$output")" == *"zsh-zero Usage"* ]]
}

@test "csm docs renders real markdown through real glow (when installed)" {
  local real_glow repo_root
  real_glow="$(command -v glow)" || skip 'glow is not installed'
  repo_root="$(shell_config_repo_root)"
  mkdir -p "$TEST_ROOT/real-glow-bin"
  ln -s "$real_glow" "$TEST_ROOT/real-glow-bin/glow"

  # PAGER=cat lets glow -p render and exit without waiting for a keypress.
  DOCS_PAGER=cat run_docs_in_pty "$TEST_ROOT/real-glow-bin:$BASE_PATH" brew
  [ "$status" -eq 0 ]
  [[ "$(strip_ansi "$output")" == *"brew module"* ]]
  [[ "$(strip_ansi "$output")" != *"# 🍺 brew module"* ]]

  # The vendored Catppuccin Mocha theme renders text in Mocha's #cdd6f4.
  DOCS_PAGER=cat DOCS_GLAMOUR_STYLE="$repo_root/zsh-tll-citadel-dev-fortress/config/glow/catppuccin-mocha.json" \
    run_docs_in_pty "$TEST_ROOT/real-glow-bin:$BASE_PATH" brew
  [ "$status" -eq 0 ]
  [[ "$output" == *$'\e[38;2;205;214;244m'* ]]
}

@test "fortress exports the vendored Catppuccin glamour theme when glow is installed" {
  local repo_root theme
  repo_root="$(shell_config_repo_root)"
  theme="$repo_root/zsh-tll-citadel-dev-fortress/config/glow/catppuccin-mocha.json"
  [ -r "$theme" ]

  run_zsh_in_test_env "$repo_root/scripts/csm bootstrap"
  [ "$status" -eq 0 ]
  mkdir -p "$XDG_STATE_HOME/shell-config" "$HOME/.local/bin"
  printf 'zsh-tll-citadel-dev-fortress\n' > "$XDG_STATE_HOME/shell-config/active-profile"
  cp "$STUB_BIN/glow" "$HOME/.local/bin/glow"

  run_interactive_zsh_in_test_env 'print -r -- "style=$GLAMOUR_STYLE"; fortress-hud'
  [ "$status" -eq 0 ]
  [[ "$output" == *"style=$theme"* ]]
  [[ "$(strip_ansi "$output")" == *"[features] glamour_style: $theme"* ]]

  GLAMOUR_STYLE=dark run_interactive_zsh_in_test_env 'print -r -- "style=$GLAMOUR_STYLE"'
  [[ "$output" == *"style=dark"* ]]
}

@test "Tab completes csm docs with profiles, module guides, and --plain" {
  local repo_root
  repo_root="$(shell_config_repo_root)"
  printf 'ZDOTDIR=%q\nfpath=(%q $fpath)\nautoload -Uz _csm\ncompdef _csm csm\n' \
    "$repo_root/zsh-clean" "$repo_root/shared/completions" > "$TEST_ROOT/complete-setup.zsh"

  run /bin/zsh "$repo_root/tests/support/capture-completion.zsh" "$TEST_ROOT/complete-setup.zsh" 'csm docs '
  [ "$status" -eq 0 ]
  [[ "$output" == *$'\nbrew\n'* ]]
  [[ "$output" == *'--plain'* ]]
  [[ "$output" == *'zsh-tll-citadel-dev-fortress'* ]]
  [[ "$output" != *'docker'* ]]

  run /bin/zsh "$repo_root/tests/support/capture-completion.zsh" "$TEST_ROOT/complete-setup.zsh" 'csm do'
  [[ "$output" == *'docs'* ]]
}
