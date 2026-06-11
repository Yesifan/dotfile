# Dotfiles

These dotfiles are managed with a bare Git repository stored at `$HOME/.cfg`.
Tracked configuration is intended to work on both macOS and Linux.

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
- Vim with tracked config at `~/.vimrc`
- Ghostty with a shared XDG config at `~/.config/ghostty/config.ghostty`

The committed `~/.zshrc` is intentionally thin. Stable shared shell behavior
lives in `~/.config/zsh/zshrc`, while machine-local tool installer blocks can
remain in `~/.zshrc` without becoming part of the shared configuration. All
optional tool initialization in the shared zsh config is guarded with
`command -v` or file checks, so a fresh machine can load the shell before every
tool is installed.

## Install Tools

macOS with Homebrew:

```zsh
brew install starship zoxide fzf zsh-autosuggestions zsh-syntax-highlighting tmux git-delta
```

Debian or Ubuntu:

```zsh
sudo apt update
sudo apt install zsh fzf tmux zsh-autosuggestions zsh-syntax-highlighting git-delta vim
```

Install `starship`, `zoxide`, and `git-delta` from your package manager if
available, or use their official release packages. If you use Linuxbrew, the
same Homebrew command works:

```zsh
brew install starship zoxide fzf zsh-autosuggestions zsh-syntax-highlighting tmux git-delta
```

Fedora:

```zsh
sudo dnf install zsh starship zoxide fzf tmux zsh-autosuggestions zsh-syntax-highlighting git-delta vim
```

Arch Linux:

```zsh
sudo pacman -S zsh starship zoxide fzf tmux zsh-autosuggestions zsh-syntax-highlighting git-delta vim
```

## Shell Layout

Shell files are split by responsibility:

```text
~/.zprofile
  Login shell setup such as Homebrew/Linuxbrew shellenv. Local-only, not tracked.

~/.zshrc
  Thin interactive entrypoint. It sources the tracked shared config and optional
  local config. Tool installers may append machine-local blocks here.

~/.config/zsh/zshrc
  Tracked cross-platform interactive shell config: dgit, history search, fzf,
  zoxide, starship, history, completion, autosuggestions, and syntax highlighting.

~/.config/zsh/zshrc.local
  Optional local-only config for private paths, host aliases, proxies, and
  machine-specific tool setup. Not tracked.

~/.config/zsh/zshrc.local.example
  Tracked example for the local-only interactive config.

~/.zshalias
  Legacy local-only alias file. Still sourced if present, not tracked.
```

This keeps the dotfiles stable even when installers such as `nvm`, `uv`,
`cargo`, `bun`, or language managers append setup snippets to `~/.zshrc`.
When a setup block is useful everywhere, move a guarded version into
`~/.config/zsh/zshrc`; otherwise leave it in local config.

## Shell Behavior

The shared zsh config keeps startup portable by checking whether optional tools
or plugin files exist before loading them.

- History is persisted in `~/.zsh_history` with a larger limit, incremental
  append, shared history across terminals, duplicate reduction, and leading
  space exclusion.
- The zsh completion system is initialized with `compinit`, menu selection,
  case-insensitive matching, and grouped completion output.
- Type a prefix such as `ls`, then press Up or Down to search only matching
  history entries.
- `zsh-autosuggestions` shows gray inline suggestions from history.
- `zsh-syntax-highlighting` highlights commands as you type.
- `zoxide` provides `z` and `zi` for directory jumping.
- `fzf` provides fuzzy search integrations in real terminal sessions. New fzf
  uses `fzf --zsh`; older Ubuntu packages fall back to bundled example scripts.

## Git

Shared Git behavior lives in:

```text
~/.config/git/config
```

Personal identity stays local in `~/.gitconfig` and is not committed. The shared
config uses `git-delta` as the pager for readable `git diff` and `git show`
output. Install `git-delta` before using this config on a new machine.

## Vim

Tracked Vim config lives in:

```text
~/.vimrc
```

The Vim config is intentionally lightweight: no plugin manager, cross-platform
clipboard defaults, line numbers, persistent undo, sane search behavior, and
basic filetype indentation.

## Starship

Starship uses the tracked config at:

```text
~/.config/starship.toml
```

The config keeps Starship close to its defaults and does not add a local/remote host indicator.

## tmux

The tracked tmux config is:

```text
~/.tmux.conf
```

It keeps the default prefix `C-b`, enables mouse support, uses 1-based
window/pane numbering, keeps a larger scrollback, and supports OSC 52 clipboard
copy through SSH/Ghostty:

```text
C-b r  reload ~/.tmux.conf
C-b |  split horizontally
C-b -  split vertically
C-b [  enter copy mode, then y copies selection to clipboard
```

After updating a server, reload tmux:

```zsh
tmux source-file ~/.tmux.conf
```

If clipboard copy works over SSH outside tmux but fails inside tmux, verify OSC
52 forwarding inside tmux:

```zsh
printf '\e]52;c;%s\a' "$(printf 'tmux-copy-test' | base64 | tr -d '\n')"
```

Then paste locally and confirm the clipboard contains `tmux-copy-test`.

## Local-Only Files

`~/.zprofile` is intentionally not tracked. Use it for login-shell or
machine-specific setup such as Homebrew:

```zsh
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
```

`~/.config/zsh/zshrc.local` is intentionally not tracked. Prefer it for
machine-local setup that should run in interactive shells:

```zsh
cp ~/.config/zsh/zshrc.local.example ~/.config/zsh/zshrc.local
[[ -x /Applications/Tailscale.app/Contents/MacOS/Tailscale ]] && alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
```

Use `~/.npmrc` for npm-specific configuration such as registry URLs, npm cache
location, `save-exact`, strict SSL behavior, and package-manager authentication
tokens. Do not put general shell exports or aliases there.

Use `~/.config/zsh/zshrc.local` for interactive shell behavior: aliases,
machine-specific `PATH` entries, proxy exports, local app paths, host shortcuts,
or guarded initialization for tools that are not shared across every machine,
such as `nvm`, `pnpm`, `uv`, `pyenv`, `cargo`, or app-specific CLIs. Keep
credentials out of tracked files; if a token must exist locally, prefer the
tool's own private config file such as `~/.npmrc`.

`~/.zshalias` is intentionally not tracked. Use it for machine-local aliases,
private paths, proxy helpers, host shortcuts, and app-specific commands:

```zsh
[[ -x /Applications/Tailscale.app/Contents/MacOS/Tailscale ]] && alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
```

## Bare Repo Workflow

Create or use the helper alias:

```zsh
alias dgit='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
```

Start from scratch:

```zsh
git init --bare "$HOME/.cfg"
dgit config --local status.showUntrackedFiles no
```

Install on a new machine:

```zsh
echo ".cfg" >> "$HOME/.gitignore"
git clone --bare git@github.com:Yesifan/dotfile.git "$HOME/.cfg"
alias dgit='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
dgit checkout -f
dgit config --local status.showUntrackedFiles no
```

Only add explicit files when committing. Do not use `dgit add -u`:

```zsh
dgit add ~/.zshrc
dgit add ~/.config/zsh/zshrc
dgit add ~/.config/zsh/zshrc.local.example
dgit add ~/.config/git/config
dgit add ~/.config/ghostty/config.ghostty
dgit add ~/.config/starship.toml
dgit add ~/.vimrc
dgit add ~/.tmux.conf
dgit add ~/README.md
dgit commit -m "Update dotfiles"
dgit push origin main
```

Before pushing, inspect staged changes and make sure local-only or sensitive
files are not included:

```zsh
dgit status --short --untracked-files=all
dgit diff --cached
dgit diff --cached --name-only
```

Do not commit private keys, tokens, cookies, credentials, `.proxyenv`,
`.zprofile`, `.zshalias`, `.config/zsh/zshrc.local`, `.gitconfig`, or
machine-specific SSH host metadata unless you have reviewed it intentionally.

## 更新引导

On a server that already has an older checkout of these dotfiles:

```zsh
alias dgit='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
dgit status
dgit pull origin main
```

If the server has local changes, inspect and stash them before pulling:

```zsh
dgit diff
dgit stash push -m "local server changes"
dgit pull origin main
dgit stash pop
# or use rebase
dgit pull --rebase origin main
# 它会把你的本地提交“挪到”远程最新提交后面，历史更干净：
# A---B'---C''
```

After updating, install any missing tools for that platform. On Ubuntu, the apt
`fzf` package may be older and not support `fzf --zsh`; `.zshrc` falls back to
the package's example scripts when available.

If the server still has old oh-my-zsh files and the current `.zshrc` no longer
references them, remove them:

```zsh
rm -rf ~/.oh-my-zsh ~/.cache/oh-my-zsh ~/.zcompdump*
```

The tracked `~/.vimrc` is the Vim entrypoint; no symlink is required.


## Ghostty

Linux reads the tracked config directly from:

```text
~/.config/ghostty/config.ghostty
```

On macOS, keep the tracked file in the same XDG location and symlink Ghostty's
Application Support config to it:

```zsh
mkdir -p "$HOME/.config/ghostty"
mkdir -p "$HOME/Library/Application Support/com.mitchellh.ghostty"
ln -s "$HOME/.config/ghostty/config.ghostty" "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"
```

The macOS symlink itself is local-only and is not committed.
