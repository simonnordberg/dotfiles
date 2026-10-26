SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# put <mode> <src> <dest>: copy to a temp name, then rename it over dest. Bash reads a running
# script as it goes, so rewriting wt or a hook in place breaks the builds that are running it.
put() { install -m "$1" "$2" "$3.new.$$" && mv -f "$3.new.$$" "$3"; }

sudo npm install -g @anthropic-ai/claude-code

mkdir -p $HOME/.claude/hooks $HOME/.claude/agents $HOME/.claude/bin

put 644 "$SCRIPT_DIR/settings.json" "$HOME/.claude/settings.json"
put 644 "$SCRIPT_DIR/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
# MCP servers (user scope, available in all projects)
rm -f "$HOME/.claude/.mcp.json"
claude mcp get playwright >/dev/null 2>&1 || claude mcp add --scope user playwright -- npx -y @playwright/mcp@latest
claude mcp get linear >/dev/null 2>&1 || claude mcp add --scope user --transport http linear https://mcp.linear.app/mcp
claude mcp get codebahn >/dev/null 2>&1 || claude mcp add --scope user --transport http codebahn https://codebahn.net/mcp
claude mcp get codebahn-staging >/dev/null 2>&1 || claude mcp add --scope user --transport http codebahn-staging https://staging.codebahn.net/mcp

for f in "$SCRIPT_DIR"/hooks/*.sh; do put 755 "$f" "$HOME/.claude/hooks/${f##*/}"; done

put 755 "$SCRIPT_DIR/bin/wt" "$HOME/.claude/bin/wt"

for f in "$SCRIPT_DIR"/agents/*.md; do put 644 "$f" "$HOME/.claude/agents/${f##*/}"; done

rm -rf "$HOME/.claude/skills"
cp -r "$SCRIPT_DIR/skills" "$HOME/.claude/skills"

# Global gitignore patterns
for pattern in '.claude/worktrees/' '.claude/.env-ready' '.plans/' '.worktrees/'; do
  grep -qxF "$pattern" "$HOME/.gitignore" 2>/dev/null || echo "$pattern" >>"$HOME/.gitignore"
done
git config --global core.excludesfile "$HOME/.gitignore"
