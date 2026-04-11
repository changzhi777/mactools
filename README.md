# MacTools 🛠️

**作者:** 外星动物（常智）
**组织:** [IoTchange](https://github.com/IoTchange)
**邮箱:** 14455975@qq.com
**版本:** V1.0.1
**许可证:** Copyright (C) 2026 IoTchange - All Rights Reserved

---

## 📌 版本信息

**当前版本:** V1.0.1

**版本规则:** V主版本.次版本.修订版本
- 主版本：重大架构变更
- 次版本：功能添加或修改
- 修订版本：Bug修复和小改进（每次推送自动+1）

**快速更新版本号:**
```bash
./version.sh --help
```

详见: [VERSION_MANAGEMENT.md](VERSION_MANAGEMENT.md)

---

## 📦 项目简介

MacTools 是一个面向 macOS 开发者和 AI 用户的工具集，包含本地 AI 环境一键安装、GitHub SSH 配置、UI/UX 设计资源等多个实用工具。

### ✨ 核心功能

- 🤖 **MacClaw Installer** - 一键安装 OpenClaw + oMLX 本地 AI 环境
- 🔐 **GitHub SSH 配置** - 自动配置 SSH 密钥和 Git 环境
- 🎨 **UI/UX Pro Max** - 完整的 UI/UX 设计提示词资源库
- 📚 **开发工具集** - 开发效率提升脚本和配置

---

## 🚀 一键安装 (推荐)

> **⚡ 快速体验 MacClaw AI 环境 - 3 步搞定**

```bash
curl -fsSL https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw-installer/install.sh | bash
```

**就这么简单！** 🎉

**或使用 wget**:
```bash
wget -qO- https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw-installer/install.sh | bash
```

**💡 安装内容**:
- ✅ Node.js + OpenClaw CLI
- ✅ oMLX 推理服务
- ✅ gemma-4 AI 模型
- ✅ Web UI (http://127.0.0.1:18789)

**⏱️ 预计时间**: 15-30 分钟（国内网络）

**📖 详细指南**: [INSTALL_GUIDE.md](INSTALL_GUIDE.md)

---

## ⚡ 一键安装

### 🚀 在线安装 MacClaw（推荐）

```bash
curl -fsSL https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw-installer/install.sh | bash
```

**或使用 wget**:
```bash
wget -qO- https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw-installer/install.sh | bash
```

### 📋 安装内容

- ✅ **Node.js** - JavaScript 运行环境
- ✅ **OpenClaw CLI** - 本地 AI Agent 框架
- ✅ **oMLX** - Apple Silicon 优化推理引擎
- ✅ **gemma-4-e4b-it-4bit** - 本地 AI 模型（约 4GB）
- ✅ **Web UI** - 访问 http://127.0.0.1:18789/

### ⏱️ 预计时间

- 🌐 **国内网络**: 15-20 分钟
- 🌍 **国际网络**: 30-40 分钟

---

## 🚀 快速开始

### 方式 1：克隆仓库

```bash
git clone https://github.com/changzhi777/mactools.git
cd mactools
```

### 方式 2：使用 SSH（推荐）

```bash
git clone git@github.com:changzhi777/mactools.git
cd mactools
```

### 方式 3：本地安装

```bash
cd mactools/macclaw-installer
chmod +x install.sh
./install.sh
```

---

## 🧪 测试验证

项目包含完整的测试套件，**无需任何外部依赖**：

```bash
# 运行所有测试
./tests/run_tests.sh
```

**测试结果**：
- ✅ 38 个测试用例
- ✅ 100% 通过率
- ✅ 执行时间 < 2 秒
- ✅ 零依赖（纯 Shell）

详见: [tests/README.md](tests/README.md)

---

---

## 📦 功能模块

### 1. 🤖 MacClaw Installer - 本地 AI 环境安装器

> **⚡ 一键安装命令**
> ```bash
> curl -fsSL https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw-installer/install.sh | bash
> ```

**功能说明：**

一键安装 OpenClaw（小龙虾）+ oMLX 本地 AI 推理环境，支持：

- ✅ **Node.js** - 通过 nvm 安装最新版本
- ✅ **OpenClaw CLI** - 本地 AI Agent 框架
- ✅ **oMLX** - Apple Silicon 优化的推理引擎
- ✅ **gemma-4-e4b-it-4bit** - 本地 AI 模型（约 4GB）
- ✅ **Agent 管理** - 自动创建和配置 AI 智能体
- ✅ **Skills 支持** - 安装和管理扩展技能包
- 🇨🇳 **国内源优化** - 使用国内镜像，下载速度更快

**使用方法：**

```bash
cd macclaw-installer
chmod +x install.sh
./install.sh
```

**一键安装（在线）：**

```bash
curl -fsSL https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw-installer/install.sh | bash
```

**卸载：**

```bash
cd macclaw-installer
chmod +x uninstall.sh
./uninstall.sh
```

**访问 Web UI：**

安装完成后访问：http://127.0.0.1:18789/

**系统要求：**

- macOS 12+ (Monterey 或更高)
- Apple Silicon (M1/M2/M3) 或 Intel Mac
- 至少 16GB 内存（推荐 24GB+）
- 至少 20GB 可用磁盘空间

**详细文档：** [macclaw-installer/README.md](macclaw-installer/README.md)

---

### 2. GitHub SSH 配置脚本

**功能说明：**

自动化 GitHub SSH 密钥配置流程，包括：

- 🔍 检测现有 SSH 密钥
- 🔑 显示公钥并指导添加到 GitHub
- ⚙️ 自动配置 Git 用户信息
- 🌐 配置 SSH 客户端
- 🧪 测试 GitHub 连接
- 📦 配置仓库使用 SSH

**使用方法：**

```bash
chmod +x setup-github-ssh.sh
./setup-github-ssh.sh
```

**脚本特点：**

- 交互式向导，操作简单
- 自动检测并配置 SSH 环境
- 支持多个 GitHub 仓库配置
- 提供详细的错误提示和解决方案

---

### 3. UI/UX Pro Max 提示词资源

**功能说明：**

完整的 UI/UX 设计提示词资源库，包含：

- 🎨 **67 种设计风格** - 从极简主义到新粗野主义
- 🌈 **96 种配色方案** - 精心挑选的色彩组合
- 🔤 **57 种字体配对** - 专业的排版组合
- 📊 **25 种图表类型** - 数据可视化设计
- 🛠️ **13 种技术栈** - React, Next.js, Vue, Flutter 等

**使用场景：**

- 前端项目 UI 设计指导
- AI 辅助设计和开发
- 设计系统构建参考
- 原型设计和用户界面优化

**资源位置：**

```
.github/prompts/ui-ux-pro-max/
├── PROMPT.md              # 主提示词文件
├── data/
│   ├── styles.csv         # 67 种设计风格
│   ├── colors.csv         # 96 种配色方案
│   ├── typography.csv     # 57 种字体配对
│   ├── charts.csv         # 25 种图表类型
│   └── stacks/            # 13 种技术栈配置
│       ├── nextjs.csv
│       ├── react.csv
│       ├── vue.csv
│       └── ...
└── scripts/               # 数据查询脚本
```

**详细文档：** [.github/prompts/ui-ux-pro-max/PROMPT.md](.github/prompts/ui-ux-pro-max/PROMPT.md)

---

## 🔧 常用操作

### MacClaw CLI 命令

```bash
# Gateway 管理
openclaw gateway status          # 查看状态
openclaw gateway restart         # 重启服务
openclaw gateway logs            # 查看日志

# Agent 管理
openclaw agents list             # 列出所有 Agents
openclaw agents config <name>    # 配置 Agent
openclaw agents use <name>       # 切换 Agent

# Skills 管理
openclaw skills list             # 列出所有 Skills
openclaw skills install <name>   # 安装 Skill

# 推理测试
openclaw infer model run \
  --model omlx/gemma-4-e4b-it-4bit \
  --prompt "你好"
```

### Git 操作

```bash
# 查看状态
git status

# 提交更改
git add .
git commit -m "描述信息"
git push

# 拉取更新
git pull

# 查看日志
git log --oneline -10
```

---

## 📁 项目结构

```
mactools/
├── .github/
│   └── prompts/
│       └── ui-ux-pro-max/       # UI/UX 提示词资源
├── macclaw-installer/           # AI 环境安装器
│   ├── install.sh              # 安装脚本
│   ├── uninstall.sh            # 卸载脚本
│   ├── lib/                    # 核心库
│   ├── config/                 # 配置文件
│   ├── scripts/                # 组件脚本
│   └── docs/                   # 详细文档
├── setup-github-ssh.sh          # SSH 配置脚本
├── GitHub-SSH配置指南.md        # SSH 配置文档
├── README.md                    # 本文件
└── LICENSE                      # 许可证
```

---

## 📚 详细文档

- [MacClaw Installer 完整文档](macclaw-installer/README.md)
- [安装指南](macclaw-installer/docs/INSTALL.md)
- [配置说明](macclaw-installer/docs/CONFIG.md)
- [Agent 使用指南](macclaw-installer/docs/AGENTS.md)
- [Skills 开发指南](macclaw-installer/docs/SKILLS.md)
- [问题排查](macclaw-installer/docs/TROUBLESHOOTING.md)
- [UI/UX Pro Max 提示词](.github/prompts/ui-ux-pro-max/PROMPT.md)
- [GitHub SSH 配置指南](GitHub-SSH配置指南.md)

---

## 🐛 问题排查

### MacClaw 安装问题

1. **安装失败**
   - 检查系统版本：`sw_vers`
   - 查看安装日志：`~/macclaw-install.log`
   - 确认磁盘空间：`df -h`

2. **服务无法启动**
   - 检查端口占用：`lsof -i :18789`
   - 查看服务日志：`tail -f /tmp/openclaw/openclaw-*.log`
   - 重启服务：`openclaw gateway restart`

3. **推理失败**
   - 检查 oMLX 服务：`curl http://127.0.0.1:8008/health`
   - 验证模型加载：检查 oMLX 应用
   - 查看 API Key：`cat ~/.omlx/settings.json`

### SSH 配置问题

1. **连接失败**
   - 测试 SSH 连接：`ssh -T git@github.com`
   - 检查密钥权限：`ls -la ~/.ssh/id_ed25519*`
   - 验证密钥添加：访问 https://github.com/settings/keys

2. **推送被拒绝**
   - 确认远程地址：`git remote -v`
   - 检查分支权限：`git branch -vv`
   - 拉取最新代码：`git pull origin main`

---

## 🤝 贡献

欢迎贡献代码、报告问题或提出建议！

1. Fork 本仓库
2. 创建特性分支：`git checkout -b feature/AmazingFeature`
3. 提交更改：`git commit -m 'Add some AmazingFeature'`
4. 推送分支：`git push origin feature/AmazingFeature`
5. 开启 Pull Request

---

## 📝 版本管理

**版本规则：** 每次推送更新第三位数字 +1

- **当前版本:** V1.0.1
- **版本格式:** V主版本.次版本.修订版本
  - 主版本：重大架构变更
  - 次版本：功能添加或修改
  - 修订版本：Bug 修复和小改进

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

**🦊 享受 macOS 开发和本地 AI 的强大能力！**