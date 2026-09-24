# Dotfiles

把下面这段话发给你的 AI Agent，即可开始安装或更新：

```text
请先运行 npx skills use YeSifan/dotfile@dotfile，阅读并遵循该 skill 的指导，根据当前机器状态安装或更新 dotfile。
```

使用 bare Git 仓库管理（`$HOME/.cfg`），别名 `dgit`。兼容 macOS 和 Linux。

仓库保存所有共享配置。每台机器的密钥、路径、个人设置都不进仓库。追踪文件里可以带一个 **LOCAL 块**标记机器本地内容：仓库里该书为空模板，由每台机器自行填写。LOCAL 块里的内容永不推送。

## 配置文件一览

| 软件      | 配置文件                                                   |
| --------- | ---------------------------------------------------------- |
| Zsh       | `~/.zshenv`, `~/.zprofile`, `~/.zshrc`, `~/.config/shell/` |
| Git       | `~/.config/git/config`                                     |
| Vim       | `~/.vimrc`                                                 |
| Neovim / NvChad | `~/.config/nvim/`                                    |
| Starship  | `~/.config/starship.toml`                                  |
| tmux      | `~/.tmux.conf`                                             |
| Ghostty   | `~/.config/ghostty/config`                                 |
| Codex CLI | `~/.codex/*`                                               |
| OpenCode  | `~/.config/opencode/*`                                     |

用 LOCAL 块标记任意追踪文件里的机器本地内容：

- `.zshrc`、`.zshenv`、`.zprofile`、`.config/shell/*`、`.codex/config.toml` — `# ===== LOCAL =====` … `# ===== END LOCAL =====`
- `.config/opencode/opencode.jsonc` — `// ===== LOCAL =====` … `// ===== END LOCAL =====`

LOCAL 块内是机器本地内容（pull/rebase 时保留、推送前剥离）；块外是仓库管理区（冲突时以远程为准）。

若要覆盖/删除仓库已发货的值（如 `model`、`lsp`），用行内 `LOCAL REPLACE: <key>` 标记，而不是加一个空块。两类标记 pull 时都保留、push 前都剥离 — 详见 `.agents/skills/dotfile/references/conventions.md`。

## 依赖工具

必装工具如下，安装前仍需征求你的同意：

- **基础工具**：Git、Zsh、Neovim >= 0.11（默认 `EDITOR` / `VISUAL`）、git-delta（Git 分页与交互式 diff）。
- **Shell 体验**：Starship（提示符）、zoxide（目录跳转）、fzf（模糊搜索）、zsh-autosuggestions（历史建议）、zsh-syntax-highlighting（语法高亮）。
- **服务器常用工具**：tmux >= 3.5（持久会话）、ripgrep（`rg`，内容搜索）、fd（文件搜索，也接受 `fdfind`）、jq（JSON 处理）。

GitHub CLI（`gh`）和 Ghostty 保持推荐、选装。**Ghostty 和 Nerd Font 仅安装在运行图形终端的客户端，无 UI 的 SSH 服务器不需要安装。**在客户端终端中选用 Nerd Font 即可显示 NvChad 图标。Shell 集成保留存在性检查，缺少依赖不会阻止 Shell 启动，但 `dotfile-doctor` 会将缺失的必装工具或 Zsh 插件报告为失败。保留 Vim 配置供偶尔使用。

仓库包含最小化 NvChad 配置，使用共享插件锁文件，支持 SSH 下的 OSC 52 剪贴板和普通 `y` / `d` / `p` 操作。Ghostty 选中文字时不再自动复制。启动、插件同步和 tmux 限制见 [NvChad 说明](.agents/skills/dotfile/references/packages/nvchad.md)。

对于向网络开放 SSH 的 Linux 服务器，另推荐 **Fail2ban**，在重复认证失败后临时封禁来源 IP。它是服务器端可选工具，推荐配置见 [Fail2ban 说明](.agents/skills/dotfile/references/packages/fail2ban.md)。

## 包管理工具偏好

- `mise`：管理开发工具和运行时版本；仅推荐，不强制安装，也不自动激活。
- `pnpm`：管理 JavaScript / TypeScript 包。
- `uv`：管理 Python 环境、依赖和工具。

优先遵循现有项目明确的工具配置和锁文件，不因这些偏好自动迁移已有项目。

## 环境体检

部署配置后打开新 Shell，运行 `dotfile-doctor`。命令由 `~/.config/shell/doctor.zsh` 定义，默认检查 `$HOME` 下的工具、兼容版本、配置文件和共享 Agent 符号链接。检查源码仓库可运行 `dotfile-doctor /path/to/dotfile`。

缺少必需依赖或配置无效时返回非零退出码；缺少可选工具只提示，不判失败。命令不会安装工具或修改配置。

## 安装 / 维护 / 更新

安装或更新 dotfile 之前，先把 **`dotfile` skill** 同步到最新，让 agent 拿到最新的指导：

```zsh
npx skills use YeSifan/dotfile@dotfile
```

分步操作在仓库自带的 **`dotfile` skill**（`.agents/skills/dotfile/`）：

- **新机器安装** — `.agents/skills/dotfile/references/install.md`
- **修改、审查、提交、推送** — `.agents/skills/dotfile/references/maintain.md`
- **更新现有机器**（含破坏性变更） — `.agents/skills/dotfile/references/update.md`
- **追踪/未追踪文件、LOCAL 块、冲突规则、LOCAL 提交约定** — `.agents/skills/dotfile/references/conventions.md`

该 skill **不会自动触发**（`disable-model-invocation: true`）。通过 skill 命令（`/skill:dotfile`）或让 agent 使用 dotfile skill 显式加载。

## Agent 配置

Agent 环境变量（`CONTEXT7_API_KEY`、`EXA_API_KEY`）、MCP 服务器、skills 工具见 `.agents/skills/dotfile/references/agents.md`。变量为机器本地值，写在 LOCAL 块里，永不提交。
