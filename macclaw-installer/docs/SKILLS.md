# MacClaw Installer - Skills 开发指南

**版本:** V1.0.1  
**作者:** 外星动物（常智）

---

## 📦 什么是 Skills？

Skills（技能包）是 OpenClaw 的扩展插件，为 Agent 提供额外的功能：
- 文件操作
- 网络搜索
- 代码执行
- 数据处理
- 任务管理
- Git 操作
- 等等...

---

## 🔍 查看可用 Skills

### 列出已安装 Skills

```bash
openclaw skills list
```

### 查看技能详情

```bash
openclaw skills inspect <skill-name>
```

---

## 📥 安装 Skills

### 安装单个 Skill

```bash
openclaw skills install file-operations
```

### 安装多个 Skills

```bash
openclaw skills install file-operations web-search code-executor
```

### 从本地安装

```bash
openclaw skills install /path/to/skill-directory
```

---

## 🤖 为 Agent 配置 Skills

### 绑定 Skill 到 Agent

```bash
openclaw agents skills attach main file-operations
```

### 查看Agent Skills

```bash
openclaw agents skills list --agent main
```

### 移除 Agent Skill

```bash
openclaw agents skills detach main file-operations
```

---

## 🛠️ 常用 Skills 详解

### file-operations

**功能:** 文件和目录操作

**能力:**
- 读取文件
- 写入文件
- 创建目录
- 删除文件
- 文件搜索

**使用示例:**
```
Agent: 请读取 /path/to/file.txt
Agent: 创建一个新目录 /path/to/new-dir
Agent: 删除 /path/to/old-file.txt
```

### web-search

**功能:** 网络搜索

**能力:**
- 搜索引擎查询
- URL 访问
- 网页内容提取

**使用示例:**
```
Agent: 搜索 "macOS 安装 Node.js"
Agent: 访问 https://example.com 并总结内容
```

### code-executor

**功能:** 代码执行

**能力:**
- 执行 Shell 命令
- 运行 Python 脚本
- 执行 Node.js 代码
- 返回执行结果

**使用示例:**
```
Agent: 执行 ls -la 命令
Agent: 运行 Python 脚本计算 1+1
Agent: 执行 npm install
```

### task-manager

**功能:** 任务管理

**能力:**
- 创建任务
- 任务列表
- 任务状态跟踪
- 任务完成提醒

**使用示例:**
```
Agent: 创建任务"完成项目报告"
Agent: 列出所有待办任务
Agent: 标记任务"学习 Python"为完成
```

### data-processor

**功能:** 数据处理

**能力:**
- CSV 处理
- JSON 转换
- 数据统计
- 格式转换

**使用示例:**
```
Agent: 读取 data.csv 并统计行数
Agent: 将 JSON 转换为 CSV
Agent: 计算数据的平均值
```

---

## 🚀 开发自定义 Skill

### Skill 目录结构

```bash
my-custom-skill/
├── skill.json          # Skill 配置
├── index.js            # 入口文件
├── lib/                # 库文件
│   └── helper.js
└── README.md           # 文档
```

### skill.json 配置

```json
{
  "name": "my-custom-skill",
  "version": "1.0.0",
  "description": "我的自定义技能",
  "author": "你的名字",
  "main": "index.js",
  "permissions": [
    "file:read",
    "file:write",
    "network:read"
  ],
  "dependencies": []
}
```

### index.js 实现

```javascript
class MyCustomSkill {
  constructor(context) {
    this.context = context;
  }

  // 技能函数
  async execute(input) {
    // 处理输入
    const result = await this.process(input);
    
    // 返回结果
    return {
      success: true,
      data: result
    };
  }

  async process(input) {
    // 实现具体逻辑
    return `处理结果: ${input}`;
  }
}

module.exports = MyCustomSkill;
```

### 安装自定义 Skill

```bash
openclaw skills install /path/to/my-custom-skill
```

---

## 📝 Skill 权限系统

### 权限类型

**文件权限:**
- `file:read` - 读取文件
- `file:write` - 写入文件
- `file:delete` - 删除文件

**网络权限:**
- `network:read` - 网络读取
- `network:write` - 网络写入

**系统权限:**
- `system:execute` - 执行命令
- `system:process` - 进程管理

**数据权限:**
- `data:read` - 读取数据
- `data:write` - 写入数据

### 配置权限

在 `skill.json` 中声明：

```json
{
  "permissions": [
    "file:read",
    "file:write",
    "network:read"
  ]
}
```

---

## 🧪 测试 Skills

### 本地测试

```bash
# 测试 Skill
openclaw skills test file-operations

# 查看测试结果
openclaw skills test file-operations --verbose
```

### 在 Agent 中测试

```bash
# 绑定 Skill
openclaw agents skills attach main my-custom-skill

# 测试对话
openclaw chat --agent main --prompt "使用 my-custom-skill 做某事"
```

---

## 🔧 Skill 调试

### 查看 Skill 日志

```bash
# 查看 Skill 执行日志
tail -f /tmp/openclaw/openclaw-*.log | grep -i skill
```

### 调试模式

```bash
# 启用调试模式
openclaw config set debug true

# 运行 Skill
openclaw skills test my-custom-skill --debug
```

---

## 📚 Skill 最佳实践

### 1. 权限最小化

只申请必要的权限：
```json
{
  "permissions": [
    "file:read"  // 只读权限
  ]
}
```

### 2. 错误处理

完善的错误处理：
```javascript
try {
  const result = await this.process(input);
  return { success: true, data: result };
} catch (error) {
  return { 
    success: false, 
    error: error.message 
  };
}
```

### 3. 输入验证

验证输入参数：
```javascript
if (!input || typeof input !== 'string') {
  throw new Error('无效的输入');
}
```

### 4. 文档完整

提供清晰的文档：
- README.md
- 使用示例
- API 文档
- 配置说明

### 5. 版本管理

使用语义化版本：
```json
{
  "version": "1.0.0"
}
```

---

## 🌟 发布 Skill

### 准备发布

1. 完善文档
2. 测试功能
3. 添加示例
4. 更新版本号

### 发布到 GitHub

```bash
git init
git add .
git commit -m "Initial release"
git remote add origin https://github.com/your-username/your-skill.git
git push -u origin main
```

### 发布到 npm

```bash
npm publish
```

---

## 🔗 社区 Skills

### 查找社区 Skills

- [OpenClaw Skills Registry](https://github.com/openclaw-skills)
- [NPM Packages](https://www.npmjs.com/search?q=openclaw-skill)

### 安装社区 Skills

```bash
# 从 GitHub 安装
openclaw skills install https://github.com/user/skill.git

# 从 npm 安装
npm install -g openclaw-skill-name
openclaw skills install openclaw-skill-name
```

---

## 🐛 常见问题

### Q1: Skill 无法加载？

1. 检查 Skill 配置：`skill.json`
2. 查看日志：`tail -f /tmp/openclaw/openclaw-*.log`
3. 验证权限：检查 `permissions` 配置

### Q2: Skill 执行失败？

1. 检查依赖：`npm install`
2. 查看错误信息：日志中的错误堆栈
3. 测试 Skill：`openclaw skills test skill-name`

### Q3: 如何调试 Skill？

```bash
# 启用调试
openclaw config set debug true

# 查看详细日志
openclaw skills test skill-name --verbose
```

---

## 📞 获取帮助

- **完整文档:** https://github.com/changzhi777/mactools
- **问题反馈:** https://github.com/changzhi777/mactools/issues
- **Skill 开发:** https://docs.openclaw.ai/skills

---

**🦞 开始开发你的专属 Skill 吧！**
