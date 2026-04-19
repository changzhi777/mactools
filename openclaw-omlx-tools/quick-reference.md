# OpenClaw + oMLX 快速参考卡 🚀

**版本：** V1.0.0 | **更新：** 2026-04-18

---

## ⚡ 一键命令

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

---

## 📂 关键文件位置

| 文件 | 路径 |
|------|------|
| **oMLX 配置** | `~/.omlx/settings.json` |
| **OpenClaw 配置** | `~/.openclaw/openclaw.json` |
| **oMLX 模型** | `~/.omlx/models/` |
| **工作空间** | `~/.openclaw/workspaces/` |

---

## 🔌 API 端点

| 端点 | 方法 | 用途 |
|------|------|------|
| `/health` | GET | 健康检查 |
| `/v1/models` | GET | 模型列表 |
| `/v1/chat/completions` | POST | 聊天完成 |

**Base URL:** `http://127.0.0.1:8008`

---

## 🧪 快速测试

### 健康检查
```bash
curl http://127.0.0.1:8008/health
```

### 模型列表
```bash
curl http://127.0.0.1:8008/v1/models
```

### 聊天测试
```bash
curl -X POST http://127.0.0.1:8008/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ak47" \
  -d '{
    "model": "gemma-4-e4b-it-4bit",
    "messages": [{"role": "user", "content": "你好"}]
  }'
```

---

## 🔧 服务管理

### 启动 oMLX
```bash
omlx serve --port 8008
```

### 后台运行
```bash
nohup omlx serve --port 8008 > ~/omlx.log 2>&1 &
```

### 停止服务
```bash
killall omlx
```

### 查看日志
```bash
tail -f ~/omlx.log
```

---

## 📊 性能指标

| 指标 | 值 |
|------|-----|
| **默认端口** | 8008 |
| **上下文窗口** | 32K tokens |
| **最大 tokens** | 4096 |
| **并发请求** | 12 |

---

## 🎯 OpenClaw 命令

### 查看配置
```bash
openclaw config get models.providers.omlx
```

### 测试推理
```bash
openclaw infer model run \
  --model omlx/gemma-4-e4b-it-4bit \
  --prompt "你好"
```

### 切换模型
```bash
openclaw config set agents.defaults.model.primary "omlx/gemma-4-e4b-it-4bit"
```

---

## 🐛 故障排查

### 端口被占用
```bash
lsof -i :8008
kill -9 <PID>
```

### 权限问题
```bash
chmod +x ./bin/*.sh
```

### 重置配置
```bash
./bin/config-omlx.sh --reset
```

---

## 📝 配置模板

### oMLX 提供商配置
```json
{
  "baseUrl": "http://127.0.0.1:8008/v1",
  "apiKey": "ak47",
  "api": "openai-completions"
}
```

### 默认模型配置
```json
{
  "primary": "omlx/gemma-4-e4b-it-4bit",
  "fallbacks": ["zhipuai/glm-5.1"]
}
```

---

## 💡 最佳实践

✅ **定期备份配置**
```bash
cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.backup
```

✅ **使用别名简化命令**
```bash
alias omlx-test='./bin/test-api.sh'
alias omlx-check='./bin/verify-config.sh'
```

✅ **监控服务状态**
```bash
watch -n 5 'curl -s http://127.0.0.1:8008/health'
```

---

## 📞 获取帮助

- **完整文档：** `docs/configuration-guide.md`
- **API 参考：** `docs/api-reference.md`
- **故障排除：** `docs/troubleshooting.md`
- **示例代码：** `examples/basic-usage.sh`

---

**🚀 快速上手，高效开发！**
