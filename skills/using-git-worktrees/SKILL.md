---
name: using-git-worktrees
description: Use whenever writing to any file inside a git repository - editing code, fixing bugs, adding features, updating config, or executing implementation plans. Any write to a git repo means work on a branch in an isolated worktree. Skip only for purely read-only tasks (searching, reading, explaining).
---

# Using Git Worktrees

**Announce at start:** "I'm using the using-git-worktrees skill to set up an isolated workspace."

## Setup

```bash
scripts/git-worktree-setup.sh <branch-name>
```

Worktrees are always created at `<repo-root>/.worktrees/<branch-name>`, branching from the latest `origin/HEAD`. The script ensures `.worktrees/` is in `.gitignore` and is idempotent.

## After Setup

1. `cd` into the reported path
2. If the project has dependencies, inspect the repo to determine how to install them and run it
3. If the project has tests, inspect the repo to determine how to run them and verify a clean baseline - if they fail, report and ask whether to proceed or investigate
