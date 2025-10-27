# TruffleHog Integration – Boomerang Context

This repository needs the same TruffleHog guardrails we planned for `board-shape-view-client-dotnet-lima66`. Nothing has been implemented here yet, so the following checklist remains open:

- [ ] Add `.github/workflows/secret-scan-trufflehog.yml` that runs `trufflesecurity/trufflehog@main` on `push`, `pull_request`, and `workflow_dispatch` with shallow clone and artifact uploads.
- [ ] Create/verify `security/trufflehog-allowlist.yml` and `security/trufflehog-baseline.yml` (YAML format) and document how to regenerate them.
- [ ] Add cross-platform helpers under `scripts/security/` (`run-trufflehog.sh`, `run-trufflehog.ps1`, plus quick helpers for developer workflows).
- [ ] Provide pre-commit hook templates in `.githooks/` (shell + PowerShell) mirroring the CI command.
- [ ] Extend existing docs (e.g., `docs/TESTING.md`) with CI behavior, hook installation, baseline maintenance, and escalation guidance.
- [ ] Run validation passes (canary secret in feature branch, allowlist update rehearsal) and record outcomes.

Reference plan (approved in the other repo):
1. CI workflow fails when verified/unknown secrets are introduced.
2. Developers can reproduce scans locally via helper scripts or hooks.
3. Documentation captures triage and incident response steps.
4. Stakeholders sign off once validation is complete.

You can start implementation here by checking out a new branch (e.g., `feature/trufflehog-integration`) and executing the above checklist. This file can be removed once the work is complete.
