# Changelog

## 2026-07-15

### Added

- `instructions/dotfile/agent.md` — auth setup + skills guide for Codex + OpenCode (replaces `auth.md`)
- `.codex/config.toml` — MCP servers: context7 (remote + CONTEXT7_API_KEY), github (npx local + PAT), playwright (npx local)
- `.config/opencode/opencode.jsonc` — MCP servers: github (remote + readonly), playwright (local); permissions: `github_*`, `playwright_*` allow

### Changed

- `.config/opencode/opencode.jsonc` — deny `.pem`/`.key` in `read` and `edit` to align with Codex
- `README.md` — added Auth Setup link to Quick Links

### Removed

- `.config/zsh/zshrc.local.example` — no longer needed; local config goes in
  `.zshrc` below the `LOCAL CONFIG BELOW` separator
- `.zshalias` sourcing — users add local aliases directly in `.zshrc`
- `.ssh/config` — machine-local proxy/identity config, removed from repo

### Changed

- `.zshrc` — removed `zshrc.local` and `.zshalias` source lines; added
  `LOCAL CONFIG BELOW` separator for machine-local additions
- `README.md` — updated Shell Layout and Local-Only Files sections
- `instructions/dotfile/update.md` — removed deleted files from add/ignore lists;
  added breaking-change check reference to migrate.md
- `instructions/dotfile/migrate.md` — new agent-facing migration guide covering
  breaking changes with per-commit plans
- `README.md` — added `.ssh/config` to Local-Only Files; linked migrate.md
  from Maintenance section

## 2026-07-15

### Added

- `instructions/dotfile/shell.md` — Shell Layout and Behavior extracted from README
- `instructions/dotfile/config.md` — Tool Configurations (Git, Vim, Starship, tmux, Ghostty) extracted from README

### Changed

- `README.md` — restructured: intro with config table, tools, install (clone-first order + env vars), file management principles (tracked/untracked/conflict rules)
- `instructions/dotfile/migrate.md` — absorbed update.md content (dgit workflow, making changes, updating machines); added conflict rules for `.codex/config.toml` and `.config/opencode/opencode.jsonc`

### Removed

- `instructions/dotfile/update.md` — merged into migrate.md

## 2026-07-15

### README restructuring

- **Tools**: added `jq` to tool list and all platform install commands
- **Quick Links**: added table of contents for navigation
- **Install**: split into per-platform subheadings, consolidated notes
- **Shell Behavior**: reformatted as bold-keyed list for scannability
- **Tool Configs**: grouped Git / Vim / Starship / tmux / Ghostty under shared section
- **Local-Only Files**: restructured with subheadings per file
- **Ghostty**: moved from top-level section into Tool Configs
- **Workflow + Update**: extracted to `instructions/dotfile/update.md`, replaced with short reference link
- **Removed**: mixed Chinese/English content, duplicate Homebrew install block

### New file

- `instructions/dotfile/update.md` — bare repo workflow (dgit init, commit, push, review) and per-machine update guide, merged from previously separate sections.
