# Curated git local module.
# Adds primary-branch, recent-branch, and compact log helpers on top of the fortress git base.
# tags: git, scm, productivity
# environments: local, workstation, container
# requires: git

# Print a consistent greframe error and return failure.
#
# Arguments:
#   $1: Error message to display.
# Returns:
#   1 after printing the error.
# Side effects:
#   Writes to stderr.
git-reframe-fail() {
  print -u2 -- "greframe: $1"
  return 1
}

# Require the current directory to be inside a git repository.
#
# Arguments:
#   None.
# Returns:
#   0 when inside a git repository, otherwise 1.
# Side effects:
#   Runs git rev-parse in the current directory.
git-reframe-require-repo() {
  command git rev-parse --is-inside-work-tree >/dev/null 2>&1 || git-reframe-fail 'not inside a git repository'
}

# Require the current worktree to be clean before mutating branch state.
#
# Arguments:
#   None.
# Returns:
#   0 when the worktree is clean, otherwise 1.
# Side effects:
#   Reads git status from the current repository.
git-reframe-require-clean-worktree() {
  local status_output

  status_output="$(command git status --porcelain --untracked-files=normal 2>/dev/null)" || return 1
  [[ -z "${status_output}" ]] || git-reframe-fail 'worktree is not clean; commit or stash changes first'
}

# Require a local branch name to exist.
#
# Arguments:
#   $1: Branch name to validate.
# Returns:
#   0 when the branch exists locally, otherwise 1.
# Side effects:
#   Reads local refs from the repository.
git-reframe-require-local-branch() {
  local branch_name=$1

  command git show-ref --verify --quiet "refs/heads/${branch_name}" || git-reframe-fail "local branch does not exist: ${branch_name}"
}

# Return success when a branch exists locally or on origin.
#
# Arguments:
#   $1: Branch name to inspect.
# Returns:
#   0 when the branch exists locally or on origin, otherwise 1.
# Side effects:
#   Reads local and remote refs from the repository.
git-reframe-branch-exists-anywhere() {
  local branch_name=$1

  command git show-ref --verify --quiet "refs/heads/${branch_name}" && return 0
  command git show-ref --verify --quiet "refs/remotes/origin/${branch_name}" && return 0
  return 1
}

# Fail when a branch name is already in use locally or on origin.
#
# Arguments:
#   $1: Branch name to validate.
# Returns:
#   0 when the branch name is available, otherwise 1.
# Side effects:
#   Reads local and remote refs from the repository.
git-reframe-require-available-branch() {
  local branch_name=$1

  git-reframe-branch-exists-anywhere "${branch_name}" && git-reframe-fail "branch already exists: ${branch_name}"
  return 0
}

# Resolve the repository's primary branch for greframe workflows.
#
# Arguments:
#   None.
# Returns:
#   0 after printing the branch name, otherwise 1.
# Side effects:
#   Reads git refs from the current repository.
git-reframe-primary-branch() {
  git-primary-branch
}

# Print a unique timestamp suffix for a temporary reframe branch.
#
# Arguments:
#   None.
# Returns:
#   0 after printing the timestamp.
# Side effects:
#   Reads the local system clock.
git-reframe-timestamp() {
  date +%Y%m%d-%H%M
}

# Print the temporary branch name for a requested final branch root.
#
# Arguments:
#   $1: Final branch root.
# Returns:
#   0 after printing the temporary branch name.
# Side effects:
#   Reads the local system clock.
git-reframe-temp-branch-name() {
  local final_branch=$1

  print -r -- "${final_branch}--wip-$(git-reframe-timestamp)"
}

# Persist greframe metadata on a temporary branch.
#
# Arguments:
#   $1: Temporary branch name.
#   $2: Source branch name.
#   $3: Base branch name.
#   $4: Final branch root.
# Returns:
#   0 when metadata is written.
# Side effects:
#   Writes branch-local git config values.
git-reframe-store-metadata() {
  local temp_branch=$1
  local source_branch=$2
  local base_branch=$3
  local final_branch=$4

  command git config "branch.${temp_branch}.fortresssourcebranch" "${source_branch}"
  command git config "branch.${temp_branch}.fortressbasebranch" "${base_branch}"
  command git config "branch.${temp_branch}.fortressfinalbranch" "${final_branch}"
}

# Read one greframe metadata value from branch-local git config.
#
# Arguments:
#   $1: Branch name.
#   $2: Metadata key suffix.
# Returns:
#   0 after printing the value when present, otherwise 1.
# Side effects:
#   Reads branch-local git config values.
git-reframe-read-metadata() {
  local branch_name=$1
  local key_suffix=$2

  command git config --get "branch.${branch_name}.${key_suffix}" 2>/dev/null
}

# Remove greframe metadata from branch-local git config.
#
# Arguments:
#   $1: Branch name.
# Returns:
#   0 regardless of whether metadata existed.
# Side effects:
#   Deletes branch-local git config values when present.
git-reframe-clear-metadata() {
  local branch_name=$1

  command git config --unset-all "branch.${branch_name}.fortresssourcebranch" >/dev/null 2>&1 || true
  command git config --unset-all "branch.${branch_name}.fortressbasebranch" >/dev/null 2>&1 || true
  command git config --unset-all "branch.${branch_name}.fortressfinalbranch" >/dev/null 2>&1 || true
}

# Refresh the base branch from origin with a fast-forward-only update when possible.
#
# Arguments:
#   $1: Base branch name.
# Returns:
#   0 when the base branch is ready, otherwise non-zero.
# Side effects:
#   Fetches from origin, switches branches, and may pull new commits.
git-reframe-sync-base-branch() {
  local base_branch=$1

  command git fetch --prune origin >/dev/null 2>&1 || true
  command git switch "${base_branch}" || return 1

  if command git ls-remote --exit-code --heads origin "${base_branch}" >/dev/null 2>&1; then
    command git pull --ff-only origin "${base_branch}" || return 1
  fi
}

# Print a compact summary of a greframe branch handoff.
#
# Arguments:
#   $1: Label for the branch being reported.
#   $2: Branch name.
# Returns:
#   0 after printing the summary line.
# Side effects:
#   Writes to stdout.
git-reframe-summary-line() {
  local label=$1
  local branch_name=$2

  print -r -- "greframe ${label}: ${branch_name}"
}

autoload -Uz git-primary-branch git-recent-branches git-switch-primary gdone greframe-start greframe-finish greframe-rollback

alias gpb='git-primary-branch'
alias grb='git-recent-branches'
alias gmain='git-switch-primary'
alias gl='git log --oneline --decorate --graph -20'
alias gpff='git pull --ff-only'
alias gps='git push'
