# 🚀 MacClaw Installer - 快速安装

## 方法 1：一键安装（推荐）

复制以下命令并在终端中粘贴执行：

```bash
curl -fsSL https://raw.githubusercontent.com/changzhi777/macclaw-installer/main/install.zsh | zsh
```

**就这么简单！** 这一条命令将自动完成所有安装。

---

## 方法 2：下载后安装

如果一键安装遇到问题，使用此方法：

```bash
# 步骤 1：下载安装脚本
curl -fsSL https://raw.githubusercontent.com/changzhi777/macclaw-installer/main/install.zsh -o install.zsh

# 步骤 2：添加执行权限
chmod +x install.zsh

# 步骤 3：运行安装
./install.zsh
```

---

## 方法 3：使用 Git 克隆

适合开发者或需要查看代码的情况：

```bash
# 克隆仓库
git clone https://github.com/changzhi777/macclaw-installer.git
cd macclaw-installer

# 运行安装
chmod +x install.zsh
./install.zsh
```

---

## 📋 安装内容

- ✅ Homebrew（macOS 包管理器）
- ✅ Node.js 20.x LTS
- ✅ OpenClaw CLI（本地 AI 框架）
- ✅ oMLX 推理引擎（Apple Silicon 优化）
- ✅ gemma-4-e4b-it-4bit AI 模型（约 4GB）
- ✅ 开发者插件（编程助手、开发工具）

---

## ⏱️ 预计时间

**总计：15-30 分钟**

- 环境配置：5-10 分钟
- 算力配置：10-20 分钟（包括模型下载）
- OpenClaw 安装：2-5 分钟
- 测试和插件：2-3 分钟

---

## 🎯 安装选项

**交互式安装（默认）：**
```bash
./install.zsh
```

**自动安装（无交互）：**
```bash
./install.zsh --auto
```

**详细日志（调试用）：**
```bash
./install.zsh --verbose
```

**静默安装（只显示错误）：**
```bash
./install.zsh --silent
```

---

## 🗑️ 卸载

```bash
curl -fsSL https://raw.githubusercontent.com/changzhi777/macclaw-installer/main/uninstall.zsh | zsh
```

---

## ✅ 安装后验证

```bash
# 查看版本
openclaw --version

# 查看系统信息
openclaw system info

# 测试推理
openclaw infer model run --model omlx/gemma-4-e4b-it-4bit --prompt "你好"
```

---

## 📚 更多信息

- **完整文档**: [README.md](README.md)
- **安装指南**: [INSTALL_GUIDE.md](INSTALL_GUIDE.md)
- **快速参考**: [QUICK_REFERENCE.md](QUICK_REFERENCE.md)
- **项目主页**: https://github.com/changzhi777/macclaw-installer

---

## 💡 常见问题

### Q: 命令太长，容易复制错误？
**A:** 使用方法 2（下载后安装），更稳定。

### Q: 安装失败怎么办？
**A:** 查看安装日志：`cat ~/macclaw_install.log`

### Q: 需要多少磁盘空间？
**A:** 至少 20GB 可用空间

### Q: Intel Mac 可以使用吗？
**A:** 可以，但会跳过 oMLX 安装（仅支持 Apple Silicon）

---

**🦞 享受本地 AI 的强大能力！**
