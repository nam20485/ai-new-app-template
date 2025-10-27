#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$hookDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = git -C $hookDir rev-parse --show-toplevel 2>$null
if (-not $repoRoot) {
    Write-Error 'Unable to resolve repository root for TruffleHog pre-commit hook.'
    exit 2
}
$repoRoot = (Resolve-Path -LiteralPath $repoRoot).ProviderPath

$scriptPath = Join-Path -Path $repoRoot -ChildPath 'scripts/security/run-trufflehog.ps1'
if (-not (Test-Path -LiteralPath $scriptPath)) {
    Write-Error "TruffleHog helper script not found at $scriptPath"
    exit 2
}

Write-Host 'Running TruffleHog staged scan...'
& $scriptPath -Staged:$true @args
exit $LASTEXITCODE
