# Migration Guide

For agents updating local machines via dgit. Covers both regular updates
and per-commit migration plans for breaking changes.

## Conventions

-   Local always aligns to remote. Never create branches; never let local
    diverge from origin.
-   Always `dgit pull --rebase origin main` (no merge commits).
-   Conflict default rule: anything ABOVE the `LOCAL CONFIG BELOW`
    separator in `~/.zshrc` (and all other repo-tracked files) is
    repo-managed -- prefer remote ("theirs"). Anything BELOW the
    separator in `~/.zshrc` is machine-local -- preserve local ("ours").
-   After each step, reload shell: `exec zsh -l`.

## Baseline

This guide starts from `fa12020` (docs restructure + agent configs).
Machines on an older commit must `dgit pull --rebase` to `fa12020` first;
those updates are regular (non-breaking) and need no migration plan.

## Regular (non-breaking) updates

Apply when the only changes are doc additions, config tweaks, or new
tool blocks guarded by `command -v`:

```sh
dgit pull --rebase origin main
```

Verify:

-   `dgit status --short` is clean
-   Open a new terminal or `exec zsh -l`; shell starts without errors

If `dgit pull --rebase` conflicts on a tracked file:

1.  Determine which side to favour (see conflict rule above).
2.  Resolve markers in the file, then `dgit add <file>`.
3.  `dgit rebase --continue`

If conflicts recur or you need a clean slate:

```sh
dgit rebase --abort
dgit fetch origin
dgit reset --hard origin/main
# Then re-apply any machine-local blocks to ~/.zshrc below the
# LOCAL CONFIG BELOW separator from your backup.
```

## Breaking updates (per-commit migration list, newest first)

Each commit below breaks existing behaviour. If `dgit log --oneline`
does not yet contain the hash, apply the migration plan.

---

### `cc9c297` -- refactor(zsh): fold local config into .zshrc separator

**Date:** 2026-07-15

**What breaks:**

-   `~/.zshrc` no longer sources `~/.config/zsh/zshrc.local`
-   `~/.zshrc` no longer sources `~/.zshalias`
-   `.config/zsh/zshrc.local.example` -- removed from repo
-   `.ssh/config` -- removed from tracking

**Affected files:**

-   `~/.zshrc`
-   `~/.config/zsh/zshrc.local` (contents must migrate)
-   `~/.zshalias` (contents must migrate)
-   `~/.ssh/config` (still on disk, now untracked)

**Detect (any one applies):**

-   `grep -q zshrc.local ~/.zshrc` returns 0
-   `grep -q zshalias ~/.zshrc` returns 0
-   `dgit ls-files --error-unmatch .ssh/config 2>/dev/null` succeeds

**Pre-flight -- backup machine-local data:**

```sh
mkdir -p /tmp/dotfile-migrate
cp ~/.zshrc /tmp/dotfile-migrate/zshrc
[[ -r ~/.config/zsh/zshrc.local ]] && cp ~/.config/zsh/zshrc.local /tmp/dotfile-migrate/
[[ -r ~/.zshalias ]] && cp ~/.zshalias /tmp/dotfile-migrate/
[[ -f ~/.ssh/config ]] && cp ~/.ssh/config /tmp/dotfile-migrate/ssh_config
```

**Migration steps (run once per machine):**

1.  Pull with rebase:

    ```sh
    dgit pull --rebase origin main
    ```

    If `~/.zshrc` was locally modified, the rebase will conflict on it.
    Proceed to step 2. If the rebase succeeds cleanly, still check
    `~/.zshrc` has the new format (separator line, no `zshrc.local`
    source), then skip to step 3.

2.  Resolve `~/.zshrc` conflict:

    -   Open `~/.zshrc`.
    -   Keep the **remote** version as the top section -- verify it
        contains the new header, the `source ...zshrc` line, and the
        `LOCAL CONFIG BELOW` separator. It should NOT have `zshrc.local`
        or `.zshalias` source lines.
    -   From the backup file `/tmp/dotfile-migrate/zshrc`, find the
        machine-local blocks that were appended below the old source
        section: proxy exports, `opencode` PATH, `Codex CLI` PATH,
        `pnpm` block, and any custom aliases.
    -   Append each block BELOW the `LOCAL CONFIG BELOW` separator,
        preserving any `command -v` or `[[ -r ... ]]` guards. Order:
        1. Proxy exports (commented if previously commented)
        2. PATH additions
        3. Tool inits (`nvm`, `pnpm`, etc.)
        4. Aliases
    -   Also check `/tmp/dotfile-migrate/zshrc.local` -- its nvm and
        pnpm blocks should be migrated to `~/.zshrc` below the
        separator, guarded by the same conditions.
    -   Also check `/tmp/dotfile-migrate/zshalias` -- its Tailscale
        alias (or any alias) should be appended below the separator,
        guarded by `[[ -x ... ]]`.
    -   Save, then mark resolved and continue:

        ```sh
        dgit add ~/.zshrc
        dgit rebase --continue
        ```

3.  Remove legacy source files (no longer referenced by anything; kept
    on disk only as untracked cruft):

    ```sh
    rm -f ~/.config/zsh/zshrc.local ~/.config/zsh/zshrc.local.example ~/.zshalias
    ```

4.  `.ssh/config` is now untracked. The file remains on disk unchanged.
    Confirm permissions are correct:

    ```sh
    chmod 600 ~/.ssh/config
    ```

    It will not appear in `dgit status` because
    `status.showUntrackedFiles` is `no`.

5.  Reload and verify:

    ```sh
    exec zsh -l
    ```

    -   `dgit status --short` -- clean (no tracked file modified)
    -   `dgit ls-files | grep -E 'ssh/config|zshrc\.local|zshalias'` --
        empty
    -   `which pnpm` && `which nvm` -- still resolve
    -   `ssh -T git@github.com` -- still authenticates (proxy/identity
        preserved)

---

### Future entries -- append below (template)

```
### `<full-hash>` -- `<subject>`

**Date:** YYYY-MM-DD

**What breaks:**

**Detect (any one applies):**

**Pre-flight:**

**Migration:**

**Verify:**
```
