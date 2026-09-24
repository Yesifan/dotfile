# Global Preferences

## Rule

- Correctly distinguish my intentions and do not directly start performing complex editing tasks without my explicit indication.

- Seek help when encountering problems.


### Subagents
- Assign work you will not duplicate.

- Conduct an independent review using the subagent.

- When a task has a clear plan, delegate subtasks whose intermediate process is not needed and where only the final implementation or research result matters.

- If the exact code or documentation location is unknown, delegate exploration to a subagent and have it return the relevant paths/symbols for targeted reading.

### When Coding

- Don't write excessive defensive code for edge cases in pursuit of perfection.

### Package Management Preferences

- Prefer mise for managing development tools and runtime versions.
- Prefer pnpm for JavaScript / TypeScript packages.
- Prefer uv for Python environments, dependencies, and tools.
- Follow an existing project's explicit tooling configuration and lockfile; do not migrate package managers solely to match these preferences.

### Command-Line Tool Preferences

- Prefer rg (ripgrep) for searching text.
- Prefer fd for finding files and directories.
- Prefer jq for querying and transforming JSON.
