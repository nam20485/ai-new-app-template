# AGENTS.md
Build/Lint/Test
- Env: Node 22.18 (`.nvmrc`), pnpm via Corepack; `npm run env:summary`
- Orchestration: use your agent to orchestrate workflows per remote instructions (no local .mjs)
- Lint: none; add ESLint+Prettier and expose `pnpm lint`
- Tests (JS/TS): none; prefer Vitest `pnpm vitest -t "name"` or Jest `pnpm jest path -t name`
- Tests (.NET): `dotnet test` | single `dotnet test --filter "FullyQualifiedName~TestName"`
Coding Style
- Imports: relative by default; side-effect imports explicit
- Formatting: Prettier/EditorConfig if present; target ~100 cols
- Types/null-safety: explicit TS types; avoid `any`; narrow with guards; validate external data
- Naming: kebab-case files; PascalCase types/classes; camelCase vars/functions; CONSTANT_CASE constants
- Errors: fail fast; never swallow; wrap async with try/catch; surface exit codes
- Git: small focused commits; no secrets; never change git config
Agent-Instructions & Workflows
- SSOT: use `nam20485/agent-instructions@main` via RAW URLs; see `local_ai_instruction_modules/*` indices
- Dynamic workflows: resolve by shortId from remote RAW files and orchestrate via your agent (no local script)
- Assignments: resolve by shortId from `ai-workflow-assignments.md`; follow acceptance criteria verbatim
- Copilot rules: `.github/copilot-instructions.md` (shell detect, RAW URLs, automation-first, web-fetch disabled → use `Invoke-WebRequest`/`curl`)
- Tool priority: MCP GitHub tools → VS Code → `gh` CLI; avoid GitHub web UI; scripts `./scripts/*.ps1`; .NET SDK via `global.json` (9.0.102); no Cursor rules
Use the `workflow-orxchestrator-v2` agent to run dynamic workflows. Have this agent delegate tasks to other agents as needed.