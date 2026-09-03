# Dotfiles

Managed with a bare Git repository at `$HOME/.cfg`, aliased as `dgit`. Works on macOS and Linux.

The repo owns all the shared config. Each machine's secrets, paths, and personal settings stay out of it. A tracked file may carry a **LOCAL block** that marks its machine-local content; the repo ships the block empty and each machine fills it in. Nothing inside a LOCAL block is ever pushed.

## Configuration overview

| Software  | Config File                                                |
| --------- | ---------------------------------------------------------- |
| Zsh       | `~/.zshenv`, `~/.zprofile`, `~/.zshrc`, `~/.config/shell/` |
| Git       | `~/.config/git/config`                                     |
| Vim       | `~/.vimrc`                                                 |
| Starship  | `~/.config/starship.toml`                                  |
| tmux      | `~/.tmux.conf`                                             |
| Ghostty   | `~/.config/ghostty/config`                                 |
| Codex CLI | `~/.codex/*`                                               |
| OpenCode  | `~/.config/opencode/*`                                     |
| Pi        | `~/.pi/agent/*`                                            |

LOCAL blocks mark machine-local content in any tracked file:

- `.zshrc`, `.zshenv`, `.zprofile`, `.config/shell/*`, `.codex/config.toml` — `# ===== LOCAL =====` … `# ===== END LOCAL =====`
- `.config/opencode/opencode.jsonc` — `// ===== LOCAL =====` … `// ===== END LOCAL =====`

Content inside a LOCAL block is machine-local (preserved on pull/rebase, stripped before push); everything else is repo-managed (remote wins on conflict).

Pi's `~/.pi/agent/settings.json` cannot carry a LOCAL block (it is strict JSON and Pi warns-and-ignores any comment), so the repo only tracks Pi's **shared resources** — `~/.pi/agent/AGENTS.md` (a symlink to `.codex/AGENTS.md`), `~/.pi/agent/prompts/`, and the shared permission policy. Its `settings.json` is dominated by machine-local provider/model/package config and stays on the machine, like `.gitconfig` and `.zprofile`.

## Tools

`zsh`, `starship`, `zoxide`, `fzf`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, `tmux`, `git-delta`, `ripgrep`, `fd`, `jq`, Vim, and Ghostty. Every optional tool block is guarded by `command -v`, so a fresh machine loads the shell before tools are installed.

## Install, maintain, update

Before you install or update the dotfiles, sync the **`dotfile` skill** to the latest first, so the agent has the most current guidance:

```zsh
npx skills use YeSifan/dotfile@dotfile
```

The step-by-step procedures live in the bundled **`dotfile` skill** at `.agents/skills/dotfile/`:

- **Install** on a new machine — `.agents/skills/dotfile/references/install.md`
- **Make, review, commit, push** a change — `.agents/skills/dotfile/references/maintain.md`
- **Update an existing machine** (incl. breaking changes) — `.agents/skills/dotfile/references/update.md`
- **Tracked vs untracked files, LOCAL blocks, conflict rules, LOCAL commit convention** — `.agents/skills/dotfile/references/conventions.md`

The skill is intentionally **not auto-triggered** (`disable-model-invocation: true`). Load it explicitly via the skill command (`/skill:dotfile`) or by asking an agent to use the dotfile skill.

## Agent setup

Agent-side environment variables (`CONTEXT7_API_KEY`, `EXA_API_KEY`), MCP servers, and the skills tooling are in `.agents/skills/dotfile/references/agents.md`. Variables are machine-local; put them in a LOCAL block and never commit them.
