# Dotfiles

使用 bare Git 仓库管理（`$HOME/.cfg`），兼容 macOS 和 Linux。

## 配置文件一览

| 软件      | 配置文件                           |
| --------- | ---------------------------------- |
| Zsh       | `~/.zshrc`, `~/.config/zsh/zshrc`  |
| Git       | `~/.config/git/config`             |
| Vim       | `~/.vimrc`                         |
| Starship  | `~/.config/starship.toml`          |
| tmux      | `~/.tmux.conf`                     |
| Ghostty   | `~/.config/ghostty/config.ghostty` |
| Codex CLI | `~/.codex/*`                       |
| OpenCode  | `~/.config/opencode/*`             |

`~/.zshrc` 仅保留薄入口和 `LOCAL CONFIG BELOW` 分隔线；共享 shell 行为在 `~/.config/zsh/zshrc`。
所有可选工具初始化均通过 `command -v` 守卫，新机器可先加载 shell 再安装工具。

Shell 行为详解见 [shell.md](instructions/dotfile/shell.md)，各工具配置详解见 [config.md](instructions/dotfile/config.md)。

## 依赖工具

交互式 shell 使用以下工具的组合：

- `zsh` — shell
- `starship` — 提示符
- `zoxide` — 目录跳转
- `fzf` — 模糊搜索和 shell 快捷键
- `zsh-autosuggestions` — 灰色行内历史建议
- `zsh-syntax-highlighting` — 实时命令行高亮
- `tmux` — 终端复用器
- `git-delta` — 可读的 `git diff` / `git show`
- `ripgrep` (`rg`) — 快速递归文本搜索
- `fd` — 快速文件和目录搜索
- `jq` — JSON 解析和查询
- Vim — 配置文件在 `~/.vimrc`
- Ghostty — XDG 共享配置 `~/.config/ghostty/config.ghostty`

## Install

### 前提

- git（macOS: `xcode-select --install`，Linux 大多预装）
- SSH key 已添加到 GitHub

### 1. 克隆配置

```zsh
echo ".cfg" >> "$HOME/.gitignore"
git clone --bare git@github.com:Yesifan/dotfile.git "$HOME/.cfg"
alias dgit='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
dgit checkout -f
dgit config --local status.showUntrackedFiles no
```

### 2. 加载 shell

```zsh
exec zsh -l
```

或开新终端。未安装的工具不会报错。

### 3. 安装依赖工具

#### macOS

```zsh
brew install starship zoxide fzf zsh-autosuggestions zsh-syntax-highlighting tmux git-delta ripgrep fd jq
```

#### Debian / Ubuntu

```zsh
sudo apt update
sudo apt install zsh fzf tmux zsh-autosuggestions zsh-syntax-highlighting git-delta vim ripgrep fd-find jq
```

`starship`、`zoxide`、`git-delta` 如果不在包管理器中，可从官方 release 安装。Debian/Ubuntu 的 `fd` 包名为 `fd-find`，安装后命令可能是 `fdfind`。如有需要：

```zsh
mkdir -p "$HOME/.local/bin"
ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
```

#### Fedora

```zsh
sudo dnf install zsh starship zoxide fzf tmux zsh-autosuggestions zsh-syntax-highlighting git-delta vim ripgrep fd-find jq
```

#### Arch Linux

```zsh
sudo pacman -S zsh starship zoxide fzf tmux zsh-autosuggestions zsh-syntax-highlighting git-delta vim ripgrep fd jq
```

#### Linuxbrew

```zsh
brew install starship zoxide fzf zsh-autosuggestions zsh-syntax-highlighting tmux git-delta ripgrep fd jq
```

### 4. 设置环境变量

添加到 `~/.zshrc`，放在 `LOCAL CONFIG BELOW` 分隔线以下：

```zsh
export CONTEXT7_API_KEY="ctx7_..."
```

| 变量                           | 用途                                                 |
| ------------------------------ | ---------------------------------------------------- |
| `CONTEXT7_API_KEY`             | Context7 API Key，用于 Codex + OpenCode MCP          |
| `OPENCODE_ENABLE_EXA=1`        | OpenCode Web Search（仅非 OpenCode Provider 时需要） |

详情见 [agent.md](instructions/dotfile/agent.md)。

### 5. 验证

```zsh
exec zsh -l
```

### 6. 安装 Agent Skills（可选）

```zsh
pnpm dlx skills add <package> -g
pnpm dlx skills update -g
```

详见 [agent.md](instructions/dotfile/agent.md) 的 Skills 章节。

## 文件更新原则

### 追踪文件（通过 dgit 管理）

`dgit add` 只添加显式指定的文件，不要用 `dgit add -u`：

```
~/.zshrc                          # 仅追踪 LOCAL CONFIG BELOW 分隔线以上
~/.config/zsh/zshrc
~/.config/git/config
~/.config/ghostty/config.ghostty
~/.config/starship.toml
~/.vimrc
~/.tmux.conf
~/.codex/*
~/.agents/.skill-lock.json
~/.config/opencode/*
instructions/dotfile/*
```

### 不追踪文件（本地维护）

```
~/.zprofile                        # Homebrew shellenv 等登录初始化
~/.ssh/config                      # 机器专属 SSH 配置
~/.npmrc                           # npm registry、认证 token
~/.gitconfig                       # 个人 git 身份
~/.zshrc 中 LOCAL CONFIG BELOW 以下  # 机器专属 PATH、alias、环境变量
*.pem, *.key, .proxyenv            # 敏感信息永远不进 repo
```

### 冲突处理

| 文件                                                    | 归属      | 策略                                       |
| ------------------------------------------------------- | --------- | ------------------------------------------ |
| 追踪文件的 repo 管理部分（如 `.zshrc` 分隔线以上）      | 远程      | 远程版本优先（theirs）                     |
| `.zshrc` 分隔线以下内容                                 | 本地      | 保留本地（ours）                           |
| `.zprofile`, `.ssh/config`, `.npmrc`, `.gitconfig`      | 本地      | 不进 repo                                  |
| `.codex/config.toml`, `.config/opencode/opencode.jsonc` | 远程+本地 | 相同配置用 repo 版本覆盖，本地特有配置保留 |
| `.agents/.skill-lock.json`                               | 远程+本地 | 合并 — 本地安装的 skill 与 repo 记录共存     |

### 日常维护

日常提交、推送、更新现有机器、迁移操作见 [migrate.md](instructions/dotfile/migrate.md)。
