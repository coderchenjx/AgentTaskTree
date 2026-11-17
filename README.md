# Agent Task Tree

Agent Task Tree is a small, repository-owned Codex Skill for complex work that needs a durable plan, nested tasks, dependency relationships, user decisions, and cross-session recovery. It stores state as human-readable Markdown under `agent-tasks/` in each business project.

The repository is the maintenance source. The installer copies `skills/task-tree/` to the user's global Skill directory and adds a short, managed block to the global Codex `AGENTS.md`. It does not copy project task data into the global directory and does not modify business projects.

The repository ignores local `agent-tasks/` checkpoints because they belong to the working copy using the Skill, not to the reusable Skill source. The current checkout may still contain local checkpoints for recovery; they are intentionally excluded from GitHub backups.

## Install or update

From this repository in PowerShell:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\install.ps1
```

The default global locations are:

- Skill: `$HOME\.agents\skills\task-tree`
- Rules: `$env:CODEX_HOME\AGENTS.md` when `CODEX_HOME` is set, otherwise `$HOME\.codex\AGENTS.md`

Use `-WhatIf` to preview changes, `-SkipGlobalAgents` to copy only the Skill, or `-GlobalSkillRoot` / `-GlobalAgentsPath` for an explicit target. A timestamped backup is created before an existing global `AGENTS.md` is changed.

## Use

For a complex request, say `$task-tree` or let the Skill activate automatically. The agent creates or resumes `agent-tasks/INDEX.md` and a stable-ID task file such as `BUG-001.md`. Simple one-step requests do not need a task tree.

## Validate

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\validate-task-tree.ps1 -TaskRoot .\agent-tasks
pwsh -NoProfile -ExecutionPolicy Bypass -File .\tests\scenarios\Test-TaskTree.ps1
```

The scenario test uses a temporary directory and removes it on completion. The scenarios validate the durable file model and installer invariants; decisions made by an Agent during a live conversation still depend on the Skill instructions and are not fully automatable from a file-only test.

## Updating

Edit the repository Skill and references, rerun the installer, then rerun the validator and scenarios. Existing unrelated Skills and unmanaged global `AGENTS.md` content are preserved.

GitHub Actions runs the scenario test on Windows for every push and pull request.
