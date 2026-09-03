# Install on a new machine

> **Scope:** this reference is for the **production / machine path** (deploying the dotfiles onto an installed machine via bare repo `$HOME/.cfg` and `dgit`). It is not about the dotfiles source repo — installing a source checkout is just `git clone` + `git checkout`.

Set up the dotfiles from scratch. Before you start, sync this skill to the latest so you have the most current install steps: `npx skills add Yesifan/dotfile`.

Two things to keep in mind: the shell must be loadable before the tools are installed (every optional block is guarded by `command -v`), and the clone is a **bare** repo whose work-tree is `$HOME`.

## 0. Prerequisites

- `git` (macOS: `xcode-select --install`; most Linux distros pre-install it)
- An SSH key added to the GitHub account that owns the repo

## 1. Clone the config

```zsh
echo ".cfg" >> "$HOME/.gitignore"
git clone --bare git@github.com:Yesifan/dotfile.git "$HOME/.cfg"
alias dgit='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
dgit checkout -f
dgit config --local status.showUntrackedFiles no
```

Notes:

- `.cfg` is added to `~/.gitignore` so the bare repo isn't treated as an untracked file in the user's own git repos.
- `dgit checkout -f` checks the tracked files out into `$HOME`. It is `-f` because the work-tree already contains real user files; warning about them is noise, not a reason to stop.
- `status.showUntrackedFiles no` keeps `dgit status` from listing the machine's untracked files (which by design are many).

## 2. Load the shell

```zsh
exec zsh -l
```

Or open a new terminal. Missing tools won't cause errors because the config guards every optional feature with `command -v`.

## 3. Install dependencies

Install the tool chain for the platform. Only install what you actually want; the shell works without them. Example for Debian / Ubuntu:

```zsh
sudo apt update
sudo apt install zsh fzf tmux zsh-autosuggestions zsh-syntax-highlighting git-delta vim ripgrep fd-find jq
```

On other platforms use your package manager (`macOS`/`Linuxbrew`: `brew`, Fedora: `dnf`, Arch: `pacman`) to install the same tool set; `starship`, `zoxide`, and `git-delta` come from their official releases if a distro package is missing.

Debian/Ubuntu package `fd` as `fd-find`, and the command may be `fdfind`. If needed, make a `fd` shim:

```zsh
mkdir -p "$HOME/.local/bin"
ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
```

## 4. Set up environment variables

Only the variables the user needs belong here, and they go **inside a LOCAL block in `~/.zshrc`** (machine-local, never committed):

| Variable           | Needed for   | Purpose                   |
| ------------------ | ------------ | ------------------------- |
| `CONTEXT7_API_KEY` | Context7 MCP | Context7 API access       |
| `EXA_API_KEY`      | Exa MCP      | Exa web search API access |

See [agents.md](agents.md) for the full agent-side setup.

## 5. Verify

```zsh
exec zsh -l
```

The shell should start with no errors. Confirm the tracked files are present and the work-tree is clean:

```zsh
dgit status --short
command -v zoxide >/dev/null && echo "zoxide ok"
```

## 6. Install Agent Skills (optional)

The dotfile repo bundles the skills under `~/.agents/skills/` as part of the checkout. Additional global skills can be installed with:

```zsh
pnpm dlx skills add <package> -g
pnpm dlx skills update -g
```

See [agents.md](agents.md) for the skill list and tooling.
