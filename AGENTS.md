---
description: Entry point for AGENTS custom instructions
scope: global
role: System Orchestrator
---

<instructions>
  <overview>
    This file serves as the bootstrap entry point for the AI agent's instruction set.
    It defines the location of core modules, the protocol for loading remote instructions, and the single source of truth policy.
  </overview>

  <configuration>
    <!-- BRANCH PARAMETER: Change this value to load instructions from a different branch -->
    <!-- Valid values: main, optimization, feature/*, or any valid branch name -->
    <branch>main</branch>
  </configuration>

  <instruction_source>
    <repository>
      <name>nam20485/agent-instructions</name>
      <url>https://github.com/nam20485/agent-instructions/tree/{branch}</url>
      <branch>{branch}</branch>
    </repository>
    <guidance>
      Start with the Core Instructions linked below. Follow links to other modules as required by the user's request.
      All remote URLs use the branch specified in the configuration section above.
    </guidance>
  </instruction_source>

  <module_registry>
    <module type="core" required="true">
      <name>Core Instructions</name>
      <link>https://github.com/nam20485/agent-instructions/blob/{branch}/ai_instruction_modules/ai-core-instructions.md</link>
      <description>The foundational behaviors and rules for the agent.</description>
    </module>

    <module type="local" required="true">
      <name>Local AI Instructions</name>
      <path>../local_ai_instruction_modules</path>
      <description>Context-specific instructions located in the local workspace.</description>
    </module>

    <module type="dynamic workflow" required="true">
      <name>Dynamic Workflow Orchestration</name>
      <path>../local_ai_instruction_modules/ai-dynamic-workflows.md</path>
      <description>Protocol for resolving workflows from the remote canonical repository.</description>
    </module>

    <module type="workflow assignment" required="true">
      <name>Workflow Assignments</name>
      <path>../local_ai_instruction_modules/ai-workflow-assignments.md</path>
      <description>Index of active workflow assignments by shortId.</description>
    </module>

    <module type="optional">
      <name>Terminal Commands</name>
      <path>../local_ai_instruction_modules/ai-terminal-commands.md</path>
      <description>Reference for terminal operations and GitHub CLI usage.</description>
    </module>
  </module_registry>

  <loading_protocol>
    <rule id="branch_resolution">
      <description>Resolving the active branch</description>
      <instruction>
        Read the branch value from the configuration section at the top of this file.
        Replace all `{branch}` placeholders in URLs with this value.
        Default: use the configured `<branch>` value; if missing, use the repository default branch.
      </instruction>
    </rule>

    <rule id="remote_access">
      <description>Accessing files in the remote repository</description>
      <instruction>
        Always use the RAW URL to read file contents. Do not use the GitHub UI URL.
      </instruction>
    </rule>

    <algorithm name="url_translation">
      <step>Read the configured branch from `<configuration><branch>`.</step>
      <step>Identify the GitHub UI URL (e.g., `https://github.com/.../blob/{branch}/...`).</step>
      <step>Replace `https://github.com/` with `https://raw.githubusercontent.com/`.</step>
      <step>Remove `blob/` from the path.</step>
      <step>Substitute `{branch}` with the configured branch value.</step>
      <step>Result: `https://raw.githubusercontent.com/.../{branch}/...`</step>
    </algorithm>

    <examples>
      <example title="Default (configured branch)">
        <config_branch>{branch}</config_branch>
        <input>https://github.com/nam20485/agent-instructions/blob/{branch}/ai_instruction_modules/ai-core-instructions.md</input>
        <output>https://raw.githubusercontent.com/nam20485/agent-instructions/{branch}/ai_instruction_modules/ai-core-instructions.md</output>
      </example>
      <example title="Optimization branch">
        <config_branch>optimization</config_branch>
        <input>https://github.com/nam20485/agent-instructions/blob/{branch}/ai_instruction_modules/ai-core-instructions.md</input>
        <output>https://raw.githubusercontent.com/nam20485/agent-instructions/optimization/ai_instruction_modules/ai-core-instructions.md</output>
      </example>
    </examples>
  </loading_protocol>

  <policy name="single_source_of_truth">
    <statement>
      The remote canonical repository is the ONLY authoritative source for dynamic workflows and workflow assignments.
    </statement>
    <rules>
      <rule>Do not use local mirrors or cached plans to derive steps.</rule>
      <rule>Fetch and execute directly from the remote canonical URLs.</rule>
      <rule>Changes in the remote repo take effect immediately.</rule>
    </rules>
  </policy>
</instructions>

---

# Project Overview

This repository is an **AI-Powered Template System** for application development that enforces strict automation protocols. It serves as a template repository for AI-assisted software development with workflow orchestration, multiple AI agent integrations, and comprehensive automation tools.

## What is this Project?

- **Template Repository**: A starting point for new AI-assisted application projects
- **Workflow Orchestration System**: Dynamic workflows resolved from remote canonical sources
- **Multi-Agent AI Platform**: Supports Claude, Gemini, and OpenCode AI agents
- **Automation Framework**: 90%+ automation coverage required for all GitHub operations

## Key Architecture Components

1. **Remote Canonical Instructions**: Core AI instruction modules live in `nam20485/agent-instructions` repository
2. **Local Instruction Modules**: Local files in `local_ai_instruction_modules/` that reference and extend remote instructions
3. **GitHub Actions Workflows**: Automated CI/CD with multiple AI agent triggers
4. **Docker Containerization**: Pre-built dev containers with AI CLIs pre-installed
5. **Security-First Design**: Secret scanning with TruffleHog integrated into CI

---

# Technology Stack

## Core Technologies

| Technology | Version | Purpose |
|------------|---------|---------|
| .NET SDK | 10.0.100 | Backend development (pinned in `global.json`) |
| Node.js | 22.18.0 | Frontend/CLI tooling (specified in `.nvmrc`) |
| PowerShell | 7+ | Cross-platform scripting |
| Docker | Latest | Containerization and workflow execution |
| pnpm | 8.11.0 | Package management (specified in `package.json`) |

## AI CLI Tools

| Tool | Source | Authentication |
|------|--------|----------------|
| Claude Code | Anthropic | `ANTHROPIC_API_KEY` env var or `~/.config/anthropic/claude.json` |
| OpenCode | npm (`opencode-ai`) | `OPENAI_API_KEY` env var or `~/.local/share/opencode/auth.json` |
| Gemini CLI | Google | `GEMINI_API_KEY` or GCP Workload Identity |

## MCP Servers (Required)

The following MCP servers are required for full functionality:

- `filesystem` - File operations
- `github` - GitHub API operations
- `sequential-thinking` - Complex problem solving
- `memory` - Context persistence
- `gemini-cli` - Large context operations
- `desktop-commander` - Advanced file operations

---

# Project Structure

```
.
├── .claude/                    # Claude-specific settings
├── .cursor/                    # Cursor IDE settings
├── .devcontainer/              # Dev container configuration
│   ├── devcontainer.json       # Dev container spec
│   └── post-create.sh          # Post-creation setup script
├── .gemini/                    # Gemini CLI configuration
├── .githooks/                  # Git hooks (pre-commit secret scanning)
├── .github/
│   ├── workflows/              # GitHub Actions workflows
│   │   ├── claude.yml          # Claude Code trigger
│   │   ├── gemini-cli/         # Gemini CLI workflows
│   │   ├── opencode.yml        # OpenCode trigger
│   │   ├── orchestrator-agent.yml  # Main orchestration
│   │   ├── prebuild.yml        # Dev container prebuild
│   │   ├── secret-scan-trufflehog.yml  # Security scanning
│   │   └── ...
│   ├── .labels.json            # Label definitions
│   └── .mcp-github.json        # MCP GitHub configuration
├── .kilocode/                  # Kilocode settings
├── .qwen/                      # Qwen settings
├── .vscode/                    # VS Code settings
├── .workflow/                  # Workflow orchestration scripts
│   ├── prompt.sh               # Docker entrypoint script (hardened)
│   ├── DOCKERIZATION_PLAN.md   # Dockerization planning
│   └── IMPLEMENTATION_COMPLETE.md  # Implementation tracking
├── docker/                     # Docker configuration
│   ├── Dockerfile              # Workflow agent container
│   └── docker-compose.yml      # Local development setup
├── docs/                       # Documentation
│   ├── docker/cli-research.md  # CLI tool research
│   └── TESTING.md              # Testing procedures
├── local_ai_instruction_modules/   # Local AI instruction modules
│   ├── ai-custom-agents.md         # Custom agent definitions
│   ├── ai-delegation-mandate.md    # Delegation requirements
│   ├── ai-development-instructions.md  # Development guidelines
│   ├── ai-dynamic-workflows.md     # Dynamic workflow index
│   ├── ai-enhanced-filesystem.md   # Filesystem tool guide
│   ├── ai-terminal-commands.md     # Terminal/GitHub CLI reference
│   ├── ai-tools-and-automation.md  # Automation protocols
│   └── ai-workflow-assignments.md  # Workflow assignment index
├── scripts/                    # Automation scripts
│   ├── create-milestones.ps1   # GitHub milestone creation
│   ├── gh-auth.ps1             # GitHub authentication
│   ├── import-labels.ps1       # Label import from JSON
│   ├── query.ps1               # GitHub query utilities
│   └── security/               # Security scripts
│       ├── allowlist_flags.py  # TruffleHog allowlist helper
│       ├── run-trufflehog.ps1  # PowerShell secret scan
│       └── run-trufflehog.sh   # Bash secret scan
├── security/                   # Security configuration
│   ├── trufflehog-allowlist.yml    # Secret scan allowlist
│   └── trufflehog-baseline.yml     # Secret scan baseline
├── AGENTS.md                   # This file - AI agent entry point
├── CLAUDE.md                   # Claude-specific entry point
├── global.json                 # .NET SDK version pinning
├── opencode-instructions.md    # OpenCode instructions
├── opencode.json               # OpenCode configuration
├── package.json                # Node.js dependencies (dummy for CI caching)
└── .nvmrc                      # Node.js version
```

---

# Build and Development Commands

## Environment Verification

```powershell
# Verify Node.js environment
node -e "console.log('Environment OK')"

# Check .NET SDK version
dotnet --version

# Verify Docker is available
docker --version
```

## GitHub Automation Scripts

```powershell
# Import labels from .labels.json
./scripts/import-labels.ps1

# Create standard milestones
./scripts/create-milestones.ps1

# Test GitHub permissions
./scripts/test-github-permissions.ps1
```

## Docker Commands

```powershell
# Build the workflow agent image
docker build -f docker/Dockerfile -t workflow-agent:latest .

# Run the workflow agent (requires ANTHROPIC_API_KEY)
docker run --rm -e ANTHROPIC_API_KEY=$env:ANTHROPIC_API_KEY workflow-agent:latest

# Run with specific workflow
docker run --rm -e ANTHROPIC_API_KEY=$env:ANTHROPIC_API_KEY -e WORKFLOW_NAME="project-setup" workflow-agent:latest
```

## Docker Compose

```powershell
# Start the workflow agent with compose (requires .env file)
cd docker
docker-compose up

# Create required Docker secrets for compose
echo "your-api-key" | docker secret create anthropic_api_key -
```

---

# Testing Instructions

## Secret Scanning with TruffleHog

This repository uses TruffleHog to scan for secrets in the codebase. This is enforced in CI and can be run locally.

### CI Behavior

The `.github/workflows/secret-scan-trufflehog.yml` workflow runs on every `push` and `pull_request` to the `main` branch. It will fail if it finds any verified or unknown secrets.

### Local Usage

```powershell
# PowerShell
./scripts/security/run-trufflehog.ps1

# Bash
./scripts/security/run-trufflehog.sh
```

### Pre-commit Hook

Install the pre-commit hook to automatically scan for secrets before committing:

```bash
git config core.hooksPath .githooks
```

### Baseline Maintenance

The `security/trufflehog-baseline.yml` file contains a baseline of all secrets found in the repository. To regenerate:

```bash
docker run --rm -v "$(pwd):/repo" trufflesecurity/trufflehog:latest github --repo file:///repo --only-verified > security/trufflehog-baseline.yml
```

### Allowlist

The `security/trufflehog-allowlist.yml` file contains secrets that are allowed to be in the repository.

---

# Code Style Guidelines

## Shell Scripting

- Use PowerShell 7+ (`pwsh.exe`) as the default shell
- All automation scripts must use PowerShell with proper error handling
- Bash is only used within Docker containers (Linux base image)

## Error Handling

```powershell
# Required pattern for all scripts
param ()
$ErrorActionPreference = "Stop"
```

```bash
# Required pattern for bash scripts
set -e          # Exit on error
set -u          # Exit on undefined variable
set -o pipefail # Exit on pipe failure
```

## JSON/YAML Formatting

- Use 2-space indentation for JSON files
- Use consistent formatting in workflow files
- Pin action versions with SHA hashes in GitHub Actions

---

# Security Considerations

## Secret Management

1. **Never commit secrets to version control**
2. Use environment variables or Docker secrets for API keys
3. TruffleHog scans all commits for potential secrets
4. Pre-commit hooks prevent accidental secret commits

## Required Secrets

| Secret | Purpose | Location |
|--------|---------|----------|
| `ANTHROPIC_API_KEY` | Claude CLI authentication | GitHub Secrets / Docker Secrets |
| `OPENAI_API_KEY` | OpenCode CLI authentication | GitHub Secrets / Docker Secrets |
| `GEMINI_API_KEY` | Gemini CLI authentication | GitHub Secrets |
| `CLAUDE_CODE_OAUTH_TOKEN` | Claude Code Action | GitHub Secrets |
| `ZHIPU_API_KEY` | OpenCode orchestrator | GitHub Secrets |

## Authentication Priority

1. Pre-existing config files (`~/.config/anthropic/claude.json`)
2. Environment variables (`ANTHROPIC_API_KEY`)
3. Docker secrets mounted at `/run/secrets/`
4. Fail with actionable error message if none available

---

# GitHub Actions Workflows

## Workflow Overview

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `claude.yml` | `@claude` mention | Run Claude Code on issues/PRs |
| `claude-code-review.yml` | PR events | Automated code review |
| `gemini-cli.yml` | `@gemini-cli` mention | Run Gemini CLI |
| `opencode.yml` | `/oc` or `/opencode` command | Run OpenCode |
| `orchestrator-agent.yml` | `/oc` command | Main orchestration workflow |
| `prebuild.yml` | Push to main/development | Prebuild dev container |
| `secret-scan-trufflehog.yml` | Push/PR to main | Security scanning |
| `validate-setup-scripts.yml` | Manual/scheduled | Validate setup scripts |

## Triggering AI Agents

### Claude Code
Mention `@claude` in:
- Issue comments
- PR review comments
- Issue bodies
- PR review bodies

### OpenCode
Type commands in comments:
- `/oc <your request>`
- `/opencode <your request>`

### Gemini CLI
Mention `@gemini-cli` in:
- Issue comments
- PR review comments
- Issue bodies

---

# Tool Hierarchy (CRITICAL)

**Must follow this priority order for all GitHub operations:**

1. **MCP GitHub Tools** (`mcp_github_*` functions) - Use first
2. **VS Code GitHub Integration** (`run_vscode_command`) - Fallback
3. **Terminal GitHub CLI** (`gh` commands) - Last resort only
4. **Manual GitHub Web Interface** - **PROHIBITED**

## Automation Coverage Target

- **Minimum 90% automation coverage** required for all GitHub operations
- Document justification for any manual steps
- Every manual step must include tool limitation justification

---

# Remote Repository Reference

## Canonical Source

- **Repository**: `nam20485/agent-instructions`
- **Current Branch**: `optimization` (as configured in `<configuration><branch>`)
- **Workflow Directory**: `ai_instruction_modules/ai-workflow-assignments/`
- **Dynamic Workflows**: `ai_instruction_modules/ai-workflow-assignments/dynamic-workflows/`

## URL Translation

Always convert GitHub UI URLs to raw URLs:

```
GitHub UI:  https://github.com/nam20485/agent-instructions/blob/{branch}/ai_instruction_modules/...
Raw URL:    https://raw.githubusercontent.com/nam20485/agent-instructions/{branch}/ai_instruction_modules/...
```

With `optimization` branch:
```
Raw URL: https://raw.githubusercontent.com/nam20485/agent-instructions/optimization/ai_instruction_modules/...
```

---

# Development Environment

## Dev Container

This repository includes a dev container configuration (`.devcontainer/devcontainer.json`) that:
- Uses the prebuilt image `ghcr.io/nam20485/agents-prebuild:main-latest`
- Mounts GPG keys for commit signing
- Runs post-create setup automatically

## Pre-built Image

The base image includes:
- Claude CLI v2.0.14
- UV package manager
- Node.js and npm
- OpenCode CLI (via npm)
- Git

## Local Development Setup

1. Ensure Docker is installed and running
2. Open the repository in VS Code with Dev Containers extension
3. Reopen in Container when prompted
4. The post-create script will configure GPG keys

---

# License

See `LICENSE.md` for the full license text.
