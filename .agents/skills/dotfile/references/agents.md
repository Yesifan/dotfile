# Agent-side setup

The codebase uses AI coding agents (Codex, OpenCode, pi) with shared skills and a couple of MCP servers. This is the machine-local setup that lives outside the repo (env vars, API keys) plus the tooling used to install skills.

## AGENTS.md project instructions

The three AI agents (Codex, OpenCode, pi) read instructions from an `AGENTS.md`, unified behind a single source of truth using **relative symlinks**:

- `.codex/AGENTS.md` — the canonical, real file; the only place to edit.
- `.config/opencode/AGENTS.md` — a symlink to `../../.codex/AGENTS.md`.
- `.pi/agent/AGENTS.md` — a symlink to `../../.codex/AGENTS.md` (Pi's global instructions).

### How it was done

1. Keep `.codex/AGENTS.md` as the real file (it already held the superset of the rules).
2. Replace `.config/opencode/AGENTS.md` and `.pi/agent/AGENTS.md` with symlinks instead of copies:

   ```zsh
   rm .config/opencode/AGENTS.md
   ln -s ../../.codex/AGENTS.md .config/opencode/AGENTS.md
   rm .pi/agent/AGENTS.md
   ln -s ../../.codex/AGENTS.md .pi/agent/AGENTS.md
   git add .codex/AGENTS.md .config/opencode/AGENTS.md .pi/agent/AGENTS.md
   ```

The path is **relative** (`../../.codex/AGENTS.md`) so it resolves whether you're in the repo checkout or on a machine where the dotfiles are installed via the bare repo (i.e. `$HOME/.config/opencode/` → `$HOME/.codex/AGENTS.md`, `$HOME/.pi/agent/` → `$HOME/.codex/AGENTS.md`, and in a clone root → `<repo>/.codex/AGENTS.md`). Git records the link as a symlink (mode `120000`), so it survives `clone` and `dgit` checkout on other machines.

### Behaviour to remember

- **Edit one, update all:** editing any path edits the canonical file, so Codex, OpenCode, and Pi always read identical instructions.
- **Delete a link, keep the source:** `rm` / `git rm` on `.config/opencode/AGENTS.md` or `.pi/agent/AGENTS.md` removes only the link; `.codex/AGENTS.md` survives.
- **Don't delete the canonical** unless intentional: removing `.codex/AGENTS.md` leaves _dangling_ opencode/pi links (broken paths, not deleted files). Recreate them with `ln -s ../../.codex/AGENTS.md <dir>/AGENTS.md`.

## Pi config

Pi reads its global instructions/resources from a machine path, not the project: `~/.pi/agent/` (AGENTS.md, prompts, skills, extensions). The repo tracks only Pi's **shared resources** — `.pi/agent/AGENTS.md` (a symlink to `.codex/AGENTS.md`), `.pi/agent/prompts/`, and the shared permission policy. Its `settings.json` is machine-owned (strict JSON, no LOCAL block) and holds the provider/model/package config, so it stays on the machine like `.gitconfig`/`.zprofile`.

## Environment variables

Add only the variables you use, **below** the local marker in `~/.zshrc` (or wherever the machine keeps such settings). Values are machine-local secrets — never commit them.

| Variable           | Needed when        | Purpose                   |
| ------------------ | ------------------ | ------------------------- |
| `CONTEXT7_API_KEY` | Using Context7 MCP | Context7 API access       |
| `EXA_API_KEY`      | Using the Exa MCP  | Exa web search API access |

`EXA_API_KEY` is read directly by the Exa MCP. `OPENCODE_ENABLE_EXA` is no longer needed.

## Skills tooling

Skills are managed with `pnpm dlx skills`. Global skills live in `~/.agents/skills/` and work with Codex, OpenCode, Warp, Zed, and GitHub Copilot.

```bash
pnpm dlx skills add <package> -g     # install global
pnpm dlx skills add <package> -a '*' # install to all agents (project-level)
pnpm dlx skills experimental_sync -y # sync from node_modules to agent dirs
pnpm dlx skills update -g            # update global skills
pnpm dlx skills ls -g                # list global skills
pnpm dlx skills ls                   # list project skills
```
