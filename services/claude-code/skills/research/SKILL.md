---
name: research
description: >
  Delegate reading and investigation to a background agent that writes cited findings.
  Use when the user wants a topic researched, docs or API facts gathered, or reading
  legwork offloaded.
disable-model-invocation: true
model: claude-sonnet-5
effort: medium
---
Topic: $ARGUMENTS

Spin up a background fork subagent to do the research so you keep working.

Its job:

1. Investigate the question against primary sources only (official docs, source code,
   specs, first-party APIs). Not secondary write-ups. Follow every claim back to the
   source that owns it.
2. Write findings to a single markdown file, citing each claim's source inline.
3. Save to `.plans/<slug>/research/<question-slug>.md` if a slug context exists in this
   session (check for `.plans/*/map.md` or `.plans/*/spec.md`). Otherwise save to the
   scratchpad directory.

Report the file path when done.
