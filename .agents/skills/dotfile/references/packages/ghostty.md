# Ghostty 说明

Ghostty 和 Nerd Font 仅安装在运行图形终端的客户端，并在 Ghostty 中选用该字体。无 UI 的 SSH 服务器不需要安装 Ghostty 或 Nerd Font；同步配置文件不等于需要安装客户端软件。

> **范围：** 本文件说明仓库里 `~/.config/ghostty/config` 的行为与平台要点。在 macOS 和 Linux 间共享。

## SSH 服务器需要 terminfo，不能省略兼容性检查

**服务器不需要 Ghostty 图形程序或字体，但需要与会话 `$TERM` 对应的 terminfo 终端描述。** Ghostty 常使用 `xterm-ghostty`；服务器没有该条目时，可能出现终端类型未知、Zsh 光标移动或重绘异常，以及看起来像重复输入的字符。这与中文字体是否安装无关。

初次安装和更新后，都应在真实 SSH 会话中检查；先在 tmux 外验证，避免 `$TERM=tmux-256color` 掩盖外层终端缺项：

```sh
printf '%s\n' "$TERM"
infocmp -x "$TERM" >/dev/null
tput -T "$TERM" cup 0 0 >/dev/null
tput -T "$TERM" el >/dev/null
```

以上命令应成功退出。使用 tmux 时，还应确认 `infocmp -x tmux-256color` 成功。`dotfile-doctor` 会检查当前终端描述、光标定位和清除行能力；在 tmux 中还会尝试检查当前客户端的终端类型。`TERM` 为空或 `dumb` 时只能提示未验证，不能据此宣称 SSH 交互正常。

仓库已设置 `shell-integration-features = ssh-env,ssh-terminfo`，但自动处理取决于实际使用的 Ghostty SSH 入口及集成是否生效，不能代替上述验证。

### 缺失时的修复

先向用户说明缺少的终端描述、安装位置和命令，按 [依赖同意规则](../dependencies.md) 取得同意。客户端需要 `infocmp`，服务器需要 `tic`；缺少这些命令时也应先确认对应 ncurses 工具的安装计划。

在 **客户端 A 的 Ghostty 终端**执行以下命令，将 `your-server` 替换为实际的 SSH 主机名、`user@hostname` 或 SSH 配置中的主机别名：

```sh
infocmp -x xterm-ghostty | ssh your-server 'mkdir -p "$HOME/.terminfo" && tic -x -o "$HOME/.terminfo" -'
```

此命令只在服务器当前用户的 `~/.terminfo` 中安装终端描述，不安装 Ghostty 图形程序、不需要 sudo。该目录是机器本地产物，不加入 dotfiles。系统软件包已经提供对应描述时，无需重复安装。老版本 macOS 自带的 `infocmp` 若不能正确导出，按 [Ghostty 官方说明](https://ghostty.org/docs/help/terminfo) 使用较新的 ncurses 工具。

安装后，在服务器确认：

```sh
infocmp -x xterm-ghostty >/dev/null
tput -T xterm-ghostty cup 0 0 >/dev/null
tput -T xterm-ghostty el >/dev/null
```

随后关闭异常 SSH 会话并重新连接，再检查输入、方向键、退格和重绘。若复用了 tmux 中原来的异常 Shell，可新建 pane 或在该 Shell 中运行 `exec zsh -l`。命令检查通过只证明能力可读取，实际按键效果仍需用户确认。

不要通过在共享 `.zshrc` 中强制设置 `TERM=xterm-256color` 来掩盖缺失；那会丢失真实终端能力，并可能破坏 tmux 的终端类型。

依据：[Ghostty terminfo 兼容性说明](https://ghostty.org/docs/help/terminfo)、[Ghostty SSH 集成及适用条件](https://ghostty.org/docs/features/ssh)、[ncurses tic 的输出目录选项](https://invisible-island.net/ncurses/man/tic.1m.html)。

## 配置路径与平台优先级

仓库跟踪 `~/.config/ghostty/config`。Ghostty 会按平台从不同位置加载配置，**后加载的覆盖先加载的**：

| 平台        | 加载顺序                                                                                                                                        |
| ----------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| Linux / BSD | `$XDG_CONFIG_HOME/ghostty/config`（默认 `~/.config/ghostty/config`）                                                                            |
| macOS       | `$XDG_CONFIG_HOME/ghostty/config` **再**读 `~/Library/Application Support/com.mitchellh.ghostty/config` —— Application Support 里的文件**胜出** |

因此 Linux 上仓库的 `config` 会被直接读取。macOS 上，若 `~/Library/Application Support/com.mitchellh.ghostty/config` 存在，它会覆盖仓库的配置。

要让仓库的 `config` 在 macOS 上生效，要么删掉那个 Application Support 文件，要么把它软链到仓库的文件：

```zsh
mkdir -p ~/Library/Application\ Support/com.mitchellh.ghostty
ln -sf ~/.config/ghostty/config ~/Library/Application\ Support/com.mitchellh.ghostty/config
```

## 验证

```zsh
ghostty +show-config
```

打印生效的配置。如果仓库里的非默认项出现（如 theme、font-size、keybind），说明配置已被加载。`+show-config` 目前不会打印加载的文件路径。
