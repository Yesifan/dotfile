# Maintain: make, review, commit, and push a change

> **Scope:** this reference is for the **production / machine path** (bare repo at `$HOME/.cfg`, work-tree `$HOME`, commands via `dgit`). If you are editing the dotfiles **source repo** (a normal clone such as `/home/ye/code/dotfile`), use plain `git` instead — none of the `/tmp` isolation or LOCAL-convention machinery below applies.

Two distinct jobs get conflated here: **committing** a change (fast, local) and **pushing** it to the shared repo (needs care if the machine carries local-only content). Never assume you can push straight from the work-tree.

## 1. Add only the files you mean

Add tracked files explicitly. Never use `dgit add -u`, `dgit add .`, or `dgit commit -a` — the work-tree is `$HOME`, so a wide add would pull machine-local files into the repo.

```zsh
dgit add ~/.zshrc
dgit add ~/.config/zsh/zshrc
dgit add ~/.config/git/config
dgit add ~/.config/ghostty/config.ghostty
dgit add ~/.config/starship.toml
dgit add ~/.vimrc
dgit add ~/.tmux.conf
dgit add ~/.codex/AGENTS.md
dgit add ~/.codex/config.toml
dgit add ~/.codex/agents/reviewer.toml
dgit add ~/.codex/agents/waiter.toml
dgit add ~/.codex/rules/development.rules
dgit add ~/.agents/.skill-lock.json
dgit add ~/.config/opencode/opencode.jsonc
dgit add ~/.config/opencode/AGENTS.md
dgit add ~/.config/opencode/tui.json
dgit add ~/README.md
```

## 2. Review before committing

```zsh
dgit status --short --untracked-files=all
dgit diff --cached
dgit diff --cached --name-only
```

Block the commit if any of these appear in the staged diff: private keys, tokens, `.proxyenv`, `.zprofile`, `.gitconfig`, `.ssh/config`, `.npmrc`, or any line below a local marker.

## 3. Commit

```zsh
dgit commit -m "Describe the change"
```

## 4. Push — use the isolated clone when local content exists

If the machine's managed files contain **no** machine-local sections (e.g. `.zshrc` has nothing below its remote end marker, `.codex/config.toml` has nothing below its marker), you can push directly:

```zsh
dgit push origin main
```

But if any tracked file carries a local-only section, **do not push from the work-tree.** It risks leaking local config. Instead, strip the local sections in an isolated clone under `/tmp`:

```zsh
mkdir -p /tmp/dotfile-merge
git clone --bare git@github.com:Yesifan/dotfile.git /tmp/dotfile-merge/dotfile.git
mkdir -p /tmp/dotfile-merge/worktree
git --git-dir=/tmp/dotfile-merge/dotfile.git \
    --work-tree=/tmp/dotfile-merge/worktree checkout -f main
```

Copy the managed content out of the machine's files, discarding everything below each local marker:

```zsh
# .zshrc — keep the whole file, but strip from the remote end marker:
#   sed '/^# =========remote end==============$/q' ~/.zshrc

# .codex/config.toml — keep what's above the local-only marker:
sed '/^# ---- Local-only additions below ----$/q' ~/.codex/config.toml \
  | head -n -1 > /tmp/dotfile-merge/worktree/.codex/config.toml

# .config/opencode/opencode.jsonc — keep what's above the local config marker:
sed '/\/\/ ======= local config ===$/q' ~/.config/opencode/opencode.jsonc \
  | head -n -1 > /tmp/dotfile-merge/worktree/.config/opencode/opencode.jsonc
```

Verify the extracted files are still valid before committing:

```zsh
python3 -c "import toml; toml.load(open('/tmp/dotfile-merge/worktree/.codex/config.toml'))" 2>&1
python3 -c "import json; json.load(open('/tmp/dotfile-merge/worktree/.config/opencode/opencode.jsonc'))" 2>&1
```

> JSON and TOML cut with `sed` can end on a dangling comma or a missing closing `}` / `]`. Fix those by hand before you commit — a broken `config.toml` or `opencode.jsonc` will crash the agent on every load.

Then commit and push from the isolated clone:

```zsh
git --git-dir=/tmp/dotfile-merge/dotfile.git --work-tree=/tmp/dotfile-merge/worktree add -A
git --git-dir=/tmp/dotfile-merge/dotfile.git --work-tree=/tmp/dotfile-merge/worktree commit -m "..."
git --git-dir=/tmp/dotfile-merge/dotfile.git push origin main
```

## 5. Sync the local repo back

After pushing, bring the machine's `main` up to date and keep the LOCAL commit one ahead:

```zsh
dgit fetch origin
dgit reset --soft origin/main
dgit commit --amend -m "LOCAL: <summary> [never push]"
```

`reset --soft` keeps the machine's changes staged and discards the now-redundant LOCAL branch line. Re-committing as a single `LOCAL:` commit preserves the "one ahead" invariant.

Clean up the scratch clone:

```zsh
rm -rf /tmp/dotfile-merge
```
