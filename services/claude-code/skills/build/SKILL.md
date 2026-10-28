---
name: build
description: Plan, implement, and ship a spec'd slug in the background, per repo in merge order
argument-hint: <slug> [plan|tdd|ship|all] [repo]
disable-model-invocation: true
---
!`"$HOME/.claude/bin/wt" build $ARGUMENTS 2>&1`

Relay the output above in two or three lines. If it started: it runs detached, so this session
can close; `wt status` lists every feature, `wt watch <slug>` follows this one live, and a
desktop notification arrives when it blocks, fails, or finishes. A BLOCKED repo is resolved by
answering the question in that repo's plan.md, deleting the BLOCKED line, and running
`/build <slug>` again, or `/work <slug> <repo>` to continue by hand.

If it says the slug is already running or has no plans, say so and stop. Do not run /steps,
/tdd, or /fix yourself in this session.

After relaying, update the Linear issue for this slug (search by title or slug in the
description) to "In Progress". If the build finished or failed, update to "Done" or "Cancelled"
and attach the PR URL(s) to the issue.
