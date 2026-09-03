# Dotfiles

使用 bare Git 仓库管理（`$HOME/.cfg`），别名 `dgit`。兼容 macOS 和 Linux。

仓库保存所有共享配置。每台机器的密钥、路径、个人设置都不进仓库。追踪文件里可以带一个 **LOCAL 块**标记机器本地内容：仓库里该书为空模板，由每台机器自行填写。LOCAL 块里的内容永不推送。

## 配置文件一览

| 软件      | 配置文件                           |
| --------- | ---------------------------------- |
| Zsh       | `~/.zshenv`, `~/.zprofile`, `~/.zshrc`, `~/.config/shell/` |
| Git       | `~/.config/git/config`             |
| Vim       | `~/.vimrc`                         |
| Starship  | `~/.config/starship.toml`          |
| tmux      | `~/.tmux.conf`                     |
| Ghostty   | `~/.config/ghostty/config.ghostty` |
| Codex CLI | `~/.codex/*`                       |
| OpenCode  | `~/.config/opencode/*`             |

用 LOCAL 块标记任意追踪文件里的机器本地内容：

- `.zshrc`、`.zshenv`、`.zprofile`、`.config/shell/*`、`.codex/config.toml` — `# ===== LOCAL =====` … `# ===== END LOCAL =====`
- `.config/opencode/opencode.jsonc` — `// ===== LOCAL =====` … `// ===== END LOCAL =====`

LOCAL 块内是机器本地内容（pull/rebase 时保留、推送前剥离）；块外是仓库管理区（冲突时以远程为准）。

## 依赖工具

`zsh`、`starship`、`zoxide`、`fzf`、`zsh-autosuggestions`、`zsh-syntax-highlighting`、`tmux`、`git-delta`、`ripgrep`、`fd`、`jq`、Vim、Ghostty。每个可选工具块都用 `command -v` 守卫，新机器可先加载 shell 再安装工具。

## 安装 / 维护 / 更新

分步操作在仓库自带的 **`dotfile` skill**（`.agents/skills/dotfile/`）：

- **新机器安装** — `.agents/skills/dotfile/references/install.md`
- **修改、审查、提交、推送** — `.agents/skills/dotfile/references/maintain.md`
- **更新现有机器**（含破坏性变更） — `.agents/skills/dotfile/references/update.md`
- **追踪/未追踪文件、LOCAL 块、冲突规则、LOCAL 提交约定** — `.agents/skills/dotfile/references/conventions.md`

该 skill **不会自动触发**（`disable-model-invocation: true`）。通过 skill 命令（`/skill:dotfile`）或让 agent 使用 dotfile skill 显式加载。

## Agent 配置

Agent 环境变量（`CONTEXT7_API_KEY`、`EXA_API_KEY`）、MCP 服务器、skills 工具见 `.agents/skills/dotfile/references/agents.md`。变量为机器本地值，写在 LOCAL 块里，永不提交。
