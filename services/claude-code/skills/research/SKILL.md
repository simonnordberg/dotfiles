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

2. **Create the project folder** at `~/code/research/<slug>/` with a `PROMPT.md` containing the full research prompt.

3. **Launch a background agent** to conduct the research. The agent prompt must include:
   - The full research question from PROMPT.md
   - Instructions to work in the project folder
   - Instructions to write and execute real code — never fabricate data
   - Generate charts as PNG in `charts/`
   - Store raw data as JSON in `results/`
   - Write a `README.md` research report that starts with:
     ```
     # <Title>

     ## Top Finding

     <Single sentence: the most important or surprising result>
     ```
     Followed by: methodology, results with chart references, analysis, conclusions
   - Be honest about limitations

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

5. **Git commit** the new project folder and updated README:
   ```
   research: <slug>
   ```

## Conventions

Read `~/code/research/CLAUDE.md` if it exists for any project-specific conventions.

## Notes

- Use a background agent for the actual research so the user isn't blocked.
- The research agent should have full tool access (Bash, Read, Write, Edit, Glob, Grep).
- If Docker/network/tools aren't available, the agent should note limitations and work with what's available.
- Each project is self-contained. No shared code between projects.
