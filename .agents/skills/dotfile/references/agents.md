# Agent-side setup

The codebase uses AI coding agents (Codex, OpenCode, pi) with shared skills and a couple of MCP servers. This is the machine-local setup that lives outside the repo (env vars, API keys) plus the tooling used to install skills.

## Environment variables

Add only the variables you use, **below** the local marker in `~/.zshrc` (or wherever the machine keeps such settings). Values are machine-local secrets — never commit them.

| Variable | Needed when | Purpose |
|----------|-------------|---------|
| `CONTEXT7_API_KEY` | Using Context7 MCP | Context7 API access |
| `EXA_API_KEY` | Using the Exa MCP | Exa web search API access |

`EXA_API_KEY` is read directly by the Exa MCP. `OPENCODE_ENABLE_EXA` is no longer needed.

## MCP servers

### Context7

Create an API key at [context7.com/dashboard](https://context7.com/dashboard). Set `CONTEXT7_API_KEY`, or log in from the terminal:

```bash
npx ctx7 setup --opencode
```

Choose `MCP` mode and complete the OAuth login.

### Web Search (OpenCode only)

OpenCode's built-in `websearch` uses Exa. With an OpenCode provider (model name containing `opencode-`): no extra setup. With any other provider (direct Anthropic/OpenAI API): set `EXA_API_KEY`.

### Playwright

No API key needed; `npx @playwright/mcp@latest` handles dependencies. First run downloads browser binaries (~30s).

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

### Installed global skills

| Skill | Purpose | Trigger |
|-------|---------|---------|
| ask-matt | Router to the best skill/flow for your situation | Ask directly |
| caveman | Ultra-compressed communication (~75% fewer tokens) | Say "caveman mode" |
| caveman-commit | Ultra-compressed Conventional Commits | Say "write a commit" |
| caveman-review | Ultra-compressed code review comments | Say "review this PR" |
| codebase-design | Design deep module interfaces, improve testability | When designing modules |
| diagnosing-bugs | Debug loop: reproduce → bisect → root cause → fix | Auto-triggers on bug reports |
| domain-modeling | Build domain model, unify terminology, record ADRs | When modeling domains |
| find-skills | Search and discover installable skills | Say "find a skill for..." |
| grill-me | Relentless interview to sharpen a plan/design | Say "grill me" |
| grill-with-docs | Interview while generating ADRs and glossary | Say "grill with docs" |
| grilling | Stress-test plans/designs for blind spots | Uses "grill" keywords |
| handoff | Compact conversation into handoff doc for another agent | When handing off |
| improve-codebase-architecture | Scan codebase for deepening opportunities, generate HTML report | When requesting architecture review |
| prototype | Build throwaway prototypes (terminal app or UI variants) | When prototyping |
| setup-matt-pocock-skills | One-time project setup: issue tracker, labels, domain layout | First-time setup |
| tdd | Test-driven development: red → green → refactor → integration | Say "tdd" or test-first |
| teach | Teach a new skill/concept within this workspace | Say "teach me" |
| to-issues | Break plans/specs into independent issues | Say "break into issues" |
| to-prd | Synthesize conversation into PRD, publish to tracker | Say "write a PRD" |
| triage | Move issues and PRs through a triage state machine | Say "triage" |
| writing-great-skills | Reference for writing and editing skills | When creating/editing skills |

The project's own `dotfile` skill is bundled here in the repo under `.agents/skills/dotfile/`; it is intentionally not in the global list and not auto-triggered.
