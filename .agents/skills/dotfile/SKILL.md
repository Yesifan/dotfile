---
name: dotfile
description: Guides installing, maintaining, and updating this user's dotfiles, which live in a bare git repository at $HOME/.cfg and are manipulated through a dgit alias. Use it when the user wants to set up their dotfiles on a new machine, commit or push a change to a tracked config file, update an existing machine, resolve a conflict between the repo-managed and machine-local parts of a config file, or migrate a machine after a breaking change. It also applies whenever the conversation touches the dgit workflow, the LOCAL block conventions, the LOCAL [never push] commit, or keeping $HOME/.cfg in sync with the dotfile repository.
compatibility: zsh, git. Requires git. The helper alias dgit wraps git --git-dir=$HOME/.cfg/ --work-tree=$HOME. Commands assume zsh, but the git operations run the same in bash.
disable-model-invocation: true
---

# Dotfiles

These dotfiles are managed by a **bare git repository** at `$HOME/.cfg`, reached through the alias `dgit` (i.e. `/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME`). The source repo is github.com/Yesifan/dotfile and it is shared across macOS and Linux machines.

The whole system is built around one idea: **the repo owns all the shared config; every machine's secrets, paths, and personal settings stay out of it.** A tracked file may carry a **LOCAL block** that marks its machine-local content. The repo ships the block empty; each machine fills it in. Nothing inside a LOCAL block is ever pushed.

You are here to walk through the install, maintenance, and update flows. Read the reference for the task before acting, and lean on the rules below so you never leak local config into the repo or clobber a machine's local setup.

> **Before installing or updating on a machine, sync this skill to the latest so the agent has current guidance:** `npx skills use YeSifan/dotfile@dotfile`.

## Two places this skill applies — pick the right commands

There are two very different places you can be when "working on the dotfiles", and **the commands differ**. Read this first so you don't run `dgit` where you should run `git`, or vice-versa.

### Editing the dotfiles source repo (a normal clone)

When you're inside the dotfiles repository as a git checkout — e.g. `/home/ye/code/dotfile` — you're authoring the repo's own _content_: config files, README/docs, `.agents/`, `.skill-lock.json`, these skill files. Use **plain `git`** here (`git status`, `git add <file>`, `git commit`, `git push origin main`, review with `git diff --cached`). The repo's checked-out files _are_ the managed content, with no LOCAL blocks, so there are **no LOCAL blocks to preserve and no `/tmp` isolation needed**. The only rule that still applies: never commit secrets.

### Operating an installed machine's config (the **production** environment)

When you're on a machine whose dotfiles are deployed as a bare repo at `$HOME/.cfg` with work-tree `$HOME`, you're touching the LIVE configuration (`~/.zshrc`, `~/.config/...`). Use **`dgit`** here. This is where LOCAL blocks, the `/tmp` isolated-clone push, the `LOCAL [never push]` commit convention, and the migration / `dgit pull` workflows all live.

> **Everything in this skill's references (`install`, `maintain`, `update`, `migrations`, `conventions`) describes the production/machine path (`dgit`) — not the source repo.** If you are in the source repo, just use normal `git`; none of the LOCAL-block,/tmp/LOCAL-commit machinery applies.

## Rules that matter most

These are the failure modes that actually hurt. Understand why each exists before you run anything.

- **`dgit` only ever commits what you name.** No `dgit add -u`, no `dgit commit -a`, no `dgit add .`. Files are tracked one at a time, explicitly. The reason: a bare-repo work-tree is the user's real `$HOME`, so a broad add would sweep machine-local files into the repo. That is the single most dangerous footgun here.
- **LOCAL blocks mark machine-local content.** Any tracked file may carry a `# ===== LOCAL =====` … `# ===== END LOCAL =====` block (using the file's comment char). Content inside is machine-local: preserved on pull/rebase, stripped before you push. The repo ships files without such blocks; you add one only where a machine needs local content. Full details in [references/conventions.md](references/conventions.md).
- **Each machine keeps `main` exactly one commit ahead of `origin/main`.** That commit is `LOCAL: <summary> [never push]` and holds only machine-local additions. It is there so a machine can stay in sync with origin without committing its local content. **Never push it.**
- **Pushing shared changes off a machine that carries LOCAL-block content must happen in an isolated clone under `/tmp`**, stripping those blocks first. Pushing from the work-tree can leak machine-local config into the public repo.
- **Never commit** private keys, tokens, `.proxyenv`, `.ssh/config`, `.npmrc`, `.gitconfig`, or any content inside a LOCAL block.

When you are unsure what is tracked or how a file is split, start with [references/conventions.md](references/conventions.md).

## Task selection

| Job                                                                               | Reference                                                          |
| --------------------------------------------------------------------------------- | ------------------------------------------------------------------ |
| Set up the dotfiles on a new machine                                              | [references/install.md](references/install.md)                     |
| Make, review, commit, and safely push a change                                    | [references/maintain.md](references/maintain.md)                   |
| Update an existing machine (incl. breaking changes)                               | [references/update.md](references/update.md)                       |
| Tracked vs untracked files, LOCAL blocks, conflict rules, LOCAL commit convention | [references/conventions.md](references/conventions.md)             |
| Per-commit migration plans for breaking updates                                   | [references/migrations/readme.md](references/migrations/readme.md) |
| Agent-side setup: env vars, MCP servers, skills tooling                           | [references/agents.md](references/agents.md)                       |
| Package special cases (tmux, Ghostty)                                            | [packages/tmux.md](references/packages/tmux.md), [packages/ghostty.md](references/packages/ghostty.md) |

> All tables above are the **production / machine path** (`dgit` on `$HOME/.cfg`). Editing the **source repo** (a normal clone like `/home/ye/code/dotfile`) is plain `git` and is _not_ in these references.

> Invocation note: this skill is deliberately not auto-triggered from the system prompt (`disable-model-invocation: true`). Load it explicitly via the skill command or by telling the agent to use the dotfile skill.
