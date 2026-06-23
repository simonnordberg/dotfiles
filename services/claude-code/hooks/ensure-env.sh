#!/usr/bin/env bash
[ -f .claude/setup-env ] && [ ! -f .claude/.env-ready ] || exit 0
eval "$(cat .claude/setup-env)" >/tmp/cc-setup.log 2>&1 && touch .claude/.env-ready
exit 0
