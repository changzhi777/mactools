# MacClaw Installer

**作者:** 外星动物（常智）  
**组织:** [IoTchange](https://github.com/IoTchange)  
**邮箱:** 14455975@qq.com  
**版本:** V1.0.1  
**许可证:** Copyright (C) 2026 IoTchange - All Rights Reserved

---

## 📦 项目简介

MacClaw Installer 是一个一键安装 OpenClaw（小龙虾）+ oMLX 本地 AI 模型的 Shell 脚本，支持 macOS 系统，采用国内源优化下载速度。

### ✨ 主要特性

- 🚀 **一键安装** - 自动安装所有必要组件
- 🇨🇳 **国内源优化** - 使用国内镜像源，下载速度更快
- 🔄 **交互式安装** - 自定义选择安装组件
- 🤖 **Agent 管理** - 自动创建和配置 AI 智能体
- 📦 **Skills 支持** - 安装和管理扩展技能包
- 🗑️ **完整卸载** - 支持完全卸载所有组件

---

## 📋 系统要求

- **操作系统:** macOS 12+ (Monterey 或更高)
- **架构:** Apple Silicon (M1/M2/M3) 或 Intel Mac
- **内存:** 至少 16GB（推荐 24GB+）
- **磁盘空间:** 至少 20GB 可用空间
- **网络:** 稳定的互联网连接

---

## 🚀 快速开始

### 一键安装（推荐）

```bash
curl -fsSL https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw-installer/install.sh | bash
```

### 使用 wget

```bash
wget -qO- https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw-installer/install.sh | bash
```

### 手动安装

```bash
# 克隆仓库
git clone https://github.com/changzhi777/mactools.git
cd macclaw-installer

# 运行安装脚本
chmod +x install.sh
./install.sh
```

---

## 📦 安装组件

安装程序将自动安装以下组件：

### 核心组件
- ✅ **Node.js** (通过 nvm) - JavaScript 运行环境
- ✅ **OpenClaw CLI** - OpenClaw 命令行工具
- ✅ **oMLX** - 本地 AI 推理服务
- ✅ **gemma-4-e4b-it-4bit** - 本地 AI 模型（约 4GB）

### 可选组件
- 🤖 **默认 Agents** - 预配置的 AI 智能体
- 📦 **常用 Skills** - 扩展技能包

---

## 🔧 卸载

### 一键卸载

```bash
curl -fsSL https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw-installer/uninstall.sh | bash
```

### 手动卸载

```bash
git clone https://github.com/changzhi777/mactools.git
cd macclaw-installer
chmod +x uninstall.sh
./uninstall.sh
```

---

## 📖 使用指南

### 访问 Web UI

安装完成后，访问：http://127.0.0.1:18789/

### 常用命令

```bash
# 查看 Gateway 状态
openclaw gateway status

# 重启 Gateway
openclaw gateway restart

# 列出所有 Agents
openclaw agents list

# 测试推理
openclaw infer model run --model omlx/gemma-4-e4b-it-4bit --prompt "你好"

# 查看日志
tail -f /tmp/openclaw/openclaw-*.log
```

### Agent 管理

```bash
# 创建新 Agent
openclaw agents add myagent --workspace ~/.openclaw/workspace-myagent

# 配置 Agent 模型
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

## 📁 项目结构

```
macclaw-installer/
├── install.sh                    # 一键安装脚本
├── uninstall.sh                  # 一键卸载脚本
├── README.md                     # 项目文档
├── VERSION                       # 版本号文件
├── lib/                          # 核心库
│   ├── logger.sh                 # 日志模块
│   ├── detector.sh               # 环境检测
│   ├── config.sh                 # 配置管理
│   ├── agent.sh                  # Agent 管理
│   └── utils.sh                  # 工具函数
├── config/                       # 配置文件
│   ├── sources.conf              # 国内源配置
│   └── versions.conf             # 版本配置
└── scripts/                      # 组件脚本
    ├── install-nodejs.sh         # Node.js 安装
    ├── install-openclaw.sh       # OpenClaw 安装
    ├── install-omlx.sh           # oMLX 安装
    ├── install-model.sh          # 模型下载
    └── install-skills.sh         # Skills 安装
```

---

## 🔐 安全说明

- 本脚本仅安装开源组件
- 所有下载使用 HTTPS 加密
- 不收集任何用户数据
- 完全在本地运行，数据不出本地

---

## 🐛 问题排查

### 安装失败

1. 检查系统版本是否满足要求
2. 确保有足够的磁盘空间
3. 查看安装日志：`~/macclaw-install.log`

### 服务无法启动

1. 检查端口是否被占用：`lsof -i :18789`
2. 查看服务日志：`/tmp/openclaw/openclaw-*.log`
3. 重启服务：`openclaw gateway restart`

### 推理失败

1. 检查 oMLX 服务状态：`curl http://127.0.0.1:8008/health`
2. 验证模型是否加载：检查 oMLX 应用
3. 查看 API Key 配置：`~/.omlx/settings.json`

---

## 📚 更多文档

- [安装指南](docs/INSTALL.md)
- [配置说明](docs/CONFIG.md)
- [Agent 使用指南](docs/AGENTS.md)
- [Skills 开发指南](docs/SKILLS.md)
- [问题排查](docs/TROUBLESHOOTING.md)

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

---

## 📝 版本管理

**版本规则：** 每次推送更新第三位数字+1

- **当前版本:** V1.0.1
- **版本格式:** V主版本.次版本.修订版本
  - 主版本：重大架构变更
  - 次版本：功能添加或修改
  - 修订版本：Bug修复和小改进

---

## 📞 联系方式

**作者:** 外星动物（常智）  
**组织:** IoTchange  
**邮箱:** 14455975@qq.com  
**项目:** https://github.com/changzhi777/mactools  
**问题反馈:** https://github.com/changzhi777/mactools/issues

---

## ⚖️ 许可证

Copyright (C) 2026 IoTchange - All Rights Reserved

---

## 🙏 致谢

感谢以下开源项目：

- [OpenClaw](https://github.com/openclaw-dev/openclaw) - 本地 AI Agent 框架
- [oMLX](https://github.com/jundot/omlx) - Apple Silicon 优化推理引擎
- [ModelScope](https://github.com/modelscope/modelscope) - 模型社区
- [nvm](https://github.com/nvm-sh/nvm) - Node.js 版本管理器

---

**🦞 享受本地 AI 的强大能力！**
