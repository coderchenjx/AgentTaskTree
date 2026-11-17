[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$RepositoryRoot = (Split-Path -Parent $PSScriptRoot),
    [string]$GlobalSkillRoot = (Join-Path $HOME '.agents\skills'),
    [string]$GlobalAgentsPath = $(if ($env:CODEX_HOME) { Join-Path $env:CODEX_HOME 'AGENTS.md' } else { Join-Path $HOME '.codex\AGENTS.md' }),
    [switch]$SkipGlobalAgents
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$sourceSkill = Join-Path $RepositoryRoot 'skills\task-tree'
if (-not (Test-Path -LiteralPath (Join-Path $sourceSkill 'SKILL.md') -PathType Leaf)) {
    throw "Source Skill not found: $sourceSkill"
}

$destinationSkill = Join-Path $GlobalSkillRoot 'task-tree'
$managedStart = '<!-- agent-task-tree:start -->'
$managedEnd = '<!-- agent-task-tree:end -->'
$managedBlock = @"
$managedStart
## Agent Task Tree

For complex multi-step, investigative, dependency-heavy, or cross-session work, use the globally available task-tree Skill, including when the user invokes the task-tree command. Keep durable task state under the current project agent-tasks directory. Preserve parent return points, distinguish parent-child, blocks, and discovered-from, record user decisions and unverified assumptions separately from verified evidence, and save a checkpoint when task state changes. Do not treat skipped or deferred as done; resume from agent-tasks/INDEX.md and the matching task file when asked to continue.
$managedEnd
"@

function Write-AtomicDirectory {
    param([string]$Source, [string]$Destination)
    $parent = Split-Path -Parent $Destination
    $staging = Join-Path $parent ('.task-tree-stage-' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $staging -Force | Out-Null
    try {
        Copy-Item -LiteralPath $Source -Destination $staging -Recurse -Force
        $stagedSkill = Join-Path $staging (Split-Path -Leaf $Source)
        if (Test-Path -LiteralPath $Destination) {
            Remove-Item -LiteralPath $Destination -Recurse -Force
        }
        Move-Item -LiteralPath $stagedSkill -Destination $Destination
    }
    finally {
        if (Test-Path -LiteralPath $staging) { Remove-Item -LiteralPath $staging -Recurse -Force }
    }
}

if ($PSCmdlet.ShouldProcess($destinationSkill, 'Install or update the task-tree Skill')) {
    New-Item -ItemType Directory -Path $GlobalSkillRoot -Force | Out-Null
    Write-AtomicDirectory -Source $sourceSkill -Destination $destinationSkill
    Write-Output "Installed Skill: $destinationSkill"
}

if (-not $SkipGlobalAgents) {
    $agentsDirectory = Split-Path -Parent $GlobalAgentsPath
    if ($PSCmdlet.ShouldProcess($GlobalAgentsPath, 'Add or update the managed Agent Task Tree rules')) {
        New-Item -ItemType Directory -Path $agentsDirectory -Force | Out-Null
        $existing = if (Test-Path -LiteralPath $GlobalAgentsPath) { Get-Content -LiteralPath $GlobalAgentsPath -Raw } else { '' }
        $pattern = '(?s)<!-- agent-task-tree:start -->.*?<!-- agent-task-tree:end -->'
        if ($existing -match $pattern) {
            $updated = [regex]::Replace($existing, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $managedBlock.TrimEnd() })
            $backup = "$GlobalAgentsPath.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
            Copy-Item -LiteralPath $GlobalAgentsPath -Destination $backup -Force
            Set-Content -LiteralPath $GlobalAgentsPath -Value $updated.TrimEnd() -Encoding UTF8
            Write-Output "Updated managed rules; backup: $backup"
        }
        else {
            if ($existing -and -not $existing.EndsWith("`n")) { $existing += "`r`n" }
            $updated = ($existing + "`r`n" + $managedBlock.Trim() + "`r`n").TrimStart("`r", "`n")
            if (Test-Path -LiteralPath $GlobalAgentsPath) {
                $backup = "$GlobalAgentsPath.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
                Copy-Item -LiteralPath $GlobalAgentsPath -Destination $backup -Force
                Write-Output "Backup: $backup"
            }
            Set-Content -LiteralPath $GlobalAgentsPath -Value $updated -Encoding UTF8
            Write-Output "Added managed rules: $GlobalAgentsPath"
        }
    }
}
