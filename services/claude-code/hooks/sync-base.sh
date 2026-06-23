#!/usr/bin/env bash
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
fh=$(git rev-parse --git-path FETCH_HEAD 2>/dev/null)
[ -f "$fh" ] && [ -z "$(find "$fh" -mmin +10 2>/dev/null)" ] || git fetch --prune --quiet origin 2>/dev/null
def=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's@^origin/@@')
def=${def:-main}; cur=$(git branch --show-current)
behind=$(git rev-list --count "HEAD..origin/$def" 2>/dev/null)
if [ "$cur" = "$def" ] && [ "${behind:-0}" -gt 0 ]; then
  echo "'$def' is $behind behind origin -- pull, or start the feature in a new worktree (it branches from origin)."
elif [ "${behind:-0}" -gt 0 ]; then
  echo "'$cur' is $behind behind origin/$def -- run /rebase before continuing."
fi
exit 0
