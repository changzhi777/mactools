# 更新日志

所有重要变更都将记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

---

## [1.0.0] - 2026-04-12

### 🎉 首次发布

#### 新增
- ✨ 完整的本地安装脚本系统
  - `install.sh` - 主安装脚本（macOS/Linux/WSL2）
  - `install.ps1` - Windows PowerShell 安装脚本
  - `verify.sh` - 安装验证脚本
  - `uninstall.sh` - 卸载脚本

#### 功能模块
- 🔧 **logger.sh** - 日志和彩色输出模块
  - 支持彩色终端输出
  - 多级别日志（info, success, warning, error, debug）
  - 交互式用户询问
  - 进度显示

- 🔍 **detector.sh** - 环境检测模块
  - 操作系统检测（macOS/Linux/WSL2/Termux）
  - Python 版本检测
  - uv 包管理器检测
  - Git 检测
  - Node.js 检测（可选）

- ✅ **validator.sh** - 依赖验证模块
  - Python 环境验证
  - uv 包管理器验证
  - Git 验证
  - 网络连接验证
  - 文件权限验证
  - 自动安装缺失依赖

- 🛠️ **utils.sh** - 工具函数模块
  - 版本比较
  - 文件操作（安全删除、备份、创建目录）
  - 下载工具（curl/wget）
  - 字符串处理
  - 进度显示
  - 交互式菜单
  - 系统信息获取

#### 配置文件
- ⚙️ **hermes.conf** - 主配置文件
  - 安装目录配置
  - Python 版本配置
  - uv 包管理器配置
  - 网络配置
  - 日志配置

- ⚙️ **extras.conf** - 可选依赖配置
  - 功能扩展包配置
  - 开发工具配置
  - 数据存储配置
  - 高级选项配置

#### 特性
- ✅ 自动环境检测和依赖安装
- ✅ 使用 uv 包管理器快速安装依赖
- ✅ 支持虚拟环境和系统 Python
- ✅ 交互式配置向导
- ✅ 完整的安装验证功能
- ✅ 支持自定义安装选项
- ✅ 友好的卸载功能
- ✅ 详细的日志和错误提示
- ✅ 中文界面和文档

#### 文档
- 📚 **README.md** - 完整使用文档
  - 快速开始指南
  - 详细安装说明
  - 验证和卸载指南
  - 故障排查
  - 配置文件说明

- 📋 **CHANGELOG.md** - 版本更新日志

#### 版权信息
- 📄 所有源文件包含完整的版权和作者信息
  - 作者: 外星动物（常智）
  - 组织: IoTchange
  - 邮箱: 14455975@qq.com
  - 版权: Copyright (C) 2026 IoTchange - All Rights Reserved

---

## [未来版本]

### 计划中的功能
- 🔜 Windows 原生支持完善
- 🔜 Docker 容器化安装支持
- 🔜 自动更新功能
- 🔜 更多验证和诊断工具
- 🔜 性能优化和错误处理增强

---

## 版本说明

版本号格式：`主版本号.次版本号.修订号`

- **主版本号**：不兼容的 API 修改
- **次版本号**：向下兼容的功能性新增
- **修订号**：向下兼容的问题修正

---

## 链接

- **当前版本**: [1.0.0](https://github.com/NousResearch/hermes-agent)
- **GitHub 仓库**: https://github.com/NousResearch/hermes-agent
- **问题反馈**: https://github.com/NousResearch/hermes-agent/issues

---

**维护者**: 外星动物（常智） <14455975@qq.com>
