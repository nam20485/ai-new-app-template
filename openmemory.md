# OpenMemory Guide

## Overview
- Repository contains templates and automation for AI-assisted project workflows.

## Architecture
- GitHub Actions workflows under `.github/workflows/` orchestrate automated agent actions.
- Prompt templates for workflow-driven agents are stored under `.github/workflows/prompts/`.

## User Defined Namespaces
- [Leave blank - user populates]

## Components
- `orchestrator-agent` workflow: listens for `/oc` and `/opencode` comment triggers and runs the `anomalyco/opencode/github` action.

## Patterns
- Prompt file loading pattern: read markdown prompt content using a shell step, expose it as a step output, map that output into a step env var, and pass the env var into action inputs.
