# MacClaw Install 安装指南

**版本**: 1.0.0
**更新日期**: 2026-04-12

---

## ⚡ 一键安装（推荐）

```bash
curl -fsSL https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw_install/install.zsh | zsh
```

**或使用 wget：**
```bash
wget -qO- https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw_install/install.zsh | zsh
```

**🎯 这一条命令即可完成所有安装！**

---

## 📋 目录

1. [系统要求](#系统要求)
2. [安装前准备](#安装前准备)
3. [其他安装方式](#其他安装方式)
4. [安装过程](#安装过程)
5. [安装后验证](#安装后验证)
6. [常见问题](#常见问题)
7. [卸载方法](#卸载方法)

---

## 系统要求

### 最低要求

- **操作系统**: macOS 12 (Monterey) 或更高版本
  - 兼容模式支持 macOS 10.15 (Catalina) 及更高版本
- **CPU 架构**: Apple Silicon (M1/M2/M3) 或 Intel Mac
- **内存**: 至少 16GB RAM
- **磁盘空间**: 至少 20GB 可用空间
- **网络**: 稳定的互联网连接

### 推荐配置

- **操作系统**: macOS 13 (Ventura) 或更高版本
- **CPU**: Apple Silicon (M1/M2/M3)
- **内存**: 24GB RAM 或更多
- **磁盘空间**: 40GB 或更多可用空间

### 检查系统信息

```bash
# 查看 macOS 版本
sw_vers

# 查看 CPU 架构
uname -m

# 查看内存大小
sysctl -n hw.memsize | awk '{print $1/1024/1024/1024 "GB"}'

# 查看磁盘空间
df -h /
```

---

## 🔧 其他安装方式

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
- 显示友好的菜单界面
- 可以查看系统信息
- 支持自定义安装选项

**自动安装**（推荐）：
```bash
./install.zsh --auto
```
- 无需任何交互
- 自动安装所有组件
- 适合自动化部署

**静默安装**：
```bash
./install.zsh --silent
```
- 最小输出
- 仅显示错误信息
- 适合脚本调用

---

## 安装前准备

### 1. 安装 Xcode Command Line Tools

```bash
# 检查是否已安装
xcode-select -p

# 如果未安装，执行
xcode-select --install
```

等待安装完成后，继续下一步。

### 2. 确保网络连接正常

```bash
# 测试网络连接
ping -c 3 mirrors.ustc.edu.cn
```

### 3. 清理磁盘空间（如果需要）

```bash
# 清理 Homebrew 缓存（如果已安装）
brew cleanup

# 清理 npm 缓存（如果已安装）
npm cache clean --force

# 清理系统缓存
sudo rm -rf /Library/Caches/*
```

---

## 🔧 其他安装方式

### 手动安装

### 方法 1：一键安装（推荐）

```bash
curl -fsSL https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw_install/install.zsh | zsh
```

或使用 wget：

```bash
wget -qO- https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw_install/install.zsh | zsh
```

### 方法 2：下载后安装

```bash
# 下载脚本
curl -fsSL https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw_install/install.zsh -o install.zsh

# 添加执行权限
chmod +x install.zsh

# 执行安装
./install.zsh
```

### 方法 3：克隆仓库安装

```bash
# 克隆仓库
git clone https://github.com/changzhi777/mactools.git
cd mactools/macclaw_install

# 运行安装脚本
chmod +x install.zsh
./install.zsh
```

### 安装模式

**交互式安装**（默认）：
```bash
./install.zsh
```
- 显示菜单，让您选择安装选项
- 可以查看系统信息
- 可以自定义安装

**自动安装**（推荐）：
```bash
./install.zsh --auto
```
- 无需任何交互
- 自动安装所有组件
- 适合自动化部署

**静默安装**：
```bash
./install.zsh --silent
```
- 最小输出
- 仅显示错误信息
- 适合脚本调用

---

## 安装过程

### 第1部分：环境配置

安装内容：
- ✅ Homebrew（包管理器）
- ✅ Node.js 20.x LTS
- ✅ npm（淘宝镜像）

预计时间：5-10 分钟

### 第2部分：算力配置

安装内容：
- ✅ oMLX（Apple Silicon 优化推理引擎）
- ✅ gemma-4-e4b-it-4bit AI 模型（约 4GB）

预计时间：10-20 分钟（取决于网络速度）

**注意**：Intel Mac 将跳过此部分。

### 第3部分：OpenClaw 安装

安装内容：
- ✅ OpenClaw CLI（npm 淘宝镜像）

预计时间：2-5 分钟

### 第4部分：测试和插件

安装内容：
- ✅ 基础测试
- ✅ @iotchange/skill-developer（开发者工具）
- ✅ @iotchange/skill-coder（编程助手）

预计时间：2-3 分钟

---

## 安装后验证

### 1. 验证 Homebrew

```bash
brew --version
```

预期输出：
```
Homebrew 4.3.0
```

### 2. 验证 Node.js

```bash
node --version
npm --version
```

预期输出：
```
v20.11.0
10.2.4
```

### 3. 验证 OpenClaw

```bash
openclaw --version
```

预期输出：
```
OpenClaw CLI v1.x.x
```

### 4. 验证 oMLX（Apple Silicon）

```bash
pip3 show omlx
```

预期输出：
```
Name: omlx
Version: 0.x.x
```

### 5. 测试推理

```bash
openclaw infer model run --model omlx/gemma-4-e4b-it-4bit --prompt "你好"
```

预期输出：
```
你好！我是 AI 助手...
```

---

## 常见问题

### Q1: 安装失败怎么办？

**A**:
1. 查看安装日志：`cat ~/macclaw_install.log`
2. 检查网络连接
3. 确认磁盘空间充足
4. 重启安装脚本

### Q2: 磁盘空间不足怎么办？

**A**:
1. 清理磁盘空间
2. 或选择最小化安装（在高级选项中）
3. 最小化安装仅需约 5GB

### Q3: 网络下载慢怎么办？

**A**:
1. 脚本已自动使用国内镜像源
2. 如仍然慢，检查代理设置
3. 可以稍后手动下载模型

### Q4: Apple Silicon 但没安装 oMLX？

**A**:
1. oMLX 安装失败时可以选择跳过
2. 不影响 OpenClaw 使用
3. 可以稍后手动安装：`pip3 install omlx`

### Q5: Intel Mac 可以使用吗？

**A**:
1. 可以，但会跳过 oMLX 安装
2. 使用 CPU 推理，速度较慢
3. 建议使用 Apple Silicon Mac

### Q6: 如何更新安装？

**A**:
```bash
cd macclaw_install
git pull
./install.zsh
```

---

## 卸载方法

### 完全卸载

```bash
cd macclaw_install
chmod +x uninstall.zsh
./uninstall.zsh
```

### 手动卸载

```bash
# 卸载 OpenClaw
npm uninstall -g @iotchange/openclaw

# 卸载 Node.js 和 nvm
rm -rf ~/.nvm

# 卸载 Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"

# 清理配置文件
rm -rf ~/.openclaw
rm -rf ~/.omlx
rm ~/macclaw_install.log
```

---

## 获取帮助

- **项目主页**: https://github.com/changzhi777/mactools
- **问题反馈**: https://github.com/changzhi777/mactools/issues
- **文档**: https://github.com/changzhi777/mactools/tree/main/macclaw_install
- **邮箱**: 14455975@qq.com

---

**祝您安装顺利！🎉**
