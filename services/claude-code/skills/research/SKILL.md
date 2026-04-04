---
name: research
description: >
  Launch an autonomous code-based research project. Writes code, runs experiments,
  collects real data, generates charts, and produces a research report. Use when you
  want to investigate a technical question with actual benchmarks and data.
invocation: /research
---

# Research

Run an autonomous, code-based research investigation. The research repo lives at `~/code/research/`.

## Arguments

`/research <prompt>` — the research question or topic. Be as detailed as possible.

## Steps

1. **Derive a slug** from the prompt (lowercase, hyphenated, max 4 words). Check `~/code/research/` — if the folder already exists, error out.

2. **Create the project folder** at `~/code/research/<slug>/`.

3. **Launch a background agent** to conduct the research. The agent prompt must include the full research question and these instructions:

   ### Working process

   - Work in `~/code/research/<slug>/`.
   - Create a `notes.md` file immediately and **append to it as you work** — track what you tried, what worked, what didn't, and anything you learned. This is your working log.
   - Write and execute real code. Never fabricate data.
   - Be honest about limitations.

   ### Output files

   - `notes.md` — working log (created first, appended throughout)
   - `README.md` — final research report, structured as:
     ```
     # <Title>

     ## Top Finding

     <Single sentence: the most important or surprising result>
     ```
     Followed by: methodology, results with chart references, analysis, conclusions.
   - Any code you wrote along the way
   - If you checked out and modified an existing repo, save the output of `git diff` as a file — do NOT include a full copy of the repo
   - Charts as PNG (keep under 2MB each)
   - Raw data as JSON

   ### What NOT to include

   - Do NOT include full copies of code you fetched as part of the investigation
   - Only include new files you created or diffs showing changes you made to existing code
   - Do NOT create a `_summary.md` file

4. **After the agent completes**, rebuild the root index:
   - Scan every subfolder in `~/code/research/` for a `README.md`
   - Extract the title (first `# ` heading) and top finding (`## Top Finding` section)
   - Get the date from git log (or today's date)
   - Write `~/code/research/README.md` as:
     ```
     # Research

     Every line of text and code in the project folders was written by an LLM (Claude).

     ## Projects

     | Project | Top Finding | Date |
     |---------|-------------|------|
     | [Title](slug/) | finding text | YYYY-MM-DD |
     ```

5. **Git commit** only the project folder and updated root README:
   ```
   research: <slug>
   ```

## Notes

- Use a background agent for the actual research so the user isn't blocked.
- The research agent should have full tool access (Bash, Read, Write, Edit, Glob, Grep).
- If Docker/network/tools aren't available, the agent should note limitations and work with what's available.
- Each project is self-contained. No shared code between projects.
