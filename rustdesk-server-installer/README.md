# RustDesk Server - Docker 一键安装器

> 在 Debian 服务器上一键部署 RustDesk 中继服务（HBBS + HBBR）

## 📖 项目简介

RustDesk 是一个开源的远程桌面软件，类似于 TeamViewer 和 AnyDesk。本项目提供了一个自动化安装脚本，可以在 Debian 服务器上快速部署 RustDesk 的中继服务节点（ID 服务器 HBBS 和中继服务器 HBBR）。

### ✨ 主要特性

- ✅ **一键部署**：自动化安装流程，无需手动配置
- ✅ **Docker 容器化**：使用 Docker Compose 管理，隔离性好
- ✅ **自动防火墙配置**：支持 UFW、firewalld、iptables
- ✅ **数据持久化**：密钥和配置数据持久保存
- ✅ **健康检查**：内置健康检查和状态监控
- ✅ **完整管理工具**：安装、配置、卸载一应俱全
- ✅ **交互式菜单**：友好的命令行交互界面

## 🎯 适用场景

- 个人自建远程桌面中继服务器
- 企业内网远程访问支持
- 家庭实验室（Homelab）环境
- 需要稳定远程桌面服务的场景

## 📋 系统要求

### 硬件要求

- **CPU**：1 核心或以上
- **内存**：512MB 或以上
- **磁盘**：1GB 可用空间
- **网络**：稳定的网络连接

### 软件要求

- **操作系统**：Debian 11 或更高版本
- **权限**：root 或 sudo 权限
- **Docker**：20.10 或更高版本
- **Docker Compose**：v2 或 v1.29+

### 网络要求

以下端口需要在防火墙中开放：

| 端口 | 协议 | 说明 |
|------|------|------|
| 21114 | TCP | Web 控制台（Pro 版本） |
| 21115 | TCP | NAT 类型测试 |
| 21116 | TCP | ID 注册和 TCP 打洞 |
| 21116 | UDP | 心跳服务 |
| 21117 | TCP | 中继服务 |
| 21118 | TCP | Web 客户端支持（可选） |
| 21119 | TCP | Web 客户端支持（可选） |

## 🚀 快速开始

### 1. 下载安装器

```bash
# 克隆项目或下载脚本
git clone https://github.com/changzhi777/mactools.git
cd mactools/rustdesk-server-installer
```

### 2. 运行安装脚本

```bash
chmod +x install.sh
sudo ./install.sh
```

### 3. 按照提示操作

1. 查看环境检测结果
2. 选择配置方式（默认/自定义）
3. 等待安装完成
4. 记录服务器地址和公钥

### 4. 配置客户端

1. 打开 RustDesk 客户端
2. 点击右上角菜单 → ID 服务器
3. 输入服务器 IP 地址和公钥
4. 保存并重启 RustDesk

## 📁 项目结构

```
rustdesk-server-installer/
├── install.sh              # 主安装脚本
├── uninstall.sh            # 卸载脚本
├── config.sh               # 配置管理脚本
├── status.sh               # 状态检查脚本
├── docker-compose.yml      # Docker Compose 配置
├── .env.example            # 环境变量示例
├── README.md               # 使用文档
└── lib/                    # 功能模块库
    ├── logger.sh           # 日志输出
    ├── utils.sh            # 工具函数
    ├── detector.sh         # 环境检测
    └── firewall.sh         # 防火墙配置
```

## 🔧 管理命令

### 安装服务

```bash
sudo ./install.sh
```

### 查看状态

```bash
./status.sh                 # 交互式菜单
./status.sh health          # 快速健康检查
./status.sh logs            # 查看日志
```

### 管理配置

```bash
./config.sh                 # 配置管理菜单
```

配置管理功能包括：
1. 查看当前配置
2. 编辑配置文件
3. 重新生成密钥对
4. 重启服务
5. 更新 Docker 镜像
6. 查看服务日志

### 卸载服务

```bash
sudo ./uninstall.sh         # 卸载菜单
```

卸载选项：
1. 保留数据，仅删除容器
2. 完全卸载（删除所有数据）

### Docker 命令

```bash
# 查看容器状态
docker ps

# 查看日志
docker logs -f rustdesk-hbbs    # HBBS 日志
docker logs -f rustdesk-hbbr    # HBBR 日志

# 重启服务
docker restart rustdesk-hbbs rustdesk-hbbr

# 停止服务
docker stop rustdesk-hbbs rustdesk-hbbr

# 启动服务
docker start rustdesk-hbbs rustdesk-hbbr
```

## ⚙️ 配置说明

### 环境变量

编辑 `.env` 文件来自定义配置：

```bash
# 复制示例配置
cp .env.example .env

# 编辑配置
nano .env
```

主要配置项：

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `ALWAYS_USE_RELAY` | 强制使用中继（N=自动，Y=强制） | N |
| `KEY_LEN` | 密钥长度 | 32 |
| `PORT_OFFSET` | 端口偏移量 | 0 |
| `DATA_DIR` | 数据目录 | ./data |

### 网络模式

默认使用 `host` 网络模式（Linux 推荐）：

```yaml
network_mode: "host"
```

如需使用桥接网络（非 Linux 或特殊场景），修改 `docker-compose.yml`：

```yaml
ports:
  - "21114:21114"
  - "21115:21115"
  - "21116:21116"
  - "21116:21116/udp"
  - "21117:21117"
  - "21118:21118"
  - "21119:21119"
```

## 🔐 安全建议

1. **使用防火墙**：确保只开放必要的端口
2. **定期更新**：使用 `./config.sh` 更新 Docker 镜像
3. **备份数据**：定期备份 `./data` 目录
4. **监控日志**：使用 `./status.sh logs` 查看异常活动
5. **密钥管理**：妥善保管 `id_ed25519.pub` 公钥

## 🐛 故障排查

### 容器无法启动

```bash
# 查看详细日志
docker logs rustdesk-hbbs
docker logs rustdesk-hbbr

# 检查端口占用
netstat -tulpn | grep -E "21114|21115|21116|21117"

# 重启 Docker 服务
sudo systemctl restart docker
```

### 端口被占用

```bash
# 查看占用进程
sudo lsof -i :21116

# 停止占用进程或修改端口配置
```

### 客户端无法连接

1. **检查防火墙**：确保端口已开放
   ```bash
   sudo ufw status
   ```

2. **检查容器状态**
   ```bash
   ./status.sh health
   ```

3. **验证公钥**：确认客户端使用正确的公钥

4. **网络测试**：从客户端测试服务器连通性
   ```bash
   telnet <服务器IP> 21116
   ```

### 密钥问题

```bash
# 重新生成密钥对
./config.sh
# 选择 3) 重新生成密钥对
```

## 📚 相关资源

- **RustDesk 官网**：https://rustdesk.com/
- **RustDesk 文档**：https://rustdesk.com/docs/
- **Docker 文档**：https://docs.docker.com/
- **项目主页**：https://github.com/changzhi777/mactools

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License

## 👨‍💻 作者

外星动物（常智）
- Email: 14455975@qq.com
- GitHub: [@changzhi777](https://github.com/changzhi777)

## ⚠️ 免责声明

本脚本仅供学习和个人使用。使用本脚本安装的软件和组件请遵守其各自的许可证条款。作者不对本脚本的使用结果承担任何责任。

---

**享受您的 RustDesk 远程桌面服务！** 🎉
