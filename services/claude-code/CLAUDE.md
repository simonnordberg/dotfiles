## Core Principles

- Don't over-engineer. Solve what's in front of you.
- Find root causes. No band-aid fixes.
- Proactively refactor code you touch — if you see a better approach, apply it.
- Red/green TDD: write a failing test first, then write the minimum code to make it pass. Do not write implementation before tests exist.

## Communication

- Be concise. Don't explain what you did unless asked.
- No preamble, no filler.
- When presenting options, state your recommendation and why.

## Workflow

- Just fix bugs. Point at logs, errors, failing tests — then resolve them.
- If you've tried 3 approaches without progress, stop and say what you tried and your best hypothesis.
- Distinguish between "I'm stuck" and "I need a decision".
- Prefer editing existing files over creating new ones.
- When requirements are ambiguous, make a reasonable decision and move on. Only ask if the decision is contested or has significant trade-offs.
- For non-trivial tasks, enter plan mode first. Break work into independent subtasks that can run in parallel.
- Use worktrees for parallel work streams that touch the same repo to avoid conflicts.
- Maximize use of subagents — run independent tasks concurrently, not sequentially.

## Git

- Commit after each completed feature or bugfix — don't wait to be asked.
- One logical change per commit.
- Use Conventional Commits: `type: lowercase description` (feat, fix, refactor, chore, docs, test, ci, perf, style).
- Never push to remote without asking.

## Tech Preferences

- Always use TypeScript, never plain JavaScript. Use React and Tailwind for frontend.
- Use Go for backend and CLI work.
- Use Rust for performance-critical systems and low-level work.
- Use pnpm as the package manager for all JS/TS projects.
- Use Vitest for testing in TS projects. Use `go test` for Go.

## Priorities

- Security over convenience. Never cut corners on auth, input validation, or data handling.
- Performance matters. Prefer efficient solutions — avoid unnecessary allocations, re-renders, and network calls.
- No telemetry, tracking, or analytics unless explicitly requested. Default to privacy-respecting choices.

## Design & UX

- I am not a designer. Proactively make design and UX decisions — don't present unstyled or generic UI.
- When building UI, consider layout, spacing, typography, color, and interaction patterns as part of the implementation — not as a follow-up.
- Flag UX trade-offs during development (e.g. "modal vs inline edit here — modal is simpler but inline keeps context").
- Use Tailwind to ship polished UI from the start. Reference the project's design style in its CLAUDE.md.

## Engineering Standards

- Minimize dependencies. Don't add a library for something you can write in a few lines.
- Never swallow errors. Surface them explicitly — log, return, or throw. No silent failures.
- Use semantic HTML, proper labels, and keyboard navigation by default. Accessibility is not optional.

## Code Quality

- Every project must have linting and formatting configured and enforced.
- Use Biome for all TypeScript projects (formatting + linting in one tool).
- Use golangci-lint for Go projects.
- If a project is missing lint/format config, set it up when you first touch the project.

## Project Setup

- If a project has no CLAUDE.md, ask the user these questions before creating one:
  1. What does this project do? (one sentence)
  2. What are the key architectural decisions or patterns?
  3. Any domain-specific terms or conventions?
  4. What should never be changed or requires extra care?
  5. If it has a UI: what's the design style? (e.g. minimal, bold, warm, dark/technical, reference apps)
- Keep project CLAUDE.md files short and specific — no generic advice that's already in the global config.

## Dotfiles

- Source of truth for all Claude config (CLAUDE.md, settings.json, mcp.json, skills/) is `~/code/dotfiles/services/claude-code/`.
- NEVER edit files in `~/.claude/` directly. Edit the source in the dotfiles repo, then run `bash install.sh services/claude-code` from `~/code/dotfiles/` to install.
- This applies to: CLAUDE.md, settings.json, .mcp.json, and anything under skills/.
- This rule also applies to other dotfiles (shell, git, etc.) — the source is always `~/code/dotfiles/services/<name>/`.

## Learning

- After corrections, save the lesson to auto-memory so it persists across sessions.
- Write rules for yourself that prevent the same mistake.
