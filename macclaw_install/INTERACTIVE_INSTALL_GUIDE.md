# MacClaw 交互式安装指南

**作者**: 外星动物（常智） / IoTchange / 14455975@qq.com  
**版权**: Copyright (C) 2026 IoTchange - All Rights Reserved  
**版本**: 1.0.0
**更新日期**: 2026-04-13

---

## 📖 概述

`install-interactive.zsh` 是一个全新的交互式安装脚本，专为 Apple Silicon Mac 设计，提供图形化用户界面和浏览器集成功能。

---

## ✨ 主要特性

- 🎨 **macOS 原生对话框**：使用 osascript 实现系统级对话框
- 🌐 **浏览器集成**：自动打开官网并等待用户确认
- 🔄 **交互式工作流**：7个步骤引导用户完成安装
- 🧪 **自动化测试**：OpenClaw 提示词生成测试
- 📊 **详细环境检测**：系统、硬件、软件全面检测

---

## 🚀 使用方法

### 快速开始

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

## 📋 安装流程

### 步骤 1: 部署环境确认
- 检测 macOS 版本
- 检测硬件信息（芯片、内存、磁盘）
- 检测已安装软件
- 环境兼容性检查

### 步骤 2: 安装 omlx app
- 自动打开 https://omlx.ai/
- 显示安装指引对话框
- 等待用户确认安装完成
- 验证 omlx 安装状态

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

## 📁 文件结构

```
macclaw_install/
├── install-interactive.zsh              # 主入口脚本
├── lib/
│   ├── interactive/                     # 交互式专用模块
│   │   ├── dialog-helper.zsh           # macOS dialog 工具
│   │   ├── browser-helper.zsh          # 浏览器操作工具
│   │   ├── workflow-steps.zsh          # 工作流步骤定义
│   │   └── openclaw-tester.zsh         # OpenClaw 测试工具
│   └── core/
│       └── env-detector-interactive.zsh # 环境检测（简化版）
└── config/
    └── interactive.conf                 # 交互式配置
```

---

## ⚙️ 配置文件

`config/interactive.conf` 包含以下配置项：

### 对话框配置
```zsh
DIALOG_TITLE="MacClaw 交互式安装"
DIALOG_ICON="note"  # note, caution, stop
```

### 浏览器配置
```zsh
BROWSER_OPEN_CMD="open"
BROWSER_OPENInBackground=false
```

### URL 配置
```zsh
OMLX_URL="https://omlx.ai/"
OPENCLAW_URL="https://openclaw.ai/"
MODEL_NAME="mlx-community/gemma-4-e4b-it-4bit"
```

### 测试配置
```zsh
OPENCLAW_TEST_PROMPT="你好，请做一个自我介绍。"
OPENCLAW_TEST_TIMEOUT=30
```

---

## 🔧 系统要求

### 最低要求
- **操作系统**: macOS 12 (Monterey) 或更高版本
- **CPU**: Apple Silicon (M1/M2/M3/M4/M5)
- **内存**: 16GB RAM
- **磁盘**: 20GB 可用空间

### 推荐配置
- **操作系统**: macOS 13 (Ventura) 或更高版本
- **内存**: 24GB RAM 或更多
- **磁盘**: 40GB 或更多可用空间

---

## 🐛 故障排除

### 问题 1: 对话框不显示
**解决方案**:
- 确保有权限访问 System Events
- 检查 macOS 安全设置

### 问题 2: 浏览器无法打开
**解决方案**:
- 确认 `open` 命令可用
- 检查默认浏览器设置
- 手动访问提供的 URL

### 问题 3: omlx 或 OpenClaw 检测失败
**解决方案**:
- 确认使用 `pip3` 安装 omlx
- 确认使用 `npm` 安装 OpenClaw
- 检查 PATH 环境变量

### 问题 4: 测试超时
**解决方案**:
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

## 🔗 相关链接

- **项目主页**: https://github.com/changzhi777/mactools
- **问题反馈**: https://github.com/changzhi777/mactools/issues
- **omlx 官网**: https://omlx.ai/
- **OpenClaw 官网**: https://openclaw.ai/

---

## 📄 许可证

**作者**: 外星动物（常智） / IoTchange / 14455975@qq.com  
**版权**: Copyright (C) 2026 IoTchange - All Rights Reserved

---

## 🙏 致谢

- omlx - https://omlx.ai
- OpenClaw - https://openclaw.ai
- ModelScope - https://modelscope.cn
