# Update an existing machine

> **Scope:** this reference is for the **production / machine path** (`dgit`, bare repo at `$HOME/.cfg`, work-tree `$HOME`). If you are in the dotfiles **source repo** (a normal clone), update with plain `git pull --rebase origin main` instead.

Bring a machine already running these dotfiles up to date. Before you start, sync this skill to the latest so you have the most current update/migration steps: `npx skills add Yesifan/dotfile`.

The path depends on whether the machine has a LOCAL commit, and whether the incoming change is breaking.

## First: inspect the state

```zsh
dgit status --short                 # any tracked file modified?
dgit log --oneline --graph -5
dgit log -1 --format=%s             # what is at HEAD, and is it a breaking commit?
```

The last command matters: if HEAD matches a hash listed in [migrations/readme.md](migrations/readme.md), follow that plan before reloading the shell.

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
