SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

sudo npm install -g @anthropic-ai/claude-code

mkdir -p $HOME/.claude
cp $SCRIPT_DIR/settings.json $HOME/.claude/settings.json
cp $SCRIPT_DIR/CLAUDE.md $HOME/.claude/CLAUDE.md
cp $SCRIPT_DIR/mcp.json $HOME/.claude/.mcp.json
rm -rf "$HOME/.claude/skills"
cp -r "$SCRIPT_DIR/skills" "$HOME/.claude/skills"
