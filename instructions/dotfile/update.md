# Dotfile Maintenance

## dgit alias

All operations go through the bare-repo alias:

```zsh
alias dgit='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
```

## Initial Setup

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

## Making Changes

Only add explicit files. Do not use `dgit add -u`:

```zsh
dgit add ~/.zshrc
dgit add ~/.config/zsh/zshrc
dgit add ~/.config/git/config
dgit add ~/.config/ghostty/config.ghostty
dgit add ~/.config/starship.toml
dgit add ~/.vimrc
dgit add ~/.tmux.conf
dgit add ~/README.md
dgit commit -m "Describe the change"
dgit push origin main
```

Inspect before pushing — never commit sensitive files:

```zsh
dgit status --short --untracked-files=all
dgit diff --cached
dgit diff --cached --name-only
```

Do not commit: private keys, tokens, credentials, `.proxyenv`, `.zprofile`, `.gitconfig`, local additions below the `LOCAL CONFIG BELOW` separator in `.zshrc`.

## Updating an Existing Machine

```zsh
alias dgit='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
dgit pull origin main
```

If there are local changes, stash first:

```zsh
dgit stash push -m "local changes"
dgit pull origin main
dgit stash pop
```

Or rebase for cleaner history:

```zsh
dgit pull --rebase origin main
```

After pulling, install any missing tools for that platform. On Ubuntu the apt
`fzf` package may be older and not support `fzf --zsh`; `.zshrc` falls back to
the package's example scripts.

If the machine still has old oh-my-zsh files, remove them:

```zsh
rm -rf ~/.oh-my-zsh ~/.cache/oh-my-zsh ~/.zcompdump*
```

The tracked `~/.vimrc` is the Vim entrypoint; no symlink required.

After pulling, check whether the update includes a breaking change. If
`dgit log -1 --format=%s` matches a hash in
[instructions/dotfile/migrate.md](migrate.md), follow that section's
migration plan before reloading the shell.
