# Dotfiles

These dotfiles are managed with a bare Git repository stored at `$HOME/.cfg`.
Tracked configuration is intended to work on both macOS and Linux.

## Tools

The interactive shell setup uses:

- `zsh` as the shell
- `starship` for the prompt
- `zoxide` for directory jumping
- `fzf` for fuzzy search and shell key bindings
- Ghostty with a shared XDG config at `~/.config/ghostty/config.ghostty`

All optional tool initialization in `.zshrc` is guarded with `command -v` or
file checks, so a fresh machine can load the shell before every tool is
installed.

## Install Tools

macOS with Homebrew:

```zsh
brew install starship zoxide fzf
```

Debian or Ubuntu:

```zsh
sudo apt update
sudo apt install zsh fzf
```

Install `starship` and `zoxide` from your package manager if available, or use
their official installers. If you use Linuxbrew, the same Homebrew command works:

```zsh
brew install starship zoxide fzf
```

Fedora:

```zsh
sudo dnf install zsh starship zoxide fzf
```

Arch Linux:

```zsh
sudo pacman -S zsh starship zoxide fzf
```

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
dgit add ~/.zshenv
dgit add ~/.config/ghostty/config.ghostty
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
`.zprofile`, `.zshalias`, or machine-specific SSH host metadata unless you have
reviewed it intentionally.

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
