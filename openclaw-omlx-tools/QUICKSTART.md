# OpenClaw + oMLX 快速开始指南

**5分钟快速上手！**

---

## 📋 前置检查

### 1. 检查 oMLX 服务

```bash
# 检查服务是否运行
lsof -i :8008

# 如果未运行，启动服务
omlx serve --port 8008

# 或后台运行
nohup omlx serve --port 8008 > ~/omlx.log 2>&1 &
```

### 2. 检查 OpenClaw 配置

```bash
# 查看配置
cat ~/.openclaw/openclaw.json | jq .models.providers.omlx

# 如果没有配置，运行配置向导
cd openclaw-omlx-tools
./bin/config-omlx.sh
```

---

## 🚀 三步快速开始

### 步骤1：验证配置（1分钟）

```bash
cd openclaw-omlx-tools
./bin/verify-config.sh
```

**预期输出：**
```
✅ 通过：检查必要命令
✅ 通过：oMLX 服务正在运行
✅ 通过：配置文件格式正确
✅ 通过：模型已安装
```

### 步骤2：测试 API（2分钟）

```bash
./bin/test-api.sh
```

**预期输出：**
```
✅ SUCCESS: 健康检查端点正常（HTTP 200）
✅ SUCCESS: 模型列表获取成功（HTTP 200）
✅ SUCCESS: 聊天完成成功（HTTP 200）
💬 回复：你好！我是 Gemma...
```

### 步骤3：运行示例（2分钟）

```bash
./examples/basic-usage.sh
```

**选择：**
1. 验证配置
2. 测试 API
3. 简单对话 ← 推荐先试这个
4. 多轮对话
5. 批量处理
6. 流式响应

---

## 📖 常用命令

### 验证配置
```bash
./bin/verify-config.sh
```

### 测试 API
```bash
./bin/test-api.sh
```

### 诊断问题
```bash
./bin/troubleshoot.sh
```

### 重新配置
```bash
./bin/config-omlx.sh
```

### 运行示例
```bash
./examples/basic-usage.sh
```

---

## 🔧 快速修复

### 问题1：服务未运行

```bash
# 启动 oMLX
omlx serve --port 8008

# 验证
curl http://127.0.0.1:8008/health
```

### 问题2：配置错误

```bash
# 运行配置向导
./bin/config-omlx.sh

# 选择：1) 完整配置向导
```

### 问题3：API 无响应

```bash
# 诊断问题
./bin/troubleshoot.sh

# 按照提示修复
```

---

## 💡 使用示例

### Bash/cURL

```bash
curl -X POST http://127.0.0.1:8008/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ak47" \
  -d '{
    "model": "gemma-4-e4b-it-4bit",
    "messages": [{"role": "user", "content": "你好"}],
    "max_tokens": 100
  }'
```

### Python

```python
from openai import OpenAI

client = OpenAI(
    base_url="http://127.0.0.1:8008/v1",
    api_key="ak47"
)

response = client.chat.completions.create(
    model="gemma-4-e4b-it-4bit",
    messages=[{"role": "user", "content": "你好"}],
    max_tokens=100
)

print(response.choices[0].message.content)
```

### JavaScript

```javascript
import OpenAI from 'openai';

const client = new OpenAI({
  baseURL: 'http://127.0.0.1:8008/v1',
  apiKey: 'ak47'
});

const response = await client.chat.completions.create({
  model: 'gemma-4-e4b-it-4bit',
  messages: [{ role: 'user', content: '你好' }],
  max_tokens: 100
});

console.log(response.choices[0].message.content);
```

---

## 📚 进阶学习

### 完整文档
- **配置指南：** `docs/configuration-guide.md`
- **API 参考：** `docs/api-reference.md`
- **故障排除：** `docs/troubleshooting.md`

### 快速参考
- **命令速查：** `quick-reference.md`
- **高级配置：** `examples/advanced-config.json`

---

## ✅ 下一步

1. **阅读完整文档** - 深入了解配置和API
2. **运行测试脚本** - `./bin/test-api.sh`
3. **尝试不同示例** - `./examples/basic-usage.sh`
4. **优化配置** - 根据需求调整参数

---

## 🆘 获取帮助

**遇到问题？**
1. 运行诊断：`./bin/troubleshoot.sh`
2. 查看故障排除：`docs/troubleshooting.md`
3. 查看主文档：`README.md`

**需要更多帮助？**
- 项目：https://github.com/changzhi777/mactools
- 邮箱：14455975@qq.com

---

**🚀 开始使用本地 AI 的强大能力！**
