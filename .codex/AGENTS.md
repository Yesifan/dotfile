# Global development preferences

## Orchestration

The main agent owns planning, design judgment, user-facing tradeoffs, final integration, verification, Git operations, and final correctness.

When a task has a clear plan, delegate subtasks whose intermediate process is not needed and where only the final implementation or research result matters.

Do not delegate one broad multi-part task when the work can be split into coherent, non-overlapping units. Use one explorer, librarian, or OpenCode dispatch per implementation unit.

Prefer doing the work directly when the task is small, the relevant file is already known, the change is under roughly 20 lines in one file, or explaining and reviewing the delegation would take longer than implementing it.

### Delegation rules

Every delegated task must include:

- the concrete goal
- the files or directories likely involved
- the specific implementation or research unit it owns
- what it must not read or change
- the scoped tests or checks it may run
- the required completion report format

## Preference

- Use pnpm for Node.js projects unless the repository specifies otherwise.
- Prefer existing project scripts and tooling over introducing new tooling.

Prefer fast search tools for routine repository inspection:

- Prefer `rg` for text search and `fd` for file search.
