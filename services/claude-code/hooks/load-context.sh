#!/usr/bin/env bash
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
echo "Branch: $(git branch --show-current)  (worktree: $(basename "$PWD"))"
git status --porcelain | head -n 20
exit 0
