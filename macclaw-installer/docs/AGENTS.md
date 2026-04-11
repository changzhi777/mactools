# MacClaw Installer - Agent 使用指南

**版本:** V1.0.1  
**作者:** 外星动物（常智）

---

## 🤖 什么是 Agent？

Agent（智能体）是 OpenClaw 的核心概念，每个 Agent 都是一个独立的 AI 助手，具有：
- 独立的配置
- 独立的模型
- 独立的工作空间
- 独立的对话历史
- 专属的技能包

---

## 📋 默认 Agents

### main Agent

**用途:** 通用对话和任务

**配置:**
- 模型: omlx/gemma-4-e4b-it-4bit
- 工作空间: ~/.openclaw/workspace-main
- Skills: file-operations, web-search, code-executor

**使用场景:**
- 日常对话
- 信息查询
- 代码编写
- 问题解答

### assistant Agent

**用途:** 文件操作和数据处理

**配置:**
- 模型: omlx/gemma-4-e4b-it-4bit
- 工作空间: ~/.openclaw/workspace-assistant
- Skills: file-operations, task-manager

**使用场景:**
- 文件管理
- 任务规划
- 数据处理
- 工作流程

---

## 🚀 使用 Agents

### 列出所有 Agents

```bash
openclaw agents list
```

输出示例:
```
main
  - workspace: ~/.openclaw/workspace-main
  - model: omlx/gemma-4-e4b-it-4bit
  - skills: file-operations, web-search, code-executor

assistant
  - workspace: ~/.openclaw/workspace-assistant
  - model: omlx/gemma-4-e4b-it-4bit
  - skills: file-operations, task-manager
```

### 切换 Agent

```bash
# 在对话中切换 Agent
openclaw agents use main
```

### 查看 Agent 配置

```bash
openclaw agents config main
```

---

## 🛠️ 创建自定义 Agent

### 基础创建

```bash
openclaw agents add myagent \
  --workspace ~/.openclaw/workspace-myagent \
  --non-interactive
```

### 配置模型

```bash
openclaw agents config myagent \
  --model omlx/gemma-4-eb-it-4bit
```

### 绑定 Skills

```bash
# 绑定单个 Skill
openclaw agents skills attach myagent file-operations

# 绑定多个 Skills
openclaw agents skills attach myagent web-search
openclaw agents skills attach myagent code-executor
```

### 验证创建

```bash
# 查看 Agent 配置
openclaw agents config myagent

# 查看 Agent Skills
openclaw agents skills list --agent myagent
```

---

## 📝 Agent 配置详解

### 工作空间

每个 Agent 都有独立的工作空间：

```bash
~/.openclaw/workspace-<agent-name>/
├── conversations/    # 对话历史
├── files/           # 文件存储
├── memory/          # 记忆存储
└── tasks/           # 任务列表
```

### 模型选择

为不同 Agent 选择不同模型：

```bash
# 高级 Agent（使用更强的模型）
openclaw agents config advanced \
  --model anthropic/claude-opus-4-6

# 快速 Agent（使用轻量模型）
openclaw agents config fast \
  --model omlx/gemma-4-e4b-it-4bit
```

### 系统提示词

为 Agent 设置系统提示词：

```bash
openclaw agents config myagent \
  --system-prompt "你是一个专业的代码助手，专注于 Python 开发"
```

---

## 🎯 Agent 使用场景

### 场景 1: 开发助手 Agent

```bash
# 创建
openclaw agents add developer \
  --workspace ~/.openclaw/workspace-developer

# 配置
openclaw agents config developer \
  --model omlx/gemma-4-e4b-it-4bit \
  --system-prompt "你是一个专业的软件开发助手"

# 绑定 Skills
openclaw agents skills attach developer code-executor
openclaw agents skills attach developer git-helper
```

### 场景 2: 写作助手 Agent

```bash
# 创建
openclaw agents add writer \
  --workspace ~/.openclaw/workspace-writer

# 配置
openclaw agents config writer \
  --model omlx/gemma-4-e4b-it-4bit \
  --system-prompt "你是一个专业的写作助手，擅长技术文档和博客"

# 绑定 Skills
openclaw agents skills attach writer file-operations
openclaw agents skills attach writer web-search
```

### 场景 3: 数据分析 Agent

```bash
# 创建
openclaw agents add analyst \
  --workspace ~/.openclaw/workspace-analyst

# 配置
openclaw agents config analyst \
  --model omlx/gemma-4-e4b-it-4bit \
  --system-prompt "你是一个数据分析专家"

# 绑定 Skills
openclaw agents skills attach analyst data-processor
openclaw agents skills attach analyst file-operations
```

---

## 🔄 Agent 管理

### 更新 Agent 配置

```bash
# 更改模型
openclaw agents config myagent --model new-model

# 更改系统提示词
openclaw agents config myagent --system-prompt "新的提示词"
```

### 删除 Agent

```bash
openclaw agents delete myagent
```

⚠️ **注意:** 删除 Agent 会删除其工作空间和所有数据。

### 导出 Agent 配置

```bash
# 导出为 JSON
openclaw agents config myagent --output json > myagent-config.json
```

---

## 💡 Agent 最佳实践

### 1. 合理分工

为不同任务创建专用 Agent：
- 通用对话 → main
- 代码开发 → developer
- 文件管理 → file-manager
- 数据分析 → analyst

### 2. 技能匹配

只绑定必要的 Skills：
- 代码 Agent → code-executor, git-helper
- 文件 Agent → file-operations, task-manager
- 数据 Agent → data-processor, web-search

### 3. 模型选择

根据任务复杂度选择模型：
- 简单任务 → omlx/gemma-4-e4b-it-4bit
- 复杂任务 → anthropic/claude-opus-4-6
- 快速响应 → 轻量模型

### 4. 提示词优化

为每个 Agent 设置清晰的系统提示词：
```bash
--system-prompt "你是一个专业的[角色]，专注于[领域]..."
```

---

## 🔍 Agent 调试

### 查看 Agent 日志

```bash
# 查看对话日志
ls ~/.openclaw/workspace-main/conversations/

# 查看最新对话
cat ~/.openclaw/workspace-main/conversations/*.json | tail -1
```

### 测试 Agent

```bash
# 测试推理
openclaw infer model run \
  --agent main \
  --prompt "测试消息"
```

### 检查 Agent 状态

```bash
# 查看所有 Agent
openclaw agents list

# 查看特定 Agent
openclaw agents config main
```

---

## 📚 进阶话题

### Agent 间通信

Agents 之间可以相互调用：
```bash
# 在 Agent A 中调用 Agent B
openclaw agents skills attach agent-a agent-communication
```

### Agent 工作流

创建工作流 Agent：
```bash
openclaw agents add workflow \
  --system-prompt "你是一个工作流协调者，负责调度其他 Agents"
```

### Agent 记忆系统

Agent 可以记忆对话历史：
```bash
openclaw agents config myagent \
  --memory-enabled true \
  --memory-retention 1000
```

---

## 🐛 常见问题

### Q1: Agent 无响应？

1. 检查 Gateway 状态：`openclaw gateway status`
2. 查看日志：`tail -f /tmp/openclaw/openclaw-*.log`
3. 重启 Gateway：`openclaw gateway restart`

### Q2: Agent 技能不工作？

1. 检查 Skills 是否安装：`openclaw skills list`
2. 检查 Agent Skills：`openclaw agents skills list --agent myagent`
3. 重新绑定 Skills：`openclaw agents skills attach myagent skill-name`

### Q3: 如何切换 Agent？

```bash
openclaw agents use agent-name
```

---

## 📞 获取帮助

- **完整文档:** https://github.com/IoTchange/macclaw-installer
- **问题反馈:** https://github.com/IoTchange/macclaw-installer/issues

---

**🦞 开始创建你的专属 Agent 吧！**
