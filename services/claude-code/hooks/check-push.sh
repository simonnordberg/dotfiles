#!/usr/bin/env bash
# PreToolUse(Bash): a git push needs a clean tree and a green `wt check` (the repo's
# .claude/check, the same commands CI runs), so CI gets exactly what was checked.
WT_BIN=${WT_BIN:-$HOME/.claude/bin/wt}
input=$(cat)
cmd=$(jq -r '.tool_input.command // empty' <<<"$input")
case $cmd in *git*push*) ;; *) exit 0 ;; esac

# Find a segment that runs git push (not one that merely mentions it), and the dir it runs in.
push= dir= seg=
env_re='([A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*[[:space:]]+)*'
wrap_re='((command|exec|env|nohup|timeout([[:space:]]+-[^[:space:]]+)*[[:space:]]+[0-9.]+[smhd]?)[[:space:]]+)*'
push_re="^${env_re}${wrap_re}git([[:space:]]+-C[[:space:]]+([^[:space:]]+))?[[:space:]]+push([[:space:]]|\$)"
cd_re='^cd[[:space:]]+([^[:space:]]+)[[:space:]]*$'
lead_re='^[[:space:]({]*(.*)$'
while IFS= read -r seg; do
  [[ $seg =~ $lead_re ]] && seg=${BASH_REMATCH[1]}
  if [[ $seg =~ $cd_re ]]; then dir=${BASH_REMATCH[1]}
  elif [[ $seg =~ $push_re ]]; then push=$seg; [ -n "${BASH_REMATCH[6]}" ] && dir=${BASH_REMATCH[6]}; break
  fi
done < <(sed -E 's/(&&|\|\||;|\|)/\n/g' <<<"$cmd")
[ -n "$push" ] || exit 0
case " $push " in *' --dry-run '*|*' -n '*|*' --delete '*|*' -d '*|*' :'*) exit 0 ;; esac

cwd=$(jq -r '.cwd // empty' <<<"$input")
dir=${dir//[\"\']/}; dir=${dir/#\~/$HOME}
case $dir in '') dir=${cwd:-$PWD} ;; /*) ;; *) dir=${cwd:-$PWD}/$dir ;; esac
cd "$dir" 2>/dev/null && git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
top=$(git rev-parse --show-toplevel)

dirty=$(git status --porcelain)
if [ -n "$dirty" ]; then
  printf 'Push blocked: uncommitted or untracked files in %s. The check and CI must see the same tree: commit, stash, or gitignore them, then push again.\n%s\n' \
    "$top" "$(head -n 20 <<<"$dirty")" >&2
  exit 2
fi

log=$(git rev-parse --path-format=absolute --git-path wt-check.log)
"$WT_BIN" check >"$log" 2>&1 && exit 0
{ echo "Push blocked: wt check failed in $top. Fix it, commit, and push again. Full output: $log"
  grep -E -A 8 -m 10 -e '^--- FAIL|^FAIL|^panic:' "$log" | head -n 60
  echo "Last lines:"
  tail -n 25 "$log"
} >&2
exit 2
