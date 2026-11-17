# Workflow and recovery

## Create

1. Create `agent-tasks/` and `INDEX.md` only for a complex task or an explicit `$task-tree` request.
2. Pick the next unused stable ID by inspecting `INDEX.md`; do not reuse an old ID.
3. Write the goal, acceptance conditions, initial tree, and checkpoint before starting investigation.
4. Add the main task to the index with status and next action.

## Enter and return

Before entering a child, set `current-node`, `current-path`, `return-to`, and `next-action`. When the child changes state, save its evidence and then return to `return-to`. Re-evaluate parent acceptance and dependencies; the original plan may now be obsolete. Continue up the tree until an executable node is selected or the goal is satisfied.

## Update discipline

Save after task creation, a status transition, a new relation, a user decision, a material assumption, a failed route, a scope change, and before ending a response. Keep a short checkpoint and link to detailed artifacts instead of pasting logs.

## Resume

Read `INDEX.md`, then the selected task file and its latest checkpoint. Inspect the repository, tests, and relevant files to confirm the saved state. Treat `verified` evidence as historical evidence that may need rechecking if code changed; treat `user_decision` and `assumption` as still applicable unless the user changes them or new evidence conflicts.

## Finish

Use the acceptance section and actual evidence to decide completion. If a skipped or deferred node affects confidence, say so in the checkpoint and final result. If a node is no longer necessary, mark it `cancelled` with the reason rather than pretending it was done.
