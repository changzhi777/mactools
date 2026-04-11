# GitHub SSH Key 快速配置指南

**作者:** 外星动物（常智）  
**版本:** V1.0.1  
**时间:** 2026-04-11

---

## 🎯 配置目标

实现 GitHub 仓库免密码推送，使用 SSH key 认证。

---

## 📋 配置步骤

### 1️⃣ SSH 公钥（已生成）

```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKnrUY3G8HW06tag/6E7UkQi1MwXf30AtMxEGJUpyXY1 14455975@qq.com
```

### 2️⃣ 添加到 GitHub

1. 访问：https://github.com/settings/keys
2. 点击【New SSH key】
3. 标题：`MacClaw Installer - 2026-04-11`
4. 粘贴上面的公钥
5. 点击【Add SSH key】

### 3️⃣ 运行配置脚本

```bash
./setup-github-ssh.sh
```

### 4️⃣ 测试连接

```bash
ssh -T git@github.com
```

成功会显示：`Hi IoTchange! You've successfully authenticated...`

---

## 🔧 已完成的配置

### ✅ SSH 密钥对
- 私钥：`~/.ssh/id_ed25519`
- 公钥：`~/.ssh/id_ed25519.pub`

### ✅ SSH 客户端配置
```bash
~/.ssh/config
```

### ✅ Git 用户配置
```bash
user.name: 外星动物（常智）
user.email: 14455975@qq.com
```

---

## 📤 使用 SSH 推送

### 初始化仓库

```bash
cd macclaw-installer
git init
git add .
git commit -m "Initial commit"
git remote add origin git@github.com:IoTchange/macclaw-installer.git
git branch -M main
git push -u origin main
```

### 后续推送

```bash
git add .
git commit -m "commit message"
git push
```

---

## 🧪 验证配置

### 检查 SSH 连接

```bash
ssh -T git@github.com
```

### 查看 Git 配置

```bash
git config --global --list
```

### 查看远程仓库

```bash
git remote -v
```

应显示：`origin git@github.com:IoTchange/macclaw-installer.git`

---

## 🔄 从 HTTPS 切换到 SSH

### 查看当前远程地址

```bash
git remote -v
```

### 切换到 SSH

```bash
git remote set-url origin git@github.com:IoTchange/macclaw-installer.git
```

---

## 🐛 常见问题

### Q: SSH 连接失败？

**A:** 
1. 确认公钥已添加到 GitHub
2. 检查网络连接
3. 验证私钥权限：`ls -la ~/.ssh/id_ed25519`

### Q: 推送时仍要求密码？

**A:**
1. 确认远程地址使用 SSH：`git remote -v`
2. 如果是 HTTPS，切换到 SSH
3. 清理凭据：`git credential-osxkeychain erase`

### Q: Permission denied？

**A:**
```bash
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

---

## 📞 获取帮助

- **GitHub 文档:** https://docs.github.com/zh/authentication
- **SSH 设置:** https://github.com/settings/keys
- **项目地址:** https://github.com/IoTchange/macclaw-installer

---

**🦞 配置完成后，享受免密码推送！**
