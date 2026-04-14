# MacClaw Install 🦞

**一键安装 OpenClaw + 智能双模型配置（智谱AI + 本地模型） + BB小子智能助手**

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-2.1.0-green.svg)](CHANGELOG.md)
[![macOS](https://img.shields.io/badge/macOS-12%2B-blue.svg)](https://www.apple.com/macosx/)
[![Tests](https://img.shields.io/badge/tests-26%2F26%20passing-brightgreen.svg)](TEST_REPORT.md)
[![Dual Model](https://img.shields.io/badge/models-zhipuai%20AI%20%2B%20omlx-orange.svg)](README.md#智能双模型配置)

---

## 🥋 BB小子 Agent - 李小龙风格智能助手

**BB小子** 是一个基于 OpenClaw 框架的本地 AI 助手，采用**李小龙风格**设计：

- ✨ **简洁直接** - 不说废话，直奔主题
- 💪 **行动导向** - "知道不够，必须做到"
- 🧠 **哲学融入** - 功夫智慧融入日常对话
- ⏰ **时间感知** - 智能健康提醒系统

### 核心功能

- 📰 **Hacker News 实时新闻** - 科技动态 + 李小龙健康提醒
- 📅 **macOS 提醒事项** - AppleScript 自动化 + 功夫精神指导
- 💧 **智能健康提醒** - 根据时间和工作日提供喝水、运动、休息提醒
- 🤖 **企业级工具链** - 依赖管理、路径处理、完整测试框架

---

## ⚡ 一键安装（推荐）

### 快速安装命令

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
- ✅ OpenClaw CLI（本地 AI 框架）
- ✅ oMLX 推理引擎（Apple Silicon）
- ✅ **BB小子 Agent**（李小龙风格智能助手）
- ✅ gemma-4-e4b-it-4bit AI 模型（约 4GB）
- ✅ 开发者工具、编程助手插件

**⏱️ 预计时间：** 15-30 分钟（国内网络）

---

## 📖 项目简介

MacClaw Install 是一个专为 macOS 设计的一键安装工具，用于快速搭建 OpenClaw 本地 AI 开发环境，并预配置**BB小子 Agent**（李小龙风格）。

### ✨ 核心特性

- 🧠 **智能双模型配置** - 智谱AI云端（快6-10倍）+ 本地模型（高可用）
- 🔄 **自动降级机制** - API故障时自动切换到本地，无感知
- 👁️ **视觉理解能力** - GLM-5V-Turbo 支持图像分析和OCR
- 🚀 **一键安装** - 自动安装所有必要组件
- 🇨🇳 **国内源优化** - 使用国内镜像源，下载速度更快
- 🤖 **BB小子 Agent** - 李小龙风格智能助手，开箱即用
- 💪 **健康提醒系统** - 时间感知，功夫哲学融入日常
- 📰 **实时新闻收集** - Hacker News API 集成
- 📅 **提醒事项自动化** - AppleScript 智能管理
- 🔧 **企业级工具链** - 依赖自动检查、智能路径处理
- 🗑️ **完整卸载** - 支持完全卸载所有组件

### 🎯 适用场景

- 本地 AI 开发和测试
- OpenClaw Agent 开发
- 本地大语言模型部署
- AI 应用原型开发
- **个人智能助手** - 健康提醒、新闻收集、任务管理
- **李小龙哲学实践** - 功夫精神融入日常工作

---

## 🥋 BB小子 Agent 详细介绍

### 对话风格特点

**简洁直接：**
```
❌ "好的，我来帮您解决这个问题..."
✅ "核心问题：X"
```

**行动导向：**
```
❌ "建议您可以考虑以下几个方面..."
✅ "立即行动：X"
```

**哲学融入：**
```
💪 "年轻也注意保持运动。功夫不是吹出来的，是练出来的。"
💧 "像水一样，保持流动。"
```

### 时间感知健康提醒

BB小子根据当前时间和工作日提供智能提醒：

**工作日提醒：**
- 上午（9-12点）：保持专注，像水一样适应变化
- 午休（12-14点）：喝水，活动身体
- 下午（14-18点）：运动提醒，防止久坐
- 傍晚（18+）：反思今天，明天继续进步

**周末提醒：**
- 早晨（6-8点）：适合运动，功夫不是一天练成的
- 上午（9-11点）：休息是为了更好地前进
- 下午（14-16点）：别忘了运动

### 技能演示

#### 1. 新闻收集（含健康提醒）

```bash
~/.openclaw/workspaces/bb-kid/skills/news-collector-bruce.zsh collect tech 3
```

**输出示例：**
```
✓ 成功获取 3 条 Hacker News

🥋 李小龙提醒：
  下午时光，别让疲劳积累。
  💪 年轻也注意保持运动。功夫不是吹出来的，是练出来的。
  💧 记得喝水。
```

#### 2. 创建提醒（含健康指导）

```bash
~/.openclaw/workspaces/bb-kid/skills/macos-reminders-bruce.zsh create "功夫训练" "18:00" "今日练习"
```

**输出示例：**
```
✅ 提醒已创建。

🥋 知道不够，必须做到。别忘了：
  18:00: 功夫训练

💡 李小龙提醒：
  💪 年轻也注意保持运动。功夫不是吹出来的，是练出来的。
  🧘 别让身体僵硬。功夫讲究张弛有度。
```

#### 3. 独立健康提醒

```bash
bash ~/.openclaw/workspaces/bb-kid/skills/bruce-lee-reminders.sh smart
```

---

## 📋 系统要求

- **操作系统**: macOS 12 或更高版本（兼容模式支持更低版本）
- **架构**: Apple Silicon (M1/M2/M3) 或 Intel Mac
- **内存**: 至少 16GB（推荐 24GB+）
- **磁盘**: 至少 20GB 可用空间

---

## 📦 安装内容

### 核心组件

- ✅ **Homebrew** - macOS 包管理器
- ✅ **Node.js 20.x LTS** - JavaScript 运行环境
- ✅ **OpenClaw CLI** - 本地 AI Agent 框架
- ✅ **oMLX** - Apple Silicon 优化推理引擎
- ✅ **gemma-4-e4b-it-4bit** - 本地 AI 模型（约 4GB）
- ✅ **zhipuai/glm-5.1** - 智谱AI云端模型（主模型）
- ✅ **glm-5v-turbo** - 智谱AI视觉模型（图像理解）

### BB小子 Agent 配置

- 🥋 **李小龙风格对话** - 简洁直接、行动导向
- ⏰ **时间感知系统** - 工作日/周末自动识别
- 💧 **健康提醒** - 喝水、运动、休息智能提醒
- 📰 **新闻收集技能** - Hacker News API 实时新闻
- 📅 **提醒事项技能** - AppleScript 自动化
- 🔧 **企业级工具链** - 依赖管理、路径处理

### 默认插件

- 🤖 **@iotchange/skill-developer** - 开发者工具技能
- 💻 **@iotchange/skill-coder** - 编程助手技能

---

## 🚀 使用方法

### BB小子 Agent 基本命令

```bash
# 切换到 BB小子 Agent
openclaw agents use bb-kid

# 测试对话
openclaw chat "今天科技新闻有什么？"

# 查看系统信息
openclaw system info

# 查看帮助
openclaw --help
```

### BB小子技能使用

#### 收集科技新闻
```bash
~/.openclaw/workspaces/bb-kid/skills/news-collector-bruce.zsh collect tech 5
```

#### 创建 macOS 提醒
```bash
~/.openclaw/workspaces/bb-kid/skills/macos-reminders-bruce.zsh create "任务名称" "时间" "备注"
```

#### 智能健康提醒
```bash
bash ~/.openclaw/workspaces/bb-kid/skills/bruce-lee-reminders.sh smart
```

### 智能双模型配置

#### 🧠 双模型架构说明

**主模型（云端）：** 智谱 AI GLM-5.1
- ⚡ **速度：** 2-3秒响应（比本地快6-10倍）
- 🧠 **智能度：** 更强的理解和推理能力
- 🔧 **工具支持：** 支持函数调用和复杂任务

**备用模型（本地）：** oMLX Gemma-4 4bit
- 🛡️ **高可用：** API故障时自动降级
- 💰 **免费：** 无API调用成本
- 🔒 **隐私：** 数据不出本地

**视觉模型：** GLM-5V-Turbo
- 👁️ **图像理解：** 支持图像描述和分析
- 🔍 **OCR功能：** 提取图片中的文字
- 📊 **图表分析：** 理解数据图表和趋势

#### 配置和使用

```bash
# 方式1：使用交互式菜单（推荐）
cd macclaw_install
./install.zsh
# 选择：7) 🧠 智能双模型配置（云端+本地）

# 方式2：手动配置
# 设置主模型为智谱AI
openclaw config set agents.defaults.model.primary "zhipuai/glm-5.1"

# 设置备用模型为本地模型
openclaw config set agents.defaults.model.fallbacks[0] "omlx/gemma-4-e4b-it-4bit"
```

#### 模型推理测试

```bash
# 测试智谱AI（主模型）
openclaw infer model run --prompt "你好，请介绍你自己"

# 测试本地模型（备用）
openclaw infer model run --model omlx/gemma-4-e4b-it-4bit --prompt "你好"

# 测试视觉模型（图像理解）
openclaw infer model run --model zhipuai/glm-5v-turbo \
  --prompt "详细描述这张图片的内容" \
  --image /path/to/image.jpg

# OCR文字识别
openclaw infer model run --model zhipuai/glm-5v-turbo \
  --prompt "提取图片中的所有文字" \
  --image /path/to/document.jpg
```

#### 智能降级机制

**工作原理：**
1. **正常情况：** 请求 → 智谱AI（主模型）→ 响应（2-3秒）
2. **API故障：** 请求 → 智谱AI（失败）→ 本地模型（备用）→ 响应（15-30秒）
3. **自动切换：** OpenClaw原生支持，对用户透明

**降级场景：**
- 网络连接问题
- API服务暂时不可用
- API配额用尽
- API Key失效

**无需手动干预：** 系统会自动检测并切换，保证服务连续性。

---

### OpenClaw 通用命令

```bash
# 列出所有 Agents
openclaw agents list

# 创建新 Agent
openclaw agents add myagent --workspace ~/.openclaw/workspace-myagent

# 配置 Agent
openclaw agents config myagent --model zhipuai/glm-5.1

# 切换 Agent
openclaw agents use myagent

# 查看当前配置
openclaw config get agents.defaults.model.primary
openclaw config get agents.defaults.model.fallbacks
```

---

## 📂 项目结构

```
mactools/
├── README.md                   # 本文件
├── TEST_REPORT.md              # 完整测试报告（26/26 通过）
├── bb-kid-example/             # BB小子 Agent 完整示例
│   ├── README.md               # BB小子使用说明
│   ├── IDENTITY.md             # Agent 身份定义
│   ├── USER.md                 # 用户角色配置（李小龙）
│   ├── SOUL.md                 # Agent 灵魂（李小龙哲学）
│   ├── BRUCE_LEE_STYLE.md      # 对话风格指南
│   ├── BRUCE_LEE_CONFIG_REPORT.md    # 配置报告
│   ├── BRUCE_LEE_HEALTH_REMINDER_REPORT.md  # 健康提醒报告
│   └── skills/                 # BB小子技能脚本
│       ├── news-collector-bruce.zsh      # 李小龙风格新闻收集
│       ├── macos-reminders-bruce.zsh     # 李小龙风格提醒事项
│       ├── bruce-lee-reminders.sh        # 健康提醒系统
│       ├── news-fetcher.sh              # Hacker News API
│       ├── path-utils.sh                # 智能路径处理
│       └── dependency-check.sh          # 依赖检查修复
└── macclaw_install/            # 一键安装脚本
    ├── install.zsh             # 主安装脚本
    ├── README.md               # 安装说明
    └── lib/                    # 核心库
        ├── parts/              # 模块化安装
        │   ├── part1_env.zsh       # 环境配置
        │   ├── part2_compute.zsh   # 算力配置
        │   ├── part3_openclaw.zsh  # OpenClaw 安装
        │   └── part4_test_plugins.zsh  # 测试+插件
        └── sources/            # 国内源配置
```

---

## 🔧 高级选项

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

**交互式安装**（推荐，新增主菜单）：
```bash
./install.zsh
```

**主菜单选项：**
```
╔════════════════════════════════════════════════════════════╗
║       🦞 MacClaw Install - 安装工具                        ║
║                                                            ║
║       一键安装 OpenClaw + omlx 本地 AI 环境                ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝

请选择操作：

  1) 🚀 完整安装 - 安装所有组件（推荐）
  2) 🔧 仅安装 OpenClaw
  3) 🤖 仅安装 oMLX
  4) ⚙️  配置本地算力
  5) 📦 安装插件
  6) 🤖 创建 Agent
  7) 🧠 智能双模型配置（云端+本地） ← 新增
  8) ❌ 退出
```

**管道安装**（非交互模式）：
```bash
curl -fsSL https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw_install/install.zsh | zsh
```

**特点：**
- 交互模式：显示主菜单，按需选择功能
- 管道模式：自动执行完整安装，适合脚本调用
- 智能检测：自动检测已安装组件，避免重复安装

### 自定义 BB小子 配置

BB小子的配置文件位于 `~/.openclaw/workspaces/bb-kid/`，您可以自定义：

```bash
# 编辑对话风格
vim ~/.openclaw/workspaces/bb-kid/BRUCE_LEE_STYLE.md

# 编辑 Agent 身份
vim ~/.openclaw/workspaces/bb-kid/IDENTITY.md

# 编辑用户角色
vim ~/.openclaw/workspaces/bb-kid/USER.md

# 编辑 Agent 灵魂
vim ~/.openclaw/workspaces/bb-kid/SOUL.md
```

### 智能双模型配置

**配置文件位置：** `~/.openclaw/openclaw.json`

**查看当前配置：**
```bash
# 查看主模型
openclaw config get agents.defaults.model.primary
# 预期输出：zhipuai/glm-5.1

# 查看备用模型
openclaw config get agents.defaults.model.fallbacks
# 预期输出：["omlx/gemma-4-e4b-it-4bit"]

# 查看智谱AI配置
cat ~/.openclaw/openclaw.json | jq '.models.providers.zhipuai'
```

**手动修改配置：**
```bash
# 切换主模型
openclaw config set agents.defaults.model.primary "zhipuai/glm-5.1"

# 切换备用模型
openclaw config set agents.defaults.model.fallbacks[0] "omlx/gemma-4-e4b-it-4bit"

# 更新API Key
openclaw config set models.providers.zhipuai.apiKey "your-api-key"
```

**配置备份：**
```bash
# 自动备份位置
ls -la ~/.openclaw/openclaw.json.backup.*

# 手动备份
cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.backup.manual
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
- **BB小子 Agent**（含所有配置）
- 所有配置文件
- 所有插件和模型

---

## 🐛 问题排查

### 安装失败

1. 检查系统版本：`sw_vers`
2. 查看安装日志：`cat ~/macclaw_install.log`
3. 确认磁盘空间：`df -h /`
4. 检查网络连接

### BB小子 Agent 无法使用

1. 检查 Agent 是否创建：`openclaw agents list`
2. 查看技能文件：`ls ~/.openclaw/workspaces/bb-kid/skills/`
3. 测试技能：`bash ~/.openclaw/workspaces/bb-kid/skills/bruce-lee-reminders.sh smart`
4. 查看配置：`cat ~/.openclaw/workspaces/bb-kid/IDENTITY.md`

### 服务无法启动

1. 检查端口占用：`lsof -i :18789`
2. 查看服务日志：`tail -f /tmp/openclaw/openclaw-*.log`
3. 重启服务：`openclaw gateway restart`

### 推理失败

1. 检查 oMLX 服务：`curl http://127.0.0.1:8008/health`
2. 验证模型加载：检查 oMLX 应用
3. 查看 API Key：`cat ~/.omlx/settings.json`

### 智能双模型配置问题

**问题1：智谱AI API调用失败**

症状：
```
Error: API request failed
```

解决方案：
```bash
# 1. 检查API Key配置
openclaw config get models.providers.zhipuai.apiKey

# 2. 验证网络连接
curl -I https://open.bigmodel.cn/api/paas/v4

# 3. 测试智谱AI
openclaw infer model run --model zhipuai/glm-5.1 --prompt "测试"

# 4. 系统会自动降级到本地模型
openclaw infer model run --model omlx/gemma-4-e4b-it-4bit --prompt "测试"
```

**问题2：配置未生效**

症状：
```
主模型仍为本地模型
```

解决方案：
```bash
# 1. 检查当前配置
openclaw config get agents.defaults.model.primary
openclaw config get agents.defaults.model.fallbacks

# 2. 重新配置
openclaw config set agents.defaults.model.primary "zhipuai/glm-5.1"
openclaw config set agents.defaults.model.fallbacks[0] "omlx/gemma-4-e4b-it-4bit"

# 3. 重启OpenClaw网关
openclaw gateway restart

# 4. 或使用交互式菜单
cd macclaw_install
./install.zsh
# 选择：7) 🧠 智能双模型配置
```

**问题3：视觉模型不可用**

症状：
```
Error: Model glm-5v-turbo not found
```

解决方案：
```bash
# 1. 检查视觉模型是否已添加
cat ~/.openclaw/openclaw.json | jq '.models.providers.zhipuai.models[] | select(.id == "glm-5v-turbo")'

# 2. 重新运行智能配置
cd macclaw_install
./install.zsh
# 选择：7) 🧠 智能双模型配置

# 3. 手动添加视觉模型
# （参见上方"自定义智能双模型配置"部分）
```

**问题4：自动降级未生效**

症状：
```
API失败后没有切换到本地模型
```

解决方案：
```bash
# 1. 验证备用模型配置
openclaw config get agents.defaults.model.fallbacks

# 2. 确保本地模型可用
openclaw infer model run --model omlx/gemma-4-e4b-it-4bit --prompt "测试"

# 3. 检查oMLX服务状态
# 打开 /Applications/oMLX.app
# 或检查：curl http://127.0.0.1:8008/health

# 4. 查看降级日志
tail -f /tmp/openclaw/openclaw-*.log | grep -i fallback
```

---

## 📚 文档

- [测试报告](TEST_REPORT.md) - 完整测试报告（26/26 通过）
- [智能双模型配置测试](.zcf/plan/current/智能双模型配置测试报告.md) - 双模型测试报告
- [BB小子示例](bb-kid-example/README.md) - BB小子完整使用说明
- [安装指南](macclaw_install/INSTALL_GUIDE.md) - 详细安装说明
- [架构设计](macclaw_install/docs/ARCHITECTURE.md) - 系统架构说明
- [故障排除](macclaw_install/docs/TROUBLESHOOTING.md) - 常见问题解决
- [开发指南](macclaw_install/docs/DEVELOPMENT.md) - 开发者文档
- [更新日志](CHANGELOG.md) - 版本更新记录

---

## 🎓 BB小子扩展开发

### 添加新技能

1. 在 `~/.openclaw/workspaces/bb-kid/skills/` 创建新脚本
2. 设置执行权限：`chmod +x new-skill.zsh`
3. 在 `AGENTS.md` 中注册技能
4. 遵循李小龙风格：简洁、直接、实用

### 修改对话风格

编辑 `BRUCE_LEE_STYLE.md`，添加您的风格规则：
- 移除客套话
- 强调行动导向
- 融入哲学元素
- 保持简洁直接

### 自定义健康提醒

编辑 `bruce-lee-reminders.sh`，添加您的提醒逻辑：
- 修改时间判断
- 添加新的提醒类型
- 调整消息内容

---

## 🤝 贡献

欢迎贡献代码、报告问题或提出建议！

1. Fork 本仓库
2. 创建特性分支：`git checkout -b feature/AmazingFeature`
3. 提交更改：`git commit -m 'Add some AmazingFeature'`
4. 推送到分支：`git push origin feature/AmazingFeature`
5. 开启 Pull Request

---

## 📊 测试状态

**基础功能：26/26 测试通过 ✅**

- 脚本下载: 3/3 ✅
- 完整性检查: 3/3 ✅
- BB小子功能: 5/5 ✅
- 配置文件: 4/4 ✅
- 技能文件: 3/3 ✅
- 功能测试: 4/4 ✅
- 集成测试: 4/4 ✅

**智能双模型配置：7/7 测试通过 ✅**

- 配置检查: 1/1 ✅
- 智谱AI配置: 1/1 ✅
- 主模型设置: 1/1 ✅
- 备用模型设置: 1/1 ✅
- 视觉模型添加: 1/1 ✅
- API测试: 1/1 ✅
- 降级机制: 1/1 ✅

**生产就绪状态：✅ 已就绪**

详细测试报告：
- [基础功能测试](TEST_REPORT.md)
- [智能双模型配置测试](.zcf/plan/current/智能双模型配置测试报告.md)

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

**特别致敬：李小龙（Bruce Lee）**

*"Be water, my friend."*
*"像水一样，我的朋友。"*

*"The key to immortality is first living a life worth remembering."*
*"不朽的关键是先过上值得铭记的生活。"*

---

**🦞 享受本地 AI 的强大能力！**

**🥋 "知道不够，必须做到。"**
