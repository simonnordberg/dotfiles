---
name: tdd
description: Implement the next step red/green/refactor
disable-model-invocation: true
---
Read .plans/$WT_SLUG/plan.md (or the spec). Next step: write one failing test, show it fail
for the right reason, commit it; write minimal code to pass, show green, commit; refactor
with tests green. Then end with the plan status, explicitly:
- if steps remain: "Step done. Remaining: <checklist>. Next: <the next step>." (run /tdd again)
- if none remain: "Last step done -- feature complete. Ready to /ship."
Never stop without saying which of these it is.
