# OpenClaw + oMLX 配置指南

**版本：** V1.0.0
**更新：** 2026-04-18
**作者：** 外星动物（常智）

---

## 目录

- [配置原理](#配置原理)
- [配置文件结构](#配置文件结构)
- [配置参数说明](#配置参数说明)
- [配置步骤](#配置步骤)
- [最佳实践](#最佳实践)
- [常见场景配置](#常见场景配置)

---

## 配置原理

### OpenClaw + oMLX 工作原理

```
┌─────────────┐         ┌──────────────┐         ┌─────────────┐
│  OpenClaw   │────────▶│  oMLX API    │────────▶│  AI Model   │
│  Framework  │         │  (Local)     │         │  (Local)    │
└─────────────┘         └──────────────┘         └─────────────┘
      │                         │
      │                         │
      ▼                         ▼
┌─────────────┐         ┌──────────────┐
│  ZhipuAI    │         │  Config      │
│  (Cloud)    │         │  Files       │
└─────────────┘         └──────────────┘
```

### 组件说明

**1. OpenClaw Framework**
- 本地 AI Agent 框架
- 支持多种模型提供商
- 提供统一的 API 接口

**2. oMLX (推理引擎)**
- Apple Silicon 优化
- 本地运行 AI 模型
- 提供 OpenAI 兼容 API

**3. 模型文件**
- gemma-4-e4b-it-4bit (推荐)
- 存储在本地磁盘
- 约 4GB 大小

### 配置流程

```
1. 安装 oMLX → 2. 下载模型 → 3. 配置 omlx → 4. 配置 openclaw → 5. 测试验证
```

---

## 配置文件结构

### 1. oMLX 配置文件

**位置：** `~/.omlx/settings.json`

**完整结构：**
```json
{
  "version": "1.0",
  "server": {
    "host": "127.0.0.1",
    "port": 8008,
    "log_level": "info",
    "cors_origins": ["*"]
  },
  "model": {
    "model_dirs": ["~/.omlx/models"],
    "model_dir": "~/.omlx/models",
    "max_model_memory": "auto",
    "model_fallback": false
  },
  "memory": {
    "max_process_memory": "auto",
    "prefill_memory_guard": true
  },
  "scheduler": {
    "max_concurrent_requests": 12
  },
  "cache": {
    "enabled": true,
    "ssd_cache_dir": null,
    "ssd_cache_max_size": "auto",
    "hot_cache_max_size": "536870912",
    "initial_cache_blocks": 384
  },
  "auth": {
    "api_key": "ak47",
    "secret_key": "...",
    "skip_api_key_verification": false,
    "sub_keys": []
  },
  "sampling": {
    "max_context_window": 32768,
    "max_tokens": 32768,
    "temperature": 1.0,
    "top_p": 0.95,
    "top_k": 0,
    "repetition_penalty": 1.0
  },
  "logging": {
    "log_dir": null,
    "retention_days": 7
  },
  "ui": {
    "language": "zh"
  }
}
```

### 2. OpenClaw 配置文件

**位置：** `~/.openclaw/openclaw.json`

**oMLX 提供商配置：**
```json
{
  "models": {
    "providers": {
      "omlx": {
        "baseUrl": "http://127.0.0.1:8008/v1",
        "apiKey": "ak47",
        "api": "openai-completions",
        "models": [
          {
            "id": "gemma-4-e4b-it-4bit",
            "name": "Gemma 4 4B Instruct 4bit",
            "contextWindow": 32768,
            "maxTokens": 4096,
            "cost": {
              "input": 0,
              "output": 0
            }
          }
        ]
      }
    }
  }
}
```

**默认模型配置：**
```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "zhipuai/glm-5.1",
        "fallbacks": [
          "omlx/gemma-4-e4b-it-4bit"
        ]
      }
    }
  }
}
```

---

## 配置参数说明

### oMLX 核心参数

| 参数 | 说明 | 默认值 | 建议 |
|------|------|--------|------|
| `server.host` | 绑定地址 | 127.0.0.1 | 保持默认（仅本地访问） |
| `server.port` | 监听端口 | 8008 | 确保端口未被占用 |
| `auth.api_key` | API 密钥 | ak47 | 可自定义 |
| `model.model_dir` | 模型目录 | ~/.omlx/models | 确保有足够磁盘空间 |
| `scheduler.max_concurrent_requests` | 最大并发 | 12 | 根据内存调整 |

### OpenClaw 核心参数

| 参数 | 说明 | 默认值 | 建议 |
|------|------|--------|------|
| `providers.omlx.baseUrl` | oMLX API 地址 | http://127.0.0.1:8008/v1 | 与 omlx port 对应 |
| `providers.omlx.apiKey` | API 密钥 | ak47 | 与 omlx api_key 对应 |
| `model.primary` | 主模型 | zhipuai/glm-5.1 | 根据需求选择 |
| `model.fallbacks` | 备用模型 | omlx/... | 至少配置一个备用 |

---

## 配置步骤

### 方式1：使用配置向导（推荐）

```bash
cd openclaw-omlx-tools
./bin/config-omlx.sh
```

**优点：**
- 交互式操作
- 自动备份配置
- 验证配置正确性

### 方式2：手动配置

#### 步骤1：配置 oMLX

```bash
# 创建配置文件
cat > ~/.omlx/settings.json << 'EOF'
{
  "server": {
    "host": "127.0.0.1",
    "port": 8008
  },
  "auth": {
    "api_key": "ak47"
  }
}
EOF
```

#### 步骤2：添加 OpenClaw 提供商

```bash
# 设置 baseUrl
openclaw config set models.providers.omlx.baseUrl "http://127.0.0.1:8008/v1"

# 设置 API Key
openclaw config set models.providers.omlx.apiKey "ak47"

# 设置 API 类型
openclaw config set models.providers.omlx.api "openai-completions"
```

#### 步骤3：配置默认模型

```bash
# 方案A：设置为备用模型（推荐）
openclaw config set agents.defaults.model.fallbacks[0] "omlx/gemma-4-e4b-it-4bit"

# 方案B：设置为主模型
openclaw config set agents.defaults.model.primary "omlx/gemma-4-e4b-it-4bit"
```

#### 步骤4：启动 oMLX 服务

```bash
# 前台运行
omlx serve --port 8008

# 后台运行
nohup omlx serve --port 8008 > ~/omlx.log 2>&1 &
```

#### 步骤5：验证配置

```bash
# 使用验证脚本
./bin/verify-config.sh

# 或手动测试
curl http://127.0.0.1:8008/v1/models
```

---

## 最佳实践

### 1. 模型选择策略

```
云端 API (智谱AI)
    ↓
  快速响应
    ↓
  复杂任务
    ↓
  API 故障
    ↓
本地模型 (oMLX) ← 降级切换
    ↓
  高可用性
```

**推荐配置：**
- **主模型：** zhipuai/glm-5.1（快速、智能）
- **备用模型：** omlx/gemma-4-e4b-it-4bit（稳定、免费）

### 2. 性能优化

**调整并发请求数：**
```json
{
  "scheduler": {
    "max_concurrent_requests": 6  // 从 12 降到 6（内存不足时）
  }
}
```

**启用缓存：**
```json
{
  "cache": {
    "enabled": true,
    "hot_cache_max_size": "1073741824"  // 增加到 1GB
  }
}
```

### 3. 安全配置

**限制 CORS：**
```json
{
  "server": {
    "cors_origins": ["http://localhost:*"]
  }
}
```

**更换 API Key：**
```bash
# 生成随机密钥
openssl rand -hex 16

# 更新配置
openclaw config set models.providers.omlx.apiKey "your-new-key"
```

### 4. 备份策略

**定期备份配置：**
```bash
# 创建备份脚本
cat > ~/backup-omlx.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="$HOME/.openclaw-omlx-backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
mkdir -p "$BACKUP_DIR"
cp ~/.omlx/settings.json "$BACKUP_DIR/settings.json.$TIMESTAMP"
cp ~/.openclaw/openclaw.json "$BACKUP_DIR/openclaw.json.$TIMESTAMP"
EOF

chmod +x ~/backup-omlx.sh

# 添加到 crontab（每周备份）
crontab -e
# 添加：0 0 * * 0 ~/backup-omlx.sh
```

---

## 常见场景配置

### 场景1：纯本地模式（离线使用）

**配置：**
```bash
# 设置 oMLX 为主模型
openclaw config set agents.defaults.model.primary "omlx/gemma-4-eb-it-4bit"

# 清空备用模型
openclaw config set agents.defaults.model.fallbacks "[]"
```

**优点：**
- 完全离线
- 数据隐私
- 无 API 成本

**缺点：**
- 响应较慢（15-30s）
- 模型能力较弱

### 场景2：智能降级模式（推荐）

**配置：**
```bash
# 主模型：智谱AI
openclaw config set agents.defaults.model.primary "zhipuai/glm-5.1"

# 备用模型：本地 oMLX
openclaw config set agents.defaults.model.fallbacks[0] "omlx/gemma-4-eb-it-4bit"
```

**优点：**
- 快速响应（2-3s）
- 自动降级
- 高可用性

### 场景3：负载均衡模式

**配置：**
```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "omlx/gemma-4-e4b-it-4bit",
        "fallbacks": [
          "zhipuai/glm-5.1",
          "anthropic/claude-sonnet-4-6"
        ]
      }
    }
  }
}
```

**使用场景：**
- 分散请求负载
- 成本优化
- 服务冗余

### 场景4：多模型协同

**配置：**
```bash
# 文本生成：本地模型
openclaw config set agents.defaults.model.primary "omlx/gemma-4-eb-it-4bit"

# 图像理解：视觉模型
openclaw config set agents.defaults.imageModel "zhipuai/glm-5v-turbo"

# 复杂推理：云端模型
openclaw config set agents.defaults.model.fallbacks[0] "zhipuai/glm-5.1"
```

---

## 故障排除

### 问题1：配置不生效

**症状：** 修改配置后仍使用旧配置

**原因：** OpenClaw 缓存了配置

**解决：**
```bash
# 重启 OpenClaw 网关
openclaw gateway restart

# 或清理缓存
rm -rf ~/.openclaw/cache/*
```

### 问题2：无法连接到 oMLX

**症状：** Connection refused

**检查：**
```bash
# 1. 检查服务状态
lsof -i :8008

# 2. 检查防火墙
sudo pfctl -s rules | grep 8008

# 3. 检查配置
cat ~/.omlx/settings.json | jq .server
```

### 问题3：模型加载失败

**症状：** Model not found

**解决：**
```bash
# 1. 检查模型目录
ls -la ~/.omlx/models/

# 2. 重新下载模型
omlx model download gemma-4-e4b-it-4bit

# 3. 验证模型
omlx model list
```

---

## 参考资源

- **完整文档：** `../README.md`
- **API 参考：** `api-reference.md`
- **故障排除：** `troubleshooting.md`
- **快速参考：** `../quick-reference.md`

---

**🦞 享受本地 AI 的强大能力！**
