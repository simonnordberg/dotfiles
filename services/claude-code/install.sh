SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

sudo npm install -g @anthropic-ai/claude-code

mkdir -p $HOME/.claude/hooks $HOME/.claude/agents

cp $SCRIPT_DIR/settings.json $HOME/.claude/settings.json
cp $SCRIPT_DIR/CLAUDE.md $HOME/.claude/CLAUDE.md
cp $SCRIPT_DIR/mcp.json $HOME/.claude/.mcp.json

cp $SCRIPT_DIR/hooks/*.sh $HOME/.claude/hooks/
chmod +x $HOME/.claude/hooks/*.sh

cp $SCRIPT_DIR/agents/reviewer.md $HOME/.claude/agents/

rm -rf "$HOME/.claude/skills"
cp -r "$SCRIPT_DIR/skills" "$HOME/.claude/skills"

# Global gitignore patterns
for pattern in '.claude/worktrees/' '.claude/.env-ready' '.plans/'; do
  grep -qxF "$pattern" "$HOME/.gitignore" 2>/dev/null || echo "$pattern" >> "$HOME/.gitignore"
done
git config --global core.excludesfile "$HOME/.gitignore"
