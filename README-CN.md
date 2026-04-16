# Windows 11 OpenClaw 环境一键配置脚本

<div align="center">

**自动化安装和配置 OpenClaw 运行所需的所有环境组件**

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)](https://www.microsoft.com/en-us/download/details.aspx?id=50995)
[![Platform](https://img.shields.io/badge/Platform-Windows%2011-green.svg)](https://www.microsoft.com/en-us/windows/get-windows-11)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-1.1.0-red.svg)](Install-OpenClaw.ps1)

作者：**BB小子 🤙** |
创建日期：2026-04-16 |
版本：1.1.0

</div>

---

## 📋 目录

- [功能特性](#功能特性)
- [系统要求](#系统要求)
- [快速开始](#快速开始)
- [使用说明](#使用说明)
- [功能详解](#功能详解)
- [常见问题](#常见问题)
- [故障排查](#故障排查)
- [更新日志](#更新日志)
- [许可证](#许可证)

---

## ✨ 功能特性

### 🚀 核心功能

- ✅ **一键安装** - 自动安装 Node.js、Python、Git、Windows Terminal
- ✅ **智能检测** - 自动检测已安装组件，避免重复安装
- ✅ **国内镜像** - 内置国内镜像源，下载速度快
- ✅ **离线支持** - 支持下载离线安装包，无网络环境也能安装
- ✅ **错误处理** - 完善的错误处理和日志记录
- ✅ **进度显示** - 实时显示安装进度和状态
- ✅ **彩色输出** - 清晰的彩色终端输出，易读性强
- ✅ **环境验证** - 安装后自动验证所有组件

### 🛠️ 高级功能

- 🔧 **组件更新** - 更新已安装组件到最新版本
- 🗑️ **完全卸载** - 卸载所有已安装的组件
- 🩺 **健康检查** - 检查环境状态和配置
- ⚙️ **镜像配置** - 单独配置 npm、Git 等镜像源
- 📊 **日志查看** - 查看安装历史和错误日志
- 🔄 **安装修复** - 修复损坏的组件安装

---

## 💻 系统要求

### 硬件要求

| 组件 | 最低要求 | 推荐配置 |
|------|---------|---------|
| 处理器 | 双核 CPU | 四核及以上 |
| 内存 | 4 GB RAM | 8 GB 及以上 |
| 硬盘 | 5 GB 可用空间 | 10 GB 及以上 SSD |

### 软件要求

- **操作系统**：Windows 11（构建号 22000 及以上）
- **PowerShell**：5.1 或更高版本
- **权限**：管理员权限（安装必需）

### 检查系统版本

```powershell
# 检查 Windows 版本
[System.Environment]::OSVersion.VersionString

# 检查 PowerShell 版本
$PSVersionTable.PSVersion

# 检查构建号
(Get-CimInstance Win32_OperatingSystem).BuildNumber
```

---

## 🚀 快速开始

### 方式一：交互式菜单（推荐）

1. 下载脚本到本地目录
2. 右键点击脚本 → **"以管理员身份运行"**
3. 在菜单中选择 **"1. 全新安装"**
4. 等待安装完成

### 方式二：命令行参数

```powershell
# 以管理员身份打开 PowerShell，然后：

# 全新安装
.\Install-OpenClaw.ps1 -Install

# 仅检查环境
.\Install-OpenClaw.ps1 -Check

# 仅配置镜像源
.\Install-OpenClaw.ps1 -ConfigureMirrors

# 下载离线安装包
.\Install-OpenClaw.ps1 -DownloadOffline

# 更新组件
.\Install-OpenClaw.ps1 -Update

# 修复安装
.\Install-OpenClaw.ps1 -Repair

# 卸载
.\Install-OpenClaw.ps1 -Uninstall
```

### 方式三：一键命令

```powershell
# 以管理员身份打开 PowerShell，运行：
irm https://raw.githubusercontent.com/your-repo/Install-OpenClaw.ps1 | iex
```

---

## 📖 使用说明

### 1. 下载脚本

从 GitHub 下载 `Install-OpenClaw.ps1` 文件到本地目录：

```powershell
# 使用 PowerShell 下载
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/your-repo/main/Install-OpenClaw.ps1" -OutFile "Install-OpenClaw.ps1"
```

### 2. 以管理员身份运行

**方法 A：右键菜单**
1. 右键点击 `Install-OpenClaw.ps1`
2. 选择 **"以管理员身份运行"**

**方法 B：PowerShell**
```powershell
# 以管理员身份打开 PowerShell，然后：
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
.\Install-OpenClaw.ps1
```

### 3. 选择功能

在主菜单中选择需要的功能：

```
╔════════════════════════════════════════════════════════════╗
║        OpenClaw 环境配置脚本 v1.0.0                       ║
║        by BB小子 🤙                                         ║
║                                                                ║
╚════════════════════════════════════════════════════════════╝

【主菜单】
  1. 全新安装
  2. 更新组件
  3. 卸载
  4. 修复安装
  5. 检查环境
  6. 配置镜像源
  7. 查看日志
  8. 退出

请选择操作（1-8）：
```

---

## 🔧 功能详解

### 1. 全新安装

自动安装以下组件：

| 组件 | 版本 | 说明 |
|------|------|------|
| **Node.js** | 22.14.0 LTS | JavaScript 运行时 |
| **Python** | 3.12.0 | Python 解释器 |
| **Git** | 最新版 | 版本控制系统 |
| **Windows Terminal** | 最新版 | 现代终端模拟器 |
| **npm 镜像** | 淘宝镜像 | npm 包管理器加速 |

**安装位置：**
- Node.js: `%LOCALAPPDATA%\Programs\nodejs`
- Python: `%LOCALAPPDATA%\Programs\Python`
- Git: `%ProgramFiles%\Git`
- Windows Terminal: Microsoft Store 安装

**输出示例：**
```
╔════════════════════════════════════════════════════════════╗
║          开始全新安装 OpenClaw 环境                     ║
╚════════════════════════════════════════════════════════════╝

=== 配置国内镜像源 ===
✓ npm 镜像配置完成

=== 安装 Node.js ===
✓ 下载完成，文件大小: 35.24 MB
✓ Node.js 安装完成

=== 安装 Python ===
✓ Python 安装完成

=== 安装 Git ===
✓ Git 安装完成

=== 安装 Windows Terminal ===
✓ Windows Terminal 安装完成

组件安装状态:
  Node.js: ✓ 成功
  Python: ✓ 成功
  Git: ✓ 成功
  Windows Terminal: ✓ 成功

总耗时: 5 分 23 秒
日志文件: C:\Users\YourName\Documents\openclaw-installer\logs\install-20260416-145234.log

╔════════════════════════════════════════════════════════════╗
║              环境配置完成！开始安装 OpenClaw              ║
╚════════════════════════════════════════════════════════════╝

请运行以下命令安装 OpenClaw:

  powershell -c "irm https://openclaw.ai/install.ps1 | iex"
```

### 2. 更新组件

检查并更新所有组件到最新版本。

**更新策略：**
- 检查当前版本和最新版本
- 下载并安装更新
- 保留用户配置

### 3. 卸载

完全卸载所有已安装的组件。

**安全机制：**
- 需要输入 **"确认"** 才能执行
- 备份配置文件
- 清理环境变量

**卸载顺序：**
1. Windows Terminal
2. Git
3. Python
4. Node.js
5. 配置文件和目录

### 4. 修复安装

检测并修复损坏的组件。

**修复项目：**
- 缺失的文件
- 错误的环境变量
- 损坏的配置

### 5. 检查环境

显示当前环境状态报告。

**检查内容：**
- ✅ 操作系统版本
- ✅ PowerShell 版本
- ✅ 管理员权限
- ✅ 网络连接
- ✅ 已安装组件
- ✅ npm 镜像配置

**输出示例：**
```
=== 检查系统先决条件 ===

检查 PowerShell 版本...
  当前版本: 5.1.22621.2506
  ✓ PowerShell 版本符合要求

检查管理员权限...
  ✓ 已获得管理员权限

检查操作系统版本...
  版本: Microsoft Windows NT 10.0.22631.0
  构建号: 22631
  ✓ Windows 11 检测通过

测试网络连接...
  ✓ https://www.baidu.com
  ✓ https://registry.npmmirror.com
  ✓ https://github.com
  ✓ 网络连接正常

✓ 所有检查通过！
```

### 6. 配置镜像源

配置国内镜像源加速下载。

**配置项目：**
- npm registry（淘宝镜像）
- Git 代理（可选）

### 7. 查看日志

查看安装历史和错误日志。

**日志位置：**
```
%USERPROFILE%\Documents\openclaw-installer\logs\
```

---

## 🌐 国内镜像源配置

脚本已内置以下国内镜像源：

### npm 淘宝镜像

```json
{
  "registry": "https://registry.npmmirror.com"
}
```

### Node.js 下载镜像

```
https://npmmirror.com/mirrors/node
```

### Git 镜像

```
https://mirrors.tuna.tsinghua.edu.cn/git-for-windows
```

### GitHub 代理

```
https://mirror.ghproxy.com/https://github.com
```

---

## 📦 离线安装

### 1. 下载离线包

在有网络的机器上运行：

```powershell
.\Install-OpenClaw.ps1 -DownloadOffline
```

所有安装包将下载到：
```
%USERPROFILE%\Documents\openclaw-installer\packages\
```

### 2. 复制到目标机器

将整个 `openclaw-installer` 目录复制到目标机器。

### 3. 运行离线安装

```powershell
.\Install-OpenClaw.ps1 -Install -Offline
```

---

## ❓ 常见问题

### Q1: 为什么需要管理员权限？

**A:** 安装系统组件需要管理员权限：
- 写入 `Program Files` 目录
- 修改系统环境变量
- 注册 COM 组件

### Q2: 如何查看安装日志？

**A:** 有三种方式：

1. **菜单方式**：选择 **"7. 查看日志"**
2. **日志目录**：`%USERPROFILE%\Documents\openclaw-installer\logs\`
3. **命令行**：
```powershell
Get-Content "$env:USERPROFILE\Documents\openclaw-installer\logs\install-*.log" | Select-Object -Last 50
```

### Q3: 安装失败怎么办？

**A:** 按以下步骤排查：

1. 检查日志文件获取详细错误信息
2. 确认网络连接正常
3. 确认有足够的磁盘空间
4. 尝试使用 **"4. 修复安装"** 功能
5. 查看下方「故障排查」章节

### Q4: 可以只安装部分组件吗？

**A:** 当前版本不支持选择性安装，但你可以：
1. 运行完整安装
2. 手动卸载不需要的组件
3. 后续版本将支持自定义安装

### Q5: 如何卸载？

**A:** 两种方式：

1. **脚本卸载**：选择 **"3. 卸载"**
2. **手动卸载**：
   - Windows 控制面板 → 程序和功能
   - 选择对应程序卸载

### Q6: 支持哪些 Windows 版本？

**A:** 官方支持：
- ✅ Windows 11（所有版本）
- ⚠️ Windows 10（部分支持，构建号 19041+）

### Q7: 安装后如何验证？

**A:** 运行以下命令：

```powershell
# 检查 Node.js
node --version

# 检查 Python
python --version

# 检查 Git
git --version

# 或直接运行
.\Install-OpenClaw.ps1 -Check
```

---

## 🔍 故障排查

### 问题 1：PowerShell 执行策略限制

**错误信息：**
```
无法加载文件 Install-OpenClaw.ps1，因为在此系统上禁止运行脚本
```

**解决方案：**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
```

### 问题 2：网络连接失败

**症状：** 下载组件时超时或失败

**解决方案：**
1. 检查网络连接
2. 尝试使用 VPN
3. 使用离线安装模式
4. 配置系统代理

### 问题 3：安装程序卡住

**症状：** 安装进度长时间不动

**解决方案：**
1. 等待 5-10 分钟（大型组件需要时间）
2. 检查任务管理器是否有进程运行
3. 重启计算机后重试
4. 使用修复安装功能

### 问题 4：环境变量未生效

**症状：** 安装成功但命令未找到

**解决方案：**
```powershell
# 刷新环境变量
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

# 或重启 PowerShell
```

### 问题 5：Windows Terminal 安装失败

**症状：** winget 安装 Windows Terminal 失败

**解决方案：**
1. 手动从 Microsoft Store 安装
2. 或使用以下命令：
```powershell
# Microsoft Store 方式
start ms-windows-store://pdp/?productid=9N0DX20HK701
```

---

## 📊 文件结构

安装后的文件结构：

```
%USERPROFILE%\Documents\openclaw-installer\
├── logs\                          # 日志目录
│   ├── install-20260416-145234.log
│   └── install-20260416-150123.log
├── backup\                        # 备份目录
│   └── config-backup-20260416.json
├── packages\                      # 离线安装包目录
│   ├── node-v22.14.0-win-x64.zip
│   ├── python-3.12.0-amd64.exe
│   └── Git-64-bit.exe
└── config.json                    # 配置文件（可选）
```

---

## 🔄 更新日志

### v1.1.0 (2026-04-16)

**新增功能：**
- ✨ 完整实现所有核心功能
- ✅ 组件更新功能 - 检查并更新已安装组件
- ✅ 完整卸载功能 - 卸载所有组件并备份配置
- ✅ 修复安装功能 - 检测并修复损坏的组件
- ✅ 离线安装支持 - 下载离线包并安装

**优化改进：**
- 🔧 重构代码结构，使用配置哈希表管理组件
- 🔧 抽象通用下载函数，减少代码重复
- 🔧 添加完整的参数验证
- 🔧 改进错误处理和日志记录
- 🔧 修复 Node.js 安装的架构变量问题
- 🔧 优化环境变量刷新机制

**修复问题：**
- 🐛 修复 Node.js 安装时的架构变量未定义问题
- 🐛 修复下载事件可能导致的内存泄漏
- 🐛 修复部分函数缺少错误处理的问题

### v1.0.0 (2026-04-16)

**新增功能：**
- ✨ 首次发布
- ✅ 支持一键安装 Node.js、Python、Git、Windows Terminal
- ✅ 内置国内镜像源
- ✅ 完善的错误处理和日志系统
- ✅ 交互式菜单界面
- ✅ 彩色输出和进度显示

---

## 🤝 贡献

欢迎贡献代码、报告问题或提出建议！

### 如何贡献

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

---

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

---

## 🙏 致谢

- [OpenClaw](https://openclaw.ai) - 优秀的开源 AI 助手项目
- [Node.js](https://nodejs.org/) - JavaScript 运行时
- [Python](https://www.python.org/) - Python 编程语言
- [Git](https://git-scm.com/) - 版本控制系统
- [PowerShell](https://docs.microsoft.com/en-us/powershell/) - 微软命令行外壳

---

## 📞 联系方式

- **作者**：BB小子 🤙
- **项目**：[GitHub Repository](https://github.com/your-username/openclaw-installer)
- **问题反馈**：[GitHub Issues](https://github.com/your-username/openclaw-installer/issues)

---

## 📜 许可证

MIT License

Copyright (c) 2026 BB小子

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

---

<div align="center">

**如果觉得这个项目对你有帮助，请给一个 ⭐ Star！**

Made with ❤️ by BB小子 🤙

</div>
