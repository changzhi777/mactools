# Hermes Agent 本地安装器

[![License](https://img.shields.io/badge/license-Proprietary-red.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/NousResearch/hermes-agent)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey.svg)](https://github.com/NousResearch/hermes-agent)

---

## 📋 简介

**Hermes Agent** 是由 [Nous Research](https://nousresearch.com/) 开发的开源 AI Agent 系统。本项目提供了优化的本地安装脚本，支持在 macOS、Linux 和 WSL2 环境中快速安装和配置 Hermes Agent。

### ✨ 特性

- ✅ **一键安装** - 自动化安装流程，无需手动配置
- ✅ **智能检测** - 自动检测系统环境和依赖
- ✅ **uv 包管理** - 使用现代 uv 包管理器，快速安装依赖
- ✅ **多平台支持** - 支持 macOS、Linux、WSL2/Termux
- ✅ **交互式向导** - 友好的配置向导，简化配置流程
- ✅ **完整验证** - 安装后自动验证功能是否正常
- ✅ **中文界面** - 完整的中文支持和友好提示

---

## 📦 系统要求

### 最低要求

- **操作系统**：
  - macOS 12+ (Monterey 或更高版本)
  - Linux (主流发行版：Ubuntu, Debian, Fedora, CentOS, Arch 等)
  - WSL2 (Windows Subsystem for Linux 2)
  - Termux (Android)

- **Python**：3.11 或更高版本
- **Git**：用于克隆仓库
- **磁盘空间**：至少 500MB 可用空间

### 推荐配置

- **内存**：4GB RAM 或更高
- **CPU**：2 核心或更高
- **网络**：稳定的互联网连接

### 可选依赖

- **Node.js** 22+ (用于浏览器工具功能)

---

## 🚀 快速开始

### 方法 1：使用官方安装脚本（推荐）

```bash
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
```

### 方法 2：使用本地安装脚本

```bash
# 1. 克隆本仓库或下载安装脚本
git clone https://github.com/your-repo/mactools.git
cd mactools/tools/hermes-agent-local

# 2. 运行安装脚本
bash install.sh
```

### 方法 3：自定义安装

```bash
# 安装指定分支
bash install.sh --branch develop

# 安装到自定义目录
bash install.sh --dir ~/custom/path/hermes-agent

# 跳过配置向导
bash install.sh --skip-setup

# 详细输出
bash install.sh --verbose
```

---

## 📖 详细说明

### 安装选项

| 选项 | 说明 |
|------|------|
| `--no-venv` | 不创建虚拟环境（使用系统 Python） |
| `--skip-setup` | 跳过交互式配置向导 |
| `--skip-deps` | 跳过依赖检查（不推荐） |
| `--branch NAME` | 指定 Git 分支（默认：main） |
| `--dir PATH` | 指定安装目录（默认：~/.hermes/hermes-agent） |
| `--verbose` | 显示详细输出 |
| `-h, --help` | 显示帮助信息 |

### 安装目录结构

```
~/.hermes/
├── hermes-agent/          # 安装目录
│   ├── .venv/             # Python 虚拟环境
│   ├── config/            # 配置文件
│   ├── data/              # 数据文件
│   └── ...                # 其他项目文件
├── config/                # 全局配置目录
│   ├── SOUL.md            # Persona 配置
│   ├── MEMORY.md          # 记忆配置
│   └── AGENTS.md          # 项目上下文
└── data/                  # 数据存储
```

---

## 🔧 验证安装

### 使用验证脚本

```bash
# 完整验证
bash verify.sh

# 仅验证环境
bash verify.sh env

# 仅验证安装
bash verify.sh install

# 仅验证功能
bash verify.sh function
```

### 手动验证

```bash
# 检查版本
hermes --version

# 查看帮助
hermes --help

# 启动交互式界面
hermes
```

---

## 🗑️ 卸载

### 标准卸载

```bash
bash uninstall.sh
```

### 保留配置文件卸载

```bash
bash uninstall.sh --keep-config
```

### 保留数据文件卸载

```bash
bash uninstall.sh --keep-data
```

### 强制卸载（不询问确认）

```bash
bash uninstall.sh --force
```

---

## 📚 使用指南

### 首次使用

1. **重新加载 Shell 配置**

   ```bash
   # Bash 用户
   source ~/.bashrc

   # Zsh 用户
   source ~/.zshrc
   ```

2. **验证安装**

   ```bash
   hermes --version
   ```

3. **启动配置向导**（如果安装时跳过）

   ```bash
   hermes setup
   ```

4. **启动 Hermes Agent**

   ```bash
   hermes
   ```

### 常用命令

```bash
# 查看帮助
hermes --help

# 查看所有帮助
hermes --help-all

# 查看版本
hermes --version

# 启动交互式界面
hermes

# 运行配置向导
hermes setup
```

---

## 🛠️ 故障排查

### 问题 1：Python 版本过低

**症状**：提示 "Python 版本过低"

**解决方案**：

```bash
# macOS
brew install python@3.12

# Ubuntu/Debian
sudo apt update
sudo apt install python3.12

# CentOS/RHEL
sudo yum install python3.12
```

### 问题 2：uv 包管理器安装失败

**症状**：提示 "uv 安装失败"

**解决方案**：

```bash
# 手动安装 uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# 添加到 PATH
export PATH="$HOME/.local/bin:$PATH"
```

### 问题 3：hermes 命令不可用

**症状**：运行 `hermes` 提示 "command not found"

**解决方案**：

```bash
# 检查符号链接
ls -la ~/.local/bin/hermes

# 检查 PATH
echo $PATH | grep ~/.local/bin

# 如果不在 PATH 中，添加到 shell 配置
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### 问题 4：Git 克隆失败

**症状**：提示 "仓库克隆失败"

**解决方案**：

```bash
# 检查网络连接
ping github.com

# 使用代理（如果需要）
export https_proxy=http://127.0.0.1:7890
bash install.sh
```

### 问题 5：权限不足

**症状**：提示 "权限不足"

**解决方案**：

```bash
# 确保有写入权限
mkdir -p ~/.hermes
chmod 755 ~/.hermes

# 确保符号链接可执行
chmod +x ~/.local/bin/hermes
```

---

## 🔐 配置文件

### SOUL.md

定义 Agent 的 persona 和行为特征：

```markdown
# 你的 Persona

你是一个有用的 AI 助手...
```

### MEMORY.md

定义 Agent 的记忆和上下文：

```markdown
# 项目上下文

这是我的项目...
```

### AGENTS.md

定义项目相关的 Agent 信息：

```markdown
# Agent 配置

项目使用的技术栈...
```

---

## 📝 更新日志

查看 [CHANGELOG.md](CHANGELOG.md) 了解版本更新历史。

---

## 🤝 贡献

欢迎贡献！请访问：

- **GitHub**：https://github.com/NousResearch/hermes-agent
- **问题反馈**：https://github.com/NousResearch/hermes-agent/issues

---

## 📄 许可证

**作者**: 外星动物（常智）
**组织**: IoTchange
**邮箱**: 14455975@qq.com
**版权**: Copyright (C) 2026 IoTchange - All Rights Reserved

本项目为专有软件，保留所有权利。

---

## 🔗 相关链接

- **Hermes Agent 官方仓库**: https://github.com/NousResearch/hermes-agent
- **Nous Research**: https://nousresearch.com/
- **uv 包管理器**: https://docs.astral.sh/uv/
- **Python 官方网站**: https://www.python.org/

---

## 📞 支持

如有问题或建议，请联系：

- **邮箱**: 14455975@qq.com
- **GitHub Issues**: https://github.com/NousResearch/hermes-agent/issues

---

**Happy Hacking! 🚀**
