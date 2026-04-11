# OpenClaw 国内源安装器使用指南

**版本**: V1.0.0  
**发布日期**: 2026-04-12  
**作者**: 外星动物（常智）  
**组织**: IoTchange

---

## 🚀 快速开始

### 一键安装（推荐）

```bash
bash openclaw-china-installer.sh
```

或使用 sudo：

```bash
sudo bash openclaw-china-installer.sh
```

### 下载并执行

```bash
# 下载脚本
curl -fsSL https://raw.githubusercontent.com/changzhi777/mactools/main/openclaw-china-installer.sh -o openclaw-china-installer.sh

# 添加执行权限
chmod +x openclaw-china-installer.sh

# 执行安装
sudo bash openclaw-china-installer.sh
```

---

## 📋 系统要求

### 最低要求

- **操作系统**: macOS 12 或更高版本
- **CPU架构**: arm64 (Apple Silicon) 或 x86_64 (Intel)
- **内存**: 至少 16GB
- **磁盘空间**: 至少 20GB 可用空间

### 必需工具

- ✅ Xcode Command Line Tools
- ✅ curl（下载文件）
- ✅ git（克隆仓库）
- ✅ python3（系统自带）

### 检查 Xcode Tools

```bash
xcode-select -p
```

如果报错，请先安装：

```bash
xcode-select --install
```

---

## 🎮 使用方法

### 启动脚本

```bash
./openclaw-china-installer.sh
```

或

```bash
bash openclaw-china-installer.sh
```

### 主菜单选项

启动后会显示主菜单：

```
╔════════════════════════════════════════════════════════════╗
║       OpenClaw 国内源安装器 V1.0.0                          ║
╚════════════════════════════════════════════════════════════╝

请选择安装模式：

  1) 🚀 快速安装（推荐）
     自动安装所有依赖和 OpenClaw

  2) ⚙️  自定义安装
     选择性安装组件

  3) 📋 查看系统信息
     检查当前环境

  4) ℹ️  关于
     查看版本和版权信息

  0) 🚪 退出
```

### 选项说明

#### 1. 快速安装（推荐）

自动安装所有组件：

- ✅ Node.js (LTS 版本)
- ✅ OpenClaw CLI
- ✅ oMLX 本地推理引擎
- ✅ gemma-4-e4b-it-4bit AI 模型

所有组件将从国内镜像源下载，速度更快！

#### 2. 自定义安装

选择性安装组件：

```
╔════════════════════════════════════════════════════════════╗
║       选择要安装的组件                                      ║
╚════════════════════════════════════════════════════════════╝

  [1] Node.js (JavaScript 运行环境)
  [2] OpenClaw CLI (AI 开发工具)
  [3] oMLX (本地推理引擎)
  [4] AI 模型 (gemma-4-e4b-it-4bit)

  [A] 全选
  [N] 取消所有选择
  [B] 返回主菜单
```

**操作说明**：
- 输入数字选择/取消对应组件
- 输入 `A` 全选所有组件
- 输入 `N` 取消所有选择
- 输入 `B` 返回主菜单

#### 3. 查看系统信息

显示当前系统状态：

- 操作系统信息
- 硬件配置
- 已安装组件
- 网络配置

#### 4. 关于

显示版本和版权信息：

- 项目名称和版本
- 作者和组织信息
- MIT 许可证全文
- 项目链接和文档

---

## ⚙️ 配置说明

### 国内镜像源

脚本使用以下国内镜像源加速下载：

#### Node.js
- **nvm 镜像**: https://npmmirror.com/mirrors/node
- **npm 镜像**: https://registry.npmmirror.com

#### Python
- **pip 镜像**: https://pypi.tuna.tsinghua.edu.cn/simple

### 自定义配置

可以通过环境变量自定义配置：

```bash
# 自定义安装目录
export NVM_DIR="$HOME/.nvm"
export OPENCLAW_INSTALL_DIR="$HOME/.openclaw"

# 自定义日志文件
export LOG_FILE="$HOME/openclaw-install.log"

# 执行安装
sudo bash openclaw-china-installer.sh
```

---

## 📦 安装组件说明

### Node.js

- **版本**: 最新 LTS 版本
- **安装方式**: 通过 nvm
- **配置**: 自动配置 npm 淘宝镜像

### OpenClaw CLI

- **版本**: 最新稳定版
- **安装方式**: 通过 npm 全局安装
- **源**: npm 淘宝镜像

### oMLX

- **版本**: 最新稳定版
- **安装方式**: 通过 pip3
- **源**: pip 清华镜像

### AI 模型

- **模型**: gemma-4-e4b-it-4bit
- **大小**: 约 4GB
- **安装方式**: 通过 OpenClaw 下载

---

## 🛠️ 安装后使用

### 验证安装

```bash
# 查看 OpenClaw 版本
openclaw --version

# 查看系统信息
openclaw system info
```

### 测试推理

```bash
# 测试推理功能
openclaw infer model run --model omlx/gemma-4-e4b-it-4bit --prompt "你好"

# 交互式对话
openclaw infer chat --model omlx/gemma-4-e4b-it-4bit
```

### 查看帮助

```bash
# 查看完整帮助
openclaw --help

# 查看特定命令帮助
openclaw infer --help
openclaw agents --help
```

---

## 🔍 故障排除

### 常见问题

#### 1. Xcode Command Line Tools 未安装

**错误信息**:
```
❌ Xcode Command Line Tools 未安装
```

**解决方法**:
```bash
xcode-select --install
```

等待安装完成后，重新运行脚本。

#### 2. 权限不足

**错误信息**:
```
npm ERR! EACCES: permission denied
```

**解决方法**:
```bash
# 使用 sudo 执行
sudo bash openclaw-china-installer.sh
```

#### 3. 网络连接问题

**错误信息**:
```
❌ 下载失败
```

**解决方法**:
- 检查网络连接
- 确认可以访问国内镜像源
- 尝试使用代理

#### 4. 磁盘空间不足

**错误信息**:
```
❌ 磁盘空间不足
```

**解决方法**:
```bash
# 检查可用空间
df -h /

# 清理磁盘空间
# 至少需要 20GB
```

### 查看日志

```bash
# 查看完整安装日志
cat ~/openclaw-install.log

# 查看最后 50 行
tail -50 ~/openclaw-install.log

# 实时监控
tail -f ~/openclaw-install.log
```

### 重新安装

```bash
# 清理旧安装
rm -rf ~/.nvm
rm -rf ~/.openclaw
pip3 uninstall omlx

# 重新安装
bash openclaw-china-installer.sh
```

---

## 📊 与其他安装方式的对比

### vs. 快速安装脚本 (quick-install.sh)

| 特性 | openclaw-china-installer | quick-install.sh |
|------|--------------------------|-------------------|
| 菜单系统 | ✅ 交互式菜单 | ❌ 无菜单 |
| 组件选择 | ✅ 可选择组件 | ❌ 全部安装 |
| 系统信息 | ✅ 显示系统状态 | ❌ 无此功能 |
| 国内源 | ✅ 内置配置 | ✅ 内置配置 |
| 文件大小 | ~26KB | ~15KB |

### vs. 完整安装脚本 (install.sh)

| 特性 | openclaw-china-installer | install.sh |
|------|--------------------------|------------|
| 复杂度 | ✅ 简单易用 | ⚠️  较复杂 |
| 依赖 | ✅ 最小依赖 | ⚠️ 依赖库文件 |
| 菜单 | ✅ 交互式菜单 | ⚠️ 选择式菜单 |
| 配置 | ✅ 国内源优化 | ✅ 完整配置 |

---

## 🎯 使用建议

### 推荐使用场景

**使用 openclaw-china-installer 当**：
- ✅ 想要交互式菜单体验
- ✅ 需要选择性安装组件
- ✅ 希望查看系统信息
- ✅ 使用国内镜像源加速
- ✅ 新手用户，需要引导

**使用 quick-install.sh 当**：
- ✅ 想要最快的安装速度
- ✅ 确定要安装所有组件
- ✅ 熟悉命令行操作
- ✅ 高级用户

**使用 install.sh 当**：
- ✅ 需要完整功能
- ✅ 生产环境部署
- ✅ 需要详细配置
- ✅ 需要断点续传

---

## 📚 相关文档

### 项目文档

- **README.md** - 项目总体介绍
- **config.md** - 完整配置参数说明
- **QUICK_INSTALL_GUIDE.md** - 快速安装指南
- **PIPEMODE_FIX.md** - 管道模式修复说明

### 技术文档

- **POSIX_COMPATIBILITY.md** - POSIX 兼容性说明
- **ENVIRONMENT_CHECK_IMPROVEMENT.md** - 环境检查改进说明

---

## 📞 获取帮助

**项目地址**: https://github.com/changzhi777/mactools

**问题反馈**: https://github.com/changzhi777/mactools/issues

**文档中心**: https://github.com/changzhi777/mactools/blob/main/README.md

**作者**: 外星动物（常智）  
**邮箱**: 14455975@qq.com  
**组织**: IoTchange

---

## 🔄 更新日志

### V1.0.0 (2026-04-12)

**新增**：
- ✅ 初始版本发布
- ✅ 交互式菜单系统
- ✅ 快速安装模式
- ✅ 自定义安装模式
- ✅ 系统信息查看
- ✅ 完整的版权信息
- ✅ 国内镜像源配置
- ✅ MIT 许可证

**功能**：
- ✅ 自动环境检测
- ✅ Node.js 安装（nvm + 淘宝镜像）
- ✅ OpenClaw 安装（npm 淘宝镜像）
- ✅ oMLX 安装（pip 清华镜像）
- ✅ AI 模型下载
- ✅ 安装验证
- ✅ 完成信息显示

---

## ⚖️ 许可证

MIT License

Copyright (C) 2026 IoTchange

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

---

**🎉 享受使用 OpenClaw 国内源安装器！**

**如有问题，请查看文档或提交 Issue。**
