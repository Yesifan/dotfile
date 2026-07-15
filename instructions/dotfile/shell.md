# Shell Configuration

## File Layout

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

## Behavior

The shared zsh config checks whether optional tools exist before loading them.

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
