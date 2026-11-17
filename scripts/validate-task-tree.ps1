[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TaskRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $TaskRoot -PathType Container)) { throw "Task root not found: $TaskRoot" }
$index = Join-Path $TaskRoot 'INDEX.md'
if (-not (Test-Path -LiteralPath $index -PathType Leaf)) { throw 'INDEX.md is required.' }

$validStatuses = @('proposed','pending','in_progress','blocked','deferred','skipped','done','cancelled')
$files = @(Get-ChildItem -LiteralPath $TaskRoot -Filter '*.md' -File | Where-Object Name -ne 'INDEX.md')
if ($files.Count -eq 0) { throw 'At least one main task file is required.' }

$ids = @{}
foreach ($file in $files) {
    $text = Get-Content -LiteralPath $file.FullName -Raw
    $idMatch = [regex]::Match($text, '(?m)^id:\s*([^\s]+)\s*$')
    $statusMatch = [regex]::Match($text, '(?m)^status:\s*([^\s]+)\s*$')
    if (-not $idMatch.Success -or -not $statusMatch.Success) { throw "Missing id or status in $($file.Name)." }
    $id = $idMatch.Groups[1].Value
    $status = $statusMatch.Groups[1].Value
    if ($ids.ContainsKey($id)) { throw "Duplicate task id: $id" }
    if ($validStatuses -notcontains $status) { throw "Invalid status '$status' in $($file.Name)." }
    $ids[$id] = $file.Name
    foreach ($line in ($text -split "`r?`n")) {
        if ($line -match '^\s*- \[(?<box>[ xX])\].*status:\s*(?<nodeStatus>[a-z_]+)') {
            $box = $Matches.box.Trim()
            $nodeStatus = $Matches.nodeStatus
            if ($validStatuses -notcontains $nodeStatus) { throw "Invalid node status '$nodeStatus' in $($file.Name)." }
            if (($nodeStatus -eq 'done') -ne ($box -eq 'x' -or $box -eq 'X')) { throw "Checklist state does not match status '$nodeStatus' in $($file.Name)." }
        }
    }
}
Write-Output "Validated $($files.Count) task file(s) under $TaskRoot"
