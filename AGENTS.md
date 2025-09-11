# AGENTS.md

Build/Lint/Test
- Env: `npm run env:summary` (Node 22.18, pnpm via Corepack)
- Orchestration (dry): `npm run orchestrate:dry` | file: `npm run orchestrate:dry:file`
- Lint: none configured; add ESLint/Prettier and expose `pnpm lint`
- Test: none configured; add per project; single-test e.g. Vitest `pnpm vitest -t "name"` or Jest `pnpm jest path -t name`
- Shell: prefer `pwsh` on Windows; always detect shell before running

Coding Style
- Imports: relative unless aliases configured; side-effect imports explicit
- Formatting: Prettier/EditorConfig if present; ~100 cols
- Types: explicit TS types; avoid `any`; narrow with guards
- Naming: kebab-case files; PascalCase classes/types; camelCase vars/functions; CONSTANT_CASE constants
- Errors: fail fast; never swallow; wrap async with try/catch; surface exit codes
- Null-safety: check `undefined`/`null`; validate external data before use
- Git: small focused commits; no secrets; never change git config

Automation & Rules
- Priority: MCP GitHub tools → VS Code → `gh` CLI; GitHub web UI prohibited
- Web fetch: built-in disabled; use `Invoke-WebRequest` (pwsh) or `curl`
- SSOT: resolve workflows/assignments from `nam20485/agent-instructions` via RAW URLs only
- Local modules: see `local_ai_instruction_modules/*`; Copilot rules at `.github/copilot-instructions.md`; no Cursor rules present
- Notes: automation-first; prefer PowerShell scripts in `./scripts/*.ps1`; .NET SDK pinned in `global.json`