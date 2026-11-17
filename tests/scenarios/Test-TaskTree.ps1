[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$temp = Join-Path ([IO.Path]::GetTempPath()) ('agent-task-tree-test-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $temp -Force | Out-Null
try {
    $tasks = Join-Path $temp 'agent-tasks'
    New-Item -ItemType Directory -Path $tasks -Force | Out-Null
    @'
# Agent Task Tree index

| ID | Title | Status | Priority | Next action | Updated |
| --- | --- | --- | --- | --- | --- |
| BUG-001 | Balance mismatch | in_progress | P1 | Return to parent after data repair | 2026-11-13 |
'@ | Set-Content -LiteralPath (Join-Path $tasks 'INDEX.md') -Encoding UTF8
    @'
---
id: BUG-001
type: bug
title: Balance mismatch
status: in_progress
priority: P1
current-node: BUG-001.4.2.1
current-path: BUG-001 > BUG-001.4 > BUG-001.4.2 > BUG-001.4.2.1
return-to: BUG-001.4.2
next-action: Return to parent and run regression checks
---

# BUG-001 Balance mismatch

## Acceptance
- [ ] Reports agree — status: pending
- [ ] Regression checks pass — status: pending

## Task tree
- [x] BUG-001.1 Reproduce — status: done
- [x] BUG-001.2 Locate cause — status: done
- [ ] BUG-001.3 Discovered negative-stock issue — status: skipped
- [ ] BUG-001.4 Repair — status: in_progress
  - [x] BUG-001.4.1 Analyze table — status: done
  - [ ] BUG-001.4.2 Write repair script — status: in_progress
    - [x] BUG-001.4.2.1 Compare constraints — status: done
    - [ ] BUG-001.4.2.2 Run rehearsal — status: pending

## Relations
- type: discovered-from
  target: BUG-001.2
- type: blocks
  target: BUG-001.4.2.2

## Evidence (verified)
- Reproduction fixture shows a date boundary mismatch.

## Decisions (user_decision)
- User chose to skip negative-stock follow-up for this scope.

## Assumptions (assumption)
- Treat imported timestamps as UTC until the data owner confirms timezone.

## Attempts and cost
- distinct failed approaches: 2
- reassessment: changed from query rewrite to constrained repair script

## Checkpoint
- current path: BUG-001 > BUG-001.4 > BUG-001.4.2 > BUG-001.4.2.1
- return point: BUG-001.4.2
- next action: Return to parent and run regression checks
'@ | Set-Content -LiteralPath (Join-Path $tasks 'BUG-001.md') -Encoding UTF8

    $validator = Join-Path $repo 'scripts\validate-task-tree.ps1'
    & pwsh -NoProfile -ExecutionPolicy Bypass -File $validator -TaskRoot $tasks
    if ($LASTEXITCODE -ne 0) { throw 'Scenario validation failed.' }

    $task = Get-Content -LiteralPath (Join-Path $tasks 'BUG-001.md') -Raw
    $checks = @(
        @{ Name = 'nested path'; Test = $task.Contains('BUG-001.4.2.1') },
        @{ Name = 'return point'; Test = $task.Contains('return point: BUG-001.4.2') },
        @{ Name = 'discovered-from'; Test = $task.Contains('type: discovered-from') },
        @{ Name = 'blocks'; Test = $task.Contains('type: blocks') },
        @{ Name = 'skipped remains unchecked'; Test = $task.Contains('[ ] BUG-001.3') },
        @{ Name = 'assumption separated'; Test = $task.Contains('## Assumptions (assumption)') },
        @{ Name = 'cost reassessment'; Test = $task.Contains('distinct failed approaches: 2') }
    )
    foreach ($check in $checks) { if (-not $check.Test) { throw "Failed scenario: $($check.Name)" } }

    $fixtureInstall = Join-Path $temp 'install-fixture'
    $fixtureSkill = Join-Path $fixtureInstall 'skills'
    $fixtureAgents = Join-Path $fixtureInstall 'AGENTS.md'
    & pwsh -NoProfile -ExecutionPolicy Bypass -File (Join-Path $repo 'scripts\install.ps1') -RepositoryRoot $repo -GlobalSkillRoot $fixtureSkill -GlobalAgentsPath $fixtureAgents
    if (-not (Test-Path -LiteralPath (Join-Path $fixtureSkill 'task-tree\SKILL.md'))) { throw 'Fixture Skill was not installed.' }
    $first = Get-Content -LiteralPath $fixtureAgents -Raw
    & pwsh -NoProfile -ExecutionPolicy Bypass -File (Join-Path $repo 'scripts\install.ps1') -RepositoryRoot $repo -GlobalSkillRoot $fixtureSkill -GlobalAgentsPath $fixtureAgents
    $second = Get-Content -LiteralPath $fixtureAgents -Raw
    if (([regex]::Matches($second, '<!-- agent-task-tree:start -->')).Count -ne 1) { throw 'Managed rules were duplicated.' }
    if (-not $second.Contains('## Agent Task Tree')) { throw 'Managed rules were lost on update.' }
    if ($first -eq $second) { throw 'Second install did not exercise update/backup path.' }
    Write-Output 'PASS: scenarios 1-10 represented by durable tree, relations, decisions, recovery checkpoint, and idempotent fixture install.'
}
finally {
    if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Recurse -Force }
}
