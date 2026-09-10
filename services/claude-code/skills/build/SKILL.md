---
name: build
description: Plan, implement, and ship a spec'd slug headlessly, per repo in merge order
argument-hint: <slug> [plan|tdd|ship|all] [repo]
disable-model-invocation: true
---
Run `"$HOME/.claude/bin/wt" run $ARGUMENTS` with the Bash tool in the background; it takes
minutes to hours. Say it's running and where the logs are (.plans/<slug>/<repo>/log/).
When it finishes, report its summary verbatim: per repo, steps done, BLOCKED questions, PR
URLs. For a BLOCKED repo, tell me to answer the question in that plan.md, delete the
BLOCKED line, and run `/build <slug>` again, or `/work <slug> <repo>` to continue by hand.
Do not run /steps, /tdd, or /ship yourself in this session.
