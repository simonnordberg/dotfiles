---
name: review
description: >
  Two-axis code review: Standards (does the code follow repo conventions?) and
  Spec (does the code match what was asked for?). Runs both as parallel sub-agents
  and reports side by side. Use when the user wants a second opinion on a branch,
  PR, or work-in-progress changes.
argument-hint: "[PR URL or number | branch | commit]"
disable-model-invocation: true
---
Target: $ARGUMENTS

Two-axis review of the diff between HEAD and a fixed point:

- **Standards**: does the code conform to this repo's documented coding standards?
- **Spec**: does the code faithfully implement the originating issue / spec?

Both axes run as parallel sub-agents so they don't pollute each other's context, then
this skill aggregates their findings.

## Process

### 0. Resolve the target

Detect the target type from the argument:

**GitHub PR** (URL contains `github.com`, or bare `#<number>` when `git remote` points to GitHub):
1. `gh pr view <number> --json number,title,body,headRefName,baseRefName` for metadata.
2. The PR body becomes the spec source (step 2).
3. The fixed point is the base branch.
4. `gh pr diff <number>` for the diff.

**Codebahn PR** (URL contains `codebahn.net`):
1. Use the Codebahn MCP tools (`get_pull_request_by_index`, `get_pull_request_diff`)
   to fetch metadata and diff.
2. The PR body becomes the spec source (step 2).
3. The fixed point is the base branch.

**Branch, tag, or commit SHA**: use it as the fixed point directly.

**No argument**: ask for one.

### 1. Pin the fixed point

Capture the diff command: `git diff <fixed-point>...HEAD` (three-dot, merge-base comparison).
Also note the commit list: `git log <fixed-point>..HEAD --oneline`.

Confirm the fixed point resolves (`git rev-parse`) and the diff is non-empty. A bad ref
or empty diff should fail here, not inside two parallel sub-agents.

### 2. Identify the spec source

Look for the originating spec, in this order:

1. PR body from step 0 (if target was a PR).
2. Issue references in the commit messages (`#123`, `Closes #45`, etc.), fetched via `gh issue view`.
3. A path the user passed as an argument.
4. A spec file under `.plans/`, `docs/`, `specs/`, or `.scratch/` matching the branch name or feature.
5. If nothing is found, ask the user. If they say there isn't one, the Spec sub-agent
   skips and reports "no spec available".

### 3. Identify the standards sources

Anything in the repo that documents how code should be written: `CLAUDE.md`,
`CODING_STANDARDS.md`, `CONTRIBUTING.md`, etc.

On top of whatever the repo documents, the Standards axis always carries the smell
baseline below: a fixed set of Fowler code smells (Refactoring, ch.3) that applies even
when a repo documents nothing. Two rules:

- **The repo overrides.** A documented repo standard always wins; where it endorses
  something the baseline would flag, suppress the smell.
- **Always a judgement call.** Each smell is a labelled heuristic ("possible Feature
  Envy"), never a hard violation. Skip anything tooling already enforces.

Each smell: what it is, how to fix:

- **Mysterious Name**: a function, variable, or type whose name doesn't reveal what it does or holds. Rename it; if no honest name comes, the design is murky.
- **Duplicated Code**: the same logic shape appears in more than one hunk or file in the change. Extract the shared shape, call it from both.
- **Feature Envy**: a method that reaches into another object's data more than its own. Move the method onto the data it envies.
- **Data Clumps**: the same few fields or params keep travelling together (a type wanting to be born). Bundle them into one type, pass that.
- **Primitive Obsession**: a primitive or string standing in for a domain concept that deserves its own type. Give the concept its own small type.
- **Repeated Switches**: the same switch/if-cascade on the same type recurs across the change. Replace with polymorphism, or one map both sites share.
- **Shotgun Surgery**: one logical change forces scattered edits across many files in the diff. Gather what changes together into one module.
- **Divergent Change**: one file or module is edited for several unrelated reasons. Split so each module changes for one reason.
- **Speculative Generality**: abstraction, parameters, or hooks added for needs the spec doesn't have. Delete it; inline back until a real need shows.
- **Message Chains**: long `a.b().c().d()` navigation the caller shouldn't depend on. Hide the walk behind one method on the first object.
- **Middle Man**: a class or function that mostly just delegates onward. Cut it, call the real target direct.
- **Refused Bequest**: a subclass or implementer that ignores or overrides most of what it inherits. Drop the inheritance, use composition.

### 4. Spawn both sub-agents in parallel

**Standards sub-agent prompt** should include:

- The full diff command and commit list.
- The list of standards-source files you found in step 3, plus the smell baseline from
  step 3 pasted in full (the sub-agent has no other access to it).
- The brief: "Report, per file/hunk where relevant, (a) every place the diff violates a
  documented standard: cite the standard (file + the rule); and (b) any baseline smell
  you spot: name it and quote the hunk. Distinguish hard violations from judgement calls:
  documented-standard breaches can be hard, but baseline smells are always judgement
  calls, and a documented repo standard overrides the baseline. Skip anything tooling
  enforces. Under 400 words."

**Spec sub-agent prompt** should include:

- The diff command and commit list.
- The path or fetched contents of the spec.
- The brief: "Report: (a) requirements the spec asked for that are missing or partial;
  (b) behaviour in the diff that wasn't asked for (scope creep); (c) requirements that
  look implemented but where the implementation looks wrong. Quote the spec line for each
  finding. Under 400 words."

If the spec is missing, skip the Spec sub-agent and note this in the final report.

### 5. Aggregate

Present the two reports under `## Standards` and `## Spec` headings, verbatim or lightly
cleaned. Do not merge or rerank findings, because the two axes are deliberately separate.

End with a one-line summary: total findings per axis, and the worst issue within each
axis (if any). Don't pick a single winner across axes.

## Why two axes

A change can pass one axis and fail the other:

- Code that follows every standard but implements the wrong thing: Standards pass, Spec fail.
- Code that does exactly what the issue asked but breaks conventions: Spec pass, Standards fail.

Reporting them separately stops one axis from masking the other.
