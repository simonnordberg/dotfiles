---
name: debug
description: >
  Structured debugging discipline. Use when the user says "debug", "diagnose",
  or reports something broken, failing, throwing, or slow.
---

# Debug

A discipline for hard bugs. Skip phases only when explicitly justified.

## Phase 1: Build a feedback loop

This is the skill. Everything else is mechanical. A tight pass/fail signal for the bug
makes the cause findable; without one, no amount of staring at code will help.

Spend disproportionate effort here.

### Techniques, roughly in order

1. **Failing test** at whatever seam reaches the bug: unit, integration, e2e.
2. **Curl / HTTP script** against a running dev server.
3. **CLI invocation** with a fixture input, diffing stdout against a known-good snapshot.
4. **Headless browser script** (Playwright / Puppeteer) that drives the UI and asserts on DOM/console/network.
5. **Replay a captured trace.** Save a real request/payload/event log to disk; replay it through the code path in isolation.
6. **Throwaway harness.** Minimal subset of the system that exercises the bug code path with a single function call.
7. **Property / fuzz loop.** If the bug is "sometimes wrong output", run 1000 random inputs and look for the failure mode.
8. **Bisection harness.** If the bug appeared between two known states, automate "boot at state X, check, repeat" so you can `git bisect run` it.
9. **Differential loop.** Run the same input through old-version vs new-version and diff outputs.
10. **HITL script.** Last resort. If a human must click, structure the loop so captured output feeds back to you.

### Tighten the loop

Once you have a loop, tighten it:

- Can I make it faster? (Cache setup, skip unrelated init, narrow test scope.)
- Can I make the signal sharper? (Assert on the specific symptom, not "didn't crash".)
- Can I make it more deterministic? (Pin time, seed RNG, isolate filesystem, freeze network.)

### Non-deterministic bugs

Goal: raise the reproduction rate until the bug is debuggable. Loop the trigger 100x,
parallelize, add stress, narrow timing windows, inject sleeps. A 50%-flake is debuggable;
1% is not.

### When you cannot build a loop

Stop and say so. List what you tried. Ask for: (a) access to the environment that
reproduces it, (b) a redacted captured artifact (HAR file, log dump, core dump), or
(c) permission to add temporary production instrumentation. Do not proceed to hypothesize
without a loop.

### Gate

Phase 1 is done when you can name ONE command that you have already run (show the
invocation and its output) and that is:

- [ ] Red-capable: drives the actual bug code path and asserts the user's exact symptom
- [ ] Deterministic: same verdict every run (flaky bugs: a pinned, high reproduction rate)
- [ ] Fast: seconds, not minutes
- [ ] Agent-runnable: you can run it unattended

If you catch yourself reading code to build a theory before this command exists, stop.
No red-capable command, no Phase 2.

## Phase 2: Reproduce and minimize

Run the loop. Watch it go red.

Confirm:

- [ ] The loop produces the failure mode the user described, not a different failure nearby
- [ ] The failure is reproducible across multiple runs
- [ ] You have captured the exact symptom (error message, wrong output, slow timing)

### Minimize

Cut inputs, callers, config, data, and steps one at a time. Re-run the loop after each
cut. Keep only what is load-bearing for the failure. Done when removing any one element
makes the loop go green.

Do not proceed until you have reproduced and minimized.

## Phase 3: Hypothesize

Generate 3-5 ranked hypotheses before testing any of them.

Each must be falsifiable:
> "If <X> is the cause, then <changing Y> will make the bug disappear / <changing Z> will make it worse."

If you cannot state the prediction, discard or sharpen the hypothesis.

Show the ranked list to the user before testing. They often have domain knowledge that
re-ranks instantly. Don't block on it; proceed with your ranking if the user is AFK.

## Phase 4: Instrument

Each probe must map to a specific prediction from Phase 3. Change one variable at a time.

Tool preference:
1. Debugger / REPL inspection if the env supports it. One breakpoint beats ten logs.
2. Targeted logs at the boundaries that distinguish hypotheses.
3. Never "log everything and grep".

Tag every debug log with a unique prefix: `[DEBUG-xxxx]`. Cleanup becomes a single grep.

For performance regressions: logs are usually wrong. Establish a baseline measurement
(timing harness, profiler, query plan), then bisect. Measure first, fix second.

## Phase 5: Fix and regression test

Write the regression test before the fix, at the correct seam. A correct seam exercises
the real bug pattern as it occurs at the call site. If no correct seam exists, that itself
is the finding; note it and flag the architectural gap.

If a correct seam exists:
1. Turn the minimized repro into a failing test at that seam.
2. Watch it fail.
3. Apply the fix.
4. Watch it pass.
5. Re-run the Phase 1 feedback loop against the original scenario.

## Phase 6: Cleanup

Required before declaring done:

- [ ] Original repro no longer reproduces (re-run the Phase 1 loop)
- [ ] Regression test passes (or absence of seam is documented)
- [ ] All `[DEBUG-xxxx]` instrumentation removed (grep the prefix)
- [ ] Throwaway code deleted
- [ ] Commit message states the confirmed hypothesis
