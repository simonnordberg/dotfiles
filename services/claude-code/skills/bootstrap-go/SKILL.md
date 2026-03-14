---
name: bootstrap-go
description: >
  Invoke when creating a new Go project or when a Go project is missing standard
  tooling config. Sets up the baseline that all Go projects share.
invocation: /bootstrap-go
---

# Bootstrap Go Project

Set up the minimal, opinionated baseline for a new Go project. Config only — no boilerplate app code.

## What to create

1. **Go module** — `go mod init <module-path>`
2. **golangci-lint** — create `.golangci.yml`:
   - Enable: `govet`, `errcheck`, `staticcheck`, `unused`, `gosimple`, `ineffassign`
   - Disable noisy linters by default
3. **Makefile** — minimal targets:
   - `build`, `test`, `lint`, `fmt`
4. **`.gitignore`** — binary output, .env, vendor/ (if not vendoring)
5. **CLAUDE.md** — trigger the project setup questions from the global config

## Principles

- Don't create cmd/, internal/, or pkg/ directories. Let the structure emerge from the code.
- Don't add dependencies beyond standard library unless asked.
- After setup, run `go vet ./...` to verify everything is clean.
