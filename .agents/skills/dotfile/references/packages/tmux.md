# tmux 说明

## Pi 扩展键

`~/.tmux.conf` 设置了 `extended-keys on` 和 `extended-keys-format csi-u`，让 Pi 能区分 `Enter` / `Shift+Enter` / `Ctrl+Enter` / `Alt+Enter`。

**`extended-keys-format csi-u` 需要 tmux 3.5 或更高版本。**

如果低于 3.5，请升级 tmux。

## 重载 / 重启

tmux 只在服务器启动时读取 `~/.tmux.conf`。要生效需完全重启：

```zsh
tmux kill-server
tmux
```

不杀掉其它会话的轻量重载：

```zsh
tmux source-file ~/.tmux.conf
```

## TERM

仓库依赖 `xterm-ghostty`（`default-terminal "tmux-256color"`，`terminal-features` / `terminal-overrides` 也以 `xterm-ghostty` 为键）。它期望终端支持 Kitty 键盘协议 / 扩展键（Ghostty、Kitty、WezTerm、iTerm2、Alacritty）。
