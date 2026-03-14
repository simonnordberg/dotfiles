---
name: bootstrap-ts
description: >
  Invoke when creating a new TypeScript project or when a TypeScript project is
  missing standard tooling config. Sets up the baseline that all TS projects share.
invocation: /bootstrap-ts
---

# Bootstrap TypeScript Project

Set up the minimal, opinionated baseline for a new TypeScript project. Config only — no boilerplate app code.

## What to create

### Always

1. **pnpm** — `pnpm init`, set `"type": "module"` in package.json
2. **TypeScript** — `pnpm add -D typescript`, create `tsconfig.json`:
   - `strict: true`, `noUncheckedIndexedAccess: true`
   - `target: "ES2022"`, `module: "ESNext"`, `moduleResolution: "bundler"`
3. **Biome** — `pnpm add -D @biomejs/biome`, create `biome.json`:
   - Formatter: tabs, 100 line width
   - Linter: recommended rules enabled
   - Organize imports enabled
4. **Vitest** — `pnpm add -D vitest`, add `"test": "vitest"` script
5. **`.gitignore`** — node_modules, dist, .env, coverage
6. **CLAUDE.md** — trigger the project setup questions from the global config

### If the project has a UI (ask first)

7. **React** — `pnpm add react react-dom`, `pnpm add -D @types/react @types/react-dom`
8. **Tailwind v4** — `pnpm add -D tailwindcss @tailwindcss/vite`, add CSS import
9. **Vite** — `pnpm add -D vite`, minimal `vite.config.ts`

## Principles

- Every config should be as short as possible. Don't add options that match defaults.
- Don't create src/ directories, components, or app code. That's the user's job.
- Don't add dependencies beyond what's listed above unless asked.
- After setup, run `pnpm biome check .` to verify everything is clean.
