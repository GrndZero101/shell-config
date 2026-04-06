# Test Harness

This directory contains the repo-native test harness for `shell-config`.

Current layers:

- `tests/bats/` for the main `bats-core` suite surface
- `tests/bats/test_helper.bash` for isolated XDG-home fixtures and assertions
- `tests/docker/` for clean-room container smoke wrappers
- `tests/run.zsh` for the repo-owned runner

Design intent:

- keep the actual behavior under test shell-native and agent-friendly
- use `bats-core` for readable suite output and structured test files
- keep `gum` optional and limited to local human-friendly runner polish
- avoid making Dev Fortress a dependency of the shell-config test harness

Current covered flows:

- `csm bootstrap`
- `csm select`
- curated module enable, install, sync, and removal
- `csm reset-profile`
- fortress live-shell module resolution in `fortress-hud` and `fortress-debug-interactive`

Run the suite from the repo root with:

```sh
./tests/run.zsh
```

Run the Ubuntu clean-room smoke path with:

```sh
./tests/run.zsh --docker-ubuntu
```

If `gum` is unavailable, the suite still runs with plain terminal output.

Current gap:

- the clean-room smoke layer currently focuses on Ubuntu first
- fuller TTY-heavy interaction coverage is still milestone work
