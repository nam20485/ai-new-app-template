---
description: Local development guidelines and architectural overview.
scope: local-development
prerequisites: none
---
# Development Instructions

<instructions role="assistant" scope="local-development">

<overview>
## Overview
This file provides guidance to chat clients and agents when working with code in this repository.
</overview>

<command_reference>
## Common Development Commands
- **Shell:** MS PowerShell Core (`pwsh.exe`).
- **Rule:** Do not use linux Bash or sh-based commands. Formulate all commands for pwsh.

### GitHub Automation Scripts
```powershell
# Import labels from ./.labels.json
./scripts/import-labels.ps1

# Create standard milestones
./scripts/create-milestones.ps1
```
</command_reference>

<architecture>
## Architecture Overview

### AI-Powered Template System
This repository is a **template for AI-assisted application development** that enforces strict automation protocols. The architecture is built around:
1.  **Remote Canonical Instructions**: Core AI instruction modules live in `nam20485/agent-instructions` repository.
2.  **Local Instruction Modules**: Local files that reference and extend remote instructions.
3.  **Automation Layer**: All repository operations are performed through:
    1.  MCO github server tools
    2.  gh CLI command (ask for authentication if needed)
    3.  terminal commands (pwsh shell)
    4.  create powershell .ps1 scripts and run them (or use existing)
    5.  GitHub API calls
4.  **Workflow Orchestration**: Dynamic workflows resolved from remote canonical sources.

### Tool Hierarchy (Critical for Development)
**Must follow this priority order for all GitHub operations:**
1.  **MCP GitHub Tools** (`mcp_github_*` functions) - Use first
2.  **VS Code GitHub Integration** (`run_vscode_command`) - Fallback
3.  **Terminal GitHub CLI** (`gh` commands) - Last resort only
4.  **Manual GitHub Web Interface** - **PROHIBITED**

### Key Architectural Patterns
-   **Automation-First Design**: 90% minimum automation coverage required for all GitHub operations. Every manual step must be documented with tool limitation justification.
-   **Remote-Local Instruction Split**:
    -   Remote canonical repository (`nam20485/agent-instructions`) contains authoritative workflow definitions.
    -   Local `local_ai_instruction_modules/` contains workspace-specific references and toolset configuration.
    -   Never use local mirrors for workflow derivation.
    -   When beginning a workflow, read all workflow instructions (Local + Remote).
-   **PowerShell-Centric Scripting**: Default shell is PowerShell (pwsh), not bash. All automation scripts use PowerShell with proper error handling and validation.

### Core System Components
-   **Workflow Assignment System**:
    -   Dynamic workflow assignments resolved from remote canonical sources `nam20485/agent-instructions/ai_instruction_modules/ai-workflow-assignments/dynamic-workflows`.
    -   Assignments resolved from `nam20485/agent-instructions/ai_instruction_modules/ai-workflow-assignments/`.
    -   Always use RAW URLs when fetching remote workflow files.
    -   Always read all of your `ai_instruction_modules` before planning or acting.
-   **Dynamic Workflow System**:
    -   Dynamic workflows resolved from remote canonical sources.
    -   Resolve all dynamic workflow assignment and the workflow assignments contained inside before planning or acting.
-   **Tool Configuration**:
    -   Use dynamic tool discovery to identify available capabilities.
    -   Web-fetch tool disabled - use PowerShell `Invoke-WebRequest` instead.
    -   MCP filesystem, GitHub, Sequential Thinking, Memory, and Gemini tools are primary automation interfaces.
    -   **REQUIRED MCP SERVERS**: filesystem, github, sequential-thinking, memory, gemini-cli, desktop-commander.
</architecture>

<tooling>
## Sequential Thinking, Memory, and Gemini Tools (MANDATORY)
**Use these MCP tools for ALL complex tasks:**

1.  **Sequential Thinking Tool** (`mcp_sequential_thinking_*`) - **ALWAYS USE** for:
    -   Breaking down complex problems into steps
    -   Planning multi-stage implementations
    -   Analyzing dependencies and relationships
    -   Creating systematic approaches to tasks
    -   Debugging and troubleshooting workflows

2.  **Memory Tool** (`mcp_memory_*`) - **ALWAYS USE** for:
    -   Storing important context between tasks
    -   Tracking project-specific patterns and conventions
    -   Remembering user preferences and decisions
    -   Maintaining state across workflow stages
    -   Caching frequently referenced information

3.  **Gemini Tool** (`mcp_gemini_*`) - **USE FOR CONTEXT CONSERVATION**:
    -   Reading and analyzing large codebases (1M token context)
    -   Processing extensive documentation or logs
    -   Analyzing multiple files simultaneously
    -   Conserving Claude's context window for other tasks
    -   Delegating large-scale code comprehension tasks
</tooling>

<requirements>
## Development Environment Requirements
-   **.NET SDK**: 9.0.102 (pinned in `global.json`)
-   **PowerShell**: 7+ required for cross-platform script execution
</requirements>

<rules>
## Critical Development Rules
1.  **Shell Detection**: Always check if you're in PowerShell vs bash before running commands.
2.  **Automation Coverage**: Achieve 90%+ automation for all GitHub operations or document tool limitations.
3.  **Remote Authority**: Only use remote canonical repository files for workflow definitions.
4.  **Tool Priority**: Use MCP GitHub tools first, terminal `gh` commands only as documented last resort.
5.  **Sequential Thinking**: MUST use Sequential Thinking MCP tool for ALL multi-step tasks and complex problem solving.
6.  **Memory Management**: MUST use Memory MCP tool to maintain context and state across workflow stages.
</rules>

</instructions>
