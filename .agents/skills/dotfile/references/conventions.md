# Conventions

> **Scope:** this reference is for the **production / machine path** (operating an installed machine's `$HOME` config via bare repo `$HOME/.cfg` and `dgit`). This is *not* the dotfiles source repo; editing the source repo (a normal clone) is plain `git` with no marker files present.

The rules that keep the repo clean and each machine's local config safe. Everything here follows from one fact: **the work-tree of the bare repo is the user's real `$HOME`, so every git operation affects their actual files.** Read this before touching anything.

## The dgit alias

```zsh
alias dgit='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
```

`dgit` is `git` pointed at the bare repo (`$HOME/.cfg`) with a work-tree of `$HOME`. Every bare-repo operation goes through it. Never run plain `git` in `$HOME` against this repo — it would either operate on the wrong repo or, worse, treat the user's home as a repo.

The alias is defined in `~/.config/zsh/zshrc`, so it is available in an interactive shell. In a non-interactive context (scripts, agents), re-declare it or use the full `git --git-dir=... --work-tree=...` form.

## Which files are tracked

Only explicitly added files ever become part of the repo. This is enforced by habit, not by an ignore rule — the repo's `.gitignore` only ignores `.cfg` itself.

**Tracked** (managed by dgit):

```
~/.zshrc                          # only the part inside the remote marker block
~/.config/zsh/zshrc
~/.config/git/config
~/.config/ghostty/config.ghostty
~/.config/starship.toml
~/.vimrc
~/.tmux.conf
~/.codex/AGENTS.md
~/.codex/config.toml              # only content above the local-only marker
~/.codex/agents/reviewer.toml
~/.codex/agents/waiter.toml
~/.codex/rules/development.rules
~/.agents/.skill-lock.json
~/.config/opencode/opencode.jsonc # only content above the local config marker
~/.config/opencode/AGENTS.md
~/.config/opencode/tui.json
~/README.md
~/README.zh.md
```

**Untracked, machine-local** (never commit):

```
~/.zprofile                        # brew shellenv, login init
~/.ssh/config                      # machine-specific SSH hosts/proxy
~/.npmrc                           # npm registry, auth tokens
~/.gitconfig                       # personal git identity
~/.zshrc content below the remote end marker
~/.codex/config.toml content below the local-only marker
~/.config/opencode/opencode.jsonc content below the local config marker
*.pem, *.key, .proxyenv            # secrets — never enter the repo
```

## Marker files

Three files carry both managed and local content. The **marker** draws the line. Above it is repo-managed; below it is machine-local.

| File | Marker (top = managed, bottom = local) |
|------|-----------------------------------------|
| `.zshrc` | `# =========remote config============` … `# =========remote end==============` |
| `.codex/config.toml` | `# ---- Local-only additions below ----` |
| `.config/opencode/opencode.jsonc` | `// ======= local config ===` … `// ======= local config end ===` |

**Conflict resolution** — when a pull or rebase conflicts on a tracked file, decide who owns the line:

| File / section | Owner | Strategy |
|----------------|-------|----------|
| `.zshrc` — inside the remote marker block | remote | remote takes precedence (theirs) |
| `.zshrc` — below the remote end marker | local | preserve local (ours), never commit |
| `.codex/config.toml` — above the local-only marker | remote | remote takes precedence (theirs) |
| `.codex/config.toml` — below the marker | local | preserve local (ours), never commit |
| `.config/opencode/opencode.jsonc` — above the local config marker | remote | remote takes precedence (theirs) |
| `.config/opencode/opencode.jsonc` — below the marker | local | preserve local (ours), never commit |
| `.zprofile`, `.ssh/config`, `.npmrc`, `.gitconfig` | local | never in repo |
| `.agents/.skill-lock.json` | remote + local | merge — local installs coexist with repo entries |

## The LOCAL commit convention

Every machine keeps its local `main` exactly **one commit ahead** of `origin/main`. That single commit contains all machine-local additions and is titled:

```
LOCAL: <summary of all local configs> [never push]
```

This lets a machine `fetch` + `rebase` onto new remote work without ever committing its local content. The LOCAL commit is never pushed.

To replay the local commit after fetching new remote work:

```zsh
dgit fetch origin

# If exactly 1 commit ahead, fast-forward the LOCAL commit onto origin/main:
dgit rebase origin/main

# If diverged or the rebase conflicts:
dgit reset --soft origin/main     # discard the old LOCAL commit, keep changes staged
dgit commit --amend -m "LOCAL: <summary> [never push]"
```

Verify the topology:

```zsh
dgit log --oneline --graph -3
# should show:   LOCAL: ... [never push]  →  (origin/main) ...
```

Never push the LOCAL commit. To confirm you're not about to, check `dgit status --short` is clean of tracked changes and that only `LOCAL:` is ahead.

## Review before committing

Always look before you commit:

```zsh
dgit status --short --untracked-files=all
dgit diff --cached
dgit diff --cached --name-only
```

Ask yourself: does the staged diff contain only managed content? Any local block, secret, or machine path is a blocker.
