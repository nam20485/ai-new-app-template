# Code Review: `.github/workflows/opencode.yml`

> **Date:** 2026-03-04  
> **Reviewer:** GitHub Copilot  
> **Status:** Awaiting approval

---

## Issue 1 — Wrong org + Unpinned action reference

**Severity:** CRITICAL | **Category:** Supply Chain Security

**Description:** `sst/opencode/github@latest` uses the old organization name (`sst` → moved to `anomalyco`) and `@latest` is a mutable tag — it silently pulls whatever the current `latest` is, with no way to verify what code is running. The `sst` namespace may become abandoned.

**What needs to change:** Update to `anomalyco/opencode/github` pinned to the commit SHA for the latest release **v1.2.17** (`715b844c2a88810b6178d7a2467c7d36ea8fb764`, published 2026-03-04).

| Solution | Pros | Cons | Risk vs Benefit |
| --- | --- | --- | --- |
| **Pin to commit SHA `@715b844c...`** ✅ | Immutable, auditable, safe from tampering | Must manually update for new versions | Low risk, HIGH benefit |
| Pin to semver tag `@v1.2.17` | Readable | Tags can be moved/deleted | Medium risk, medium benefit |
| Keep `@latest` on new org | Easy updates | Same supply chain risk | High risk, low benefit |

**Priority: P0 — Recommended: SHA pin + version comment.**

**REMARKS:**
<!-- Add notes here -->
commit sha is the convention in this organization for maximum security. The version comment is for human readability since SHAs are opaque

---

## Issue 2 — Missing `pull_request_review_comment` trigger

**Severity:** HIGH | **Category:** Functionality

**Description:** The workflow only fires on `issue_comment`, but the official recommended setup also includes `pull_request_review_comment`. Without this, the agent cannot respond to inline code comments made in the "Files changed" tab of a PR — a core advertised feature.

**What needs to change:** Add `pull_request_review_comment: types: [created]` to the `on:` block.

| Solution | Pros | Cons | Risk vs Benefit |
| --- | --- | --- | --- |
| **Add trigger** ✅ | Enables inline code review comments | Slight attack surface increase (mitigated by Issue 4 fix) | Low risk, HIGH benefit |
| Leave as-is | No change required | Core feature missing | Low benefit |

**Priority: P1 — Fixes missing core functionality.**

**REMARKS:**
<!-- Add notes here -->
add

---

## Issue 3 — Missing checkout security options

**Severity:** MEDIUM | **Category:** Security / Best Practice

**Description:** The checkout step doesn't pass `persist-credentials: false` or `fetch-depth: 1`. The official recommended workflow includes both.

- `persist-credentials: false` — prevents the job's credential from being stored in git helpers; only the opencode GitHub App (OIDC exchange) should push code.
- `fetch-depth: 1` — avoids fetching full commit history (unnecessary, adds time).

**What needs to change:** Add `with: fetch-depth: 1` and `persist-credentials: false` to the checkout step.

| Solution | Pros | Cons | Risk vs Benefit |
| --- | --- | --- | --- |
| **Add both options** ✅ | Security hardening + matches official template | None | Zero risk, positive benefit |
| Add only `persist-credentials: false` | Security hardening | Slightly incomplete | Zero risk |
| Leave as-is | No change | Minor security gap | Low risk currently |

**Priority: P2 — Low-cost hardening with no downside.**

**REMARKS:**
<!-- Add notes here -->
add both

---

## Issue 4 — No actor authorization check on trigger

**Severity:** MEDIUM | **Category:** Security / Abuse Prevention

**Description:** Any GitHub user who can see and comment on an issue (all users on public repos) can trigger the AI agent by typing `/oc`. This enables resource consumption/billing abuse and prompt injection attacks via crafted comments.

**What needs to change:** Extend the `if:` condition to check `github.event.comment.author_association` is `OWNER`, `MEMBER`, or `COLLABORATOR`.

| Solution | Pros | Cons | Risk vs Benefit |
| --- | --- | --- | --- |
| **Check `author_association`** ✅ | Blocks external abuse, prevents prompt injection | Excludes trusted external contributors (adjustable) | Very low risk, HIGH benefit |
| Check specific usernames | Full control | Hardcoded, maintenance burden | Low scalability |
| Leave open | Easiest | Abuse on public repos | High risk for public repos |

**Priority: P2 — Important for public repos. Minimal downside.**

**REMARKS:**
<!-- Add notes here -->
0: check author association

---

## Issue 5 — No concurrency control

**Severity:** MEDIUM | **Category:** Reliability / Cost

**Description:** Multiple rapid comments on the same PR/issue trigger simultaneous agent runs. These can conflict (both try to commit to the same branch) and waste API credits.

**What needs to change:** Add a `concurrency:` group keyed to the issue/PR number.

| Solution | Pros | Cons | Risk vs Benefit |
| --- | --- | --- | --- |
| `cancel-in-progress: false` ✅ | Queues runs; completes current before starting next | Runs may wait | Prevents conflicts, no information loss |
| `cancel-in-progress: true` | Immediately responsive to new commands | Interrupts current agent mid-task | Risk of incomplete work |
| No concurrency | Simple | Resource waste + race conditions | High risk at scale |

**Priority: P3 — Important for busy repos.**

**REMARKS:**
<!-- Add notes here -->
implement 0

---

## Issue 6 — No job timeout

**Severity:** MEDIUM | **Category:** Cost / Reliability

**Description:** A stuck or looping AI agent job will run until the runner's global limit (6 hours by default on GitHub-hosted runners), burning Actions minutes and API credits.

**What needs to change:** Add `timeout-minutes: 30` to the job.

| Solution | Pros | Cons | Risk vs Benefit |
| --- | --- | --- | --- |
| **30-minute timeout** ✅ | Caps worst-case cost | Could interrupt very long tasks | Low risk, positive benefit |
| 60-minute timeout | More generous | Higher worst-case cost | Reasonable |
| No timeout | Never interrupts | Runaway cost risk | High risk |

**Priority: P3 — Cheap insurance.**

**REMARKS:**
<!-- Add notes here -->
0: 30 mins

---

## Proposed Final Workflow

```yaml
name: opencode

on:
  issue_comment:
    types: [created]
  pull_request_review_comment:         # Issue 2: added trigger
    types: [created]

permissions: read-all

concurrency:                           # Issue 5: prevent simultaneous runs
  group: opencode-${{ github.event.issue.number || github.event.pull_request.number }}
  cancel-in-progress: false

jobs:
  opencode:
    if: |
      (
        contains(github.event.comment.body, ' /oc') ||
        startsWith(github.event.comment.body, '/oc') ||
        contains(github.event.comment.body, ' /opencode') ||
        startsWith(github.event.comment.body, '/opencode')
      ) && (
        github.event.comment.author_association == 'OWNER' ||
        github.event.comment.author_association == 'MEMBER' ||
        github.event.comment.author_association == 'COLLABORATOR'
      )
    runs-on: ubuntu-24.04
    timeout-minutes: 30                # Issue 6: cap runaway jobs
    permissions:
      id-token: write
      contents: read
      pull-requests: read
      issues: read
    steps:
      - name: Checkout repository
        uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
        with:
          fetch-depth: 1               # Issue 3: skip full history
          persist-credentials: false   # Issue 3: security hardening

      - name: Run opencode
        uses: anomalyco/opencode/github@715b844c2a88810b6178d7a2467c7d36ea8fb764 # v1.2.17
        env:                           # Issue 1: correct org + pinned SHA
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          model: github-copilot/claude-sonnet-4.5
```

---

## Change Summary

| # | Issue | Priority | Change |
| --- | --- | --- | --- |
| 1 | Org rename + unpinned action | P0 | `sst` → `anomalyco`, `@latest` → `@<SHA> # v1.2.17` |
| 2 | Missing PR review comment trigger | P1 | Add `pull_request_review_comment` event |
| 3 | Missing checkout security options | P2 | Add `fetch-depth: 1`, `persist-credentials: false` |
| 4 | No actor authorization | P2 | Add `author_association` guard to `if:` |
| 5 | No concurrency control | P3 | Add `concurrency:` group |
| 6 | No job timeout | P3 | Add `timeout-minutes: 30` |

---

## REMARKS

<!-- Add your overall notes, decisions, and sign-off below -->
looks good, changes approved per REMARKS on each issue
