# BB小子 Agent - 李小龙风格示例配置

这是BB小子 Agent的完整配置示例，展示了如何配置一个具有李小龙风格的AI助手。

## 🥋 BB小子简介

BB小子是一个基于OpenClaw框架的本地AI助手，配置为李小龙风格：
- **简洁直接**：不说废话，直奔主题
- **行动导向**：强调"知道不够，必须做到"
- **哲学融入**：功夫智慧融入日常对话
- **时间感知**：根据时间和工作日提供智能健康提醒

## 📋 核心功能

### 1. 时间感知健康提醒系统
- **喝水提醒**：根据时间动态提醒
- **运动提醒**："功夫不是吹出来的，是练出来的"
- **休息提醒**：防止久坐和过度疲劳
- **工作日激励**：融入截拳道哲学

### 2. 新闻收集技能
- Hacker News API实时科技新闻
- 李小龙风格的健康提醒融入
- 支持多种新闻类别

### 3. macOS提醒事项管理
- AppleScript真实提醒创建
- 智能时间感知提醒
- 李小龙风格的任务指导

### 4. 企业级工具链
- 依赖自动检查和修复
- 智能路径处理
- 完整的测试框架

## 🚀 快速开始

### 安装BB小子 Agent

使用macclaw-installer自动安装：

```bash
curl -fsSL https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw_install/install.zsh | zsh
```

选择"创建BB小子 Agent"选项即可。

### 手动安装

1. **复制配置到工作区**：
```bash
mkdir -p ~/.openclaw/workspaces/bb-kid/skills
cp -r bb-kid-example/* ~/.openclaw/workspaces/bb-kid/
```

2. **设置执行权限**：
```bash
chmod +x ~/.openclaw/workspaces/bb-kid/skills/*.zsh
chmod +x ~/.openclaw/workspaces/bb-kid/skills/*.sh
```

3. **测试技能**：
```bash
# 测试新闻收集
~/.openclaw/workspaces/bb-kid/skills/news-collector-bruce.zsh collect tech 3

# 测试健康提醒
bash ~/.openclaw/workspaces/bb-kid/skills/bruce-lee-reminders.sh smart
```

## 🎯 使用示例

### 收集科技新闻（含健康提醒）
```bash
~/.openclaw/workspaces/bb-kid/skills/news-collector-bruce.zsh collect tech 3
```

**输出示例**：
```
✓ 成功获取 3 条 Hacker News

🥋 李小龙提醒：
  下午时光，别让疲劳积累。
  💪 年轻也注意保持运动。功夫不是吹出来的，是练出来的。
  💧 记得喝水。
```

### 创建提醒事项（含健康指导）
```bash
~/.openclaw/workspaces/bb-kid/skills/macos-reminders-bruce.zsh create "功夫训练" "18:00" "今日练习"
```

**输出示例**：
```
✅ 提醒已创建。

🥋 知道不够，必须做到。别忘了：
  18:00: 功夫训练

💡 李小龙提醒：
  💪 年轻也注意保持运动。功夫不是吹出来的，是练出来的。
  🧘 别让身体僵硬。功夫讲究张弛有度。
```

### 独立健康提醒
```bash
bash ~/.openclaw/workspaces/bb-kid/skills/bruce-lee-reminders.sh smart
```

## 📁 配置文件说明

| 文件 | 说明 |
|------|------|
| `IDENTITY.md` | Agent身份定义（李小龙风格） |
| `USER.md` | 用户角色配置（李小龙） |
| `SOUL.md` | Agent灵魂和哲学（截拳道智慧） |
| `AGENTS.md` | Agent能力定义 |
| `TOOLS.md` | 可用工具列表 |
| `BRUCE_LEE_STYLE.md` | 对话风格指南 |
| `BRUCE_LEE_CONFIG_REPORT.md` | 配置完成报告 |
| `BRUCE_LEE_HEALTH_REMINDER_REPORT.md` | 健康提醒系统报告 |

## 🔧 技能文件说明

| 技能 | 功能 |
|------|------|
| `news-collector-bruce.zsh` | 李小龙风格新闻收集 |
| `macos-reminders-bruce.zsh` | 李小龙风格提醒事项 |
| `bruce-lee-reminders.sh` | 健康提醒系统 |
| `news-fetcher.sh` | Hacker News API集成 |
| `path-utils.sh` | 智能路径处理工具 |
| `dependency-check.sh` | 依赖检查和修复 |

## 🌟 核心特色

### 时间感知系统
- **工作日检测**：自动识别周一到周五
- **工作时间检测**：识别9:00-18:00
- **运动时间检测**：早晨6-8点，晚上18-20点
- **休息时间检测**：每2小时提醒休息

### 李小龙哲学
- **"Be water, my friend"** - 像水一样适应变化
- **"知道不够，必须做到"** - 强调实践和执行
- **"功夫不是吹出来的"** - 拒绝空谈，注重实效
- **简化是极致的复杂** - 追求简洁高效

## 📊 测试状态

✅ **26/26 测试通过** - 生产就绪

- 新闻收集功能：✅ 通过
- 提醒创建功能：✅ 通过
- 健康提醒系统：✅ 通过
- 时间感知系统：✅ 通过
- 路径处理工具：✅ 通过
- 依赖管理系统：✅ 通过

## 🎓 扩展BB小子

要自定义BB小子的技能和风格：

1. **修改对话风格**：编辑 `BRUCE_LEE_STYLE.md`
2. **添加新技能**：在 `skills/` 目录创建新的 `.zsh` 文件
3. **调整健康提醒**：修改 `bruce-lee-reminders.sh` 的时间逻辑
4. **更改Agent身份**：更新 `IDENTITY.md`、`USER.md`、`SOUL.md`

## 📚 更多资源

- [OpenClaw框架文档](https://github.com/openclaw-org)
- [macclaw-installer安装器](https://github.com/changzhi777/mactools)
- [李小龙哲学与截拳道](https://www.brucelee.com)

## 🥋

**"Be water, my friend."**
**"像水一样，我的朋友。"**

*"The key to immortality is first living a life worth remembering."*
*"不朽的关键是先过上值得铭记的生活。"*

---

**BB小子 Agent** - 以李小龙精神为您服务，关注您的健康和成长！
