SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

sudo npm install -g @anthropic-ai/claude-code

AGENT_CONFIG_DIR=$HOME/code/agent-config

mkdir -p $HOME/.claude/hooks $HOME/.claude/agents $HOME/.claude/bin

cp $AGENT_CONFIG_DIR/settings.json $HOME/.claude/settings.json
cp $AGENT_CONFIG_DIR/CLAUDE.md $HOME/.claude/CLAUDE.md

# MCP servers (user scope, available in all projects)
rm -f "$HOME/.claude/.mcp.json"
claude mcp get playwright >/dev/null 2>&1 || claude mcp add --scope user playwright -- npx -y @playwright/mcp@latest
claude mcp get linear >/dev/null 2>&1 || claude mcp add --scope user --transport http linear https://mcp.linear.app/mcp
claude mcp get codebahn >/dev/null 2>&1 || claude mcp add --scope user --transport http codebahn https://codebahn.net/mcp
claude mcp get codebahn-staging >/dev/null 2>&1 || claude mcp add --scope user --transport http codebahn-staging https://staging.codebahn.net/mcp
claude mcp get accounted >/dev/null 2>&1 || claude mcp add --scope user --transport http accounted "https://app.accounted.se/api/extensions/ext/mcp-server/mcp?tool_namespace=accounted"

cp $AGENT_CONFIG_DIR/hooks/*.sh $HOME/.claude/hooks/
chmod +x $HOME/.claude/hooks/*.sh

cp $AGENT_CONFIG_DIR/bin/wt $HOME/.claude/bin/wt
chmod +x $HOME/.claude/bin/wt

cp $AGENT_CONFIG_DIR/agents/*.md $HOME/.claude/agents/

rm -rf "$HOME/.claude/skills"
cp -r "$AGENT_CONFIG_DIR/skills" "$HOME/.claude/skills"

# Global gitignore patterns
for pattern in '.claude/worktrees/' '.claude/.env-ready' '.plans/' '.worktrees/'; do
  grep -qxF "$pattern" "$HOME/.gitignore" 2>/dev/null || echo "$pattern" >>"$HOME/.gitignore"
done
git config --global core.excludesfile "$HOME/.gitignore"
