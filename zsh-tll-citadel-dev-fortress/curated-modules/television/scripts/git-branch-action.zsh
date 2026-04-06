#!/usr/bin/env zsh

emulate -LR zsh
setopt errexit nounset pipefail

typeset -gr SCRIPT_DIR="${0:A:h}"
typeset -gr TELEVISION_ROOT="${SCRIPT_DIR:h}"
typeset -gr GIT_FUNCTIONS_DIR="${TELEVISION_ROOT:h}/git/functions"
typeset -gr GIT_MODULE_FILE="${TELEVISION_ROOT:h}/git/module.zsh"

fpath=("${GIT_FUNCTIONS_DIR}" ${fpath})
source "${GIT_MODULE_FILE}"

usage() {
  print -u2 -- 'usage: git-branch-action.zsh <checkout|delete|force-delete|cleanup> <branch>'
}

main() {
  local action_name="${1:-}"
  local branch_name="${2:-}"
  local base_branch=''

  [[ -n "${action_name}" && -n "${branch_name}" ]] || {
    usage
    return 1
  }

  command git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    print -u2 -- 'git-branch-action.zsh: not inside a git repository'
    return 1
  }

  base_branch="$(git-primary-branch)"

  case "${action_name}" in
    checkout)
      command git switch "${branch_name}"
      ;;
    delete)
      if [[ "$(command git branch --show-current 2>/dev/null)" == "${branch_name}" ]]; then
        command git switch "${base_branch}"
      fi
      command git branch -d "${branch_name}"
      ;;
    force-delete)
      if [[ "$(command git branch --show-current 2>/dev/null)" == "${branch_name}" ]]; then
        command git switch "${base_branch}"
      fi
      command git branch -D "${branch_name}"
      ;;
    cleanup)
      if [[ "${branch_name}" == *--wip-* ]]; then
        greframe-rollback "${branch_name}"
        return 0
      fi

      if command git merge-base --is-ancestor "${branch_name}" "${base_branch}"; then
        gdone "${branch_name}" --force --keep-remote
        return 0
      fi

      if command git diff --quiet "${base_branch}" "${branch_name}" >/dev/null 2>&1; then
        if [[ "$(command git branch --show-current 2>/dev/null)" == "${branch_name}" ]]; then
          command git switch "${base_branch}"
        fi
        command git branch -D "${branch_name}"
        return 0
      fi

      if [[ -z "$(command git cherry "${base_branch}" "${branch_name}" 2>/dev/null | command awk '$1 != "-" { print; exit 0 }')" ]]; then
        if [[ "$(command git branch --show-current 2>/dev/null)" == "${branch_name}" ]]; then
          command git switch "${base_branch}"
        fi
        command git branch -D "${branch_name}"
        return 0
      fi

      print -u2 -- "git-branch-action.zsh: branch is not a cleanup candidate: ${branch_name}"
      return 1
      ;;
    *)
      usage
      return 1
      ;;
  esac
}

main "$@"
