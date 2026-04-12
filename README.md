# MacClaw Install 🦞

**一键安装 OpenClaw + oMLX 本地 AI 环境**

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-green.svg)](CHANGELOG.md)
[![macOS](https://img.shields.io/badge/macOS-12%2B-blue.svg)](https://www.apple.com/macos/)

---

## ⚡ 一键安装（推荐）

```bash
curl -fsSL https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw_install/install.zsh | zsh
```

**或使用 wget：**
```bash
wget -qO- https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw_install/install.zsh | zsh
```

**🎯 这一条命令即可完成：**
- ✅ Homebrew（包管理器）
- ✅ Node.js 20.x LTS
- ✅ OpenClaw CLI
- ✅ oMLX 推理引擎（Apple Silicon）
- ✅ gemma-4-e4b-it-4bit AI 模型（约 4GB）
- ✅ 开发者工具、编程助手插件

**⏱️ 预计时间：** 15-30 分钟（国内网络）

---

## 📖 项目简介

MacClaw Install 是一个专为 macOS 设计的一键安装工具，用于快速搭建 OpenClaw 本地 AI 开发环境。

### ✨ 核心特性

- 🚀 **一键安装** - 自动安装所有必要组件
- 🇨🇳 **国内源优化** - 使用国内镜像源，下载速度更快
- 🔄 **模块化设计** - 支持4个独立部分，灵活可控
- 🤖 **AI 算力支持** - 自动配置 oMLX（Apple Silicon）
- 📦 **插件管理** - 自动安装推荐插件
- 🗑️ **完整卸载** - 支持完全卸载所有组件

### 🎯 适用场景

- 本地 AI 开发和测试
- OpenClaw Agent 开发
- 本地大语言模型部署
- AI 应用原型开发

---

## 📋 系统要求

- **操作系统**: macOS 12 或更高版本（兼容模式支持更低版本）
- **架构**: Apple Silicon (M1/M2/M3) 或 Intel Mac
- **内存**: 至少 16GB（推荐 24GB+）
- **磁盘**: 至少 20GB 可用空间

---

## 🔧 其他安装方式

### 手动安装

- **操作系统**: macOS 12 或更高版本（兼容模式支持更低版本）
- **架构**: Apple Silicon (M1/M2/M3) 或 Intel Mac
- **内存**: 至少 16GB（推荐 24GB+）
- **磁盘**: 至少 20GB 可用空间

### 一键安装

```bash
# 下载并执行
curl -fsSL https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw_install/install.zsh | zsh

# 或使用 wget
wget -qO- https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw_install/install.zsh | zsh
```

### 手动安装

```bash
# 克隆仓库
git clone https://github.com/changzhi777/mactools.git
cd mactools/macclaw_install

# 运行安装脚本
chmod +x install.zsh
./install.zsh
```

### 安装模式说明

**交互式安装**（默认）：
```bash
./install.zsh
```

**自动安装**（无交互）：
```bash
./install.zsh --auto
```

**静默安装**（最小输出）：
```bash
./install.zsh --silent
```

---

## 📦 安装内容

### 核心组件

- ✅ **Homebrew** - macOS 包管理器
- ✅ **Node.js 20.x LTS** - JavaScript 运行环境
- ✅ **OpenClaw CLI** - 本地 AI Agent 框架
- ✅ **oMLX** - Apple Silicon 优化推理引擎
- ✅ **gemma-4-e4b-it-4bit** - 本地 AI 模型（约 4GB）

### 默认插件

- 🤖 **@iotchange/skill-developer** - 开发者工具技能
- 💻 **@iotchange/skill-coder** - 编程助手技能

---

## 📂 项目结构

```
macclaw_install/
├── README.md                   # 本文件
├── INSTALL_GUIDE.md            # 详细安装指南
├── CHANGELOG.md                # 更新日志
├── install.zsh                 # 主入口脚本
├── uninstall.zsh               # 卸载脚本
├── lib/                        # 核心库
│   ├── core/
│   │   ├── logger.zsh          # 日志模块
│   │   ├── detector.zsh        # 环境检测
│   │   ├── validator.zsh       # 验证模块
│   │   └── utils.zsh           # 工具函数
│   ├── parts/
│   │   ├── part1_env.zsh       # 第1部分：环境配置
│   │   ├── part2_compute.zsh   # 第2部分：算力配置
│   │   ├── part3_openclaw.zsh  # 第3部分：OpenClaw安装
│   │   └── part4_test_plugins.zsh # 第4部分：测试+插件
│   └── sources/
│       ├── homebrew.zsh        # Homebrew 国内源
│       ├── nodejs.zsh          # Node.js 国内源
│       └── openclaw.zsh        # OpenClaw 国内源
├── config/                     # 配置文件
│   ├── sources.conf            # 镜像源配置
│   ├── versions.conf           # 版本配置
│   ├── plugins.conf            # 插件列表
│   └── compute.conf            # 算力配置
├── scripts/                    # 辅助脚本
│   ├── detect-compute.zsh      # 算力检测
│   ├── install-brew.zsh        # Homebrew 安装
│   └── backup-env.zsh          # 环境备份
├── tests/                      # 测试脚本
│   ├── test_part1.zsh
│   ├── test_part2.zsh
│   ├── test_part3.zsh
│   └── test_part4.zsh
└── docs/                       # 详细文档
    ├── ARCHITECTURE.md          # 架构设计
    ├── TROUBLESHOOTING.md       # 故障排除
    └── DEVELOPMENT.md           # 开发指南
```

---

## 🎮 使用方法

### OpenClaw 基本命令

```bash
# 查看版本
openclaw --version

# 查看系统信息
openclaw system info

# 测试推理
openclaw infer model run --model omlx/gemma-4-e4b-it-4bit --prompt "你好"

# 查看帮助
openclaw --help
```

### Agent 管理

```bash
# 列出所有 Agents
openclaw agents list

# 创建新 Agent
openclaw agents add myagent --workspace ~/.openclaw/workspace-myagent

# 配置 Agent
openclaw agents config myagent --model omlx/gemma-4-e4b-it-4bit

# 切换 Agent
openclaw agents use myagent
```

### Skills 管理

```bash
# 列出已安装 Skills
openclaw skills list

# 安装新 Skill
openclaw skills install <skill-name>

# 为 Agent 配置 Skill
openclaw agents skills attach myagent <skill-name>
```

---

## 🔧 高级选项

### 仅安装特定部分

```bash
./install.zsh
# 选择 "4) 高级选项"
# 然后选择要安装的部分
```

### 自定义配置

编辑配置文件：
```bash
# 镜像源配置
vim config/sources.conf

# 版本配置
vim config/versions.conf

# 插件列表
vim config/plugins.conf
```

### 查看日志

```bash
# 查看安装日志
cat ~/macclaw_install.log

# 或在主菜单选择 "5) 查看日志"
```

---

## 🗑️ 卸载

### 完全卸载

```bash
cd macclaw_install
chmod +x uninstall.zsh
./uninstall.zsh
```

这将卸载：
- OpenClaw CLI
- Node.js 和 nvm
- Homebrew
- 所有配置文件
- 所有插件和模型

---

## 🐛 问题排查

### 安装失败

1. 检查系统版本：`sw_vers`
2. 查看安装日志：`cat ~/macclaw_install.log`
3. 确认磁盘空间：`df -h /`
4. 检查网络连接

### 服务无法启动

1. 检查端口占用：`lsof -i :18789`
2. 查看服务日志：`tail -f /tmp/openclaw/openclaw-*.log`
3. 重启服务：`openclaw gateway restart`

### 推理失败

1. 检查 oMLX 服务：`curl http://127.0.0.1:8008/health`
2. 验证模型加载：检查 oMLX 应用
3. 查看 API Key：`cat ~/.omlx/settings.json`

更多问题请查看：[TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

---

## 📚 文档

- [安装指南](INSTALL_GUIDE.md) - 详细安装说明
- [架构设计](docs/ARCHITECTURE.md) - 系统架构说明
- [故障排除](docs/TROUBLESHOOTING.md) - 常见问题解决
- [开发指南](docs/DEVELOPMENT.md) - 开发者文档
- [更新日志](CHANGELOG.md) - 版本更新记录

---

## 🤝 贡献

欢迎贡献代码、报告问题或提出建议！

1. Fork 本仓库
2. 创建特性分支：`git checkout -b feature/AmazingFeature`
3. 提交更改：`git commit -m 'Add some AmazingFeature'`
4. 推送到分支：`git push origin feature/AmazingFeature`
5. 开启 Pull Request

---

## 📞 联系方式

**作者**: 外星动物（常智）
**组织**: [IoTchange](https://github.com/IoTchange)
**邮箱**: 14455975@qq.com
**项目**: https://github.com/changzhi777/mactools
**问题反馈**: https://github.com/changzhi777/mactools/issues

---

## ⚖️ 许可证

Copyright (C) 2026 IoTchange - All Rights Reserved

---

## 🙏 致谢

感谢以下开源项目：

- [OpenClaw](https://github.com/openclaw-dev/openclaw) - 本地 AI Agent 框架
- [oMLX](https://github.com/jundot/omlx) - Apple Silicon 优化推理引擎
- [ModelScope](https://modelscope.cn) - 模型社区
- [Homebrew](https://brew.sh) - macOS 包管理器
- [nvm](https://github.com/nvm-sh/nvm) - Node.js 版本管理器

---

**🦞 享受本地 AI 的强大能力！**
