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

## LOCAL REPLACE and inline markers

A `===== LOCAL =====` block **appends/preserves** content the repo doesn't already ship (PATH, aliases, a new tool). Some config instead needs to **change or drop a value the repo ships** — e.g. `model` in `.codex/config.toml`, `model`/`small_model`/`lsp` in `opencode.jsonc`, or removing `[features.network_proxy]`. Appending an empty block can't express that. Use a **LOCAL REPLACE** marker, in place, wrapping the repo's key:

```toml
# .codex/config.toml (# comment char)
model = "gpt-5.6-luna"
# LOCAL REPLACE: model
# shared: gpt-5.6-luna
model = "gpt-5.6-luna-local"        # machine override
# END LOCAL REPLACE
```

```jsonc
// .config/opencode/opencode.jsonc (// comment char)
// LOCAL REPLACE: model
// shared: opencode-go/deepseek-v4-flash
"model": "deepseek-v4-flash",
// END LOCAL REPLACE
```

Rules:
- `LOCAL REPLACE: <key>` … `END LOCAL REPLACE`: the value(s) between replace what the repo ships for `<key>`. An empty body **deletes** the key.
- Keep a `shared: <original value>` comment (the file's comment char) under the open marker, so a rebase/merge can reconcile against what the repo originally had.
- Use the **file's comment char** (`#` for zsh/toml, `//` for jsonc). A `#` in JSONC would break the file.
- **`LOCAL block` = append/preserve; `LOCAL REPLACE` = replace/delete.** Both are stripped before a push (see maintain.md).

A marker does not have to sit at the end of the file — it can be **interleaved inline** with shared content. That's the only way to touch a value inside a shared TOML table: a `[table]` header can't be reopened once closed, so an override under `[features.network_proxy]` or `[permissions.dev.filesystem]` goes in a small inline `LOCAL REPLACE:` inside that table, not in a footer block.

JSONC note: it allows a trailing comma and `//` is valid inside a string, so a naive `json.load` or a hand-cut edit can leave a dangling comma or a missing `}`. Validate with a JSONC-aware parser (`allowTrailingComma: true`) before committing.

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

## Backups

Name each backup source with a **unique, independent** filename — never reuse one target for two sources, or a second `cp` silently overwrites the first (and can destroy machine secrets). Name by source (`<file>.entrypoint`, `<file>.login`, `<file>.shell`) and give each migration its own `/tmp/dotfile-migrate` dir.

## Review before committing

Always look before you commit:

```zsh
dgit status --short
dgit diff --cached
dgit diff --cached --name-only
```

Never pass `--untracked-files=all` across `$HOME` — the work-tree is the whole home, so it scans tens of thousands of machine files. `status.showUntrackedFiles no` already keeps them out, so plain `--short` is enough.

Ask yourself: does the staged diff contain only managed content? Any local block, secret, or machine path is a blocker.
