# Dotfiles

Managed with a bare Git repository at `$HOME/.cfg`, aliased as `dgit`. Works on macOS and Linux.

The repo owns all the shared config. Each machine's secrets, paths, and personal settings stay out of it. A tracked file may carry a **LOCAL block** that marks its machine-local content; the repo ships the block empty and each machine fills it in. Nothing inside a LOCAL block is ever pushed.

## Configuration overview

| Software  | Config File                                                |
| --------- | ---------------------------------------------------------- |
| Zsh       | `~/.zshenv`, `~/.zprofile`, `~/.zshrc`, `~/.config/shell/` |
| Git       | `~/.config/git/config`                                     |
| Vim       | `~/.vimrc`                                                 |
| Neovim / NvChad | `~/.config/nvim/`                                    |
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

To override or remove a value the repo already ships (e.g. `model`, `lsp`), use an inline `LOCAL REPLACE: <key>` marker instead of appending an empty block. Both marker kinds are preserved on pull and stripped before push — see `.agents/skills/dotfile/references/conventions.md`.

Pi's `~/.pi/agent/settings.json` cannot carry a LOCAL block (it is strict JSON and Pi warns-and-ignores any comment), so the repo only tracks Pi's **shared resources** — `~/.pi/agent/AGENTS.md` (a symlink to `.codex/AGENTS.md`), `~/.pi/agent/prompts/`, and the shared permission policy. Its `settings.json` is dominated by machine-local provider/model/package config and stays on the machine, like `.gitconfig` and `.zprofile`.

## Tools

Required: **Neovim >= 0.11** (the default `EDITOR` and `VISUAL`) and **git-delta** (the Git pager and interactive diff filter), alongside Git and Zsh. These tools must be installed for the configured editor and Git workflows to work.

Recommended: `starship`, `zoxide`, `fzf`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, `tmux` (>= 3.5 if installed), `ripgrep`, `fd`, `jq`, `gh` (GitHub CLI), and Ghostty. Optional shell integrations are guarded so the shell can start before these tools are installed. Vim configuration remains available for occasional use.

The repo includes a minimal NvChad configuration with a shared plugin lockfile, OSC 52 clipboard support over SSH, and ordinary `y` / `d` / `p` operations. Ghostty selection does not automatically copy text. See the [NvChad setup notes](.agents/skills/dotfile/references/packages/nvchad.md) for startup, plugin synchronization, and tmux limitations.

## Package management preferences

- `mise` for development tools and runtime versions; recommended, not required, and not automatically activated.
- `pnpm` for JavaScript / TypeScript packages.
- `uv` for Python environments, dependencies, and tools.

Follow an existing project's explicit tool configuration and lockfiles first. These preferences do not call for automatically migrating existing projects.

## Environment check

Open a new shell after deploying the configuration, then run `dotfile-doctor`. The command is defined in `~/.config/shell/doctor.zsh` and checks tools, supported versions, configuration files, and shared agent symlinks under `$HOME`. To check a source checkout, run `dotfile-doctor /path/to/dotfile`.

Missing required dependencies or invalid configuration return a nonzero exit status. Missing optional tools are reported without failing the check. The command does not install or modify anything.

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
