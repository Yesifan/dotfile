# Fail2ban 推荐配置

Fail2ban 推荐用于向网络开放 SSH 的 Linux 服务器：根据认证失败日志临时封禁来源 IP。它是可选的系统服务，不是每台 dotfiles 机器的必装依赖，也不替代 SSH 密钥认证或服务端访问控制。

本仓库只提供配置说明。实际配置由管理员保存在服务器的 `/etc/fail2ban/`，不会随 `$HOME` 的 dotfiles checkout 自动部署；安装使用发行版包管理器。

## 安装

下面以 **Debian / Ubuntu、systemd、SSH 日志写入 journal** 为例：

```sh
sudo apt update
sudo apt install fail2ban python3-systemd
```

其他发行版使用其维护的 Fail2ban 软件包，并确认 systemd journal 的 Python 支持可用。

## SSH jail

创建 `/etc/fail2ban/jail.d/sshd.local`，只覆盖需要调整的选项，保留发行版提供的 `jail.conf` 和过滤器：

```ini
[sshd]
enabled = true
backend = systemd
port = ssh
mode = normal
maxretry = 5
findtime = 10m
bantime = 1h
```

这是一组建议起点：同一来源 IP 在 10 分钟内累计 5 次被过滤器计入的失败后，封禁 1 小时。先使用 `normal` 模式，根据实际日志再调整阈值。

- SSH 使用非标准端口时，将 `port` 改为实际端口，例如 `2222`；多个监听端口可写 `22,2222`。这项指定封禁的端口，不会修改 sshd 的监听设置。
- `backend = systemd` 读取 journal，**不要为它添加 `logpath`**。如果服务器只写日志文件，应改用合适的文件后端，并指定实际日志路径，不能直接照搬这份示例。
- 默认继承发行版的封禁动作，不强制指定 iptables、nftables 或 firewalld；部署时确认所选动作与机器的防火墙匹配。
- 有固定管理出口 IP 时，可在此 jail 的 `ignoreip` 中保留 `127.0.0.1/8 ::1` 并追加可信的管理地址。真实地址属于机器本地配置，不加入共享文档；动态出口不宜设置宽泛网段白名单。

## 启用与验证

首次配置时保留现有 SSH 会话，再从另一会话检查正常登录。

```sh
sudo fail2ban-client -t
sudo systemctl enable --now fail2ban
sudo systemctl restart fail2ban
sudo fail2ban-client status sshd
sudo fail2ban-client get sshd journalmatch
```

`-t` 成功后再启用或重启服务。`status sshd` 应能看到已启用的 jail、失败计数和封禁信息。检查 SSH 日志是否实际进入 journal，以及 Fail2ban 是否有过滤器或防火墙动作报错：

```sh
sudo journalctl -u ssh.service -u sshd.service --since '1 hour ago'
sudo journalctl -u fail2ban --since '10 minutes ago'
```

发行版若将 Fail2ban 日志写入文件，也检查 `/var/log/fail2ban.log`。服务显示 `active` 不代表过滤器已经匹配到 SSH 失败日志；应结合服务器已有失败记录与 jail 计数核对。日志正常但计数不增长时，检查 `journalmatch` 与实际 SSH 日志字段是否一致。

解除某个来源 IP 的封禁（将示例地址替换为实际地址）：

```sh
sudo fail2ban-client set sshd unbanip 203.0.113.10
```

## 依据

- [Fail2ban 官方配置指南](https://github.com/fail2ban/fail2ban/wiki/Proper-fail2ban-configuration)：使用 `.local` 文件维护覆盖配置。
- [官方 jail 配置手册](https://github.com/fail2ban/fail2ban/blob/master/man/jail.conf.5)：阈值、日志后端、白名单和动作选项。
- [官方 SSH 过滤器](https://github.com/fail2ban/fail2ban/blob/master/config/filter.d/sshd.conf)：`normal` 模式和 journal 匹配规则。
- [官方客户端手册](https://github.com/fail2ban/fail2ban/blob/master/man/fail2ban-client.1)：配置测试、状态查询和解除封禁。
