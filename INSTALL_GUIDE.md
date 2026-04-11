# MacTools 一键安装指南

**作者**: 外星动物（常智）
**组织**: IoTchange
**邮箱**: 14455975@qq.com
**版本**: V1.0.1
**版权**: Copyright (C) 2026 IoTchange - All Rights Reserved

---

## 🚀 一键安装命令

### 在线安装（推荐）

```bash
curl -fsSL https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw-installer/install.sh | bash
```

### 使用 wget

```bash
wget -qO- https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw-installer/install.sh | bash
```

---

## ✅ 安装前检查

### 系统要求

- **操作系统**: macOS 12+ (Monterey 或更高)
- **架构**: Apple Silicon (M1/M2/M3) 或 Intel Mac
- **内存**: 至少 16GB（推荐 24GB+）
- **磁盘空间**: 至少 20GB 可用空间
- **网络**: 稳定的互联网连接

### 自动检测

安装脚本会自动检测：
- ✅ macOS 版本（需要 12+）
- ✅ 系统架构（Apple Silicon 或 Intel）
- ✅ 可用磁盘空间（至少 20GB）
- ✅ 网络连接状态
- ✅ 必要的工具（curl, git, bash）
- ✅ Python 环境
- ✅ Node.js 环境
- ✅ OpenClaw 安装状态
- ✅ oMLX 安装状态

---

## 📦 安装内容

### 核心组件

- ✅ **Node.js** - JavaScript 运行环境（通过 nvm）
- ✅ **OpenClaw CLI** - 本地 AI Agent 框架
- ✅ **oMLX** - Apple Silicon 优化推理引擎
- ✅ **gemma-4-e4b-it-4bit** - 本地 AI 模型（约 4GB）
- ✅ **默认 Agent** - 预配置的 AI 智能体
- ✅ **Skills** - 扩展技能包

### 国内源配置

所有下载都使用国内镜像，速度提升 10 倍：

- **npm** → 淘宝镜像
- **pip** → 清华大学镜像
- **AI 模型** → ModelScope (阿里云)
- **HuggingFace** → HF-Mirror

---

## ⏱️ 安装时间

| 阶段 | 时间 | 说明 |
|------|------|------|
| 环境检测 | 1-2 分钟 | 检查系统环境 |
| 配置国内源 | 1 分钟 | 优化下载速度 |
| 安装 Node.js | 3-5 分钟 | 通过 nvm 安装 |
| 安装 OpenClaw | 2-3 分钟 | CLI 工具 |
| 安装 oMLX | 3-5 分钟 | 推理服务 |
| 下载 AI 模型 | 5-10 分钟 | 约 4GB |
| 配置集成 | 2-3 分钟 | 服务配置 |
| **总计** | **15-30 分钟** | |

---

## 🎯 安装步骤

### 1. 复制安装命令

```bash
curl -fsSL https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw-installer/install.sh | bash
```

### 2. 按照提示操作

安装脚本会显示欢迎界面：

```
╔════════════════════════════════════════════════════════════╗
║              🦞 MacClaw 一键安装器 V1.0.1                   ║
║       OpenClaw + oMLX 本地 AI 模型完整安装                  ║
╚════════════════════════════════════════════════════════════╝

作者: 外星动物（常智）
组织: IoTchange
邮箱: 14455975@qq.com
版权: Copyright (C) 2026 IoTchange

本项目将自动安装以下组件：
  • Node.js (通过 nvm)
  • OpenClaw CLI
  • oMLX 本地推理服务
  • gemma-4-e4b-it-4bit AI 模型
  • Agent & Skills (可选)

按 Enter 继续，或 Ctrl+C 退出...
```

### 3. 选择安装组件

脚本会提供选项让你选择要安装的组件：
- Node.js
- OpenClaw CLI
- oMLX 服务
- gemma-4 AI 模型
- Agent & Skills

### 4. 确认安装

选择完成后，脚本会要求确认：
```
确认开始安装？ [y/N]:
```

输入 `y` 并按 Enter 开始安装。

---

## 🎉 安装完成

安装成功后，你可以：

### 访问 Web UI

在浏览器中打开：
```
http://127.0.0.1:18789/
```

### 测试 AI 对话

```bash
openclaw infer model run \
  --model omlx/gemma-4-e4b-it-4bit \
  --prompt "你好，请介绍一下你自己"
```

### 查看 Agent

```bash
openclaw agents list
```

### 检查服务状态

```bash
# oMLX 服务（端口 8008）
curl http://127.0.0.1:8008/health

# OpenClaw Gateway（端口 18789）
openclaw gateway status
```

---

## 🛠️ 故障排除

### 安装失败

**问题**: 安装脚本执行失败

**解决方案**:
1. 检查网络连接
2. 查看安装日志：`~/macclaw-install.log`
3. 确认系统版本：`sw_vers -productVersion`
4. 重新运行安装命令

### 下载速度慢

**问题**: 下载速度很慢

**解决方案**:
1. 运行国内源检查脚本：
   ```bash
   curl -fsSL https://raw.githubusercontent.com/changzhi777/mactools/main/check_sources.sh | bash
   ```
2. 新开终端使配置生效
3. 重新运行安装

### 服务无法启动

**问题**: 安装完成但服务无法启动

**解决方案**:
1. 检查端口占用：
   ```bash
   lsof -i :8008  # oMLX
   lsof -i :18789  # OpenClaw
   ```
2. 重启服务：
   ```bash
   openclaw gateway restart
   ```
3. 查看日志：
   ```bash
   tail -f /tmp/openclaw/openclaw-*.log
   ```

### 推理功能不工作

**问题**: AI 推理返回错误

**解决方案**:
1. 检查 oMLX 服务：
   ```bash
   curl http://127.0.0.1:8008/health
   ```
2. 验证模型已下载：
   ```bash
   ls -lh ~/.omlx/models/
   ```
3. 测试推理功能

---

## 📞 获取帮助

### 文档

- **完整文档**: https://github.com/changzhi777/mactools
- **问题反馈**: https://github.com/changzhi777/mactools/issues

### 联系方式

- **作者**: 外星动物（常智）
- **邮箱**: 14455975@qq.com
- **组织**: IoTchange

---

## 🎯 快速开始

**立即安装，3 步搞定：**

1. **复制命令**
   ```bash
   curl -fsSL https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw-installer/install.sh | bash
   ```

2. **按 Enter 继续**

3. **等待 15-30 分钟**

**就这么简单！** 🚀

---

**🦞 享受本地 AI 的强大能力！**
