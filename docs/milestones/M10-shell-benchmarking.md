# M10 Shell Benchmarking

## Status

- [ ] Milestone complete
- [ ] Current milestone
- [x] Next candidate milestone

## Objective

Give `shell-config` a repeatable, low-spec benchmark of interactive shell
latency, so new or changed features show their cost before they land.

## Exit Criteria

- [ ] A repo-owned runner benchmarks `zsh-tll-citadel-dev-fortress` with
  [zsh-bench](https://github.com/romkatv/zsh-bench) inside a resource-capped
  Docker container (default `--cpus=0.5 --memory=2g`, overridable)
- [ ] `zsh-clean` is benchmarked in the same run as a baseline
- [ ] The fortress run includes the real interactive stack: zinit, the
  configured plugins, and the `starship` prompt
- [ ] Output reports `first_prompt_lag_ms`, `first_command_lag_ms`,
  `command_lag_ms`, and `input_lag_ms` per profile next to the zsh-bench
  default thresholds (50, 150, 10, and 20 ms)
- [ ] The runner is opt-in (`./tests/run.zsh --docker-perf`) and report-only;
  it never fails or slows the normal bats suite
- [ ] A baseline for the current `main` is recorded in this file
- [ ] Development docs explain how to run it, how to read the numbers, and
  when to run it (plugin, prompt, module, or startup-path changes)

## Non-Goals

- [ ] Hard pass/fail latency budgets in this milestone; add them later only
  when a baseline shows a margin worth guarding
- [ ] Running the benchmark in CI on shared runners, where timing is noisy
- [ ] Optimizing startup or plugin cost; findings go to the idea pool
- [ ] Measuring host-specific costs such as WSL2 Windows `PATH` hashing, which
  is accepted for the current workstation
- [ ] Full-stack benchmarks of tmux and the wider toolset; that belongs to
  dev-container-fortress

## Design Notes

- Why zsh-bench: `[startup] zshrc_total` in `fortress-hud` covers `.zshrc`
  only. zinit turbo plugins loaded with `wait` (autosuggestions, syntax
  highlighting) and `starship` prompt rendering run after it, and
  `zsh -i -c exit` exits before either. zsh-bench drives a real interactive
  session through a pseudo-terminal and measures what a user feels: time to
  first prompt, time until the first command can run, per-prompt cost, and
  keystroke latency.
- Why low-spec Docker: half a CPU and 2 GB approximates a loaded corporate
  laptop or small VM. If latency is acceptable there, it should be acceptable
  in most environments. A clean container also removes host noise such as WSL2
  Windows `PATH` entries.
- zsh-bench requires zsh 5.8 or newer as the login shell of the benchmarked
  user; the container image sets that up.
- Pin zsh-bench to a specific commit so runs stay comparable over time.
- Report-only first. Treat each run as a comparison against the recorded
  baseline, not an absolute gate.
- Reuse the `tests/docker/` runner pattern from M7 rather than adding a new
  harness.

## Issue Drafts

### M10-1 Capped benchmark container

- [ ] Problem: there is no environment for measuring shell latency on
  constrained hardware
- [ ] Scope: `tests/docker/` perf runner with `--cpus` and `--memory` caps,
  zsh 5.8+ as login shell, the repo mounted read-only, zinit and plugins
  installed, and `starship` available
- [ ] Acceptance: `SHELL_CONFIG_PERF_CPUS` and `SHELL_CONFIG_PERF_MEMORY`
  override the defaults, and the run never reads the host's own shell
  config, state, or history

### M10-2 zsh-bench integration and report

- [ ] Problem: raw zsh-bench output is per-run and hard to compare across
  profiles
- [ ] Scope: pinned zsh-bench checkout, a run per profile (`zsh-clean`,
  `zsh-tll-citadel-dev-fortress`), and a compact table of the four lags
  against the default thresholds
- [ ] Acceptance: `./tests/run.zsh --docker-perf` prints one table and exits 0
  whenever the benchmark itself ran, whatever the latencies

### M10-3 Baseline and docs

- [ ] Problem: numbers mean little without a reference point and guidance
- [ ] Scope: record the current `main` baseline here; add a benchmarking
  section to `tests/README.md` and a pointer from the fortress `USAGE.md`
- [ ] Acceptance: a contributor can tell from the docs whether a change made
  the shell meaningfully heavier

## Verification Notes

- [ ] `zsh -n` passes on the new runner
- [ ] Existing bats suite still passes locally and in `--docker-ubuntu`
- [ ] Two consecutive perf runs on the same host land close enough to compare
- [ ] Baseline recorded with host, Docker caps, and zsh-bench commit

## Branch and Merge Plan

- [ ] Branch from `main` as `feat/m0010-shell-benchmarking`
- [ ] Commit freely at verified checkpoints
- [ ] Squash merge when the exit criteria are met
