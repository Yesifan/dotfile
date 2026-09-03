# Dotfiles

Managed with a bare Git repository at `$HOME/.cfg`, aliased as `dgit`. Works on macOS and Linux.

The repo holds only shared config. Each machine's secrets, paths, and personal settings stay out of it and are never committed. A few files are split by markers into a repo-managed section (above the marker) and a machine-local section (below) that must never be pushed.

## Configuration overview

| Software  | Config File                        |
| --------- | ---------------------------------- |
| Zsh       | `~/.zshrc`, `~/.config/zsh/zshrc`  |
| Git       | `~/.config/git/config`             |
| Vim       | `~/.vimrc`                         |
| Starship  | `~/.config/starship.toml`          |
| tmux      | `~/.tmux.conf`                     |
| Ghostty   | `~/.config/ghostty/config.ghostty` |
| Codex CLI | `~/.codex/*`                       |
| OpenCode  | `~/.config/opencode/*`             |

Markers that split managed from local content:

- `.zshrc` — `# =========remote config============` … `# =========remote end==============`
- `.codex/config.toml` — `# ---- Local-only additions below ----`
- `.config/opencode/opencode.jsonc` — `// ======= local config ===` … `// ======= local config end ===`

Content above a marker is repo-managed (remote wins on conflict); content below is machine-local (preserved, never committed).

## Tools

`zsh`, `starship`, `zoxide`, `fzf`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, `tmux`, `git-delta`, `ripgrep`, `fd`, `jq`, Vim, and Ghostty. Every optional tool block is guarded by `command -v`, so a fresh machine loads the shell before tools are installed.

## Install, maintain, update

The step-by-step procedures live in the bundled **`dotfile` skill** at `.agents/skills/dotfile/`:

- **Install** on a new machine — `.agents/skills/dotfile/references/install.md`
- **Make, review, commit, push** a change — `.agents/skills/dotfile/references/maintain.md`
- **Update an existing machine** (incl. breaking changes) — `.agents/skills/dotfile/references/update.md`
- **Tracked vs untracked files, markers, conflict rules, LOCAL convention** — `.agents/skills/dotfile/references/conventions.md`

The skill is intentionally **not auto-triggered** (`disable-model-invocation: true`). Load it explicitly via the skill command (`/skill:dotfile`) or by asking an agent to use the dotfile skill.

## Agent setup

Agent-side environment variables (`CONTEXT7_API_KEY`, `EXA_API_KEY`), MCP servers, and the skills tooling are in `.agents/skills/dotfile/references/agents.md`. Variables are machine-local; set them below the local marker and never commit them.
