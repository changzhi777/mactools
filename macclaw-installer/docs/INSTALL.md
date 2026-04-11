# MacClaw Installer - 安装指南

**版本:** V1.0.1  
**作者:** 外星动物（常智）

---

## 📋 系统要求

### 必要要求
- **操作系统:** macOS 12+ (Monterey 或更高)
- **架构:** Apple Silicon (M1/M2/M3) 或 Intel Mac
- **内存:** 至少 16GB（推荐 24GB+）
- **磁盘空间:** 至少 20GB 可用空间
- **网络:** 稳定的互联网连接

### 可选要求
- Xcode Command Line Tools（将自动安装）
- Python 3.9+（系统自带或通过 Homebrew 安装）

---

## 🚀 安装方法

### 方法 1: 一键安装（推荐）

```bash
curl -fsSL https://raw.githubusercontent.com/IoTchange/macclaw-installer/main/install.sh | bash
```

### 方法 2: 使用 wget

```bash
wget -qO- https://raw.githubusercontent.com/IoTchange/macclaw-installer/main/install.sh | bash
```

### 方法 3: 手动安装

```bash
# 1. 克隆仓库
git clone https://github.com/IoTchange/macclaw-installer.git
cd macclaw-installer

# 2. 运行安装脚本
chmod +x install.sh
./install.sh
```

---

## 📦 安装流程

### 1. 欢迎界面

```
╔════════════════════════════════════════════════════════════╗
║              🦞 MacClaw 一键安装器 V1.0.1                   ║
║       OpenClaw + oMLX 本地 AI 模型完整安装                  ║
╚════════════════════════════════════════════════════════════╝
```

### 2. 环境检测

自动检测：
- macOS 版本
- CPU 架构
- 内存大小
- 磁盘空间
- Xcode Command Line Tools
- 网络连接

### 3. 组件选择

交互式选择要安装的组件：
- Node.js (通过 nvm)
- OpenClaw CLI
- oMLX 服务
- gemma-4-e4b-it-4bit 模型
- 创建默认 Agent
- 安装常用 Skills

### 4. 配置国内源

自动配置以下国内镜像：
- npm: 淘宝镜像
- pip: 清华大学镜像
- ModelScope: Hugging Face 镜像

### 5. 安装组件

按顺序安装所有选中的组件，显示实时进度。

### 6. 配置集成

自动配置：
- OpenClaw 配置文件
- oMLX API Key
- Agent 工作空间
- Skills 绑定

### 7. 验证测试

自动测试：
- 服务状态
- 推理功能
- Agent 功能

---

## ✅ 安装完成后

### 访问 Web UI

安装完成后，浏览器将自动打开：
```
http://127.0.0.1:18789/
```

### 验证安装

在终端运行：
```bash
# 检查服务状态
openclaw gateway status

# 测试推理
openclaw infer model run --model omlx/gemma-4-e4b-it-4bit --prompt "你好"

# 查看 Agent 列表
openclaw agents list
```

---

## 🔧 常见问题

### Q1: 安装失败怎么办？

1. 查看安装日志：`cat ~/macclaw-install.log`
2. 检查系统版本是否满足要求
3. 确保有足够的磁盘空间
4. 检查网络连接是否正常

### Q2: Xcode Tools 安装卡住？

安装过程中，系统会弹出安装窗口：
1. 点击"安装"按钮
2. 等待安装完成（可能需要几分钟）
3. 安装完成后继续

### Q3: 模型下载失败？

1. 检查网络连接
2. 确认 ModelScope 镜像配置正确
3. 重新运行安装脚本
4. 或手动下载：`modelscope download --model mlx-community/gemma-4-eb-it-4bit`

### Q4: 端口被占用？

检查端口占用：
```bash
# 检查 OpenClaw 端口 (18789)
lsof -i :18789

# 检查 oMLX 端口 (8008)
lsof -i :8008
```

### Q5: 服务无法启动？

1. 查看服务日志：`tail -f /tmp/openclaw/openclaw-*.log`
2. 重启服务：`openclaw gateway restart`
3. 检查配置文件：`~/.openclaw/openclaw.json`

---

## 🗑️ 卸载

### 一键卸载

```bash
curl -fsSL https://raw.githubusercontent.com/IoTchange/macclaw-installer/main/uninstall.sh | bash
```

### 手动卸载

```bash
cd macclaw-installer
chmod +x uninstall.sh
./uninstall.sh
```

---

## 📞 获取帮助

- **项目地址:** https://github.com/IoTchange/macclaw-installer
- **问题反馈:** https://github.com/IoTchange/macclaw-installer/issues
- **邮箱:** 14455975@qq.com

---

**🦞 享受本地 AI 的强大能力！**
