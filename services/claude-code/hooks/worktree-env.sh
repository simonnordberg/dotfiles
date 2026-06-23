#!/usr/bin/env bash
[ -n "$CLAUDE_ENV_FILE" ] || exit 0
case "$PWD" in *"/.claude/worktrees/"*) ;; *) exit 0 ;; esac   # only in worktrees
name=$(git branch --show-current 2>/dev/null || basename "$PWD")
slug=$(printf '%s' "$name" | tr -c 'A-Za-z0-9' '_' | tr -s '_' | sed 's/^_//;s/_$//' | tr 'A-Z' 'a-z')
h=$(printf '%s' "$slug" | cksum | cut -d' ' -f1)
base=$(( 20000 + (h % 4000) * 10 ))            # 20000..59990, 10 ports per worktree
{ echo "export WT_SLUG=$slug"
  echo "export WT_PORT=$base"                  # primary (e.g. dev server / HTTP)
  echo "export WT_PORT_2=$((base+1))"          # secondary (SSH / debug)
  echo "export WT_PORT_3=$((base+2))"          # tertiary (DB / service host port)
  echo "export COMPOSE_PROJECT_NAME=$slug"     # isolates docker compose stacks
} >> "$CLAUDE_ENV_FILE"
echo "Worktree runtime: slug=$slug, ports from $base, COMPOSE_PROJECT_NAME=$slug"
exit 0
