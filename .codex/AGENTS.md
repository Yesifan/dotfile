# Global development preferences

When performing complex tasks, first confirm whether the infrastructure such as the environment and dependencies (databases, etc.) is ready.
Avoid situations where tasks cannot be completed due to incomplete environments.

## Delegation rules

When a task has a clear plan, delegate subtasks whose intermediate process is not needed and where only the final implementation or research result matters.

## Preference

- Use pnpm for Node.js projects unless the repository specifies otherwise.
- Prefer existing project scripts and tooling over introducing new tooling.

Prefer fast search tools for routine repository inspection:

- Prefer `rg` for text search and `fd` for file search.
