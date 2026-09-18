---
name: map
description: >
  Chart a fog-of-war map for efforts too big to scope in one /spec session.
  Resolves decision tickets one at a time until the way to the destination is clear.
argument-hint: <idea or slug>
disable-model-invocation: true
---
Idea: $ARGUMENTS
Here: !`"$HOME/.claude/bin/wt" here 2>/dev/null || echo "No worktree context"`

Check if `.plans/<slug>/map.md` already exists for this slug. If yes, go to Resume mode.
If no (or the argument is a loose idea, not a slug), go to Chart mode.

## Chart mode

A loose idea has arrived, too big for one session. The way from here to the destination
is not visible yet.

1. Pick a short kebab-case slug (same convention as /spec).
2. Interview using a design tree. Every decision branches into the decisions that hang
   off it. Work the tree in frontier-based rounds: the frontier is every decision whose
   prerequisites are already settled. Ask the whole frontier in one round, numbered,
   with your recommended answer for each. Wait for the user's answers before the next
   round. Recompute the frontier after each round.

   Finding facts is your job: dispatch Explore or fork subagents to look things up.
   Don't ask the user for anything you could find yourself. Decisions are the user's:
   put each to them and wait.

   No question cap. Done when the frontier is empty.

3. Write `.plans/<slug>/map.md`:

   ```
   ## Destination

   <what "done" looks like: one or two lines>

   ## Decisions so far

   <one line per resolved question, linking to its ticket file>

   ## Not yet specified

   <fog: in-scope decisions you can tell are coming but can't pin down yet>

   ## Out of scope

   <work ruled beyond the destination>
   ```

4. Write ticket files under `.plans/<slug>/tickets/` for decisions that can be specified
   now. One file per decision, named `<NN>-<kebab-name>.md`. Each file contains:

   ```
   ---
   type: research | prototype | grilling | task
   status: open
   ---

   ## Question

   <the decision or investigation this ticket resolves>
   ```

   Types:
   - **research** (background): reading docs or code to surface a fact. Fire `/research`
     for these immediately as background subagents.
   - **prototype** (interactive): make something concrete to react to. Resolved via
     `/prototype`.
   - **grilling** (interactive): conversation. The default.
   - **task** (either): manual work that must happen before a decision can be made.

5. Stop. Tell the user:
   - `/map <slug>` to resume and work the next ticket
   - `/spec <slug>` once the fog clears and the destination is visible

## Resume mode

1. Read `.plans/<slug>/map.md` and scan `.plans/<slug>/tickets/` for open tickets.
2. Pick the first open ticket (or the one the user named in the argument).
3. Resolve it:
   - research: fire `/research` as a background subagent
   - prototype: tell the user to run `/prototype`
   - grilling: interview using the same frontier-based design tree pattern
   - task: do it if possible, otherwise hand the user a precise checklist
4. Update the ticket file: set `status: resolved`, add a `## Resolution` section with
   the answer.
5. Update `map.md`: add the resolution to "Decisions so far".
6. Graduate any fog: if the resolution makes new decisions specifiable, create new ticket
   files. Remove graduated items from "Not yet specified".
7. Stop. Report what was resolved and what is next on the frontier.
