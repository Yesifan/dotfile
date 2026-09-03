# Maintain: make, review, commit, and push a change

> **Scope:** this reference is for the **production / machine path** (bare repo at `$HOME/.cfg`, work-tree `$HOME`, commands via `dgit`). If you are editing the dotfiles **source repo** (a normal clone such as `/home/ye/code/dotfile`), use plain `git` instead — none of the `/tmp` isolation or LOCAL-convention machinery below applies.

Two distinct jobs get conflated here: **committing** a change (fast, local) and **pushing** it to the shared repo (needs care if the machine carries local-only content). Never assume you can push straight from the work-tree.

## 1. Add only the files you mean

Add tracked files explicitly. Never use `dgit add -u`, `dgit add .`, or `dgit commit -a` — the work-tree is `$HOME`, so a wide add would pull machine-local files into the repo.

```zsh
dgit add ~/.zshenv
dgit add ~/.zprofile
dgit add ~/.zshrc
dgit add ~/.config/shell/main.zsh
dgit add ~/.config/git/config
dgit add ~/.config/ghostty/config
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
dgit status --short
dgit diff --cached
dgit diff --cached --name-only
```

Block the commit if any of these appear in the staged diff: private keys, tokens, `.proxyenv`, `.ssh/config`, `.npmrc`, `.gitconfig`, or any content inside a LOCAL block.

## 3. Commit

```zsh
dgit commit -m "Describe the change"
```

## 4. Push — use the isolated clone when local content exists

If the machine's tracked files contain **no** LOCAL-block content (e.g. the blocks are still empty templates), you can push directly:

```zsh
dgit push origin main
```

But if any tracked file carries LOCAL-block content, **do not push from the work-tree.** It risks leaking the machine's local config. Instead, strip the LOCAL blocks in an isolated clone under `/tmp`:

```zsh
mkdir -p /tmp/dotfile-merge
git clone --bare git@github.com:Yesifan/dotfile.git /tmp/dotfile-merge/dotfile.git
mkdir -p /tmp/dotfile-merge/worktree
git --git-dir=/tmp/dotfile-merge/dotfile.git \
    --work-tree=/tmp/dotfile-merge/worktree checkout -f main
```

Copy the managed content out of the machine's files, dropping every LOCAL block:

```sh
# Remove any LOCAL marker: a `===== LOCAL =====` block (append) or a
# `LOCAL REPLACE: <key>` block (replace/delete). Marker lines and body are both dropped.
strip_local() {
  awk '
    /===== LOCAL =====/ || /LOCAL REPLACE:/ { s=1 }
    !s { print }
    /===== END LOCAL =====/ || /END LOCAL REPLACE/ { s=0 }
  ' "$1"
}

strip_local ~/.zshrc                            > /tmp/dotfile-merge/worktree/.zshrc
strip_local ~/.zprofile                         > /tmp/dotfile-merge/worktree/.zprofile
strip_local ~/.codex/config.toml                > /tmp/dotfile-merge/worktree/.codex/config.toml
strip_local ~/.config/opencode/opencode.jsonc   > /tmp/dotfile-merge/worktree/.config/opencode/opencode.jsonc
```

(The match is on the marker text anywhere in a line, so it works for both comment chars — `#` for zsh/toml, `//` for opencode — and for both append and REPLACE markers.)

Verify the extracted files are still valid before committing:

```zsh
zsh -n /tmp/dotfile-merge/worktree/.zshrc /tmp/dotfile-merge/worktree/.zprofile 2>&1
python3 -c "import tomllib;tomllib.load(open('/tmp/dotfile-merge/worktree/.codex/config.toml','rb'))" 2>&1
node -e "const fs=require('fs'),{parse}=require('jsonc-parser');parse(fs.readFileSync('/tmp/dotfile-merge/worktree/.config/opencode/opencode.jsonc','utf8'),{allowTrailingComma:true})" 2>&1
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
