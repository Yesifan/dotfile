# Update an existing machine

> **Scope:** this reference is for the **production / machine path** (`dgit`, bare repo at `$HOME/.cfg`, work-tree `$HOME`). If you are in the dotfiles **source repo** (a normal clone), update with plain `git pull --rebase origin main` instead.

Bring a machine already running these dotfiles up to date. Before you start, sync this skill to the latest so you have the most current update/migration steps: `npx skills use YeSifan/dotfile@dotfile`.

The path depends on whether the machine has a LOCAL commit, whether the work-tree is dirty, and whether the incoming change is breaking.

## First: inspect the state

```zsh
dgit status --short                 # any tracked file modified?
dgit log --oneline --graph -5
dgit log -1 --format=%s             # what is at HEAD, and is it a breaking commit?
```

The last command matters: if HEAD matches a hash listed in [migrations/readme.md](migrations/readme.md), follow that plan before reloading the shell.

Then pick the path:

| Machine state | Path |
|---------------|------|
| Clean main, nothing modified, not ahead | Case A — `dgit pull --rebase origin main` |
| Only a `LOCAL:` commit ahead | Case B — `dgit rebase origin/main` |
| `LOCAL:` commit **plus dirty tracked files**, or a breaking commit rewrote the local section | Case C — back up, reset to `origin/main`, rewrap, new `LOCAL:` commit |

## Case A — clean main, no local commit

The machine has no local changes (nothing modified, and `main` is not ahead). Fast-forward update:

```zsh
dgit pull --rebase origin main
```

After pulling:

- Install any tools new to this platform (see [install.md](install.md)).
- On Ubuntu the apt `fzf` may be too old for `fzf --zsh`; `.zshrc` falls back to the package's example scripts, so no action is needed.
- If old oh-my-zsh files linger, remove them:

  ```zsh
  rm -rf ~/.oh-my-zsh ~/.cache/oh-my-zsh ~/.zcompdump*
  ```

- The tracked `~/.vimrc` is the Vim entrypoint; no symlink is required.
- If the update is breaking, run the migration plan from [migrations/readme.md](migrations/readme.md) first.
- Reload and verify: `exec zsh -l`, then `dgit status --short` should be clean.

## Case B — machine has a LOCAL commit

`main` is one ahead of `origin/main` and the tip is `LOCAL: ... [never push]`. Replay it onto the new remote:

```zsh
dgit fetch origin
dgit rebase origin/main
```

If the rebase succeeds, the LOCAL commit moves on top of the new `origin/main`. If it fails or you want a clean slate:

```zsh
dgit reset --soft origin/main        # discard old LOCAL commit, keep changes staged
<resolve any working-tree conflicts>
dgit commit --amend -m "LOCAL: <summary> [never push]"
```

Always re-verify the invariant:

```zsh
dgit log --oneline --graph -3        # local exactly 1 ahead of origin/main
```

## Case C — dirty work-tree, or a breaking commit rewrote your local content

When the machine has **uncommitted tracked changes** (often a machine-local edit to a tracked file) plus a LOCAL commit, `dgit rebase origin/main` fails because the work-tree is dirty. And if the incoming commit **rewrites or removes** the exact section your machine-local content sits in (e.g. the old `REMOTE CONFIG` split), a rebase can't carry it — the local edits get stranded. Don't fight the rebase; reset-and-rewrap:

1. **Inventory** what diverges from origin, and label each file **shared** (belongs in the repo) or **machine-local** (goes in a LOCAL block / LOCAL REPLACE):

   ```zsh
   dgit log --oneline origin/main..main        # your LOCAL commit(s)
   dgit diff --name-only origin/main           # tracked files diverging from origin
   dgit status --short                         # uncommitted tracked changes
   ```

2. **Back up** the full machine-local content (unique filenames — conventions → Backups):

   ```zsh
   mkdir -p /tmp/dotfile-migrate
   cp ~/.zshrc                  /tmp/dotfile-migrate/zshrc.entrypoint
   cp ~/.zprofile               /tmp/dotfile-migrate/zprofile.login
   cp ~/.config/shell/main.zsh  /tmp/dotfile-migrate/shell.main
   cp ~/.codex/config.toml      /tmp/dotfile-migrate/codex.config
   cp ~/.config/opencode/opencode.jsonc /tmp/dotfile-migrate/opencode.jsonc
   ```

3. **Rebuild to the new origin** (this discards the old LOCAL commit and the machine-local edits — they're safely in `/tmp`):

   ```zsh
   dgit fetch origin
   dgit reset --hard origin/main
   ```

4. **Rewrap** the local content from the backup into the new files — a `===== LOCAL =====` block for additions, an inline `LOCAL REPLACE:` for keys you must override (conventions → LOCAL REPLACE).

5. **Commit one LOCAL commit** and re-check the invariant:

   ```zsh
   dgit add <tracked files you touched>
   dgit commit -m "LOCAL: <summary> [never push]"
   dgit log --oneline --graph -3        # exactly 1 ahead of origin/main
   ```

## If the pull/rebase conflicts on a tracked file

Decide who owns each conflicting region (see [conventions.md](conventions.md) — remote for shared lines, preserve anything inside a LOCAL block). Resolve it, then:

```zsh
dgit add ~/.zshrc                   # or whichever file conflicted
dgit rebase --continue
```

If conflicts recur or you want a clean reset, abort and redo cleanly:

```zsh
dgit rebase --abort
dgit fetch origin
dgit reset --hard origin/main
# then re-apply any machine-local content from a backup, inside the LOCAL block.
```

## After the update

- `exec zsh -l` loads without errors.
- `dgit status --short` is clean for tracked files.
- If the update was breaking, confirm the migration completed before reloading.
