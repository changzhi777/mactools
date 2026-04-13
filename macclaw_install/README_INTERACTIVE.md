# MacClaw 交互式安装脚本

**作者:** 外星动物（常智） / IoTchange / 14455975@qq.com  
**版权:** Copyright (C) 2026 IoTchange - All Rights Reserved  
**版本:** 1.0.0  
**更新日期:** 2026-04-13

---

## 📦 项目简介

MacClaw 交互式安装脚本是一个专为 Apple Silicon Mac 设计的 **omlx + OpenClaw** 图形化安装工具，通过 macOS 原生对话框和浏览器集成，提供友好的用户交互体验。

### ✨ 主要特性

- 🎨 **macOS 原生对话框** - 使用 osascript 实现系统级对话框
- 🌐 **浏览器集成** - 自动打开官网并等待用户确认
- 🔄 **交互式工作流** - 7 个步骤引导完成安装
- 🧪 **自动化测试** - OpenClaw 提示词生成测试
- 📊 **详细环境检测** - 系统、硬件、软件全面检测
- 🇨🇳 **国内源优化** - 使用国内镜像源，下载速度更快
- 🔧 **模块化设计** - 代码结构清晰，易于维护

---

## 📋 系统要求

### 最低要求
- **操作系统:** macOS 12 (Monterey) 或更高版本
- **CPU:** Apple Silicon (M1/M2/M3/M4/M5)
- **内存:** 16GB RAM
- **磁盘空间:** 20GB 可用空间
- **网络:** 稳定的互联网连接

### 推荐配置
- **操作系统:** macOS 13 (Ventura) 或更高版本
- **内存:** 24GB RAM 或更多
- **磁盘空间:** 40GB 或更多可用空间

---

## 🚀 快速开始

### 一键安装

```bash
cd macclaw_install
chmod +x install-interactive.zsh
./install-interactive.zsh
```

### 命令行选项

```bash
# 交互式安装（默认）
./install-interactive.zsh

# 自动模式（减少交互）
./install-interactive.zsh --auto

# 显示帮助
./install-interactive.zsh --help

# 显示版本
./install-interactive.zsh --version
```

---

## 📖 安装流程

### 步骤 1: 部署环境确认
- 检测 macOS 版本
- 检测硬件信息（芯片、内存、磁盘）
- 检测已安装软件
- 环境兼容性检查

### 步骤 2: 安装 omlx app
- 自动打开 https://omlx.ai/
- 显示安装指引对话框
- 提示下载模型：`mlx-community/gemma-4-e4b-it-4bit`
- 等待用户确认安装完成

### 步骤 3: 环境检测（omlx）
- 检测 omlx 包安装状态
- 显示检测结果
- 提供重试选项

### 步骤 4: 安装 OpenClaw
- 自动打开 https://openclaw.ai/
- 显示安装指引对话框
- 等待用户确认安装完成
- 验证 OpenClaw 安装状态

### 步骤 5: 配置本地算力 API
- **功能待开发**
- 当前占位步骤

### 步骤 6: 命令行测试
- 测试 OpenClaw 提示词生成
- 显示测试结果
- 支持自定义提示词测试

### 步骤 7: 跳转技能安装菜单
- 显示安装完成摘要
- 询问是否安装技能插件
- 跳转到主安装脚本（可选）

---

## 📁 项目结构

```
macclaw_install/
├── install-interactive.zsh              # 交互式安装主脚本
├── INTERACTIVE_INSTALL_GUIDE.md         # 交互式安装指南
├── lib/
│   ├── interactive/                     # 交互式专用模块
│   │   ├── dialog-helper.zsh           # macOS Dialog 工具
│   │   ├── browser-helper.zsh          # 浏览器操作工具
│   │   ├── workflow-steps.zsh          # 工作流步骤定义
│   │   └── openclaw-tester.zsh         # OpenClaw 测试工具
│   ├── core/
│   │   └── env-detector-interactive.zsh # 环境检测（简化版）
│   └── parts/                           # 原有安装部分
│       ├── part1_env.zsh               # 环境配置
│       ├── part2_compute.zsh           # 算力配置
│       ├── part3_openclaw.zsh          # OpenClaw 安装
│       └── part4_test_plugins.zsh      # 测试和插件
├── config/
│   ├── interactive.conf                # 交互式安装配置
│   ├── sources.conf                    # 国内源配置
│   ├── versions.conf                   # 版本配置
│   ├── compute.conf                    # 算力配置
│   └── plugins.conf                    # 插件配置
└── install.zsh                         # 原有主安装脚本
```

---

## 🔧 配置说明

### 交互式安装配置

`config/interactive.conf` 文件包含以下配置项：

#### 对话框配置
```zsh
DIALOG_TITLE="MacClaw 交互式安装"
DIALOG_ICON="note"  # note, caution, stop
```

#### 浏览器配置
```zsh
BROWSER_OPEN_CMD="open"
BROWSER_OPENInBackground=false
```

#### URL 配置
```zsh
OMLX_URL="https://omlx.ai/"
OPENCLAW_URL="https://openclaw.ai/"
MODEL_NAME="mlx-community/gemma-4-e4b-it-4bit"
```

#### 测试配置
```zsh
OPENCLAW_TEST_PROMPT="你好，请做一个自我介绍。"
OPENCLAW_TEST_TIMEOUT=30
```

---

## 📊 功能模块说明

### 1. macOS Dialog 工具

提供 8 种对话框类型：
- ✅ 信息对话框
- ✅ 确认对话框（是/否）
- ✅ 确认对话框（是/否/稍后）
- ✅ 输入对话框
- ✅ 选择对话框
- ✅ 进度对话框
- ✅ 等待对话框
- ✅ 错误/警告对话框

### 2. 浏览器工具

- 🌐 自动打开 URL（系统默认浏览器）
- ⏸️ 等待用户确认
- 📝 显示操作指引
- 🔍 检测浏览器状态

### 3. 环境检测

- 🍎 macOS 版本检测
- 💻 硬件信息检测（芯片、内存、磁盘）
- 📦 软件安装检测（Homebrew、Node.js、Python、omlx、OpenClaw）
- ⚠️ 环境兼容性检查

### 4. 工作流步骤

完整的 7 步安装流程，每步都有：
- 📋 详细说明
- ✅ 状态检测
- ⏸️ 用户确认
- 🔄 错误处理

### 5. OpenClaw 测试

- 🧪 标准测试（预定义提示词）
- 🎯 自定义提示词测试
- 📊 测试结果分析
- 🔄 失败重试机制

---

## 🐛 故障排除

### 问题 1: 对话框不显示
**解决方案:**
- 确保有权限访问 System Events
- 检查 macOS 安全设置

### 问题 2: 浏览器无法打开
**解决方案:**
- 确认 `open` 命令可用
- 检查默认浏览器设置
- 手动访问提供的 URL

### 问题 3: omlx 或 OpenClaw 检测失败
**解决方案:**
- 确认使用 `pip3` 安装 omlx
- 确认使用 `npm` 安装 OpenClaw
- 检查 PATH 环境变量

### 问题 4: 测试超时
**解决方案:**
- 增加测试超时时间（配置文件）
- 检查网络连接
- 确认模型已下载

---

## 📝 日志文件

安装日志保存在：`~/macclaw_interactive_install.log`

查看日志：
```bash
cat ~/macclaw_interactive_install.log
```

---

## 📚 相关文档

- [交互式安装详细指南](INTERACTIVE_INSTALL_GUIDE.md)
- [原有安装指南](INSTALL_GUIDE.md)
- [快速参考](QUICK_REFERENCE.md)
- [变更日志](CHANGELOG.md)

---

## 🔗 相关链接

- **项目主页:** https://github.com/changzhi777/mactools
- **问题反馈:** https://github.com/changzhi777/mactools/issues
- **omlx 官网:** https://omlx.ai/
- **OpenClaw 官网:** https://openclaw.ai/
- **ModelScope:** https://modelscope.cn/

---

## ⚖️ 许可证

**作者:** 外星动物（常智） / IoTchange / 14455975@qq.com  
**版权:** Copyright (C) 2026 IoTchange - All Rights Reserved

---

## 🙏 致谢

感谢以下开源项目：

- [OpenClaw](https://github.com/openclaw-dev/openclaw) - 本地 AI Agent 框架
- [oMLX](https://github.com/jundot/omlx) - Apple Silicon 优化推理引擎
- [ModelScope](https://github.com/modelscope/modelscope) - 模型社区

---

**🦊 享受本地 AI 的强大能力！**
