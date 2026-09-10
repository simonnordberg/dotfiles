---
name: work
description: Enter a slug's worktree for a repo in this session, to drive or unblock it by hand
argument-hint: <slug> [repo]
disable-model-invocation: true
---
Worktree: !`"$HOME/.claude/bin/wt" create $ARGUMENTS 2>&1 || true`

If the line above is an error, show it and stop. Otherwise: if this session is already inside
a worktree, ExitWorktree (keep) first; then EnterWorktree with `path` set to the line above.
Then tell me to run /clear (cheap context; the SessionStart hooks set WT_SLUG and ports
there), and that /tdd and /ship work here. A BLOCKED line in plan.md is resolved by
answering it, deleting the line, and running /tdd.
