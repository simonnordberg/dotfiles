#!/usr/bin/env bash
[ -n "$CLAUDE_ENV_FILE" ] || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
# linked worktrees only, whatever directory layout they use
[ "$(git rev-parse --path-format=absolute --git-dir)" != "$(git rev-parse --path-format=absolute --git-common-dir)" ] || exit 0
slug=${WT_SLUG:-$("$HOME/.claude/bin/wt" slug 2>/dev/null)}
[ -n "$slug" ] || slug=$(basename "$(git rev-parse --show-toplevel)")
compose=$(printf '%s' "$slug" | tr -c 'A-Za-z0-9' '_' | tr -s '_' | sed 's/^_//;s/_$//' | tr 'A-Z' 'a-z')
h=$(printf '%s' "$compose" | cksum | cut -d' ' -f1)
base=$(( 20000 + (h % 4000) * 10 ))            # 20000..59990, 10 ports per worktree
{ echo "export WT_SLUG=$slug"
  echo "export WT_PORT=$base"                  # primary (e.g. dev server / HTTP)
  echo "export WT_PORT_2=$((base+1))"          # secondary (SSH / debug)
  echo "export WT_PORT_3=$((base+2))"          # tertiary (DB / service host port)
  echo "export COMPOSE_PROJECT_NAME=$compose"  # isolates docker compose stacks
} >> "$CLAUDE_ENV_FILE"
echo "Worktree runtime: slug=$slug, ports from $base, COMPOSE_PROJECT_NAME=$compose"
exit 0
