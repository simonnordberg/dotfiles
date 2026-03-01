SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

sudo npm install -g @anthropic-ai/claude-code

mkdir -p $HOME/.claude
cp $SCRIPT_DIR/settings.json $HOME/.claude/settings.json
cp $SCRIPT_DIR/CLAUDE.md $HOME/CLAUDE.md
