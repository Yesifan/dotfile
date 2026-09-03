# Ghostty 说明

> **范围：** 本文件说明仓库里 `~/.config/ghostty/config` 的行为与平台要点。在 macOS 和 Linux 间共享。

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
