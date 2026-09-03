# Migrations

> **Scope:** this reference is for the **production / machine path** (updating an installed machine's `$HOME` config via `dgit`). It is not about editing the dotfiles **source repo** — that is a normal `git` clone and uses plain `git pull`.

Every breaking-change commit has its own migration file here, named by its commit **hash** (e.g. [`cc9c297.md`](cc9c297.md)). A migration file tells you how to bring a machine that hasn't yet applied that commit up to it, without losing machine-local config.

## Finding the migration for your commit

Get the hash of the commit you're about to apply on the machine:

```zsh
dgit log -1 --format=%h    # short hash (what the files are named by)
dgit log -1 --format=%H    # full hash
```

Then:

1. **Is it breaking?** The hash matches a `<githash>.md` file in this directory → yes. Read it and follow it **before** reloading the shell (`exec zsh -l`).
2. **Not in the list?** It's an ordinary update — just `dgit pull --rebase origin main` (see [update.md](../update.md)).

If a machine is still on an older commit (its `dgit log` doesn't yet contain the hash), you may need to apply several migrations **in order: oldest → newest** to reach the latest. For example, a machine before `fa12020` first runs [fa12020.md](fa12020.md), then [cc9c297.md](cc9c297.md), then any newer ones.

| Hash | Subject |
|------|---------|
| [fa12020](fa12020.md) | baseline snapshot (one-shot for very old machines) |
| [cc9c297](cc9c297.md) | refactor(zsh): fold local config into .zshrc separator |

## Conventions

The shared marker rules, the `LOCAL: [never push]` one-ahead convention, and "never push the LOCAL commit" are described in [conventions.md](../conventions.md). Every migration below assumes them — read that first if you need a refresher.

## Adding a new migration

When a future commit breaks existing behaviour, add a new `<full-hash>.md` file here using the template below, and add a row to the table above.

```
# `<full-hash>` — `<subject>`

**Date:** YYYY-MM-DD

**What breaks:**

**Detect (any one applies):**

**Pre-flight:**

**Migration:**

**Verify:**
```
