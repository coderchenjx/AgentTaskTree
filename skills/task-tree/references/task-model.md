# Task file model

Use Markdown with a small YAML-like metadata block. Keep the metadata readable and stable; do not depend on a parser being available.

```markdown
---
id: BUG-001
type: bug
title: Two reports disagree on balance
status: in_progress
priority: P1
parent: none
created: 2026-11-13
updated: 2026-11-13
current-node: BUG-001.2
current-path: BUG-001 > BUG-001.2
return-to: BUG-001
next-action: Confirm the query's date boundary
---

# BUG-001 Two reports disagree on balance

## Original goal
...

## Acceptance
- [ ] The reports agree for the affected period — status: pending
- [ ] Regression checks pass — status: pending

## Task tree
- [ ] BUG-001.1 Reproduce — status: done
- [ ] BUG-001.2 Locate cause — status: in_progress
  - [x] BUG-001.2.a Compare query and fixture — status: done
  - [ ] BUG-001.2.b Confirm date boundary — status: pending
- [ ] BUG-001.3 Repair — status: pending

## Relations
- type: blocks
  target: BUG-001.3
- type: discovered-from
  target: BUG-001.1

## Evidence (verified)
- `tests/balance.spec.ts`: reproduced on fixture `...`; result: ...

## Decisions (user_decision)
- 2026-11-13: user chose to defer the unrelated negative-stock issue.

## Assumptions (assumption)
- 2026-11-13: treat the imported date as UTC for this task; unverified; impact: repair validation may change if false.

## Blockers and unresolved questions
- ...

## Attempts and cost
- distinct failed approaches: 1
- last route: ...
- reassessment: none

## Checkpoint
- current path: BUG-001 > BUG-001.2 > BUG-001.2.b
- return point: BUG-001.2 after BUG-001.2.b
- completed since last checkpoint: ...
- next action: ...
```

Status meanings:

| Status | Meaning |
| --- | --- |
| `proposed` | Recorded for consideration; do not spend substantial effort yet. |
| `pending` | Accepted work that has not started. |
| `in_progress` | The current route is being executed. |
| `blocked` | A named dependency or decision prevents progress. |
| `deferred` | Deliberately postponed; unresolved. |
| `skipped` | Deliberately omitted; unresolved unless the acceptance criteria were changed. |
| `done` | The node's acceptance conditions are met and evidence is recorded. |
| `cancelled` | Removed from the current scope with a reason. |

Only `done` uses a checked Markdown box. Keep all other statuses unchecked so `skipped` cannot look complete.
