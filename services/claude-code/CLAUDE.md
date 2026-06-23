## Core Principles

- Don't over-engineer. Solve what's in front of you.
- Find root causes. No band-aid fixes.
- Proactively refactor code you touch. If you see a better approach, apply it.
- TDD: no production code without a failing test first. Show the test fail for the right reason, then write the minimal code to pass, then refactor with tests green.

## Communication

- Be concise. Don't explain what you did unless asked.
- No preamble, no filler.
- When presenting options, state your recommendation and why.
- Show evidence (command + output), not claims.
- When you finish a step, state explicitly whether more work remains, list what's left and name the next step, or say the feature is complete. Never end ambiguously.
- Never use em dashes (—). They read as AI output. Use a period, semicolon, comma, colon, or parentheses. Applies to chat, code, comments, commit messages, docs, and UI copy.

## Workflow

- Just fix bugs. Point at logs, errors, failing tests, then resolve them.
- If you've tried 3 approaches without progress, stop and say what you tried and your best hypothesis.
- Distinguish between "I'm stuck" and "I need a decision".
- Prefer editing existing files over creating new ones.
- When requirements are ambiguous, make a reasonable decision and move on. Only ask if the decision is contested or has significant trade-offs.
- One feature = one worktree = one branch = one PR.
- Reuse before writing: search for an existing function, helper, or pattern first. Use or extend it rather than duplicating.
- For non-trivial tasks, enter plan mode first. Break work into independent subtasks that can run in parallel.
- Use worktrees for parallel work streams that touch the same repo to avoid conflicts.
- Maximize use of subagents: run independent tasks concurrently, not sequentially.

## Git

- Never commit to the default branch. Always use a feature branch/worktree.
- Never build on a stale default. A new worktree branches from the freshly-fetched origin/HEAD; if a branch is behind, run /rebase before continuing.
- Commit after each completed feature or bugfix. Don't wait to be asked.
- Commits small and reviewable (one task each); the PR tells the feature's whole story.
- Use Conventional Commits: `type: lowercase description` (feat, fix, refactor, chore, docs, test, ci, perf, style). If the project's CLAUDE.md or recent git history uses a different commit format, follow that instead.
- Pre-authorized without confirmation: status, diff, log, blame, show, add, commit, branch create/checkout/switch, stash, fetch, pull, merge (ff or non-ff), rebase (non-interactive), tag, push (any non-default branch, non-force), PR create/comment/review via `gh`.
- Still require explicit confirmation: force-push (any branch), push to main/master, `reset --hard`, `clean -f`, `branch -D` on unmerged work, rewriting published history, deleting remote branches.

## Code Review

- Code review reports findings by severity. Fix only Blockers/Majors, triage false positives (push back, don't contort code), and defer or drop nits. Never "fix all review comments"; it grows the diff and loops.

## Tech Preferences

- Always use TypeScript, never plain JavaScript. Use React and Tailwind for frontend.
- Use Go for backend and CLI work.
- Use Rust for performance-critical systems and low-level work.
- Use pnpm as the package manager for all JS/TS projects.
- Use Vitest for testing in TS projects. Use `go test` for Go.

## Priorities

- Security over convenience. Never cut corners on auth, input validation, or data handling.
- Performance matters. Prefer efficient solutions: avoid unnecessary allocations, re-renders, and network calls.
- No telemetry, tracking, or analytics unless explicitly requested. Default to privacy-respecting choices.

## Design & UX

- I am not a designer. Proactively make design and UX decisions. Don't present unstyled or generic UI.
- When building UI, consider layout, spacing, typography, color, and interaction patterns as part of the implementation, not as a follow-up.
- Flag UX trade-offs during development (e.g. "modal vs inline edit here: modal is simpler but inline keeps context").
- Use Tailwind to ship polished UI from the start. Reference the project's design style in its CLAUDE.md.

## Engineering Standards

- Minimize dependencies. Don't add a library for something you can write in a few lines.
- Never swallow errors. Surface them explicitly: log, return, or throw. No silent failures.
- Use semantic HTML, proper labels, and keyboard navigation by default. Accessibility is not optional.
- If a project has i18n configured, user-facing strings go through it, never hardcoded.

## Code Quality

- Every project must have linting and formatting configured and enforced.
- Use Biome for all TypeScript projects (formatting + linting in one tool).
- Use golangci-lint for Go projects.
- If a project is missing lint/format config, set it up when you first touch the project.
- Extract recurring patterns into well-defined, reusable modules. If something appears twice, make it a component or utility. Don't duplicate; modularize.

## Project Setup

- If a project has no CLAUDE.md, ask the user these questions before creating one:
  1. What does this project do? (one sentence)
  2. What are the key architectural decisions or patterns?
  3. Any domain-specific terms or conventions?
  4. What should never be changed or requires extra care?
  5. If it has a UI: what's the design style? (e.g. minimal, bold, warm, dark/technical, reference apps)
- Keep project CLAUDE.md files short and specific. No generic advice that's already in the global config.

## Dotfiles

- Source of truth for all Claude config (CLAUDE.md, settings.json, mcp.json, skills/) is `~/code/dotfiles/services/claude-code/`.
- NEVER edit files in `~/.claude/` directly. Edit the source in the dotfiles repo, then run `bash install.sh services/claude-code` from `~/code/dotfiles/` to install.
- This applies to: CLAUDE.md, settings.json, .mcp.json, and anything under hooks/, agents/, or skills/.
- This rule also applies to other dotfiles (shell, git, etc.): the source is always `~/code/dotfiles/services/<name>/`.

## Cross-Project Knowledge

- `~/code/knowledge/` is a git repo of reusable knowledge (TILs, decisions, bookmarks).
- When you learn something reusable, make a non-obvious decision, or find a useful reference, add a markdown file there following its CLAUDE.md conventions.
- When looking for past decisions, patterns, or learnings, check there first.
- Don't duplicate what's already in a project's own CLAUDE.md; knowledge/ is for cross-cutting things.

## Learning

- After corrections, save the lesson to auto-memory so it persists across sessions.
- Write rules for yourself that prevent the same mistake.
