# Conventions

> **Scope:** this reference is for the **production / machine path** (operating an installed machine's `$HOME` config via bare repo `$HOME/.cfg` and `dgit`). This is _not_ the dotfiles source repo; editing the source repo (a normal clone) is plain `git` with no marker files present.

The rules that keep the repo clean and each machine's local config safe. Everything here follows from one fact: **the work-tree of the bare repo is the user's real `$HOME`, so every git operation affects their actual files.** Read this before touching anything.

## The dgit alias

```zsh
alias dgit='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
```

`dgit` is `git` pointed at the bare repo (`$HOME/.cfg`) with a work-tree of `$HOME`. Every bare-repo operation goes through it. Never run plain `git` in `$HOME` against this repo — it would either operate on the wrong repo or, worse, treat the user's home as a repo.

The alias is defined in `~/.config/zsh/rc.d/10-main.zsh`, so it is available in an interactive shell. In a non-interactive context (scripts, agents), re-declare it or use the full `git --git-dir=... --work-tree=...` form.

## Which files are tracked

The repo only ever holds **explicitly added** files — never `dgit add -u`, `.`, or `-a`. To see what's tracked, run `dgit ls-files`; the machine-local vs managed split is the LOCAL-block rule below. Since the bare repo's work-tree is `$HOME`, everything under `$HOME` is either a tracked file or an untracked machine file.

## LOCAL blocks

The repo owns whole tracked files. Machine-local content *inside* a tracked file is wrapped in a **LOCAL block** using the file's comment character. The repo ships these blocks **empty** (just the markers); each machine fills them in.

| File | Comment char | LOCAL block |
|------|--------------|-------------|
| `.zshrc`, `.zshenv`, `.zprofile`, `.config/shell/main.zsh`, `.codex/config.toml` | `#` | `# ===== LOCAL =====` … `# ===== END LOCAL =====` |
| `.config/opencode/opencode.jsonc` | `//` | `// ===== LOCAL =====` … `// ===== END LOCAL =====` |

The repo ships these files **without** LOCAL blocks. If a machine needs local content in one, it adds a block there — don't pre-add empty blocks just for show.

Two rules govern them:

- **On pull / rebase: preserve your LOCAL block.** It's machine-local ("ours"). Shared lines take the remote version; the block stays put.
- **On push: never push LOCAL-block content.** Strip the blocks before committing/pushing shared changes so machine-specific settings and secrets stay off the shared repo.

**Conflict resolution** — when a pull or rebase conflicts on a tracked file:

| Where | Owner | Strategy |
|-------|-------|----------|
| Inside a LOCAL block | local | preserve local (ours), never push |
| Everywhere else in the file | remote | remote takes precedence (theirs) |
| `.zprofile`, `.ssh/config`, `.npmrc`, `.gitconfig`, `.pi/agent/settings.json`, secrets | local | never in repo |
| `.agents/.skill-lock.json` | remote + local | merge — local installs coexist with repo entries |

Pi's tracked files are its shared resources only (`~/.pi/agent/AGENTS.md` — a relative symlink to `.codex/AGENTS.md` — plus `~/.pi/agent/prompts/` and the shared permission policy). Its `settings.json` is machine-owned — it is strict JSON and can't hold a LOCAL block, so it belongs with the other never-in-repo files.

> Don't confuse the two "LOCAL" things: a **LOCAL block** is a marker inside a tracked file (machine content). The **LOCAL commit** below is a git topology convention (machine `main` stays one ahead). They're related but separate.

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
