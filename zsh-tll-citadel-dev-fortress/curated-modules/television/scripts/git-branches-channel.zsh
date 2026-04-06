#!/usr/bin/env zsh

emulate -LR zsh
setopt errexit nounset pipefail

git_primary_branch() {
  local origin_head

  origin_head="$(command git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || true)"
  if [[ -n "${origin_head}" ]]; then
    print -r -- "${origin_head#origin/}"
    return 0
  fi

  if command git show-ref --verify --quiet refs/heads/main; then
    print -r -- 'main'
    return 0
  fi
  if command git show-ref --verify --quiet refs/heads/master; then
    print -r -- 'master'
    return 0
  fi

  command git branch --show-current 2>/dev/null
}

branch_remote_state() {
  local branch_name="$1"

  if command git show-ref --verify --quiet "refs/remotes/origin/${branch_name}"; then
    print -r -- 'origin'
  else
    print -r -- 'local'
  fi
}

classify_cleanup() {
  local branch_name="$1"
  local base_branch="$2"
  local cherry_output=''

  if [[ "${branch_name}" == *--wip-* ]]; then
    print -r -- 'temp'
    return 0
  fi

  if command git merge-base --is-ancestor "${branch_name}" "${base_branch}"; then
    print -r -- 'merged'
    return 0
  fi

  if command git diff --quiet "${base_branch}" "${branch_name}" >/dev/null 2>&1; then
    print -r -- 'squash'
    return 0
  fi

  cherry_output="$(command git cherry "${base_branch}" "${branch_name}" 2>/dev/null || true)"
  if [[ -n "${cherry_output}" ]] && [[ -z "$(print -r -- "${cherry_output}" | command awk '$1 != "-" { print; exit 0 }')" ]]; then
    print -r -- 'squash'
    return 0
  fi

  print -r -- 'manual'
}

manage_state_label() {
  local branch_name="$1"
  local base_branch="$2"
  local current_branch="$3"
  local cleanup_state

  if [[ "${branch_name}" == "${current_branch}" && "${branch_name}" == "${base_branch}" ]]; then
    print -r -- 'current+primary'
    return 0
  fi
  if [[ "${branch_name}" == "${current_branch}" ]]; then
    print -r -- 'current'
    return 0
  fi
  if [[ "${branch_name}" == "${base_branch}" ]]; then
    print -r -- 'primary'
    return 0
  fi

  cleanup_state="$(classify_cleanup "${branch_name}" "${base_branch}")"
  if [[ "${cleanup_state}" == 'manual' ]]; then
    print -r -- 'branch'
  else
    print -r -- "${cleanup_state}"
  fi
}

print_manage_source() {
  local mode="$1"
  local base_branch current_branch branch_name state_label remote_state cleanup_state

  base_branch="$(git_primary_branch)"
  current_branch="$(command git branch --show-current 2>/dev/null)"

  while IFS= read -r branch_name; do
    [[ -n "${branch_name}" ]] || continue

    state_label="$(manage_state_label "${branch_name}" "${base_branch}" "${current_branch}")"
    cleanup_state="$(classify_cleanup "${branch_name}" "${base_branch}")"
    remote_state="$(branch_remote_state "${branch_name}")"

    if [[ "${mode}" == 'cleanup' && "${cleanup_state}" == 'manual' ]]; then
      continue
    fi

    print -r -- "${branch_name} ${state_label} ${remote_state} ${cleanup_state}"
  done < <(
    command git for-each-ref \
      --sort=-committerdate \
      --format='%(refname:short)' \
      refs/heads
  )
}

print_cleanup_source() {
  print_manage_source cleanup
}

print_preview() {
  local branch_name="$1"
  local base_branch current_branch remote_state cleanup_state source_branch final_branch

  base_branch="$(git_primary_branch)"
  current_branch="$(command git branch --show-current 2>/dev/null)"
  remote_state="$(branch_remote_state "${branch_name}")"
  cleanup_state="$(classify_cleanup "${branch_name}" "${base_branch}")"
  source_branch="$(command git config --get "branch.${branch_name}.fortresssourcebranch" 2>/dev/null || true)"
  final_branch="$(command git config --get "branch.${branch_name}.fortressfinalbranch" 2>/dev/null || true)"

  print -r -- "branch: ${branch_name}"
  print -r -- "base: ${base_branch}"
  print -r -- "current: $([[ "${branch_name}" == "${current_branch}" ]] && print -r -- yes || print -r -- no)"
  print -r -- "remote: ${remote_state}"
  print -r -- "cleanup: ${cleanup_state}"
  if [[ -n "${source_branch}" ]]; then
    print -r -- "source_branch: ${source_branch}"
  fi
  if [[ -n "${final_branch}" ]]; then
    print -r -- "final_branch: ${final_branch}"
  fi
  print
  command git branch -vv --list -- "${branch_name}"
  print
  command git log --oneline --decorate -n 12 -- "${branch_name}"
}

main() {
  local subcommand="${1:-}"

  command git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    print -u2 -- 'git-branches-channel.zsh: not inside a git repository'
    return 1
  }

  case "${subcommand}" in
    manage-source)
      print_manage_source "${2:-all}"
      ;;
    cleanup-source)
      print_cleanup_source
      ;;
    preview)
      [[ -n "${2:-}" ]] || {
        print -u2 -- 'usage: git-branches-channel.zsh preview <branch>'
        return 1
      }
      print_preview "${2}"
      ;;
    *)
      print -u2 -- 'usage: git-branches-channel.zsh <manage-source|cleanup-source|preview> [...]'
      return 1
      ;;
  esac
}

main "$@"
