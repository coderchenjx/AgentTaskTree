# Decisions, discoveries, and investigation cost

For each new issue, answer in order: Is it real or only a hypothesis? Is it already tracked? Is it required by the current acceptance criteria? Does it block a named node? Does it materially expand cost or risk?

- Required and blocking work can be added to the current tree with a relation and a short reason.
- Related but independent work should be a same-level node or a separate main task, with `discovered-from` pointing to the node where it was found.
- Non-critical work starts as `proposed` or `deferred` and waits for a user decision when pursuing it would expand scope.
- A duplicate updates the existing task's evidence instead of creating a second ID.

Record a scope decision in the task file. A skipped item remains unresolved; a deferred item remains unresolved; a cancelled item is outside the current scope for a stated reason.

When two distinct approaches have failed without new evidence, summarize what was tried and ask whether to continue, change route, defer, skip with a limitation, or proceed under a user-supplied assumption. Continue autonomously when the next step is low risk and within the original acceptance criteria.
