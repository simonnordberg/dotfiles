---
name: rebase
description: Bring the current branch up to date on the latest default branch
disable-model-invocation: true
---
Fetch origin. Resolve the default branch (origin/HEAD). If the working tree is dirty, stop and
ask me to commit or stash first. Rebase the current branch onto origin/<default>. On conflicts,
stop and show them for me to resolve -- never force or improvise. After a clean rebase, re-run
the project's tests (we use TDD -- the suite must be green) and show the result. Report how many
commits we moved onto and whether tests pass.
