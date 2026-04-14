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

# -- Idempotency ----------------------------------------------------------------

GIT_DIR="$(git rev-parse --git-dir 2>/dev/null)"
CURRENT_BRANCH="$(git branch --show-current 2>/dev/null || true)"
if [[ "$GIT_DIR" == *"/.git/worktrees/"* ]] && [[ "$CURRENT_BRANCH" == "$BRANCH" ]]; then
    info "Already inside worktree for branch $BRANCH"
    echo "$(pwd)"
    exit 0
fi

# -- Gitignore ------------------------------------------------------------------

if ! git -C "$REPO_ROOT" check-ignore -q .worktrees 2>/dev/null; then
    info ".worktrees is not git-ignored - adding to .gitignore"
    echo ".worktrees/" >> "$REPO_ROOT/.gitignore"
    git -C "$REPO_ROOT" add .gitignore
    git -C "$REPO_ROOT" commit -m "chore: ignore .worktrees directory"
fi

# -- Resolve default branch -----------------------------------------------------

DEFAULT_BRANCH="$(git -C "$REPO_ROOT" remote show origin | grep 'HEAD branch' | awk '{print $NF}')"

info "Branching from $DEFAULT_BRANCH"
git -C "$REPO_ROOT" fetch origin "$DEFAULT_BRANCH" --quiet

# -- Create Worktree ------------------------------------------------------------

WT_PATH="$REPO_ROOT/.worktrees/$BRANCH"

info "Creating worktree at $WT_PATH on branch $BRANCH"
git -C "$REPO_ROOT" worktree add "$WT_PATH" -b "$BRANCH" "origin/$DEFAULT_BRANCH"

# -- Done -----------------------------------------------------------------------

info "Worktree ready at $WT_PATH"
echo "$WT_PATH"
