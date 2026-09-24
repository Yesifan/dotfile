# NvChad 说明

仓库管理两个文件：`~/.config/nvim/init.lua` 引导安装 lazy.nvim、加载 NvChad v2.5；`~/.config/nvim/lua/clipboard.lua` 配置剪贴板。仅加载 NvChad 默认插件，不额外配置语言服务器、格式化器或语言环境。

## 安装与更新

需要 Neovim 0.11 或更高版本、Git、Nerd Font，以及编译器、make 和 tree-sitter CLI；具体平台依赖见 [NvChad 官方安装说明](https://nvchad.com/docs/quickstart/install/)。在本地 Ghostty 中选用 Nerd Font，以显示编辑器图标。

将仓库配置部署到目标机器的 `~/.config/nvim/` 后，首次运行 `nvim` 会联网下载插件。之后用 `:Lazy sync` 同步和更新插件。插件锁文件保存在 Neovim 数据目录的 `lazy-lock.json`，各机器独立维护，不纳入仓库。已有 Neovim 配置时，先备份再部署。

## SSH 剪贴板

在 A 的 Ghostty 中 SSH 到 B 并运行 Neovim，配置会根据 `SSH_TTY` 或 `SSH_CONNECTION` 强制使用 OSC 52 provider。`clipboard=unnamedplus` 让普通操作访问 A 的剪贴板：

- `y` / `yy`：复制到 A。
- `d` / `dd` / `x`：剪切到 A。
- `p` / `P`：粘贴 A 的剪贴板。
- `"_d` / `"_dd`：删除时保留剪贴板内容。

仓库的 Ghostty 配置已设置 `clipboard-read = allow`；`clipboard-write` 默认就是 `allow`。A 必须加载这些设置。非 SSH 会话使用 Neovim 的本机剪贴板 provider。

经过 tmux 时，复制到 A 可使用现有 tmux 配置，但 OSC 52 读取可能得到 tmux 缓冲区，而非 A 最新的剪贴板。因此普通 `p` 的跨机器读取不能保证；遇到此情况，在 Neovim 进入插入模式后使用 Ghostty 粘贴快捷键（macOS 为 `Cmd+V`）。

部署后应在实际 A / B 链路分别检查复制、剪切和粘贴；仓库配置本身不代表已完成端到端验证。
