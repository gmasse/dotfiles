# Global conventions

## Development principles
- Keep linter, formatter, and type checker strict and green. Never weaken a rule to avoid fixing code.
- Prefer standard-library / framework APIs over custom code. Only write custom when no suitable option exists.
- No dead code, no speculative abstractions.

## Security rules
- Config via env vars; never hardcode secrets, tokens, credentials, or private keys.
- Never print, log, or echo secrets (passwords, API keys, tokens, private keys, credentials in URLs).
- Use placeholders like `$API_KEY` or `<REDACTED>` in examples; mask real values as `sk-...abcd`.
- Warn before running commands that dump env vars (`env`, `printenv`, `set`).
- If I paste a secret by accident, don't echo it back — tell me and suggest rotation.
- Never commit `.env`, `*.key`, `*.pem`, `credentials.json`, or similar. Flag if staged.

## Git safety
- No `Co-Authored-By` trailers for Claude or any AI.
- If a pre-commit hook fails, fix the cause — don't use `--no-verify`.

## Working style
- When a repo has its own `CLAUDE.md`, its rules override anything generic here.
- Before edits in an unfamiliar repo, check `README.md`, `CLAUDE.md`, `CONCEPT.md`, `PLAN.md`, or `docs/` for context.
