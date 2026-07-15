# Dotfiles

These dotfiles are managed with a bare Git repository stored at `$HOME/.cfg`.
Tracked configuration is intended to work on both macOS and Linux.

## Quick Links

- [Tools](#tools)
- [Install](#install)
- [Shell Layout](#shell-layout)
- [Shell Behavior](#shell-behavior)
- [Tool Configs](#tool-configs)
- [Local-Only Files](#local-only-files)
- [Maintenance](instructions/dotfile/update.md)

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

The committed `~/.zshrc` is intentionally thin. Stable shared shell behavior
lives in `~/.config/zsh/zshrc`. Machine-local additions go below the
`LOCAL CONFIG BELOW` separator in `~/.zshrc` and must not be committed.
All optional tool initialization in the shared zsh config is guarded with
`command -v` or file checks, so a fresh machine can load the shell before every
tool is installed.

## Install

### macOS

```zsh
brew install starship zoxide fzf zsh-autosuggestions zsh-syntax-highlighting tmux git-delta ripgrep fd jq
```

### Debian / Ubuntu

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

### Fedora

```zsh
sudo dnf install zsh starship zoxide fzf tmux zsh-autosuggestions zsh-syntax-highlighting git-delta vim ripgrep fd-find jq
```

### Arch Linux

```zsh
sudo pacman -S zsh starship zoxide fzf tmux zsh-autosuggestions zsh-syntax-highlighting git-delta vim ripgrep fd jq
```

### Linuxbrew

If you use Linuxbrew on Linux, the same Homebrew command works:

```zsh
brew install starship zoxide fzf zsh-autosuggestions zsh-syntax-highlighting tmux git-delta ripgrep fd jq
```

### Notes

- `starship`, `zoxide`, and `git-delta` may need manual installation via their
  official releases if not in your distro's repos.
- Debian / Ubuntu packages `fd` as `fd-find` — see workaround above.
- `jq` is pre-installed on macOS; install via Homebrew for the latest version.

## Shell Layout

Shell files are split by responsibility:

```
~/.zprofile
  Login shell setup such as Homebrew/Linuxbrew shellenv. Local-only, not tracked.

~/.zshrc
  Thin interactive entrypoint. Lines above the `LOCAL CONFIG BELOW` separator
  are repo-managed; lines below are machine-local and must not be committed.

~/.config/zsh/zshrc
  Tracked cross-platform interactive shell config: dgit, history search, fzf,
  zoxide, starship, history, completion, autosuggestions, and syntax highlighting.
```

The shared config in `~/.config/zsh/zshrc` is where all portable tool
initialization lives. Machine-local setup such as proxies or tool paths
goes into `~/.zshrc` below the `LOCAL CONFIG BELOW` separator.

## Shell Behavior

The shared zsh config keeps startup portable by checking whether optional tools
or plugin files exist before loading them.

- **History**: persisted in `~/.zsh_history` with a larger limit, incremental
  append, shared history across terminals, duplicate reduction, and leading
  space exclusion.
- **Completion**: initialized with `compinit`, menu selection, case-insensitive
  matching, and grouped completion output.
- **Prefix search**: type a prefix such as `ls`, then press Up or Down to search
  only matching history entries.
- **Autosuggestions**: `zsh-autosuggestions` shows gray inline suggestions from
  history.
- **Syntax highlighting**: `zsh-syntax-highlighting` highlights commands as you
  type.
- **Directory jumping**: `zoxide` provides `z` and `zi`.
- **Fuzzy search**: `fzf` integrations in real terminal sessions. New fzf uses
  `fzf --zsh`; older Ubuntu packages fall back to bundled example scripts.

## Tool Configs

### Git

Shared Git behavior lives in:

```
~/.config/git/config
```

Personal identity stays local in `~/.gitconfig` and is not committed. The shared
config uses `git-delta` as the pager for readable `git diff` and `git show`
output. Install `git-delta` before using this config on a new machine.

### Vim

Tracked Vim config lives in:

```
~/.vimrc
```

Intentionally lightweight: no plugin manager, cross-platform clipboard defaults,
line numbers, persistent undo, sane search behavior, and basic filetype
indentation.

### Starship

Starship uses the tracked config at:

```
~/.config/starship.toml
```

Keeps Starship close to its defaults and does not add a local/remote host
indicator.

### tmux

The tracked tmux config is:

```
~/.tmux.conf
```

It keeps the default prefix `C-b`, enables mouse support, uses 1-based
window/pane numbering, keeps a larger scrollback, enables extended keys for
modified key combinations such as Shift+Enter, preserves the current directory
when splitting panes, and supports OSC 52 clipboard copy through SSH/Ghostty:

```
C-b r  reload ~/.tmux.conf
C-b |  split horizontally
C-b -  split vertically
C-b [  enter copy mode, then v selects and y copies to clipboard
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

### Ghostty

Linux reads the tracked config directly from:

```
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

## Local-Only Files

These files are intentionally **not tracked**. Use them for machine-specific
configuration that should never enter the dotfiles repo.

### `~/.zprofile`

Login-shell or machine-specific setup such as Homebrew:

```zsh
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
```

### `~/.ssh/config`

Machine-local SSH host aliases, proxy settings, and identity files.
Kept on disk; no longer tracked in the dotfiles repo.

### `~/.npmrc`

npm-specific configuration such as registry URLs, cache location, `save-exact`,
strict SSL behavior, and package-manager authentication tokens. Do not put
general shell exports or aliases here.

### Keeping secrets out

Credentials should never enter tracked files. If a token must exist locally,
prefer the tool's own private config file (e.g. `~/.npmrc`). Always review
staged changes before committing:

```zsh
dgit diff --cached --name-only
```

## Maintenance

See [instructions/dotfile/update.md](instructions/dotfile/update.md) for the
dgit workflow, making changes, and updating existing machines.

For breaking changes that need manual migration steps on existing machines,
see [instructions/dotfile/migrate.md](instructions/dotfile/migrate.md).
