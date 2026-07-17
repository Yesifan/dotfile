# Dotfiles

Managed with a bare Git repository at `$HOME/.cfg`. Works on macOS and Linux.

## Configuration Overview

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

`~/.zshrc` uses a ` =========remote config============ ` / ` =========remote end============== ` marker pair.
`.codex/config.toml` uses `# ---- Local-only additions below ----`.
`.config/opencode/opencode.jsonc` uses `// ======= local config ===` / `// ======= local config end ===`.
Content above the marker is repo-managed; content below is machine-local (never push).
Shared shell behavior lives in `~/.config/zsh/zshrc`. All optional tool initialization
is guarded by `command -v` so a fresh machine can load the shell before tools
are installed.

See [shell.md](instructions/dotfile/shell.md) for shell behavior and
[config.md](instructions/dotfile/config.md) for tool configuration details.

## Tools

The interactive shell setup uses:

- `zsh` as the shell
- `starship` for the prompt
- `zoxide` for directory jumping
- `fzf` for fuzzy search and shell key bindings
- `zsh-autosuggestions` for gray inline history suggestions
- `zsh-syntax-highlighting` for realtime command-line highlighting
- `tmux` for terminal multiplexing
- `git-delta` for readable `git diff` and `git show`
- `ripgrep` (`rg`) for fast recursive text search
- `fd` for fast file and directory search
- `jq` for JSON parsing and querying
- Vim with tracked config at `~/.vimrc`
- Ghostty with a shared XDG config at `~/.config/ghostty/config.ghostty`

## Install

### Prerequisites

- git (macOS: `xcode-select --install`, Linux: usually pre-installed)
- SSH key added to GitHub

### 1. Clone the config

```zsh
echo ".cfg" >> "$HOME/.gitignore"
git clone --bare git@github.com:Yesifan/dotfile.git "$HOME/.cfg"
alias dgit='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
dgit checkout -f
dgit config --local status.showUntrackedFiles no
```

### 2. Load the shell

```zsh
exec zsh -l
```

Or open a new terminal. Missing tools won't cause errors.

### 3. Install dependencies

#### macOS

```zsh
brew install starship zoxide fzf zsh-autosuggestions zsh-syntax-highlighting tmux git-delta ripgrep fd jq
```

#### Debian / Ubuntu

```zsh
sudo apt update
sudo apt install zsh fzf tmux zsh-autosuggestions zsh-syntax-highlighting git-delta vim ripgrep fd-find jq
```

Install `starship`, `zoxide`, and `git-delta` from your package manager if
available, or use their official release packages. Debian and Ubuntu package
`fd` as `fd-find`, and the installed command may be named `fdfind`. Create a
local `fd` shim if needed:

```zsh
mkdir -p "$HOME/.local/bin"
ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
```

#### Fedora

```zsh
sudo dnf install zsh starship zoxide fzf tmux zsh-autosuggestions zsh-syntax-highlighting git-delta vim ripgrep fd-find jq
```

#### Arch Linux

```zsh
sudo pacman -S zsh starship zoxide fzf tmux zsh-autosuggestions zsh-syntax-highlighting git-delta vim ripgrep fd jq
```

#### Linuxbrew

```zsh
brew install starship zoxide fzf zsh-autosuggestions zsh-syntax-highlighting tmux git-delta ripgrep fd jq
```

### 4. Set up environment variables

| Variable                       | Purpose                                             |
| ------------------------------ | --------------------------------------------------- |
| `GITHUB_PERSONAL_ACCESS_TOKEN` | GitHub PAT for Codex + OpenCode MCP                 |
| `CONTEXT7_API_KEY`             | Context7 API Key for Codex + OpenCode MCP           |
| `OPENCODE_ENABLE_EXA=1`        | OpenCode Web Search (non-OpenCode Provider 时需要)  |

Add to `~/.zshrc` below the `# =========remote end==============` marker. See [agent.md](instructions/dotfile/agent.md) for setup details.

### 5. Verify

```zsh
exec zsh -l
opencode mcp list       # should show github  connected
codex mcp list          # should show github  connected
```

### 6. Install Agent Skills (optional)

```zsh
pnpm dlx skills add <package> -g
pnpm dlx skills update -g
```

See [agent.md](instructions/dotfile/agent.md) for the full skill list.

## File Management Principles

### Tracked files (managed by dgit)

Only explicitly added files — never use `dgit add -u`:

```
~/.zshrc                          # only content inside the remote config block
~/.config/zsh/zshrc
~/.config/git/config
~/.config/ghostty/config.ghostty
~/.config/starship.toml
~/.vimrc
~/.tmux.conf
~/.codex/*                        # only content above `# ---- Local-only additions below ----`
~/.agents/.skill-lock.json
~/.config/opencode/*              # only content above `// ======= local config ===`
instructions/dotfile/*
```

### Untracked files (local only)

```
~/.zprofile                        # brew shellenv, login init
~/.ssh/config                      # machine-specific SSH hosts/proxy
~/.npmrc                           # npm registry, auth tokens
~/.gitconfig                       # personal git identity
~/.zshrc content outside remote config block          # local PATH, aliases, env vars
~/.codex/config.toml content below local-only marker  # project trusts, connectors, local TUI
~/.config/opencode/* content below local config marker # local-only MCP servers
*.pem, *.key, .proxyenv                               # secrets — never enter the repo
```

### Conflict Resolution

| File / Section                                                      | Owner          | Strategy                                                 |
| ------------------------------------------------------------------- | -------------- | -------------------------------------------------------- |
| `.zshrc` — inside ` =========remote config============ ` block      | remote         | remote takes precedence (theirs)                         |
| `.zshrc` — outside remote config block                              | local          | preserve local (ours), never commit                      |
| `.codex/config.toml` — above `# ---- Local-only additions below ----` | remote       | remote takes precedence (theirs)                         |
| `.codex/config.toml` — below that marker                            | local          | preserve local (ours), never commit                      |
| `.config/opencode/opencode.jsonc` — above `// ======= local config ===` | remote      | remote takes precedence (theirs)                         |
| `.config/opencode/opencode.jsonc` — below that marker               | local          | preserve local (ours), never commit                      |
| `.zprofile`, `.ssh/config`, `.npmrc`, `.gitconfig`                  | local          | never in repo                                            |
| `.agents/.skill-lock.json`                                          | remote + local | merge — local installs preserved alongside repo entries |

### Local-Only Commits

Local machines carry machine-specific config below the markers. To stay
in sync with origin without pushing local data:

1. Keep `main` exactly **1 commit ahead** of `origin/main`.
2. That single commit contains **all** local additions, with message:
   ```
   LOCAL: <summary of all local configs> [never push]
   ```
3. After `dgit fetch origin`, replay your local commit on the new remote:

   ```sh
   # If exactly 1 commit ahead, fast-forward:
   dgit rebase origin/main

   # If diverged or rebase conflicts:
   dgit reset --soft origin/main     # discard old LOCAL commit, keep changes staged
   dgit commit --amend -m "LOCAL: <summary> [never push]"   # re-create single commit
   ```

   After rebase, `dgit log --oneline --graph -3` should show:
   ```
   * [hash] (HEAD -> main) LOCAL: ... [never push]
   * [hash] (origin/main) ...
   ```

4. **Never push the LOCAL commit.**

### Daily Operations

See [migrate.md](instructions/dotfile/migrate.md) for committing changes,
pushing, updating existing machines, and migration plans.
