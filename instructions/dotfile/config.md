# Tool Configurations

## Git

Shared Git behavior lives in:

```
~/.config/git/config
```

Personal identity stays local in `~/.gitconfig` and is not committed. The shared
config uses `git-delta` as the pager for readable `git diff` and `git show`
output.

## Vim

```
~/.vimrc
```

Intentionally lightweight: no plugin manager, cross-platform clipboard defaults,
line numbers, persistent undo, sane search behavior, and basic filetype
indentation.

## Starship

```
~/.config/starship.toml
```

Keeps Starship close to its defaults and does not add a local/remote host
indicator.

## tmux

```
~/.tmux.conf
```

Keeps the default prefix `C-b`, enables mouse support, uses 1-based
window/pane numbering, keeps a larger scrollback, enables extended keys, and
preserves the current directory when splitting panes:

```
C-b r  reload ~/.tmux.conf
C-b |  split horizontally
C-b -  split vertically
C-b [  enter copy mode, then v selects and y copies to clipboard
```

Reload after changes:

```zsh
tmux source-file ~/.tmux.conf
```

## Ghostty

Linux reads the tracked config directly from:

```
~/.config/ghostty/config.ghostty
```

On macOS, symlink from Application Support:

```zsh
mkdir -p "$HOME/.config/ghostty"
mkdir -p "$HOME/Library/Application Support/com.mitchellh.ghostty"
ln -s "$HOME/.config/ghostty/config.ghostty" "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"
```

The macOS symlink itself is local-only and is not committed.
