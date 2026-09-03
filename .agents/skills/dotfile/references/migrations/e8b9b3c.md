# e8b9b3c — refactor(zsh): shared shell config in ~/.config/shell, no ZDOTDIR

**Date:** 2026-09-03

**What breaks:**

- `~/.zshrc` is no longer split by a `# =========REMOTE CONFIG============` / `# =========REMOTE CONFIG END==============` marker. Machine-local content is no longer "below the marker"; instead any tracked file may carry a `# ===== LOCAL =====` / `# ===== END LOCAL =====` block.
- Shared interactive config moved from `~/.config/zsh/zshrc` to `~/.config/shell/main.zsh`; the whole `~/.config/zsh/` directory is gone.
- `~/.zshrc` is now the standard entrypoint that sources `~/.config/shell/*.zsh`.
- `~/.zshenv` now holds shared env (`EDITOR`/`VISUAL`); `~/.zprofile` holds login env (`PATH`). Machine login/env additions must move into a LOCAL block.

**Affected files:**

- `~/.zshrc` — marker split removed; content that was below the old marker must move into a LOCAL block.
- `~/.config/zsh/zshrc` → `~/.config/shell/main.zsh`
- `~/.config/zsh/` — removed
- `~/.zshenv` — now shared env
- `~/.zprofile` — now login env

**Detect (any one applies):**

- `grep -qiE 'remote config' ~/.zshrc` returns 0 (case-insensitive — machines wrote `# =========REMOTE CONFIG============` or lowercase `remote config`)
- `[ -e ~/.config/zsh/zshrc ]` is true
- `dgit ls-files --error-unmatch .config/zsh/zshrc 2>/dev/null` succeeds

> If a machine has **no** machine-local content in `~/.zshrc` (the marker block is empty below the end marker), a plain `dgit pull --rebase origin main` is enough — no migration needed.

## Migration steps (run once per machine)

1. **Back up machine-local shell content:**

   ```zsh
   mkdir -p /tmp/dotfile-migrate
   cp ~/.zshrc /tmp/dotfile-migrate/zshrc
   [[ -r ~/.config/zsh/zshrc.local ]] && cp ~/.config/zsh/zshrc.local /tmp/dotfile-migrate/
   [[ -r ~/.zshalias ]] && cp ~/.zshalias /tmp/dotfile-migrate/
   [[ -f ~/.zprofile ]] && cp ~/.zprofile /tmp/dotfile-migrate/zprofile
   ```

2. **Pull the new structure:**

   ```zsh
   dgit pull --rebase origin main
   ```

   If this conflicts on `~/.zshrc`, resolve it by keeping the new remote `~/.zshrc` (the entrypoint that sources `~/.config/shell/*.zsh`) and dropping the old `REMOTE CONFIG` marker lines (match case-insensitively — some machines wrote `remote config`) — the machine-local content is recovered in step 3.

3. **Move machine-local content into a LOCAL block.**

   In `~/.zshrc`, below the `for file in "$HOME"/.config/shell/*.zsh ...` block, add:

   ```zsh
   # ===== LOCAL =====
   # (machine-local: proxy exports, PATH additions, nvm/pnpm, aliases)
   # ===== END LOCAL =====
   ```

   Move the relevant blocks from `/tmp/dotfile-migrate/zshrc` (and `zshrc.local` / `zshalias`) into that block, preserving any `command -v` / `[[ -r ... ]]` / `[[ -x ... ]]` guards. Order: proxy exports, PATH additions, tool inits, aliases.

   Move login env (e.g. brew shellenv) from `/tmp/dotfile-migrate/zprofile` into the LOCAL block of the new `~/.zprofile`.

4. **Remove the old config directory** (now leftover/untracked):

   ```zsh
   rm -rf ~/.config/zsh
   ```

5. **Reload and verify:**

   ```zsh
   exec zsh -l
   ```

   - `dgit status --short` — clean (no tracked file modified)
   - `grep -qiE 'remote config' ~/.zshrc` — should return non-zero (old marker gone)
   - `zsh -n ~/.zshrc ~/.zprofile ~/.config/shell/main.zsh` — parses clean
   - `command -v zoxide fzf starship` — tools resolve
   - `~/.zshrc` contains a `# ===== LOCAL =====` block with the machine's content
