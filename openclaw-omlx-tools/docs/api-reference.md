# OpenClaw + oMLX API 参考

**版本：** V1.0.0
**更新：** 2026-04-18
**作者：** 外星动物（常智）

---

## 目录

- [API 概述](#api-概述)
- [端点列表](#端点列表)
- [请求格式](#请求格式)
- [响应格式](#响应格式)
- [错误码](#错误码)
- [使用示例](#使用示例)
- [性能优化](#性能优化)

---

## API 概述

### 基本信息

**Base URL:** `http://127.0.0.1:8008`

**API 版本:** v1

**认证方式:** Bearer Token

**默认 API Key:** `ak47`

### 兼容性

oMLX API 完全兼容 OpenAI API 格式，这意味着：

✅ 可以使用 OpenAI SDK
✅ 可以使用现有的 OpenAI 工具
✅ 易于集成到现有项目

---

## 端点列表

### 1. 健康检查

**端点：** `GET /health`

**描述：** 检查 oMLX 服务健康状态

**请求：**
```bash
curl http://127.0.0.1:8008/health
```

**响应：**
```json
{
  "status": "healthy",
  "version": "1.0.0",
  "timestamp": "2026-04-18T12:00:00Z"
}
```

**状态码：**
- `200 OK` - 服务正常
- `503 Service Unavailable` - 服务异常

---

### 2. 模型列表

**端点：** `GET /v1/models`

**描述：** 获取可用模型列表

**请求：**
```bash
curl http://127.0.0.1:8008/v1/models \
  -H "Authorization: Bearer ak47"
```

**响应：**
```json
{
  "object": "list",
  "data": [
    {
      "id": "gemma-4-e4b-it-4bit",
      "object": "model",
      "created": 1234567890,
      "owned_by": "omlx"
    }
  ]
}
```

**状态码：**
- `200 OK` - 成功
- `401 Unauthorized` - 认证失败

---

### 3. 聊天完成

**端点：** `POST /v1/chat/completions`

**描述：** 生成聊天响应

**请求头：**
```
Content-Type: application/json
Authorization: Bearer ak47
```

**请求体：**
```json
{
  "model": "gemma-4-e4b-it-4bit",
  "messages": [
    {
      "role": "user",
      "content": "你好，请介绍你自己。"
    }
  ],
  "max_tokens": 100,
  "temperature": 0.7,
  "top_p": 0.95,
  "stream": false
}
```

**响应：**
```json
{
  "id": "chatcmpl-123",
  "object": "chat.completion",
  "created": 1234567890,
  "model": "gemma-4-e4b-it-4bit",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "你好！我是 Gemma，一个由 Google 开发的大型语言模型..."
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 10,
    "completion_tokens": 20,
    "total_tokens": 30
  }
}
```

**状态码：**
- `200 OK` - 成功
- `400 Bad Request` - 请求参数错误
- `401 Unauthorized` - 认证失败
- `500 Internal Server Error` - 服务器错误

---

### 4. 流式聊天完成

**端点：** `POST /v1/chat/completions`

**描述：** 流式生成聊天响应

**请求：**
```bash
curl -X POST http://127.0.0.1:8008/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ak47" \
  -d '{
    "model": "gemma-4-e4b-it-4bit",
    "messages": [{"role": "user", "content": "数到5"}],
    "stream": true
  }'
```

**响应（流式）：**
```
data: {"id":"chatcmpl-123","choices":[{"delta":{"content":"1"}}]}

data: {"id":"chatcmpl-123","choices":[{"delta":{"content":", 2"}}]}

data: {"id":"chatcmpl-123","choices":[{"delta":{"content":", 3"}}]}

data: [DONE]
```

---

## 请求格式

### 请求参数

#### model（必需）

模型的 ID

**类型：** string
**示例：** `"gemma-4-e4b-it-4bit"`

#### messages（必需）

消息列表

**类型：** array
**结构：**
```json
[
  {
    "role": "system|user|assistant",
    "content": "消息内容"
  }
]
```

**role 类型：**
- `system` - 系统提示词
- `user` - 用户消息
- `assistant` - 助手响应

#### max_tokens（可选）

生成的最大 token 数

**类型：** integer
**范围：** 1 - 4096
**默认：** 根据模型自动设置

#### temperature（可选）

采样温度，控制随机性

**类型：** float
**范围：** 0.0 - 2.0
**默认：** 1.0

**建议：**
- `0.0 - 0.3` - 创造性低，适合事实性回答
- `0.4 - 0.7` - 平衡，适合大多数场景
- `0.8 - 1.0` - 创造性高，适合创意写作
- `1.1 - 2.0` - 非常随机，实验性

#### top_p（可选）

核采样参数

**类型：** float
**范围：** 0.0 - 1.0
**默认：** 0.95

**说明：** 与 temperature 二选一使用

#### stream（可选）

是否使用流式响应

**类型：** boolean
**默认：** false

---

## 响应格式

### 标准响应

```json
{
  "id": "chatcmpl-123",
  "object": "chat.completion",
  "created": 1234567890,
  "model": "gemma-4-e4b-it-4bit",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "响应内容"
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 10,
    "completion_tokens": 20,
    "total_tokens": 30
  }
}
```

### 字段说明

#### id
请求的唯一标识符

#### object
对象类型，固定为 `chat.completion`

#### created
创建时间戳（Unix 时间）

#### model
使用的模型 ID

#### choices
响应选项列表

**message.content：** 生成的文本内容
**finish_reason：** 结束原因
- `stop` - 自然结束
- `length` - 达到 max_tokens
- `content_filter` - 内容过滤

#### usage
Token 使用统计

---

## 错误码

### 错误响应格式

```json
{
  "error": {
    "message": "错误描述",
    "type": "error_type",
    "param": null,
    "code": "error_code"
  }
}
```

### 常见错误码

| HTTP 状态码 | 错误类型 | 说明 | 解决方案 |
|------------|---------|------|----------|
| 400 | invalid_request_error | 请求参数错误 | 检查请求格式 |
| 401 | invalid_auth_error | 认证失败 | 检查 API Key |
| 404 | model_not_found_error | 模型不存在 | 检查模型 ID |
| 429 | rate_limit_error | 请求过多 | 降低请求频率 |
| 500 | server_error | 服务器错误 | 查看服务日志 |
| 503 | service_unavailable | 服务不可用 | 检查服务状态 |

### 错误处理示例

```bash
# 检查错误
response=$(curl -s -X POST http://127.0.0.1:8008/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ak47" \
  -d '{"model":"invalid-model","messages":[{"role":"user","content":"hi"}]}')

error=$(echo "$response" | jq -r '.error.message' 2>/dev/null)

if [ "$error" != "null" ] && [ -n "$error" ]; then
    echo "错误：$error"
else
    echo "成功"
fi
```

---

## 使用示例

### Bash/cURL

#### 简单对话

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

#### 多轮对话

```bash
curl -X POST http://127.0.0.1:8008/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ak47" \
  -d '{
    "model": "gemma-4-e4b-it-4bit",
    "messages": [
      {"role": "user", "content": "我叫张三"},
      {"role": "assistant", "content": "你好张三！"},
      {"role": "user", "content": "我叫什么名字？"}
    ],
    "max_tokens": 50
  }'
```

#### 流式响应

```bash
curl -X POST http://127.0.0.1:8008/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ak47" \
  -d '{
    "model": "gemma-4-e4b-it-4bit",
    "messages": [{"role": "user", "content": "讲个故事"}],
    "stream": true
  }'
```

### Python

#### 使用 requests

```python
import requests
import json

url = "http://127.0.0.1:8008/v1/chat/completions"
headers = {
    "Content-Type": "application/json",
    "Authorization": "Bearer ak47"
}
data = {
    "model": "gemma-4-e4b-it-4bit",
    "messages": [
        {"role": "user", "content": "你好"}
    ],
    "max_tokens": 100
}

response = requests.post(url, headers=headers, json=data)
result = response.json()

print(result["choices"][0]["message"]["content"])
```

#### 使用 OpenAI SDK

```python
from openai import OpenAI

client = OpenAI(
    base_url="http://127.0.0.1:8008/v1",
    api_key="ak47"
)

response = client.chat.completions.create(
    model="gemma-4-e4b-it-4bit",
    messages=[
        {"role": "user", "content": "你好"}
    ],
    max_tokens=100
)

print(response.choices[0].message.content)
```

### JavaScript/Node.js

#### 使用 fetch

```javascript
const response = await fetch('http://127.0.0.1:8008/v1/chat/completions', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ak47'
  },
  body: JSON.stringify({
    model: 'gemma-4-e4b-it-4bit',
    messages: [
      { role: 'user', content: '你好' }
    ],
    max_tokens: 100
  })
});

const data = await response.json();
console.log(data.choices[0].message.content);
```

#### 使用 OpenAI SDK

```javascript
import OpenAI from 'openai';

const client = new OpenAI({
  baseURL: 'http://127.0.0.1:8008/v1',
  apiKey: 'ak47'
});

const response = await client.chat.completions.create({
  model: 'gemma-4-e4b-it-4bit',
  messages: [
    { role: 'user', content: '你好' }
  ],
  max_tokens: 100
});

console.log(response.choices[0].message.content);
```

---

## 性能优化

### 1. 批量请求

**并行处理：**
```bash
# 使用 xargs 并行处理
seq 1 10 | xargs -P 4 -I {} curl -s http://127.0.0.1:8008/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ak47" \
  -d '{"model":"gemma-4-e4b-it-4bit","messages":[{"role":"user","content":"hi"}],"max_tokens":10}'
```

### 2. 连接复用

**保持连接：**
```bash
# 使用 curl 的连接复用
curl --no-keep-alive -X POST http://127.0.0.1:8008/v1/chat/completions \
  -H "Connection: keep-alive" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ak47" \
  -d '{"model":"gemma-4-e4b-it-4bit","messages":[{"role":"user","content":"hi"}]}'
```

### 3. 调整参数

**降低延迟：**
```json
{
  "max_tokens": 50,
  "temperature": 0.5,
  "top_p": 0.9
}
```

**提高质量：**
```json
{
  "max_tokens": 500,
  "temperature": 0.7,
  "top_p": 0.95
}
```

### 4. 缓存策略

**本地缓存：**
```python
import hashlib
import json
from pathlib import Path

def cached_request(messages):
    # 生成缓存键
    cache_key = hashlib.md5(json.dumps(messages).encode()).hexdigest()
    cache_file = Path(f"/tmp/omlx_cache/{cache_key}.json")

    # 检查缓存
    if cache_file.exists():
        return json.loads(cache_file.read_text())

    # 发送请求
    response = requests.post(url, headers=headers, json=data)
    result = response.json()

    # 保存缓存
    cache_file.parent.mkdir(exist_ok=True)
    cache_file.write_text(json.dumps(result))

    return result
```

---

## 最佳实践

### 1. 错误处理

```python
import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

# 配置重试
session = requests.Session()
retry = Retry(
    total=3,
    backoff_factor=1,
    status_forcelist=[500, 502, 503, 504]
)
adapter = HTTPAdapter(max_retries=retry)
session.mount('http://', adapter)

try:
    response = session.post(url, headers=headers, json=data, timeout=30)
    response.raise_for_status()
except requests.exceptions.RequestException as e:
    print(f"请求失败: {e}")
```

### 2. 超时控制

```bash
# 设置超时
curl -X POST http://127.0.0.1:8008/v1/chat/completions \
  --max-time 60 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ak47" \
  -d '{"model":"gemma-4-e4b-it-4bit","messages":[{"role":"user","content":"hi"}]}'
```

### 3. 日志记录

```python
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

logger.info(f"发送请求: {data}")
response = requests.post(url, headers=headers, json=data)
logger.info(f"响应状态: {response.status_code}")
logger.info(f"Token 使用: {response.json().get('usage')}")
```

---

## 参考资源

- **完整文档：** `../README.md`
- **配置指南：** `configuration-guide.md`
- **故障排除：** `troubleshooting.md`
- **测试脚本：** `../bin/test-api.sh`

---

**🚀 高效开发，从这里开始！**
