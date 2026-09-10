---
name: build
description: Plan, implement, and ship a spec'd slug headlessly, per repo in merge order
argument-hint: <slug> [plan|tdd|ship|all] [repo]
disable-model-invocation: true
---
Run `"$HOME/.claude/bin/wt" run $ARGUMENTS` with the Monitor tool (not background Bash).
Set `persistent: true` and timeout to 3600000. Use description "build <slug>" (fill in the
actual slug). Each stdout line is a progress notification that surfaces in this session:
phase starts/ends, step counts, BLOCKs, and failures.

Tell me it's running. Detailed logs are at .plans/<slug>/<repo>/log/.

When it finishes, report the summary (the `== <slug> ==` block at the end) verbatim: per
repo, steps done, BLOCKED questions, PR URLs. For a BLOCKED repo, tell me to answer the
question in that plan.md, delete the BLOCKED line, and run `/build <slug>` again, or
`/work <slug> <repo>` to continue by hand.

Do not run /steps, /tdd, or /ship yourself in this session.
