# Environment reference

What each config file sets up, so you understand the system before editing it. These are cross-platform (macOS + Linux) and every optional tool feature is guarded by `command -v`, so a fresh machine loads the shell before tools exist.

## Shell layout

Shell files are split by responsibility:

- `~/.zprofile` — login shell setup such as Homebrew/Linuxbrew shellenv. Machine-local, not tracked.
- `~/.zshrc` — thin interactive entrypoint. Lines above the remote marker are repo-managed; lines below are machine-local and must not be committed.
- `~/.config/zsh/zshrc` — tracked cross-platform interactive config: `dgit` alias, history search, fzf, zoxide, starship, completion, autosuggestions, syntax highlighting.

## Shared shell behavior

- **History** — persisted in `~/.zsh_history` with a larger limit, incremental append, shared across terminals, duplicate reduction, leading-space exclusion.
- **Completion** — `compinit`, menu selection, case-insensitive matching, grouped output.
- **Prefix search** — type a prefix such as `ls`, then Up/Down to search only matching history entries.
- **Autosuggestions** — gray inline suggestions from history.
- **Syntax highlighting** — realtime highlighting of typed commands.
- **Directory jumping** — `zoxide` (`z`, `zi`).
- **Fuzzy search** — `fzf` integrations. New fzf uses `fzf --zsh`; older Ubuntu packages fall back to bundled example scripts.

## Tool configurations

### Git

Shared Git behavior lives in `~/.config/git/config`: `git-delta` as the pager for readable `git diff` / `git show`. Personal identity stays local in `~/.gitconfig` and is not committed.

### Vim

`~/.vimrc` — intentionally lightweight: no plugin manager, cross-platform clipboard defaults, line numbers, persistent undo, sane search, basic filetype indentation. It is the Vim entrypoint; no symlink required.

### Starship

`~/.config/starship.toml` — kept close to defaults; no local/remote host indicator.

### tmux

`~/.tmux.conf` — default prefix `C-b`, mouse support, 1-based window/pane numbering, larger scrollback, extended keys, preserves current directory when splitting panes:

```
C-b r  reload ~/.tmux.conf
C-b |  split horizontally
C-b -  split vertically
C-b [  enter copy mode, then v selects and y copies to clipboard
```

Reload after changes: `tmux source-file ~/.tmux.conf`.

### Ghostty

- Linux reads the tracked config directly from `~/.config/ghostty/config.ghostty`.
- On macOS, symlink it from Application Support (the symlink itself is machine-local, not committed):

  ```zsh
  mkdir -p "$HOME/.config/ghostty"
  mkdir -p "$HOME/Library/Application Support/com.mitchellh.ghostty"
  ln -s "$HOME/.config/ghostty/config.ghostty" "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"
  ```
