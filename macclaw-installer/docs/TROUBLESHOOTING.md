# MacClaw Installer - 问题排查指南

**版本:** V1.0.1  
**作者:** 外星动物（常智）

---

## 🔧 常见问题

### 安装问题

#### Q1: 安装脚本无法执行

**症状:** 执行 `./install.sh` 时提示权限错误

**解决方案:**
```bash
chmod +x install.sh
./install.sh
```

#### Q2: macOS 版本不兼容

**症状:** 提示 macOS 版本过低

**解决方案:**
1. 升级 macOS 到 12.0 或更高版本
2. 或继续安装但可能遇到兼容性问题

#### Q3: 磁盘空间不足

**症状:** 安装过程中提示磁盘空间不足

**解决方案:**
```bash
# 检查可用空间
df -h /

# 清理磁盘空间
# 清空垃圾桶
rm -rf ~/.Trash/*

# 清理系统缓存
sudo rm -rf /Library/Caches/*
```

---

### Xcode Tools 问题

#### Q4: Xcode Tools 安装卡住

**症状:** 安装窗口弹出后无响应

**解决方案:**
1. 点击"安装"按钮
2. 等待安装完成（可能需要几分钟）
3. 如果超时，手动安装：
```bash
xcode-select --install
```

#### Q5: Xcode Tools 安装失败

**症状:** 提示安装失败

**解决方案:**
```bash
# 删除现有安装
sudo rm -rf /Library/Developer/CommandLineTools

# 重新安装
xcode-select --install
```

---

### Node.js 问题

#### Q6: nvm 安装失败

**症状:** nvm 无法正常工作

**解决方案:**
```bash
# 卸载现有 nvm
rm -rf ~/.nvm

# 清理配置
sed -i '' '/NVM_DIR/d' ~/.zshrc
sed -i '' '/nvm.sh/d' ~/.zshrc

# 重新安装
curl -o- https://gitee.com/mirrors/nvm/raw/master/install.sh | bash
```

#### Q7: Node.js 版本错误

**症状:** Node.js 版本不匹配

**解决方案:**
```bash
# 重新安装 Node.js
nvm install --lts
nvm use --lts
nvm alias default lts/*
```

---

### OpenClaw 问题

#### Q8: OpenClaw 安装失败

**症状:** npm install 失败

**解决方案:**
```bash
# 清理 npm 缓存
npm cache clean --force

# 重新安装
npm install -g openclaw
```

#### Q9: OpenClaw Gateway 无法启动

**症状:** Gateway 启动失败

**解决方案:**
```bash
# 查看错误日志
tail -f /tmp/openclaw/openclaw-*.log

# 检查端口占用
lsof -i :18789

# 重启 Gateway
openclaw gateway restart
```

#### Q10: OpenClaw 配置错误

**症状:** 配置文件无效

**解决方案:**
```bash
# 备份配置
cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.backup

# 重新初始化
openclaw onboard --non-interactive
```

---

### oMLX 问题

#### Q11: oMLX 下载失败

**症状:** DMG 文件下载失败

**解决方案:**
```bash
# 手动下载
curl -L -o /tmp/omlx.dmg \
  https://github.com/jundot/omlx/releases/download/v0.2.24/oMLX-0.2.24.arm64.dmg

# 手动安装
open /tmp/omlx.dmg
```

#### Q12: oMLX 服务无法启动

**症状:** oMLX 应用无法启动

**解决方案:**
```bash
# 检查进程
ps aux | grep omlx

# 强制重启
killall oMLX
open -a oMLX

# 检查健康状态
curl http://127.0.0.1:8008/health
```

#### Q13: oMLX API Key 错误

**症状:** 提示 API Key 无效

**解决方案:**
```bash
# 检查配置
cat ~/.omlx/settings.json | grep api_key

# 应该显示: "api_key": "ak47"

# 如果不是，手动修改
vim ~/.omlx/settings.json
```

---

### AI 模型问题

#### Q14: 模型下载失败

**症状:** ModelScope 下载失败

**解决方案:**
```bash
# 检查网络
ping hf-mirror.com

# 重新下载
modelscope download --model mlx-community/gemma-4-e4b-it-4bit

# 或手动下载
git clone https://www.modelscope.cn/mlx-community/gemma-4-e4b-it-4bit.git \
  ~/.modelscope/hub/mlx-community/gemma-4-e4b-it-4bit
```

#### Q15: 模型加载失败

**症状:** oMLX 无法加载模型

**解决方案:**
```bash
# 检查模型文件
ls -lh ~/.modelscope/hub/mlx-community/gemma-4-e4b-it-4bit

# 在 oMLX 应用中重新加载模型
# 1. 打开 oMLX 应用
# 2. 进入模型管理
# 3. 重新加载模型
```

#### Q16: 推理速度慢

**症状:** AI 响应速度很慢

**解决方案:**
```bash
# 检查内存使用
top | grep omlx

# 如果内存不足，考虑：
# 1. 关闭其他应用
# 2. 使用更小的模型
# 3. 增加 swap 空间
```

---

### Agent & Skills 问题

#### Q17: Agent 创建失败

**症状:** 无法创建 Agent

**解决方案:**
```bash
# 检查 Gateway 状态
openclaw gateway status

# 查看错误日志
tail -f /tmp/openclaw/openclaw-*.log

# 手动创建
openclaw agents add myagent \
  --workspace ~/.openclaw/workspace-myagent
```

#### Q18: Skills 无法加载

**症状:** Skill 安装后无法使用

**解决方案:**
```bash
# 列出已安装 Skills
openclaw skills list

# 重新安装
openclaw skills install skill-name --force

# 检查 Skill 权限
openclaw skills inspect skill-name
```

#### Q19: Agent Skills 不工作

**症状:** Agent 无法使用 Skill

**解决方案:**
```bash
# 检查 Agent Skills
openclaw agents skills list --agent myagent

# 重新绑定
openclaw agents skills attach myagent skill-name

# 测试 Skill
openclaw skills test skill-name
```

---

## 🔍 诊断工具

### 系统诊断

```bash
# 运行完整诊断
openclaw doctor

# 查看系统信息
sw_vers
uname -m
top -l 1 | head -10
df -h /
```

### 服务诊断

```bash
# OpenClaw Gateway
openclaw gateway status
tail -f /tmp/openclaw/openclaw-*.log

# oMLX
curl http://127.0.0.1:8008/health
ps aux | grep omlx

# 端口检查
lsof -i :18789
lsof -i :8008
```

### 日志查看

```bash
# 安装日志
cat ~/macclaw-install.log

# OpenClaw 日志
ls /tmp/openclaw/
tail -f /tmp/openclaw/openclaw-*.log

# oMLX 日志
ls ~/.omlx/logs/
tail -f ~/.omlx/logs/*.log
```

---

## 🆘 获取帮助

### 日志收集

提交问题时，请提供以下信息：

```bash
# 系统信息
sw_vers > ~/diagnostic-info.txt
uname -m >> ~/diagnostic-info.txt

# 服务状态
openclaw gateway status >> ~/diagnostic-info.txt
curl http://127.0.0.1:8008/health >> ~/diagnostic-info.txt

# 日志文件
tail -100 /tmp/openclaw/openclaw-*.log >> ~/diagnostic-info.txt
tail -100 ~/.omlx/logs/*.log >> ~/diagnostic-info.txt

# 配置文件
cat ~/.openclaw/openclaw.json >> ~/diagnostic-info.txt
cat ~/.omlx/settings.json >> ~/diagnostic-info.txt
```

### 问题反馈

**GitHub Issues:**  
https://github.com/changzhi777/mactools/issues

**邮件支持:**  
14455975@qq.com

**请包含:**
- 系统版本
- 错误信息
- 日志文件
- 复现步骤

---

## 🔄 卸载和重装

### 完全卸载

```bash
# 运行卸载脚本
./uninstall.sh

# 或手动删除
npm uninstall -g openclaw
rm -rf /Applications/oMLX.app
rm -rf ~/.openclaw
rm -rf ~/.omlx
rm -rf ~/.modelscope
```

### 重新安装

```bash
# 清理旧配置
rm -rf ~/macclaw-install.log

# 重新运行安装
./install.sh
```

---

## 💡 预防措施

### 定期备份

```bash
# 备份配置
cp ~/.openclaw/openclaw.json ~/backup/openclaw.json.backup
cp ~/.omlx/settings.json ~/backup/omlx.json.backup

# 备份对话历史
cp -r ~/.openclaw/workspace-main ~/backup/workspace-main
```

### 健康检查

```bash
# 定期检查服务状态
openclaw gateway status

# 检查磁盘空间
df -h /

# 检查内存使用
top -l 1 | head -10
```

### 更新组件

```bash
# 更新 OpenClaw
npm update -g openclaw

# 更新 oMLX
# 下载最新版本并替换
```

---

## 📞 紧急联系

**作者:** 外星动物（常智）  
**邮箱:** 14455975@qq.com  
**项目:** https://github.com/changzhi777/mactools

---

**🦞 祝您使用愉快！**
