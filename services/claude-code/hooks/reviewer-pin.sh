#!/usr/bin/env bash
# PreToolUse(Agent): the reviewer's model is pinned in agents/reviewer.md, so every review
# (headless or interactive) runs on the same model. A model override is refused.
input=$(cat)
[ "$(jq -r '.tool_input.subagent_type // empty' <<<"$input")" = reviewer ] || exit 0
[ -n "$(jq -r '.tool_input.model // empty' <<<"$input")" ] || exit 0
echo "The reviewer's model is pinned in agents/reviewer.md. Call the reviewer again without the model parameter." >&2
exit 2
