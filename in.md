# MacTools 一键安装命令

## 🚀 推荐安装命令

### 方法 1: Bash 版本（功能完整）

```bash
curl -fsSL https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw-installer/install.sh | sudo bash
```

### 方法 2: POSIX sh 版本（兼容性更好）

```bash
curl -fsSL https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw-installer/install-posix.sh | sudo sh
```

---

## 📥 分步安装（推荐，更安全）

### 步骤 1: 下载安装脚本

```bash
curl -fsSL https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw-installer/install.sh -o install.sh
```

### 步骤 2: 查看脚本内容（确认安全）

```bash
cat install.sh
```

### 步骤 3: 执行安装

```bash
sudo bash install.sh
```

### 步骤 4: 清理安装脚本

```bash
rm install.sh
```

---

## ⚠️ 重要提示

### URL 注意事项

**✅ 正确的 URL**（无空格）：
```
https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw-installer/install.sh
```

**❌ 错误的 URL**（有空格）：
```
https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw -installer/install.sh
                                                                          ↑ 这里不能有空格！
```

### 关键点

- `macclaw-installer` 是一个完整的单词
- 中间没有空格
- 使用连字符 `-` 连接

---

## 🔧 其他安装方式

### 不使用 sudo（可能权限不足）

```bash
curl -fsSL https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw-installer/install.sh | bash
```

### 下载后手动执行

```bash
# 下载
curl -O https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw-installer/install.sh

# 执行
sudo bash install.sh
```

---

## 📋 安装前检查

### 系统要求

- macOS 12 或更高版本
- Xcode Command Line Tools
- 至少 16GB 内存
- 至少 20GB 可用磁盘空间

### 检查 Xcode Tools

```bash
xcode-select -p
```

如果返回路径，说明已安装。如果报错，请先安装：

```bash
xcode-select --install
```

---

## 🎯 快速复制命令

### 最简单的一行命令（推荐）

```bash
curl -fsSL https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw-installer/install.sh | sudo bash
```

**使用方法**：
1. 复制整行命令
2. 粘贴到终端
3. 按回车执行
4. 输入密码（如果需要）

---

## 🛠️ 安装后验证

### 检查 Node.js

```bash
node --version
```

### 检查 OpenClaw

```bash
openclaw --version
```

### 检查服务状态

```bash
openclaw gateway status
```

---

## 📞 获取帮助

**项目地址**: https://github.com/changzhi777/mactools

**问题反馈**: https://github.com/changzhi777/mactools/issues

**作者**: 外星动物（常智）
**邮箱**: 14455975@qq.com

---

## 🔄 更新日志

### V1.0.1 (2026-04-12)

- ✅ 修复管道模式下脚本阻塞问题
- ✅ 修复 POSIX 兼容性问题
- ✅ 增强基础环境检查
- ✅ 完善文档和测试

---

**🎉 享受使用 MacTools！**
