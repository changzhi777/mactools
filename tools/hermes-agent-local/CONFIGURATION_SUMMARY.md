# Hermes Agent 配置完成总结

**配置时间**: 2026-04-12
**Provider**: 智谱 AI (Zhipu)
**模型**: GLM-5.1

---

## ✅ 配置完成

### 已配置内容
- ✅ **API Key**: fb153032...nwodMQ（已验证）
- ✅ **Provider**: 智谱 AI (Zhipu)
- ✅ **模型**: GLM-5.1
- ✅ **Hermes Agent**: v0.8.0
- ✅ **启动脚本**: ~/.local/bin/hermes-glm
- ✅ **环境配置**: ~/.zshrc.hermes
- ✅ **诊断通过**: 所有检查正常

---

## 🚀 启动方式

### 方式 1：快速启动命令（最简单）

```bash
hermes-glm chat
```

### 方式 2：快捷命令（需先 source ~/.zshrc）

```bash
hermes-chat
```

### 方式 3：完整命令

```bash
export ZHIPUAI_API_KEY="fb153032e213302736bb4de1f0deda84.MCZpXWmKl8nwodMQ"
export PATH="$HOME/.local/bin:$PATH"
cd ~/.hermes/hermes-agent
hermes chat
```

---

## 📋 常用命令

```bash
# 启动聊天
hermes-glm chat

# 查看状态
hermes-glm status

# 查看配置
hermes-glm config

# 管理技能
hermes-glm skills

# 配置工具
hermes-glm tools

# 会话管理
hermes-glm sessions

# 诊断检查
hermes-glm doctor

# 查看帮助
hermes-glm --help
```

---

## 🎯 首次使用建议

### 1. 重新加载配置

```bash
source ~/.zshrc
```

### 2. 启动聊天

```bash
hermes-glm chat
```

### 3. 开始对话

GLM-5.1 具有以下特点：
- ✅ 长程任务能力（8小时持续工作）
- ✅ 强大的编码能力（SWE-Bench Pro: 58.4）
- ✅ 深度思考模式
- ✅ 中文优化

---

## 📚 GLM-5.1 能力

### 推荐场景
- **Agentic Coding**: 长程编程任务
- **通用对话**: 复杂指令理解
- **创意写作**: 文学化表达
- **前端开发**: 网页和交互页面
- **Office 生产力**: 文档生成

### 技术规格
- **上下文窗口**: 200K tokens
- **最大输出**: 128K tokens
- **思考模式**: 支持
- **Function Call**: 支持
- **流式输出**: 支持

---

## 🔧 故障排查

### 问题 1：命令找不到

```bash
# 解决方案 1：使用完整路径
~/.local/bin/hermes-glm chat

# 解决方案 2：重新加载配置
source ~/.zshrc

# 解决方案 3：手动设置环境变量
export PATH="$HOME/.local/bin:$PATH"
hermes-glm chat
```

### 问题 2：API 连接失败

```bash
# 验证 API Key
export ZHIPUAI_API_KEY="fb153032e213302736bb4de1f0deda84.MCZpXWmKl8nwodMQ"
curl -X POST "https://open.bigmodel.cn/api/paas/v4/chat/completions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ZHIPUAI_API_KEY" \
  -d '{"model": "glm-5.1", "messages": [{"role": "user", "content": "你好"}]}'
```

### 问题 3：模型选择

```bash
# 查看可用模型
hermes-glm model

# 选择 GLM-5.1
hermes-glm model
# 选择: Z.AI/GLM -> glm-5.1
```

---

## 📞 获取帮助

### 内置帮助
```bash
hermes-glm --help           # 基本帮助
hermes-glm --help-all       # 所有命令帮助
hermes-glm <cmd> --help     # 特定命令帮助
```

### 官方文档
- **Hermes Agent**: https://docs.nousresearch.com
- **智谱 AI**: https://open.bigmodel.cn/dev/api
- **GLM-5.1**: https://docs.bigmodel.cn/cn/guide/capabilities/thinking-mode

---

## ✅ 配置成功！

**Hermes Agent 已成功配置并可以使用智谱 AI GLM-5.1！**

**立即启动**：
```bash
source ~/.zshrc
hermes-glm chat
```

**祝您使用愉快！** 🚀✨

---

**配置完成时间**: 2026-04-12
**配置版本**: v1.0.0
**作者**: 外星动物（常智）
**版权**: Copyright (C) 2026 IoTchange - All Rights Reserved
