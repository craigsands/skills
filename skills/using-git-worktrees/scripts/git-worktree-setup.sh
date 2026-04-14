#!/usr/bin/env bash
# git-worktree-setup
# ==================
# Create an isolated git worktree for a feature branch
#
# USAGE
#   git-worktree-setup.sh <branch-name>
#
# Worktrees are always created at <repo-root>/.worktrees/<branch-name>,
# branching from the latest origin/HEAD (fetched before creation).
# Ensures .worktrees/ is in .gitignore, committing it if missing.
# Idempotent: exists cleanly if already inside a worktree for the given branch
#
# EXIT CODES
#   0 Worktree ready (created or already exists)
#   1 Error

set -euo pipefail

info()  { echo "==> $*"; }
error() { echo "ERROR: $*" >&2; exit 1; }

[[ $# -lt 1 ]] && error "Usage: git-worktree-setup <branch-name>"

BRANCH="$1"

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || error "Not inside a git repository"

# -- Prune stale worktree metadata ----------------------------------------------

git -C "$REPO_ROOT" worktree prune

# -- Idempotency ----------------------------------------------------------------

WT_PATH="$REPO_ROOT/.worktrees/$BRANCH"

if [[ -d "$WT_PATH" ]]; then
    info "Worktree already exists at $WT_PATH"
    echo "$WT_PATH"
    exit 0
fi

# -- Gitignore ------------------------------------------------------------------

if ! grep -qx '\.worktrees/' "$REPO_ROOT/.gitignore" 2>/dev/null; then
    info ".worktrees is not git-ignored - adding to .gitignore"
    echo ".worktrees/" >> "$REPO_ROOT/.gitignore"
fi

# -- Resolve default branch -----------------------------------------------------

DEFAULT_BRANCH="$(git -C "$REPO_ROOT" remote show origin | grep 'HEAD branch' | awk '{print $NF}')"

info "Branching from $DEFAULT_BRANCH"
git -C "$REPO_ROOT" fetch origin "$DEFAULT_BRANCH" --quiet

# -- Create Worktree ------------------------------------------------------------

if git -C "$REPO_ROOT" show-ref --verify --quiet "refs/heads/$BRANCH"; then
    info "Branch $BRANCH already exists - creating worktree from it"
    git -C "$REPO_ROOT" worktree add "$WT_PATH" "$BRANCH"
else
    info "Creating worktree at $WT_PATH on branch $BRANCH"
    git -C "$REPO_ROOT" worktree add "$WT_PATH" -b "$BRANCH" "origin/$DEFAULT_BRANCH"
fi

# -- Done -----------------------------------------------------------------------

info "Worktree ready at $WT_PATH"
echo "$WT_PATH"
