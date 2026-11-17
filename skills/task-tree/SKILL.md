---
name: task-tree
description: Maintain a persistent Markdown task tree for complex, multi-step, or cross-session Codex work; use when a task has dependencies, discoveries, decisions, or recovery checkpoints, and when explicitly invoked with $task-tree.
---

# Agent Task Tree

Use this skill to keep the user's end goal visible while work moves through nested subtasks. It is a lightweight protocol: the project stores the state in `agent-tasks/`, while the agent makes the decisions.

## When to activate

Activate for `$task-tree`, or when the request has several meaningful steps, a bug investigation, a data correction, a refactor with multiple checks, unresolved hypotheses, dependencies, or work that may continue in another session. Do not create a task tree for a simple answer, one-file typo fix, or one-command lookup unless the user asks.

Before creating anything, look for `agent-tasks/INDEX.md` in the current project. If the user says “continue”, restore, or names an ID, read the index and the matching task file first. Verify the saved checkpoint against the current files and tests; saved assumptions are not verified facts.

## Files and stable IDs

Keep project state under `<project-root>/agent-tasks/`:

- `INDEX.md` lists main tasks, status, priority, and the next action.
- One `<ID>.md` file contains each main task's complete tree and checkpoint.
- Use stable IDs such as `BUG-001` or `TASK-001`. Never renumber an existing ID when a task is inserted or re-parented. Use display numbering only for readability.

Start from the templates in `assets/` when useful. Read [references/task-model.md](references/task-model.md) for the file shape and status meanings; read [references/workflow.md](references/workflow.md) when creating, resuming, or completing work; read [references/decision-policy.md](references/decision-policy.md) when triaging discoveries, assumptions, or investigation cost.

## Operating loop

1. Capture the original goal and observable acceptance conditions before splitting work.
2. Split only enough to make the next decisions and checks clear. Add deeper levels when a child has its own outcome or dependency; do not create hierarchy just to mirror a conversation.
3. Before entering a child, record the parent return point and current path in the task file. Keep the parent available in context.
4. Choose the next executable node by acceptance impact and necessary dependencies, then by user priority and low-cost verification. A checklist's visual order alone is not a scheduler.
5. At every meaningful state change, update the node status, evidence, decisions, assumptions, blockers, current path, return point, and next action. Keep logs and large command output outside the task file; record a path and short result instead.
6. When a child reaches `done`, `skipped`, `deferred`, `cancelled`, or `blocked`, return to its recorded parent and reassess the parent acceptance conditions. Continue upward until there is executable work or the main task is complete. Never treat `skipped` or `deferred` as `done`.
7. Before the final response, save a checkpoint whenever the task state changed. The final statement must distinguish verified completion, completion within a user-adjusted scope, assumption-dependent progress, and blocked work.

## Relationships and discoveries

Use the smallest relationship that describes reality:

- `parent-child` means the child is part of the parent's planned work.
- `blocks` means the target cannot proceed until this node is resolved or an explicit user decision accepts the limitation.
- `discovered-from` records where an issue was found; it does not imply parentage or blocking.

When a new issue appears, first decide whether it is real, duplicate, relevant, and blocking. Reuse an existing ID when it is the same issue. Add a child only when it is required for the parent outcome; otherwise add a same-level or separate main task and record `discovered-from`. Use `proposed` in the notes (or a pending node) for non-critical work that needs a user decision. If the issue materially expands scope, explain the impact and ask before pursuing it; keep the original path resumable.

## User decisions and evidence

Record these separately:

- `verified`: evidence from code, tests, files, or an external result.
- `user_decision`: an instruction such as skip, defer, narrow scope, or use a proposed cause.
- `assumption`: an explicitly unverified premise, its scope, and its impact.

A user may say to continue under an assumption. Record it and proceed when the risk is acceptable, but do not rewrite it as `verified`. If later evidence conflicts, pause at the decision point and surface the conflict. Production data changes and irreversible actions still require the normal authorization and safety checks.

## Cost and scope control

Prefer a cheap, observable check. Record distinct failed approaches and their evidence. After two materially different attempts without progress, or when cost/risk has clearly outgrown the parent goal, reassess instead of trying variants indefinitely: continue, change route, defer, skip with a limitation, or ask the user. This is a decision point, not an automatic failure. Do not recursively pursue every discovered issue.

## Recovery and completion

For a resumed task, read the index, task file, current path, return point, and latest checkpoint; inspect the actual repository before acting. Respect prior user decisions and do not repeat explicitly skipped work without new evidence or a new request.

Mark a node `done` only when its own acceptance conditions are met. A main task is complete only when its stated goal is met and remaining nodes are either unnecessary (with a reason), explicitly skipped/deferred by the user (with the resulting limitation), or cancelled. Code written, by itself, is not proof that a bug is fixed. Update `INDEX.md` when a main task's status or next action changes.

## Minimal examples

```text
- [ ] BUG-001.2 Locate cause — status: in_progress
  - [x] BUG-001.2.a Compare query and fixture — status: done
  - [ ] BUG-001.2.b Confirm null handling — status: blocked
```

```text
relations:
- type: discovered-from
  target: BUG-001.1
- type: blocks
  target: BUG-001.4
```

The task tree is a working record, not a substitute for the user's decisions or for repository tests.
