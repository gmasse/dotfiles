# <Project name>

<1–2 line purpose>. Docs: [README.md](README.md) | <add others as needed>

## Setup

Requires <runtime + version>. Copy `.env.example` → `.env`. Then: `<bootstrap cmd>`.

## Commands

```bash
<run>       # dev server / entry point
<test>      # test suite
<lint>      # lint + format check
<build>     # production build
```

## Tech stack

<language + version>, <framework>, <db>, <key libs>, <linter/formatter>, <test runner>.

## Development principles

- TDD — write tests first.
- <project-specific principle, e.g. "strict mypy", "Protocol for plugins">
- <project-specific principle>

## Architecture rules

<!-- Safety-critical invariants. 3–7 bullets. -->

- <rule>
- <rule>

## Gotchas

<!-- Non-obvious traps. Delete if empty. -->

- <gotcha>

## Git conventions

- Conventional Commits: `feat:`, `fix:`, `refactor:`, `docs:`, `chore:`, `test:`, `build:`, `ci:`.
- Stage files explicitly by name — never `git add .` / `git add -A`.
- One self-contained change per commit; don't batch unrelated work.
- Run tests and linters before committing.
- Never force-push to `main`/`master`. Never amend a pushed commit without explicit request.

## Out of scope

<what this repo does NOT own>
