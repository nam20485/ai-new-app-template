#!/usr/bin/env pwsh
<#!
.SYNOPSIS
Run TruffleHog with repository-aware defaults.

.DESCRIPTION
Mirrors the behavior of scripts/security/run-trufflehog.sh with PowerShell-friendly options
so developers on Windows can reproduce CI scans and staged-file checks.
#>

[CmdletBinding(PositionalBinding = $false)]
param(
    [switch] $Ci,
    [switch] $Staged,
    [string] $SinceCommit,
    [string] $Branch = 'HEAD',
    [string] $JsonOutput,
    [string] $Allowlist,
    [string[]] $ExtraArgs
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-RepoRoot {
    $root = git rev-parse --show-toplevel 2>$null
    if (-not $root) {
        throw 'Unable to determine repository root; are you inside a git repository?'
    }
    return (Resolve-Path -LiteralPath $root).ProviderPath
}

function Get-AllowlistFlags {
    param(
        [string] $AllowlistPath
    )

    $result = [ordered]@{
        Flags   = @()
        Cleanup = @()
    }

    if (-not $AllowlistPath -or -not (Test-Path -LiteralPath $AllowlistPath)) {
        return $result
    }

    $paths = New-Object System.Collections.Generic.List[string]
    $detectors = New-Object System.Collections.Generic.List[string]
    $current = $null

    foreach ($raw in Get-Content -LiteralPath $AllowlistPath) {
        $line = $raw.Trim()
        if ([string]::IsNullOrWhiteSpace($line) -or $line.StartsWith('#')) {
            continue
        }
        if ($line.StartsWith('ignored_paths')) {
            $current = 'paths'
            continue
        }
        if ($line.StartsWith('ignored_detectors')) {
            $current = 'detectors'
            continue
        }
        if ($line.StartsWith('- ')) {
            $value = $line.Substring(2).Trim()
            if (-not $value) { continue }
            if ($current -eq 'paths') {
                $paths.Add($value) | Out-Null
            }
            elseif ($current -eq 'detectors') {
                $detectors.Add($value) | Out-Null
            }
        }
    }

    if ($paths.Count -gt 0) {
        $tempFile = [System.IO.Path]::GetTempFileName()
        [System.IO.File]::WriteAllLines($tempFile, $paths)
        $result.Flags += '--exclude-paths'
        $result.Flags += $tempFile
        $result.Cleanup += $tempFile
    }

    if ($detectors.Count -gt 0) {
        $result.Flags += '--exclude-detectors'
        $result.Flags += ($detectors -join ',')
    }

    return $result
}

$repoRoot = Get-RepoRoot
Set-Location -LiteralPath $repoRoot

if (-not (Get-Command trufflehog -ErrorAction SilentlyContinue)) {
    throw "TruffleHog CLI is not installed. Install it with 'pip install trufflehog' or 'pipx install trufflehog'."
}

if (-not $Allowlist) {
    $Allowlist = Join-Path -Path $repoRoot -ChildPath 'security/trufflehog-allowlist.yml'
}

if ($Ci -and -not $SinceCommit) {
    git rev-parse --verify origin/main 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) {
        $SinceCommit = 'origin/main'
    }
    else {
        git rev-parse --verify main 2>$null | Out-Null
        if ($LASTEXITCODE -eq 0) {
            $SinceCommit = 'main'
        }
        else {
            $SinceCommit = (git rev-list --max-parents=0 HEAD | Select-Object -Last 1)
        }
    }
}

$allowlistResult = Get-AllowlistFlags -AllowlistPath $Allowlist
$cleanup = @()
if ($allowlistResult.ContainsKey('Cleanup')) {
    $cleanup = $allowlistResult['Cleanup']
}

try {
    if ($Staged) {
        $staged = git diff --cached --name-only --diff-filter=ACMR | Where-Object { $_ }
        if (-not $staged) {
            Write-Warning 'No staged files to scan; skipping TruffleHog.'
            exit 0
        }

        $targets = foreach ($entry in $staged) {
            $candidate = Join-Path -Path $repoRoot -ChildPath $entry
            if (Test-Path -LiteralPath $candidate -PathType Leaf) {
                [System.IO.Path]::GetFullPath($candidate)
            }
        }

        if (-not $targets) {
            Write-Warning 'Staged files are not regular files; skipping TruffleHog.'
            exit 0
        }

        $cmd = @('trufflehog', 'filesystem') + $targets + @('--results=verified,unknown', '--fail')
    }
    else {
        $cmd = @('trufflehog', 'git', "file://$repoRoot", '--results=verified,unknown', '--fail')
        if ($SinceCommit) {
            $cmd += @('--since-commit', $SinceCommit)
        }
        if ($Branch) {
            $cmd += @('--branch', $Branch)
        }
    }

    if ($allowlistResult.ContainsKey('Flags') -and $allowlistResult['Flags']) {
        $cmd += $allowlistResult['Flags']
    }

    if ($ExtraArgs) {
        $cmd += $ExtraArgs
    }

    if ($JsonOutput) {
        $outputDirectory = Split-Path -Parent $JsonOutput
        if (-not $outputDirectory) {
            $outputDirectory = '.'
        }
        if (-not (Test-Path -LiteralPath $outputDirectory)) {
            $null = New-Item -ItemType Directory -Path $outputDirectory -Force
        }
        $cmd += '--json'
        $cmdString = $cmd -join ' '
        Write-Verbose "Executing: $cmdString"
        $arguments = if ($cmd.Length -gt 1) { $cmd[1..($cmd.Length - 1)] } else { @() }
        & $cmd[0] @arguments 2>&1 | Tee-Object -FilePath $JsonOutput | Out-Null
        exit $LASTEXITCODE
    }
    else {
        $cmdString = $cmd -join ' '
        Write-Verbose "Executing: $cmdString"
        $arguments = if ($cmd.Length -gt 1) { $cmd[1..($cmd.Length - 1)] } else { @() }
        & $cmd[0] @arguments
        exit $LASTEXITCODE
    }
}
finally {
    foreach ($file in $cleanup) {
        if ($file -and (Test-Path -LiteralPath $file)) {
            Remove-Item -LiteralPath $file -Force -ErrorAction SilentlyContinue
        }
    }
}
