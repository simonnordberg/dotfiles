---
name: bootstrap-rust
description: >
  Invoke when creating a new Rust project or when a Rust project is missing standard
  tooling config. Sets up the baseline that all Rust projects share.
invocation: /bootstrap-rust
---

# Bootstrap Rust Project

Set up the minimal, opinionated baseline for a new Rust project. Config only — no boilerplate app code.

## What to create

1. **Cargo** — `cargo init` (binary) or `cargo init --lib` (library). Ask which.
2. **Clippy config** — in `Cargo.toml` under `[lints.clippy]`:
   - `pedantic = "warn"`
   - `nursery = "warn"`
3. **Rustfmt** — create `rustfmt.toml`:
   - `edition = "2024"`
   - `max_width = 100`
4. **Makefile** — minimal targets:
   - `build`, `test`, `lint` (clippy), `fmt`
5. **`.gitignore`** — target/, .env
6. **CLAUDE.md** — trigger the project setup questions from the global config

## Principles

- Don't add crates beyond what's needed. Rust's stdlib is strong — use it.
- Prefer `thiserror` for library errors and `anyhow` for application errors. Only add when needed.
- After setup, run `cargo clippy` to verify everything is clean.
