# Dotfiles

To install or update these dotfiles, send the following to your AI agent:

```text
First run npx skills use YeSifan/dotfile@dotfile, then read and follow the skill's instructions to install or update the dotfiles based on this machine's current setup.
```

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

Required tools (installation still requires your consent):

- **Baseline**: Git, Zsh, Neovim >= 0.11 (default `EDITOR` / `VISUAL`), and git-delta (Git paging and interactive diffs).
- **Shell experience**: Starship (prompt), zoxide (directory jumping), fzf (fuzzy search), zsh-autosuggestions (history suggestions), and zsh-syntax-highlighting (syntax highlighting).
- **Server utilities**: tmux >= 3.5 (persistent sessions), ripgrep (`rg`, content search), fd (file search; `fdfind` is also accepted), and jq (JSON processing).

GitHub CLI (`gh`) and Ghostty remain recommended, optional tools. **Ghostty and Nerd Fonts are installed only on the client that runs the graphical terminal; headless SSH servers do not need either.** The server **does need terminfo matching the SSH `$TERM`** (such as `xterm-ghostty`); missing entries can cause broken cursor movement and shell redraw. See the [Ghostty SSH compatibility checks and repair](.agents/skills/dotfile/references/packages/ghostty.md). Select the Nerd Font in the client terminal to display NvChad icons. Shell integrations retain availability guards so missing dependencies do not prevent the shell from starting, but `dotfile-doctor` reports missing required tools or Zsh plugins as failures. Vim configuration remains available for occasional use.

The repo includes a minimal NvChad configuration with a shared plugin lockfile, OSC 52 clipboard support over SSH, and ordinary `y` / `d` / `p` operations. Ghostty selection does not automatically copy text. See the [NvChad setup notes](.agents/skills/dotfile/references/packages/nvchad.md) for startup, plugin synchronization, and tmux limitations.

For Linux servers with SSH exposed to the network, **Fail2ban** is also recommended to temporarily ban source IPs after repeated authentication failures. It is optional and configured on the server; see the [recommended SSH jail configuration](.agents/skills/dotfile/references/packages/fail2ban.md).

## Package management preferences

- `mise` for development tools and runtime versions; recommended, not required, and not automatically activated.
- `pnpm` for JavaScript / TypeScript packages.
- `uv` for Python environments, dependencies, and tools.

Follow an existing project's explicit tool configuration and lockfiles first. These preferences do not call for automatically migrating existing projects.

## Environment check

Open a new shell after deploying the configuration, then run `dotfile-doctor`. The command is defined in `~/.config/shell/doctor.zsh` and checks tools, supported versions, SSH terminal capabilities (terminfo), configuration files, and shared agent symlinks under `$HOME`. To check a source checkout, run `dotfile-doctor /path/to/dotfile`.

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
