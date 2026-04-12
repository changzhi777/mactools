# ⚡ 快速参考 - 一键安装命令

## 🎯 最简单的一键安装

```bash
curl -fsSL https://raw.githubusercontent.com/changzhi777/macclaw-installer/main/install.zsh | zsh
```

**这就是全部！** 这一条命令将：
- ✅ 安装 Homebrew
- ✅ 安装 Node.js 20.x LTS
- ✅ 安装 OpenClaw CLI
- ✅ 配置 oMLX（Apple Silicon）
- ✅ 下载 gemma-4-e4b-it-4bit AI 模型
- ✅ 安装开发者插件

**预计时间**: 15-30 分钟

---

## 📋 所有可用的一键安装命令

### 1. 标准一键安装（推荐）

```bash
curl -fsSL https://raw.githubusercontent.com/changzhi777/macclaw-installer/main/install.zsh | zsh
```

**特点：**
- 🎯 交互式菜单，友好易用
- 🇨🇳 自动使用国内镜像源
- 🤖 智能模型推荐（根据芯片和内存）
- 📊 详细的进度显示

---

### 2. 自动安装（无交互）

```bash
curl -fsSL https://raw.githubusercontent.com/changzhi777/macclaw-installer/main/install.zsh | zsh -s -- --auto
```

**特点：**
- 🤖 完全自动，无需任何交互
- ⚡ 适合自动化脚本
- 🔄 适合 CI/CD 集成

---

### 3. 静默安装（最小输出）

```bash
curl -fsSL https://raw.githubusercontent.com/changzhi777/macclaw-installer/main/install.zsh | zsh -s -- --silent
```

**特点：**
- 🤫 最小输出，仅显示错误
- 📋 适合后台运行
- 🚀 最快的安装速度

---

### 4. 使用 wget

```bash
wget -qO- https://raw.githubusercontent.com/changzhi777/macclaw-installer/main/install.zsh | zsh
```

---

### 5. 下载后安装（可查看代码）

```bash
# 1. 下载脚本
curl -fsSL https://raw.githubusercontent.com/changzhi777/macclaw-installer/main/install.zsh -o macclaw-install.zsh

# 2. 查看脚本内容（可选）
cat macclaw-install.zsh

# 3. 添加执行权限
chmod +x macclaw-install.zsh

# 4. 执行安装
./macclaw-install.zsh
```

---

### 6. 从 GitHub 克隆（开发者）

```bash
# 1. 克隆仓库
git clone https://github.com/changzhi777/mactools.git
cd mactools/macclaw_install

# 2. 查看文件（可选）
ls -la

# 3. 运行安装
chmod +x install.zsh
./install.zsh
```

---

## 🎨 安装后的快速验证

安装完成后，运行以下命令验证：

```bash
# 1. 查看 OpenClaw 版本
openclaw --version

# 2. 查看系统信息
openclaw system info

# 3. 测试推理
openclaw infer model run --model omlx/gemma-4-e4b-it-4bit --prompt "你好"

# 4. 查看帮助
openclaw --help
```

---

## 🗑️ 一键卸载

```bash
curl -fsSL https://raw.githubusercontent.com/changzhi777/macclaw-installer/main/uninstall.zsh | zsh
```

---

## 📚 更多信息

- **完整文档**: [README.md](README.md)
- **安装指南**: [INSTALL_GUIDE.md](INSTALL_GUIDE.md)
- **更新日志**: [CHANGELOG.md](CHANGELOG.md)
- **项目主页**: https://github.com/changzhi777/mactools

---

## 💡 提示

1. **网络要求**: 确保网络连接稳定，国内源已配置
2. **磁盘空间**: 至少 20GB 可用空间
3. **系统要求**: macOS 12+，推荐 Apple Silicon
4. **安装时间**: 首次安装约 15-30 分钟

---

**🦞 享受本地 AI 的强大能力！**
