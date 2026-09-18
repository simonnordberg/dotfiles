---
name: prototype
description: >
  Build throwaway code to answer a design question before committing to a spec or
  implementation. Use when the user wants to sanity-check whether a state model works
  or explore what a UI should look like.
disable-model-invocation: true
model: claude-sonnet-5
effort: medium
---
Question: $ARGUMENTS

A prototype is throwaway code that answers a question. The question decides the shape.

## Pick a branch

Determine which question is being answered:

- **"Does this logic / state model work?"** Build a single HTML file with buttons that
  push the state machine through edge cases. Surface full state after every action.
  A non-developer should be able to drive it.

- **"What should this look like?"** Generate several radically different UI variations
  on a single route, switchable via a URL search param and a floating bottom bar.

If the question is ambiguous, default to whichever branch matches the surrounding code
(backend module = logic; page or component = UI) and state the assumption.

## Rules

1. Throwaway from day one. Locate it near the module or page it prototypes, named so
   a reader can tell it is a prototype.
2. Trivial to run. One command or double-click an HTML file. No setup.
3. No persistence. State lives in memory only.
4. No tests, no error handling beyond what makes it runnable, no abstractions.
5. Surface the state. After every action (logic) or on every variant switch (UI),
   render the full relevant state so the user sees what changed.

## When done

1. Commit everything to a `prototype/<slug>` branch (never main).
2. Write `.plans/<slug>/prototype.md` recording: the question, what was learned, which
   decisions are now settled.
3. Tell the user: fold validated decisions into the spec, leave the prototype on its
   branch as a primary source.
