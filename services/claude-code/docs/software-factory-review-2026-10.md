# Software factory review: what the field says, what we have, what to change

Date: 2026-10-28. Scope: the `services/claude-code` line (`/map`, `/spec`, `/build`, `wt`,
the reviewer, hooks) against writing from roughly the last 30 days on solo and small-team
software factories.

## TL;DR

- The design you have is the design the field converged on this month: spec written
  through an interview, fresh headless session per step, files on disk as the only state,
  deterministic gates in hooks, a fresh-context reviewer, a human who merges. Keep it.
- Both complaints have one root cause each, and neither needs new machinery.
  - "What was decided and excluded?" is unanswerable because nothing in the spec has an
    identity. Number requirements, decisions (with the rejected alternative) and exclusions.
    Make the machine write down every decision it takes during a build.
  - "Valid blockers survive the first loop" because review is one pass, one lens, told to
    pre-filter for precision, over the whole feature, without running anything. Run three
    lenses in parallel, make a per-requirement coverage table mandatory, make the logic lens
    execute tests and the feature, and let the fix round (which already proves findings with
    failing tests) be the filter.
- Two things already built are not wired in: `wt acceptance` is never called by the runner,
  and `/prototype` and `/research` outputs are read only on the map path.
- Order: spec shape and DECIDED lines (half a day), then the three-lens review and
  acceptance in ship, then the spec critic and the learning ratchet. Measure one number:
  blockers you find on the PR that the line did not. It should be zero most weeks.

## 1. What the field said in the last 30 days

Sources are listed in section 5. Dates verified against the page are marked; where the site
blocked fetching, the claim is from search snippets and secondary coverage and is marked
(snippet).

### 1.1 The shape everyone converged on

1. **A factory is a loop with gates, not a swarm.** "A single coding agent is not a
   factory" (awesome-software-factories index). Will Larson: "looping on a broad goal, and
   relying on the harness to drive progress" (Sept, snippet). The counter-voices are just as
   loud: Pieter Levels (Sept 4) calls factories over-engineering for indies; Paul Iusztin
   (O'Reilly, Sept 4): "the first version was so overbuilt I stopped using it"; disler's
   super-simple-software-factory README: overkill for one-off features. Thoughtworks (Jain,
   ~Oct 13, secondary): a frontier model passed 178 hidden acceptance tests with or without a
   harness at 7x the cost; a cheaper model went 3/10 to 10/10 with one. The harness earns its
   cost on the cheap model and on the verification, not on the frontier model's reasoning.
2. **Prompts advise, hooks enforce.** Claude Code best practices (current, verified): "If you
   keep adding emphasis to a CLAUDE.md line and Claude still misses it, that's a sign the
   line belongs in a hook." mini-software-factory: "Skills advise, hooks enforce." zeroshot:
   "Prompts are suggestions. Graphs are enforced." Eysermans (madewithlove, Oct, snippet): a
   prompt-line "don't skip review" guardrail worked briefly and decayed. New in Claude Code
   this window: `onFailure: "block"` on command hooks (v2.1.295, Oct 8), so a crashed gate
   blocks instead of passing.
3. **Scope is a written artifact the agent is bound to.** Best practices: "Interview me until
   you could write the spec, then write it to SPEC.md"; then a fresh session builds from it,
   and the reviewer is pointed at it. Finn-loop: numbered `AC-N` and non-goals `NG-N`; "If it
   is not in the Linear issue, it does not exist"; a PR comment cannot expand scope, only
   editing the issue can. Osmani's factory: agents "may not quietly widen their scope";
   issues missing a fact are parked with the question. The docs also warn that boundaries
   stated in conversation are lost on compaction; anything that must hold goes in a rule.
4. **Decisions are recorded where the next station reads them.** ai-light-factory: the
   decision interview writes ADRs, and "every decision appears in the PR body: what was
   fixed, what was left for you, and what was dropped and why." mini-software-factory:
   "Every station ends by committing a file the next station reads. The chain of commits is
   the audit trail." Osmani: handoffs carry expected files, completion condition, gate level
   and a confidence rating. Thorsten Ball (Oct 25, verified): "Threads are your company
   memory", linked to commits.
5. **Fresh-context reviewer that did not write the code, before the PR exists.** Anthropic,
   "How the Claude Code team does code review" (Oct 15; primary page not fetchable, six
   consistent secondaries): give Claude something it can run and ask for the output, then
   "a subagent reviews the diff with fresh context"; on the PR, "agents hunt for bugs in
   parallel, other agents vote on each finding, only the survivors get posted"; a risk
   classifier decides 0, 1 or 2 human approvals. Simon Willison's pull-quote (Oct 16): review
   "runs continuously, more like spellcheck while you write". Fabrika (Tatiyants, ~Oct 7,
   snippet): builder and checker on different model lineages; an "oracle" writes acceptance
   tests from the spec alone and never sees the implementation. paddo.dev (Oct 27, snippet)
   pushes back: fresh context in the same model family is weaker than a second family.
6. **Evidence, not claims.** Best practices: "give Claude something it can run... ask it to
   show the output." loki-mode: "Your agent says done. Loki proves it"; a fail-to-pass gate
   (the new test must fail on the old code). disler: "Gates verify claims, never
   predictions." Osmani: the strongest check is to revert the fix and confirm the new test
   fails. Komuves (Oct 25, snippet): agent code review is only the first step; the gate is
   behavior proven by e2e tests. Claude Code `/verify` runs the app and observes; a user
   skill named `verify` is now run before every commit (v2.1.286, Sept 30).
7. **Verified findings only; the reviewer must name a failure path.** Code Review GA (Oct 15,
   verified): Find in parallel, Verify (drops false positives), Rank, Post. self-review
   plugin: "A finder has to describe a concrete way the code fails"; rounds continue only
   while a severity-weighted score keeps falling; "hitting the round limit is never reported
   as clean." Best practices: ask for correctness gaps "and skip style", because "a reviewer
   that's asked to find problems will always find something."
8. **Bounded loops, explicit exits, escalate with the open list.** `/goal` conditions with
   "or stop after N turns"; Stop-hook block cap; DevJom factory-skill: max 2 fix rounds then
   "needs you"; ai-light-factory: "agents should wait for a human decision rather than guess
   one"; Osmani: `STOP_IF` caps on items awaiting review, because "the binding constraint on a
   factory is not how many agents can run, it is how many decisions are pending your
   judgment."
9. **Human attention is tiered by risk, and humans merge.** Osmani: "autonomy follows
   consequence, not difficulty"; "merge is never automated, on any tier." DevJom's approver
   escalates auth, payments, migrations, CI and new deps even when every reviewer passed.
   Ball: review by hand only the handful of central files plus migrations. Code Review and
   Copilot review never approve or block a PR.
10. **Instructions decay; test and prune them.** Ball: blind control-vs-treatment tests of
    whether AGENTS.md and skills are used at all. Huntley (Oct 16, snippet): delete AGENTS.md
    and most skills after every model release and redo them. Komuves's "learn" level: mine
    post-merge findings into prompts so the same miss does not recur. Claude Code added
    `/doctor prompt-audit` (v2.1.283, Sept 25) for exactly this.

### 1.2 What is new in Claude Code itself (Sept 17 to Oct 27, verified from the changelog)

- Stop and SubagentStop hooks block a session from ending (exit 2 or `{"decision":"block"}`);
  `/goal <condition>` has a separate model judge the done condition each turn.
- `onFailure: "block"` for command and HTTP hooks (v2.1.295).
- A user or project skill named `verify` is run before commits (v2.1.286).
- `/code-review [low..max] [--fix] [--comment] [--max-findings n|all]` runs in a fresh forked
  subagent; medium and up also report CLAUDE.md-convention findings (v2.1.290).
- Agent tool got `effort` (v2.1.292); subagent frontmatter got `autoCompactWindow`
  (v2.1.296), `memory: user|project|local`, `isolation: worktree`, `omitClaudeMd`.
- Managed Code Review on GitHub is Team and Enterprise only, never fails the check, and
  reads REVIEW.md. Not for a solo Pro or Max account; `claude-code-action` with your own key
  running `/code-review --comment` is the solo equivalent.
- `/doctor prompt-audit` flags stale prompting patterns in CLAUDE.md, skills and agents.

### 1.3 What this means for a solo line, in one paragraph

Nothing in the window argues for more orchestration than you have. The arguments are about
three things you can change without touching the runner: give scope an identity that every
later station cites; make the reviewer prove coverage and run the code rather than read it;
and treat what you find after the loop as input to the loop. The Jain result is the sharpest
warning: when the implementer is a cheaper model, the harness and the hidden tests are what
make it pass, so the review and acceptance side is where the budget belongs.

## 2. What exists today (services/claude-code)

### The line

```
/map   (optional) frontier interview for epics -> map.md + tickets/  (research | prototype | grilling | task)
/spec  2 rounds x 3 questions -> spec.md (purpose, decisions, files, reuse, out of scope, seams, E2E:) + order.md
/build wt run <slug>, detached under systemd, per repo in merge order:
         plan   /steps  (opus, high)   -> plan.md: 5-8 slices of 2-3 behaviors, each with Test:/Check:; reviewer checks plan vs spec
         tdd    /tdd    (sonnet, med)  x slice, fresh session each; red/green/refactor; wt check --quick; <=2 /fix check
         ship   rebase; wt check (<=2 /fix check); reviewer (fable, high) on whole diff; /fix review proves BLOCKER/MAJOR
                with a failing test or marks false positive; one re-review of fix commits only; spec E2E: once;
                push + PR with reviewer summary + review; poll CI; <=2 /fix ci
/work  enter a worktree by hand; /review runs the same reviewer on any branch
```

Everything headless is one fresh `claude -p` per step, driven by files under `.plans/<slug>/`
(spec.md, order.md, <repo>/plan.md, review.md, check.log, ci.log, pr.md, log/*.jsonl,
sessions.tsv). Nothing depends on a live conversation. That is the strongest property of the
current design and matches what the field converged on this month (see section 1).

### Gates (deterministic, not model-judged)

- `check-push.sh`: no `git push` from Claude unless the tree is clean and `wt check`
  (`.claude/check` = exactly what CI runs) is green.
- `format.sh`: every edit formatted with the repo's own formatter.
- `reviewer-pin.sh`: the reviewer always runs on the pinned model.
- `sync-base.sh`: a stale branch is called out at session start.
- Runner rules: a session that makes no progress blocks instead of being rerun; red after
  two fix sessions blocks; a BLOCKED line stops the run until a human clears it.

### Artifacts a human can read

spec.md, order.md, plan.md (ticked with shas), review.md (findings + Resolution + re-review),
pr.md, run.log, sessions.tsv (cost per session). The PR body carries the summary, merge
order, e2e result and the full review.

### What is good and should stay

1. Files on disk, fresh context per step, deterministic runner. Do not trade this for a
   long-lived "orchestrator agent".
2. The push gate on `.claude/check`. One definition of done, enforced by a hook, not a prompt.
3. Reviewer with evidence-only findings, severity vocabulary, and the "prove it with a
   failing test or drop it as a false positive" fix round. This is the right shape; the
   problem is recall, not shape.
4. Plan review against the spec before any code.
5. Slices with named tests; one session per slice; shas recorded in the plan.
6. BLOCKED as a first-class outcome at every phase.
7. `/map` for epics: frontier-based decision tree, one ticket per decision with a
   Resolution. This is already the best scoping tool in the repo, and it is under-used
   because `/spec` throws its structure away (see gaps).

### Unwired or half-built

- `wt acceptance` and the acceptance runner contract (added 2026-10-27) are not called
  anywhere in `wt run`. The ship phase runs only `wt check`, the reviewer, and the spec's
  single `E2E:` line.
- `/prototype` writes `prototype.md` with "which decisions are now settled", but `/spec`
  only reads it on the map path.
- `/research` findings land in `.plans/<slug>/research/`, read only on the map path.
## 3. Gaps, mapped to the two complaints

### 3.1 "Hard to grasp what was decided, included, excluded"

Root cause: the spec is prose with no fixed shape, and decisions have no identity.

- **No numbered requirements.** spec.md has "purpose; decisions; files; reuse; out of
  scope; E2E". Nothing is enumerated, so nothing downstream can point back at it. The plan
  says "nothing outside the spec" and the reviewer says "a requirement the diff misses",
  but neither can produce a coverage table because there is no list to cover.
- **Decisions lose their alternatives.** The interview settles trade-offs, the spec records
  the winner, the losers and the reason vanish. Six weeks later "why not X?" is unanswerable
  from the artifact. `/map` tickets do keep the Resolution, but `/spec` folds them into prose
  and the ticket link is gone.
- **Two rules contradict each other on ambiguity.** Global CLAUDE.md: "When requirements are
  ambiguous, make a reasonable decision and move on." `/tdd` and `/steps`: "don't guess,
  BLOCKED". The global rule is loaded in every headless session, so a sonnet slice session
  has permission to decide silently. Those silent decisions are exactly the "what was
  decided?" you cannot find later, and often the blockers you find at PR time.
- **Out of scope is written once, by the agent.** It is the reviewer's authority on what not
  to raise, yet it is the section you least control: it is whatever the agent inferred from
  two question rounds. Nothing forces an explicit "we considered X and excluded it because".
- **The interview is capped (2 rounds x 3) regardless of size.** Right for a small feature,
  wrong for anything epic-shaped, and `/map` (uncapped) is a separate entry point you have
  to remember to choose.
- **Nothing reviews the spec itself.** The plan gets a reviewer pass; the spec, the document
  you spend the most time on, gets none. Ambiguities and untestable criteria flow straight
  into `/steps`, where opus resolves them its own way.

### 3.2 "Validation lacks; I or a second agent still find valid blockers"

Root cause: one static pass, one perspective, tuned for precision, over the largest
possible diff, with no runtime evidence.

- **Precision bias in the reviewer prompt.** "Drop the ones it already handles; if you can't
  show it, drop it; zero findings is valid; don't pad; one thorough pass beats several."
  Every one of these lowers false positives and also lowers recall. The fix round already
  handles false positives (prove with a failing test or discard), so the reviewer is being
  told to pre-filter twice. The second filter is where blockers go missing.
- **One reviewer, one context, whole feature.** Recall of a single LLM review pass is
  well below 100% on a 5-8 slice diff; independent passes with fresh context find
  substantially different sets (this is the whole premise of `/code-review` at higher
  effort levels and of every "N reviewers then dedupe" writeup this month). The line runs
  exactly one.
- **Review happens only at ship.** Slices are implemented by sonnet at medium effort and
  ticked after `wt check --quick`. No one looks at a slice until all of them exist, so a
  wrong decision in slice 2 is built on by slices 3-8 and shows up as several findings at
  once, or as a design finding too big for the "prove it with a test" fix round.
- **The reviewer never runs anything.** It has Bash but is told to read the diff and its
  surroundings. It does not run the tests, mutate the code to see tests fail, start the
  service, or hit the endpoint. The `E2E:` line is one command, run once, after review.
  `wt acceptance` exists but is not in the loop.
- **No spec coverage check.** "SPEC" findings depend on the reviewer noticing an omission
  in prose. Without numbered criteria there is no mechanical "every AC has a test, name it".
- **No learning loop.** When you find a blocker in the PR, nothing turns it into a reviewer
  rule, a test, or a plan-review check. The reviewer agent starts from the same prompt every
  run. The global CLAUDE.md says to save lessons to auto-memory, but that is the
  interactive session's memory, not the reviewer's.
- **Re-review scope is fix commits only.** Correct by design, but a fix that is right in
  isolation and wrong in combination with another fix is out of its view. Minor.
## 4. Proposal

Principle: change the shape of the documents and the review loop, not the machinery. `wt`,
the headless-step design, the push gate, and the slice vocabulary stay. Every change below is
a prompt or a markdown convention plus, at most, a few dozen lines of `wt`. Nothing new runs
as a daemon, nothing needs a new tool.

### 4.1 Give every scope decision an identity

Replace the free-form spec with a fixed shape. Same file, same path, same frozen-after-
validation rule.

```
# <title>

## Purpose
Two lines. Who, what changes for them, why now.

## Requirements
R1. One sentence, observable, testable.
R2. ...

## Decisions
D1. <decision>. Rejected: <alternative> because <reason>.   (you)
D2. ...                                                     (agent, confirmed)

## Out of scope
X1. <thing>, because <reason>. Where it would go instead, if anywhere.

## Open questions
(must be empty before /build; the runner refuses otherwise)

## Reuse            file:line refs, as today
## Seams            as today, multi-repo only
E2E: <command>      as today
```

Why ids: everything downstream can point at them.

- `/steps`: each slice lists the R-ids it delivers. A plan that leaves an R-id uncovered is
  BLOCKED, mechanically (grep), not by judgement.
- The reviewer gets a mandatory `## Coverage` section: one line per R-id, either the test
  that proves it (`R3: TestPushRateLimit_PerTenant auth/limit_test.go:41`) or `MISSING`.
  MISSING is a BLOCKER by definition. This is the single change that most directly attacks
  "valid blockers not caught": it turns "did the reviewer notice an omission?" into "did the
  reviewer fill the table?".
- The reviewer cites X-ids when it declines to raise something, and D-ids when the diff
  contradicts a decision.
- The PR body (pr.md) prints Requirements, Decisions and Out of scope verbatim, then four
  buckets the field agrees on: decided during build (4.2), fixed after review (with shas),
  dismissed as false positive (with why), left for you (MINOR, NIT, anything BLOCKED and
  cleared by hand). You review the PR with the contract on screen, not from memory.

Each decision records the alternative and the reason in one line. That is the whole
"decision log": no ADR directory, no extra file. `/map` tickets already hold this; `/spec`
on the map path copies the ticket id into the D line (`D4 (ticket 03-auth-model)`).

### 4.2 Let the machine decide, but never silently

Resolve the contradiction between the global CLAUDE.md ("make a reasonable decision and
move on") and the headless skills ("BLOCKED"). Rule for every headless skill:

- If the ambiguity changes behavior a requirement covers: `BLOCKED:` as today.
- Otherwise decide, and write `  DECIDED: <what>, because <why>` under the slice in plan.md,
  same convention as BLOCKED.

`wt` collects DECIDED lines (one grep) into a "Decisions made during build" section of
pr.md, and the reviewer's spec lens (4.4) reviews them against the spec. You read that
section first. Everything the machine chose without you is in one place, every time.

The global CLAUDE.md line changes to: "In an interactive session, decide and say so. In a
headless step, DECIDED or BLOCKED; never silent."

### 4.3 Review the spec before you validate it

Add one step to `/spec`, between the interview and the stop: a fresh reviewer subagent
(the existing `reviewer`, with a short "spec review" section added to its prompt) reads
spec.md plus the Explore digest and returns only:

- requirements that are not testable as written
- requirements that contradict each other, a decision, or something in the code
- an edge case no requirement covers (empty, duplicate, concurrent, failure mid-way, permissions)
- a decision with no rejected alternative, or an out-of-scope line with no reason
- anything a headless step would have to guess

`/spec` folds these into one more round of questions for you. The interview cap becomes
"two rounds, plus whatever the critic finds". This moves work from "what you find in the
PR" to "what you decide in the spec", which is where you said you want to spend time.
No new agent, no new tool; one subagent call and a prompt section.

### 4.4 Review with three lenses, and let the fix round be the filter

The current reviewer is one pass, told repeatedly to drop anything it cannot prove. Keep the
evidence standard, drop the pre-filtering, and run three fresh contexts in parallel with
different questions:

| Lens | Reads | Asks |
|---|---|---|
| spec | spec.md, plan.md (DECIDED lines), diff | Coverage table. Every DECIDED line: consistent with D and X ids? Anything built outside R-ids? |
| logic | diff + callers, then runs the tests and the E2E command | Inputs and sequences that break it. Run the suite; run the feature; try the boundary inputs. Show output. |
| quality | diff, repo CLAUDE.md, existing helpers | Tests that cannot fail; missed reuse (file:line); rule violations; security. |

Each writes its own findings in the existing format. `wt` concatenates them into review.md
with a lens header per section. `/fix review` already proves every BLOCKER/MAJOR with a
failing test or discards it as a false positive, and now also dedupes ("one fix per defect;
findings from two lenses that describe the same defect are one finding"). One re-review of
the fix commits, as today, by one reviewer.

Cost: roughly three times the review tokens. Review is the cheapest phase in sessions.tsv;
the expensive thing is a blocker found by you after the PR exists.

Three changes to the reviewer prompt itself:

- Remove "if you can't show it, drop it", "zero findings is valid", "don't pad". Replace
  with: "Report everything you can point at a line for; the fix round proves or discards."
- The logic lens must run: `wt check --quick`, the E2E command, and the acceptance suite if
  present, and quote output. A reviewer that only reads is a linter with opinions.
- `## Coverage` is mandatory (4.1).

Also wire what is already built: `wt acceptance` runs in ship between check and review, and
the E2E command runs before the review (so the logic lens sees its output) as well as after
the fix round. The acceptance contract exists; the runner never calls it.

### 4.5 Acceptance written from the spec, by a session that never sees the code

The acceptance runner contract shipped yesterday already has the one property that makes
this work: `--paths` names the files a build must not change. Use it as the "oracle" the
field describes (Fabrika; loki's fail-to-pass gate; the Jain result that hidden tests are the
arbiter):

- In the plan phase, after `/steps`, one extra headless session writes acceptance scenarios
  from spec.md alone: one scenario per R-id, named `R3: ...`, committed with the step
  definitions. It never reads the plan or the diff. It runs on the planning model.
- `/tdd` sessions are told the acceptance paths are read-only (a PreToolUse hook on
  Edit|Write against `wt acceptance --paths` makes it enforced, not advised).
- In ship, `wt acceptance` runs between `wt check` and the review. Red blocks, as a red
  check does. The report (one line per scenario, with its R-id) goes into pr.md.

This gives you the mechanical "every requirement has a test the implementer could not bend"
check. It costs one session per repo per feature and ~20 lines of `wt`. For repos without a
suite, nothing changes: `wt acceptance` exits 3 and the line continues.

### 4.6 Catch it in the slice, not at ship

Blockers compound: slice 2's wrong assumption is slice 3 to 8's foundation. Two cheap
measures, no new review sessions:

- A `verify` skill. Claude Code now runs a user skill named `verify` before commits (since
  v2.1.286). Ours: `wt check --quick`, then re-read the slice diff against the slice's
  behaviors and R-ids and list any behavior with no assertion that would fail. The
  session fixes before it commits. Same context, no extra session.
- A Stop hook for headless sessions when `WT_SLUG` is set: `wt check --quick` red means
  exit 2 with the failing lines on stderr, so the session keeps working instead of ending
  and paying for a fresh `/fix check`. Bounded by the stop-hook block cap (8 by default).
  Deterministic, in the harness, not in a prompt.

Optional knob, measure before turning: `/tdd` runs on sonnet at medium. If the three-lens
review keeps finding LOGIC blockers, raise the implementer before adding more review.
sessions.tsv already records cost per session; review.md records findings. Compare over
five features.

### 4.7 A ratchet for what you find

The loop never learns from your PR comments. Add the smallest possible memory:

- `services/claude-code/agents/review-checklist.md`: a list, one line per class of miss,
  grouped by lens, read by the reviewer (`@review-checklist.md` from the agent prompt).
  Keep it under 40 lines; prune when a line stops firing.
- `/miss <what you found>`: appends a line to the checklist and, when the miss was a class
  the plan review or the spec critic should have caught, proposes the corresponding line
  for their sections. One skill, ten lines.
- Track one number per feature, in review.md: findings you raised on the PR that the line
  did not. The target is that this is zero most of the time. If it is not trending down
  after five features, the lens prompts are wrong, not the number of lenses.

### 4.8 Remove or leave alone

- Leave `wt` alone beyond the ~80 lines above (acceptance call, oracle session, DECIDED
  grep, three reviewer sessions, pr.md sections, Stop hook env).
- Do not add the managed Code Review service: it is Team/Enterprise only and
  its check never fails a PR anyway. A `claude-code-action` job running `/code-review` on
  PR open is a cheap fourth opinion if you want one in CI; it is not required.
- Run `/doctor prompt-audit` once over the skills; the reviewer and `/tdd` prompts predate
  the current guidance and will have stale emphasis patterns.
- The saas-*, naming, spark, product-partner skills are not part of the line; untouched.

### 4.9 Order of work

1. Spec shape (4.1) + DECIDED (4.2) + pr.md sections. Prompts and one grep. Half a day.
   Immediately fixes "what was decided and excluded".
2. Three lenses + Coverage + acceptance/E2E in ship + reviewer prompt trim (4.4). One
   `wt` change. Expect the first feature to show more findings, not fewer; that is the
   point.
3. Acceptance oracle in plan and ship (4.5). One session, one hook, one grep.
4. Spec critic (4.3), `verify` skill and Stop hook (4.6), `/miss` and the checklist (4.7).
5. After five features: read sessions.tsv and the miss counts; decide on the implementer
   model.
## 5. Sources

Verified means the page was fetched and the date read from it. Snippet means the site
blocked fetching from this environment and the claim comes from search results and
secondary coverage.

Anthropic and Claude Code
- Claude Code best practices (current; verified): https://code.claude.com/docs/en/best-practices
- Changelog, Sept 17 to Oct 27 entries (verified): https://code.claude.com/docs/en/changelog
- Hooks reference (verified): https://code.claude.com/docs/en/hooks
- Subagents (verified): https://code.claude.com/docs/en/sub-agents
- Skills (verified): https://code.claude.com/docs/en/skills
- Local code review (verified): https://code.claude.com/docs/en/code-review-local
- Managed Code Review (verified): https://code.claude.com/docs/en/code-review
- Code Review GA, Oct 15 (verified): https://claude.com/resources/articles/code-review-is-now-generally-available
- "How the Claude Code team does code review", Oct 15 (primary not fetchable; via Simon
  Willison Oct 16 https://simonwillison.net/2026/Oct/16/code-review/ and others)
- "Redesigning source control at Anthropic", Oct 13 (verified): https://www.anthropic.com/engineering/redesigning-source-control

Practitioners, in window
- Addy Osmani, factory (README verified): https://github.com/addyosmani/factory
- Addy Osmani, "Human judgment doesn't leave the software factory. It relocates", O'Reilly, Sept 25 (snippet)
- Thorsten Ball, "How I work with Agents", Oct 25 (verified via transcription): https://x.com/thorstenball/status/2114386050638336082
- Alex Tatiyants, "I Built a Software Factory" (Fabrika), ~Oct 7 (snippet): https://tatiyants.com/fabrika-software-factory/
- Akos Komuves, "How to Create Your Own Software Factory", ~Oct 25 (snippet): https://akoskm.substack.com/p/how-to-create-your-own-software-factory
- paddo.dev, "I Built the Factory", Oct 17, and "Claude Reviewing Claude", ~Oct 27 (snippet)
- Peter Eysermans, "Owning the software factory", Oct (snippet)
- Will Larson, "Trying the Software Factory pattern", ~Sept (snippet): https://lethain.com/software-factory-experiment/
- Pieter Levels on software factories, Sept 4 (snippet); Paul Iusztin, "Inside a Software Factory", O'Reilly, Sept 4 (snippet)
- Naresh Jain, "Are Harnesses Worth the Cost?", martinfowler.com, ~Oct 13 (secondary)
- Giles Edwards-Alexander, "An Accidental Blackboard", martinfowler.com, ~Oct 13 (secondary)
- Geoffrey Huntley, "state of agentic coding #11", Oct 16 (snippet): https://ghuntley.com/toronto/
- ZazenCodes, "Build Your Own Software Factory with Claude Code", ~Oct 7 (snippet); fork DevJom/factory-skill (README verified): https://github.com/DevJom/factory-skill
- LaunchDarkly, "Build a software factory small enough to understand", Oct 2 (snippet)

Repos (README verified, undated or near window)
- https://github.com/varun1505/awesome-software-factories
- https://github.com/lmagsino/ai-light-factory
- https://github.com/jintomjose/mini-software-factory
- https://github.com/disler/super-simple-software-factory
- https://github.com/finna/Finn-loop
- https://github.com/HoussemDjeghri/self-review
- https://github.com/the-open-engine/zeroshot
- https://github.com/asklokesh/loki-mode

Not found in the window: new workflow posts from Kent Beck, Birgitta Böckeler, Peter
Steinberger, Mitchell Hashimoto, Boris Cherny, Dex Horthy (talk scheduled Nov 4), or a
Yegge/Kim follow-up. The Pragmatic Engineer code-review piece (Sept 8) is paywalled.
