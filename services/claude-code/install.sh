#!/usr/bin/env bash
# Installs the Claude Code user config from the agent-config repo into ~/.claude.
# Fails closed: nothing is copied or removed until both source repos are present.
set -euo pipefail
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

AGENT_CONFIG_DIR=${AGENT_CONFIG_DIR:-$HOME/code/agent-config}
AGENT_CONFIG_URL=${AGENT_CONFIG_URL:-git@codebahn.net:simon/agent-config.git}
KNOWLEDGE_DIR=${KNOWLEDGE_DIR:-$HOME/code/agent-knowledge}
KNOWLEDGE_URL=${KNOWLEDGE_URL:-git@codebahn.net:simon/agent-knowledge.git}
CLAUDE_DIR=${CLAUDE_DIR:-$HOME/.claude}
GITIGNORE_FILE=${GITIGNORE_FILE:-$HOME/.gitignore}
INSTALL_SKIP_EXTERNAL=${INSTALL_SKIP_EXTERNAL:-0} # 1 skips npm, claude mcp and git config --global (tests)

ensure_repo() { # ensure_repo <dir> <url>: clone when missing, fail loudly when that is impossible
  [ -e "$1/.git" ] && return  # a worktree checkout has a .git file
  if ! git clone -q "$2" "$1"; then
    echo "install: cannot clone $2 into $1; clone it manually and re-run" >&2
    exit 1
  fi
}
ensure_repo "$AGENT_CONFIG_DIR" "$AGENT_CONFIG_URL"
ensure_repo "$KNOWLEDGE_DIR" "$KNOWLEDGE_URL"

if [ "$INSTALL_SKIP_EXTERNAL" != 1 ] && ! command -v claude >/dev/null 2>&1; then
  sudo npm install -g @anthropic-ai/claude-code
fi

mkdir -p "$CLAUDE_DIR/hooks" "$CLAUDE_DIR/agents" "$CLAUDE_DIR/bin" "$CLAUDE_DIR/skills"

cp "$AGENT_CONFIG_DIR/settings.json" "$CLAUDE_DIR/settings.json"
cp "$AGENT_CONFIG_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"

if [ "$INSTALL_SKIP_EXTERNAL" != 1 ]; then
  # MCP servers (user scope, available in all projects)
  rm -f "$CLAUDE_DIR/.mcp.json"
  claude mcp get playwright >/dev/null 2>&1 || claude mcp add --scope user playwright -- npx -y @playwright/mcp@latest
  claude mcp get linear >/dev/null 2>&1 || claude mcp add --scope user --transport http linear https://mcp.linear.app/mcp
  claude mcp get codebahn >/dev/null 2>&1 || claude mcp add --scope user --transport http codebahn https://codebahn.net/mcp
  claude mcp get codebahn-staging >/dev/null 2>&1 || claude mcp add --scope user --transport http codebahn-staging https://staging.codebahn.net/mcp
  claude mcp get accounted >/dev/null 2>&1 || claude mcp add --scope user --transport http accounted "https://app.accounted.se/api/extensions/ext/mcp-server/mcp?tool_namespace=accounted"
fi

cp "$AGENT_CONFIG_DIR"/hooks/*.sh "$CLAUDE_DIR/hooks/"
chmod +x "$CLAUDE_DIR"/hooks/*.sh
# The ensure-env hook was retired. Installs only copy, so drop its stale copy; no generic pruning
# because ~/.claude/hooks may hold hooks that do not come from agent-config.
rm -f "$CLAUDE_DIR/hooks/ensure-env.sh"

cp "$AGENT_CONFIG_DIR/bin/wt" "$CLAUDE_DIR/bin/wt"
chmod +x "$CLAUDE_DIR/bin/wt"

cp "$AGENT_CONFIG_DIR"/agents/*.md "$CLAUDE_DIR/agents/"

# Skills: replace each source skill in place, then drop skills that no longer exist in the source.
# skills/synced is managed by the claude.ai app and top-level files (manifest.json) are left alone.
installed=0 removed=0
for src in "$AGENT_CONFIG_DIR"/skills/*/; do
  name=$(basename "$src")
  rm -rf "${CLAUDE_DIR:?}/skills/$name"
  cp -r "$src" "$CLAUDE_DIR/skills/$name"
  installed=$((installed + 1))
done
for dst in "$CLAUDE_DIR"/skills/*/; do
  name=$(basename "$dst")
  [ "$name" = synced ] && continue
  [ -d "$AGENT_CONFIG_DIR/skills/$name" ] && continue
  rm -rf "${CLAUDE_DIR:?}/skills/$name"
  removed=$((removed + 1))
done

# Global gitignore patterns
for pattern in '.claude/worktrees/' '.plans/' '.worktrees/'; do
  grep -qxF "$pattern" "$GITIGNORE_FILE" 2>/dev/null || echo "$pattern" >>"$GITIGNORE_FILE"
done
[ "$INSTALL_SKIP_EXTERNAL" = 1 ] || git config --global core.excludesfile "$GITIGNORE_FILE"

echo "installed agent-config $(git -C "$AGENT_CONFIG_DIR" rev-parse --short HEAD): $installed skills installed, $removed removed"
