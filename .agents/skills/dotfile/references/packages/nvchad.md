# NvChad 说明

仓库管理 `~/.config/nvim/init.lua`（引导安装 lazy.nvim、加载 NvChad v2.5）、`~/.config/nvim/lua/clipboard.lua`（剪贴板）和 `~/.config/nvim/lazy-lock.json`（共享插件版本）。仅加载 NvChad 默认插件，不额外配置语言服务器、格式化器或语言环境。

## 安装与更新

需要 Neovim 0.11 或更高版本、Git、Nerd Font，以及编译器、make 和 tree-sitter CLI；具体平台依赖见 [NvChad 官方安装说明](https://nvchad.com/docs/quickstart/install/)。在本地 Ghostty 中选用 Nerd Font，以显示编辑器图标。

Neovim 是必装依赖，Shell 的 `EDITOR` 和 `VISUAL` 均设为 `nvim`。发行版软件包版本过低时，按 [Neovim 官方安装说明](https://github.com/neovim/neovim/blob/master/INSTALL.md) 安装兼容版本。

将仓库配置部署到目标机器的 `~/.config/nvim/` 后，首次运行 `nvim` 会联网下载插件。已有 Neovim 配置时，先备份再部署。

各机器共享仓库中的 `~/.config/nvim/lazy-lock.json`。日常拉取配置后运行 `:Lazy restore`，恢复锁定版本；只有明确升级时才运行 `:Lazy update` 或 `:Lazy sync`，验证后提交更新的锁文件。在源码仓库使用普通 Git；在生产机器上按 [维护规范](../maintain.md) 通过 `/tmp` 隔离副本推送共享锁文件，不推送 `LOCAL [never push]` 提交。

## SSH 剪贴板

在 A 的 Ghostty 中 SSH 到 B 并运行 Neovim，配置会根据 `SSH_TTY` 或 `SSH_CONNECTION` 强制使用 OSC 52 provider。`clipboard=unnamedplus` 让普通操作访问 A 的剪贴板：

- `y` / `yy`：复制到 A。
- `d` / `dd` / `x`：剪切到 A。
- `p` / `P`：粘贴 A 的剪贴板。
- `"_d` / `"_dd`：删除时保留剪贴板内容。

仓库的 Ghostty 配置已设置 `clipboard-read = allow`；`clipboard-write` 默认就是 `allow`。同时设置 `copy-on-select = false`，避免鼠标选中覆盖剪贴板。A 必须加载这些设置。非 SSH 会话使用 Neovim 的本机剪贴板 provider。

经过 tmux 时，复制到 A 可使用现有 tmux 配置，但 OSC 52 读取可能得到 tmux 缓冲区，而非 A 最新的剪贴板。因此普通 `p` 的跨机器读取不能保证；遇到此情况，在 Neovim 进入插入模式后使用 Ghostty 粘贴快捷键（macOS 为 `Cmd+V`）。

部署后应在实际 A / B 链路分别检查复制、剪切和粘贴；仓库配置本身不代表已完成端到端验证。
