# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Development Commands

### Environment Verification
```bash
npm run env:summary
```
Confirms Node.js environment is properly configured.

### Repository Template Initialization
```powershell
# Initialize new repository from this template
./scripts/init-template-repo.ps1 -RepoPath <target-path> -RepoName <repo-name>

# Complete new repository orchestration workflow
./scripts/initiate-new-repo.ps1

# Create repository with planning documentation
./scripts/create-repo-with-plan-docs.ps1
```

### GitHub Automation Scripts
```powershell
# Import labels from ./.labels.json
./scripts/import-labels.ps1

# Create standard milestones
./scripts/create-milestones.ps1

# Validate available toolset
./scripts/validate-toolset.ps1
```

### Orchestration Commands
```bash
# Dry run orchestration with sample workflow
npm run orchestrate:dry

# Dry run orchestration from file
npm run orchestrate:dry:file
```

## Architecture Overview

### AI-Powered Template System
This repository is a **template for AI-assisted application development** that enforces strict automation protocols. The architecture is built around:

1. **Remote Canonical Instructions**: Core AI instruction modules live in `nam20485/agent-instructions` repository
2. **Local Instruction Modules**: Local files that reference and extend remote instructions
3. **PowerShell Automation Layer**: All repository operations are PowerShell-scripted
4. **Workflow Orchestration**: Dynamic workflows resolved from remote canonical sources

### Tool Hierarchy (Critical for Development)
**Must follow this priority order for all GitHub operations:**

1. **MCP GitHub Tools** (`mcp_github_*` functions) - Use first
2. **VS Code GitHub Integration** (`run_vscode_command`) - Fallback
3. **Terminal GitHub CLI** (`gh` commands) - Last resort only
4. **Manual GitHub Web Interface** - **PROHIBITED**

### Key Architectural Patterns

**Automation-First Design**: 90% minimum automation coverage required for all GitHub operations. Every manual step must be documented with tool limitation justification.

**Remote-Local Instruction Split**: 
- Remote canonical repository (`nam20485/agent-instructions`) contains authoritative workflow definitions
- Local `local_ai_instruction_modules/` contains workspace-specific references and toolset configuration
- Never use local mirrors for workflow derivation

**PowerShell-Centric Scripting**: Default shell is PowerShell (pwsh), not bash. All automation scripts use PowerShell with proper error handling and validation.

### Core System Components

**Workflow Assignment System**: 
- Assignments resolved from `nam20485/agent-instructions/ai_instruction_modules/ai-workflow-assignments/`
- Available workflows: `create-app-plan`, `initiate-new-repository`, `orchestrate-dynamic-workflow`
- Always use RAW URLs when fetching remote workflow files

**Template Initialization Pipeline**:
1. Clone from template → 2. Rename workspace artifacts → 3. Configure devcontainer → 4. Import labels/milestones → 5. Initialize project structure

**Tool Configuration**: 
- `toolset.selected.json` defines enabled tools (126 tools enabled)
- Web-fetch tool disabled - use PowerShell `Invoke-WebRequest` instead
- MCP filesystem, GitHub, and memory tools are primary automation interfaces

## Development Environment Requirements

- **Node.js**: 22.18.0 (pinned in `.nvmrc`)
- **. NET SDK**: 9.0.102 (pinned in `global.json`) 
- **PowerShell**: 7+ required for cross-platform script execution
- **Package Manager**: pnpm via Corepack

## Critical Development Rules

1. **Shell Detection**: Always check if you're in PowerShell vs bash before running commands
2. **Automation Coverage**: Achieve 90%+ automation for all GitHub operations or document tool limitations
3. **Remote Authority**: Only use remote canonical repository files for workflow definitions
4. **Tool Priority**: Use MCP GitHub tools first, terminal `gh` commands only as documented last resort