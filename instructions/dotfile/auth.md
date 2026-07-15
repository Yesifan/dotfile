# Auth Setup

## GitHub PAT（Codex + OpenCode）

从 [GitHub](https://www.github.com) 获取：

1. [Personal access tokens](https://github.com/settings/personal-access-tokens) → Fine-grained tokens → Generate new token
2. Token name: `OpenCode GitHub MCP`
3. Expiration: `30 days` 或 `90 days`
4. Resource owner: 选你的 personal account
5. Repository access: `All repositories`（或 `Only select repositories` 并勾选所需仓库）
6. Permissions: 无需额外设置，所有仓库操作由 Repository access 控制
7. Generate and copy the token

设置环境变量：

```bash
export GITHUB_PERSONAL_ACCESS_TOKEN="github_pat_..."
```

持久化到 shell 配置：

```bash
# ~/.zshrc
export GITHUB_PERSONAL_ACCESS_TOKEN="github_pat_..."
```

验证：

```bash
opencode mcp list       # OpenCode
codex mcp list          # Codex
```

应看到 `github  connected`。

---

## Context7 API Key（Codex + OpenCode）

从 [context7.com/dashboard](https://context7.com/dashboard) 创建 API Key。

设置环境变量：

```bash
export CONTEXT7_API_KEY="ctx7_..."
```

持久化：

```bash
# ~/.zshrc
export CONTEXT7_API_KEY="ctx7_..."
```

或者在终端直接登录：

```bash
npx ctx7 setup --opencode
```

选择 `MCP` 模式，按提示完成 OAuth 登录。

---

## Web Search（仅 OpenCode）

OpenCode 内置 `websearch` 使用 Exa 服务。

- 使用 OpenCode Provider（模型名含 `opencode-` 前缀）时：**不需要** 额外设置
- 使用其他 Provider（直接调用 Anthropic / OpenAI API）时：需要设置

```bash
export OPENCODE_ENABLE_EXA=1
```

无需单独注册或 API Key。

---

## Playwright（Codex + OpenCode）

Playwright MCP 无需 API Key 或 Token，`npx @playwright/mcp@latest` 自动处理依赖。

首次运行会自动下载浏览器二进制文件，耗时约 30 秒。
