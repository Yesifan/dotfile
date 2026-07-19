# Agent Configuration

## MCP Servers

---

### Context7

从 [context7.com/dashboard](https://context7.com/dashboard) 创建 API Key。

设置环境变量：

```bash
export CONTEXT7_API_KEY="ctx7_..."
```

或者在终端直接登录：

```bash
npx ctx7 setup --opencode
```

选择 `MCP` 模式，按提示完成 OAuth 登录。

---

### Web Search（仅 OpenCode）

OpenCode 内置 `websearch` 使用 Exa 服务。

- 使用 OpenCode Provider（模型名含 `opencode-` 前缀）时：**不需要** 额外设置
- 使用其他 Provider（直接调用 Anthropic / OpenAI API）时：需要设置

```bash
export OPENCODE_ENABLE_EXA=1
```

无需单独注册或 API Key。

---

### Playwright

Playwright MCP 无需 API Key 或 Token，`npx @playwright/mcp@latest` 自动处理依赖。

首次运行会自动下载浏览器二进制文件，耗时约 30 秒。

---

## Skills

### Installation

```bash
pnpm dlx skills add <package> -g     # install global
pnpm dlx skills add <package> -a '*' # install to all agents (project-level)
pnpm dlx skills experimental_sync -y # sync from node_modules to agent dirs
pnpm dlx skills update -g            # update global skills
pnpm dlx skills ls -g                # list global skills
pnpm dlx skills ls                   # list project skills
```

### Installed Skills

All skills live in `~/.agents/skills/` and work with Codex, OpenCode, Warp, Zed, and GitHub Copilot.

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
