# OpenClaw + oMLX 故障排除

**版本：** V1.0.0
**更新：** 2026-04-18
**作者：** 外星动物（常智）

---

## 目录

- [快速诊断](#快速诊断)
- [常见问题](#常见问题)
- [错误信息对照](#错误信息对照)
- [日志分析](#日志分析)
- [调试工具](#调试工具)
- [性能问题](#性能问题)

---

## 快速诊断

### 一键诊断

```bash
cd openclaw-omlx-tools
./bin/troubleshoot.sh
```

### 手动诊断步骤

1. **检查服务状态**
   ```bash
   lsof -i :8008  # oMLX 服务
   lsof -i :18789  # OpenClaw 网关
   ```

2. **测试 API**
   ```bash
   curl http://127.0.0.1:8008/health
   ```

3. **查看配置**
   ```bash
   cat ~/.omlx/settings.json | jq .
   cat ~/.openclaw/openclaw.json | jq .models.providers.omlx
   ```

4. **检查日志**
   ```bash
   tail -f ~/omlx.log
   tail -f /tmp/openclaw/*.log
   ```

---

## 常见问题

### 1. oMLX 服务无法启动

**症状：**
```
Error: Port 8008 already in use
```

**原因：** 端口被占用

**解决方案：**
```bash
# 查找占用进程
lsof -i :8008

# 终止进程
kill -9 <PID>

# 或使用其他端口
omlx serve --port 8009
```

**预防措施：**
```bash
# 检查端口占用脚本
cat > check-port.sh << 'EOF'
#!/bin/bash
if lsof -i :8008 &> /dev/null; then
    echo "端口 8008 已被占用"
    lsof -i :8008
else
    echo "端口 8008 可用"
fi
EOF
```

---

### 2. OpenClaw 无法连接到 oMLX

**症状：**
```
Error: Connection refused (http://127.0.0.1:8008)
```

**原因：** oMLX 服务未运行或配置错误

**诊断步骤：**

1. **检查 oMLX 服务**
   ```bash
   lsof -i :8008
   ```

2. **检查配置**
   ```bash
   # 检查 omlx 配置
   cat ~/.omlx/settings.json | jq .server

   # 检查 openclaw 配置
   cat ~/.openclaw/openclaw.json | jq .models.providers.omlx
   ```

3. **测试连通性**
   ```bash
   curl http://127.0.0.1:8008/health
   ```

**解决方案：**

```bash
# 启动 oMLX 服务
omlx serve --port 8008

# 或后台运行
nohup omlx serve --port 8008 > ~/omlx.log 2>&1 &

# 验证服务
curl http://127.0.0.1:8008/health
```

**配置修复：**
```bash
# 更新 OpenClaw 配置
openclaw config set models.providers.omlx.baseUrl "http://127.0.0.1:8008/v1"
openclaw config set models.providers.omlx.apiKey "ak47"

# 重启 OpenClaw 网关
openclaw gateway restart
```

---

### 3. 模型加载失败

**症状：**
```
Error: Model 'gemma-4-e4b-it-4bit' not found
```

**原因：** 模型未下载或路径错误

**诊断步骤：**

1. **检查模型目录**
   ```bash
   ls -la ~/.omlx/models/
   ```

2. **检查模型配置**
   ```bash
   cat ~/.omlx/settings.json | jq .model
   ```

3. **列出已下载模型**
   ```bash
   omlx model list
   ```

**解决方案：**

```bash
# 下载模型
omlx model download gemma-4-e4b-it-4bit

# 验证模型
omlx model list

# 测试模型
curl -X POST http://127.0.0.1:8008/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ak47" \
  -d '{
    "model": "gemma-4-e4b-it-4bit",
    "messages": [{"role": "user", "content": "hi"}],
    "max_tokens": 10
  }'
```

---

### 4. API 认证失败

**症状：**
```
Error: Unauthorized (HTTP 401)
```

**原因：** API Key 不匹配

**诊断步骤：**

```bash
# 检查 omlx API Key
cat ~/.omlx/settings.json | jq .auth.api_key

# 检查 openclaw API Key
cat ~/.openclaw/openclaw.json | jq .models.providers.omlx.apiKey
```

**解决方案：**

```bash
# 方法1：统一 API Key
export OMLX_API_KEY="ak47"
openclaw config set models.providers.omlx.apiKey "$OMLX_API_KEY"

# 方法2：更新 omlx 配置
cat > ~/.omlx/settings.json << 'EOF'
{
  "auth": {
    "api_key": "ak47"
  }
}
EOF

# 重启服务
killall omlx && omlx serve --port 8008
```

---

### 5. 响应超时

**症状：**
```
Error: Request timeout after 30s
```

**原因：** 模型推理时间过长

**诊断步骤：**

```bash
# 检查系统资源
top -o cpu
htop

# 检查模型加载时间
tail -f ~/omlx.log | grep "load"
```

**解决方案：**

**方法1：增加超时时间**
```bash
curl -X POST http://127.0.0.1:8008/v1/chat/completions \
  --max-time 120 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ak47" \
  -d '{...}'
```

**方法2：降低请求复杂度**
```json
{
  "max_tokens": 50,
  "temperature": 0.5
}
```

**方法3：优化 oMLX 配置**
```json
{
  "memory": {
    "max_process_memory": "auto",
    "prefill_memory_guard": false
  },
  "scheduler": {
    "max_concurrent_requests": 6
  }
}
```

---

### 6. 内存不足

**症状：**
```
Error: Out of memory
```

**诊断步骤：**

```bash
# 检查内存使用
vm_stat
free -h

# 检查 oMLX 进程内存
ps aux | grep omlx
```

**解决方案：**

**方法1：限制并发**
```json
{
  "scheduler": {
    "max_concurrent_requests": 4
  }
}
```

**方法2：优化内存配置**
```json
{
  "memory": {
    "max_process_memory": "8GB"
  },
  "cache": {
    "enabled": true,
    "hot_cache_max_size": "268435456"
  }
}
```

**方法3：释放内存**
```bash
# 清理缓存
sudo purge

# 重启 oMLX
killall omlx
omlx serve --port 8008
```

---

### 7. 配置文件格式错误

**症状：**
```
Error: Invalid JSON format
```

**诊断步骤：**

```bash
# 验证 JSON 格式
jq empty ~/.omlx/settings.json
jq empty ~/.openclaw/openclaw.json
```

**解决方案：**

```bash
# 方法1：手动修复
vim ~/.omlx/settings.json

# 方法2：恢复备份
cp ~/.openclaw-omlx-backups/settings.json.backup.* ~/.omlx/settings.json

# 方法3：重新生成
./bin/config-omlx.sh
```

---

### 8. 权限问题

**症状：**
```
Error: Permission denied
```

**诊断步骤：**

```bash
# 检查文件权限
ls -la ~/.omlx/settings.json
ls -la ~/.openclaw/openclaw.json

# 检查目录权限
ls -la ~/.omlx/
ls -la ~/.openclaw/
```

**解决方案：**

```bash
# 修复文件权限
chmod 644 ~/.omlx/settings.json
chmod 600 ~/.openclaw/openclaw.json

# 修复目录权限
chmod 755 ~/.omlx/
chmod 755 ~/.openclaw/

# 修复脚本权限
chmod +x ./bin/*.sh
```

---

## 错误信息对照

| 错误信息 | 原因 | 解决方案 |
|---------|------|----------|
| `Connection refused` | 服务未运行 | 启动 oMLX 服务 |
| `Port already in use` | 端口被占用 | 终止占用进程或更换端口 |
| `Model not found` | 模型未下载 | 下载模型 |
| `Unauthorized` | API Key 错误 | 检查 API Key 配置 |
| `Invalid JSON` | 配置格式错误 | 验证 JSON 格式 |
| `Out of memory` | 内存不足 | 降低并发或增加内存 |
| `Permission denied` | 权限不足 | 修复文件权限 |
| `Timeout` | 响应超时 | 增加超时时间或优化配置 |
| `Invalid request` | 请求参数错误 | 检查请求格式 |
| `Service unavailable` | 服务异常 | 重启服务或查看日志 |

---

## 日志分析

### oMLX 日志

**日志位置：**
- 前台运行：终端输出
- 后台运行：`~/omlx.log`

**查看日志：**
```bash
# 实时查看
tail -f ~/omlx.log

# 查看最近100行
tail -n 100 ~/omlx.log

# 搜索错误
grep -i "error\|exception\|failed" ~/omlx.log
```

**关键日志信息：**

```
✅ 正常启动：
INFO: Starting server on 127.0.0.1:8008
INFO: Model loaded: gemma-4-e4b-it-4bit

❌ 启动失败：
ERROR: Port 8008 already in use
ERROR: Failed to load model
ERROR: Out of memory
```

### OpenClaw 日志

**日志位置：** `/tmp/openclaw/`

**查看日志：**
```bash
# 查看最新日志
ls -lt /tmp/openclaw/*.log | head -1

# 实时查看
tail -f /tmp/openclaw/openclaw-*.log
```

**关键日志信息：**

```
✅ 正常运行：
INFO: Gateway started on port 18789
INFO: Model provider registered: omlx

❌ 连接失败：
ERROR: Failed to connect to omlx provider
ERROR: Connection refused
```

### 系统日志

**查看系统日志：**
```bash
# 查看内核日志
dmesg | tail -100

# 查看系统日志
log show --predicate 'process == "omlx"' --last 1h

# 查看 Crash 日志
ls -la ~/Library/Logs/DiagnosticReports/
```

---

## 调试工具

### 1. 网络调试

**测试连通性：**
```bash
# 测试端口
nc -zv 127.0.0.1 8008

# 测试 HTTP
curl -v http://127.0.0.1:8008/health

# 测试 API
curl -v -X POST http://127.0.0.1:8008/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ak47" \
  -d '{"model":"gemma-4-e4b-it-4bit","messages":[{"role":"user","content":"hi"}]}'
```

### 2. 性能分析

**CPU 分析：**
```bash
# CPU 使用率
top -o cpu -pid $(pgrep omlx)

# CPU 采样
sample 60 -file ~/omlx.cpu.sample $(pgrep omlx)
```

**内存分析：**
```bash
# 内存使用
top -o mem -pid $(pgrep omlx)

# 内存泄漏检测
leaks $(pgrep omlx) > ~/omlx.leaks.txt
```

**IO 分析：**
```bash
# 磁盘 IO
iotop -o -P

# 网络流量
nettop -p omlx
```

### 3. 配置验证

**验证脚本：**
```bash
# 使用内置验证脚本
./bin/verify-config.sh

# 手动验证
cat > verify.sh << 'EOF'
#!/bin/bash

echo "检查 oMLX 配置..."
jq empty ~/.omlx/settings.json && echo "✅ oMLX 配置正确" || echo "❌ oMLX 配置错误"

echo "检查 OpenClaw 配置..."
jq empty ~/.openclaw/openclaw.json && echo "✅ OpenClaw 配置正确" || echo "❌ OpenClaw 配置错误"

echo "检查服务..."
lsof -i :8008 && echo "✅ oMLX 服务运行中" || echo "❌ oMLX 服务未运行"

echo "检查 API..."
curl -s http://127.0.0.1:8008/health && echo "✅ API 响应正常" || echo "❌ API 无响应"
EOF

chmod +x verify.sh
./verify.sh
```

---

## 性能问题

### 1. 响应慢

**诊断：**
```bash
# 测试响应时间
time curl -X POST http://127.0.0.1:8008/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ak47" \
  -d '{"model":"gemma-4-e4b-it-4bit","messages":[{"role":"user","content":"hi"}],"max_tokens":10}'
```

**优化方案：**

1. **降低并发**
   ```json
   {"max_concurrent_requests": 4}
   ```

2. **启用缓存**
   ```json
   {"cache": {"enabled": true}}
   ```

3. **减少 tokens**
   ```json
   {"max_tokens": 50}
   ```

### 2. 内存占用高

**诊断：**
```bash
# 查看内存使用
ps aux | grep omlx | awk '{print $6/1024 " MB"}'
```

**优化方案：**

1. **调整内存限制**
   ```json
   {"max_process_memory": "4GB"}
   ```

2. **减少缓存**
   ```json
   {"hot_cache_max_size": "268435456"}
   ```

3. **释放内存**
   ```bash
   killall omlx && omlx serve --port 8008
   ```

### 3. CPU 占用高

**诊断：**
```bash
# 查看 CPU 使用
top -o cpu -pid $(pgrep omlx)
```

**优化方案：**

1. **降低温度**
   ```json
   {"temperature": 0.5}
   ```

2. **减少上下文**
   ```json
   {"max_context_window": 8192}
   ```

---

## 获取帮助

### 诊断报告生成

```bash
# 生成完整诊断报告
./bin/troubleshoot.sh > ~/diagnostic-$(date +%Y%m%d).txt 2>&1
```

### 社区支持

- **项目仓库：** https://github.com/changzhi777/mactools
- **问题反馈：** https://github.com/changzhi777/mactools/issues
- **邮箱：** 14455975@qq.com

### 完整文档

- **配置指南：** `configuration-guide.md`
- **API 参考：** `api-reference.md`
- **快速参考：** `../quick-reference.md`

---

**🔧 问题解决，从这里开始！**
