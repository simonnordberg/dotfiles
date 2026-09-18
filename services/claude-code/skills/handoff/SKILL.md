---
name: handoff
description: Compress the current conversation into a handoff document for a fresh agent
argument-hint: "[what the next session should focus on]"
disable-model-invocation: true
model: claude-sonnet-5
effort: medium
---

Write a handoff document summarizing the current conversation so a fresh agent can
continue the work.

Include:

- What was accomplished this session
- Open questions and decisions pending
- Current state of .plans/ artifacts (reference by path, don't duplicate content)
- Suggested skills for the next session (e.g. "/tdd", "/ship", "/map <slug>")

Do not duplicate content captured in other artifacts (specs, plans, commits, diffs).
Reference them by path instead.

Redact any sensitive information: API keys, passwords, tokens.

If the user passed arguments, treat them as a description of what the next session should
focus on and tailor the doc accordingly.

Save to `.plans/<slug>/handoff-<YYYY-MM-DD>.md` if a slug context exists in this session.
Otherwise save to the scratchpad directory.
