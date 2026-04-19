# OpenClaw + oMLX 配置工具集 🦞

**版本：** V1.0.0
**更新时间：** 2026-04-18
**作者：** 外星动物（常智）

---

## 📋 目录

- [概述](#概述)
- [快速开始](#快速开始)
- [工具说明](#工具说明)
- [文档索引](#文档索引)
- [示例代码](#示例代码)
- [常见问题](#常见问题)

---

## 概述

### 什么是 OpenClaw + oMLX？

**OpenClaw** 是一个强大的本地 AI Agent 框架，支持多种模型提供商。

**oMLX** 是 Apple Silicon 优化的本地推理引擎，可在 Mac 上运行 AI 模型。

### 本工具集提供

✅ **自动化脚本** - 验证、测试、配置、排查
✅ **完整文档** - 配置指南、API参考、故障排除
✅ **实用示例** - 基础用法、高级配置
✅ **快速参考** - 常用命令速查

---

## 快速开始

### 前置要求

```bash
# 检查 omlx 服务
curl http://127.0.0.1:8008/health

# 检查 openclaw 配置
cat ~/.openclaw/openclaw.json | jq .models.providers.omlx
```

### 一键验证

```bash
cd openclaw-omlx-tools
./bin/verify-config.sh
```

### 快速测试

```bash
./bin/test-api.sh
```

---

## 工具说明

### 📦 bin/ - 自动化脚本

#### verify-config.sh
**功能：** 验证 OpenClaw + oMLX 配置

```bash
./bin/verify-config.sh
```

**检查项目：**
- ✅ omlx 服务状态（端口 8008）
- ✅ openclaw.json 配置
- ✅ omlx/settings.json 配置
- ✅ 模型列表获取
- ✅ API 连通性测试

#### test-api.sh
**功能：** 测试 oMLX API 端点

```bash
./bin/test-api.sh
```

**测试项目：**
- ✅ 健康检查端点
- ✅ 模型列表端点
- ✅ 聊天完成端点
- ✅ 流式响应
- ✅ 性能基准测试

#### troubleshoot.sh
**功能：** 自动诊断常见问题

```bash
./bin/troubleshoot.sh
```

**诊断项目：**
- 🔍 端口占用检查
- 🔍 权限问题检查
- 🔍 网络连接检查
- 🔍 配置文件验证
- 🔍 日志分析

#### config-omlx.sh
**功能：** 交互式配置向导

```bash
./bin/config-omlx.sh
```

**功能：**
- 📝 自动备份现有配置
- ⚙️ 交互式配置向导
- 🔄 应用配置更改
- ✅ 验证配置有效性

---

## 文档索引

### 📚 docs/ - 技术文档

#### configuration-guide.md
**配置指南**
- 配置原理说明
- 配置文件结构详解
- 配置参数说明
- 最佳实践
- 常见场景配置示例

#### api-reference.md
**API 参考**
- 端点列表
- 请求/响应格式
- 错误码说明
- 使用示例
- 性能优化建议

#### troubleshooting.md
**故障排除**
- 常见问题及解决方案
- 错误信息对照表
- 日志分析技巧
- 调试工具使用

---

## 示例代码

### 💡 examples/ - 实用示例

#### basic-usage.sh
**基础用法示例**
- 验证配置
- 测试 API
- 简单对话示例
- 批量处理示例

```bash
./examples/basic-usage.sh
```

#### advanced-config.json
**高级配置示例**
- 多模型配置
- 负载均衡配置
- 缓存策略配置
- 安全配置

---

## 快速参考

### 常用命令

```bash
# 验证配置
./bin/verify-config.sh

# 测试 API
./bin/test-api.sh

# 诊断问题
./bin/troubleshoot.sh

# 重新配置
./bin/config-omlx.sh
```

### 配置文件位置

```bash
# omlx 配置
~/.omlx/settings.json

# openclaw 配置
~/.openclaw/openclaw.json

# omlx 模型目录
~/.omlx/models/

# openclaw 工作空间
~/.openclaw/workspaces/
```

### API 端点

```bash
# 健康检查
GET http://127.0.0.1:8008/health

# 模型列表
GET http://127.0.0.1:8008/v1/models

# 聊天完成
POST http://127.0.0.1:8008/v1/chat/completions
```

---

## 常见问题

### Q1: omlx 服务无法启动？

```bash
# 检查端口占用
lsof -i :8008

# 查看 omlx 日志
cat ~/omlx.log

# 重启 omlx
killall omlx && omlx serve --port 8008
```

### Q2: openclaw 无法连接到 omlx？

```bash
# 验证配置
./bin/verify-config.sh

# 检查 API Key
cat ~/.omlx/settings.json | jq .auth.api_key

# 测试连通性
curl http://127.0.0.1:8008/v1/models
```

### Q3: 模型加载失败？

```bash
# 检查模型目录
ls -la ~/.omlx/models/

# 重新下载模型
omlx model download gemma-4-e4b-it-4bit

# 验证模型
omlx model list
```

---

## 技术支持

**项目：** https://github.com/changzhi777/mactools
**问题反馈：** https://github.com/changzhi777/mactools/issues
**邮箱：** 14455975@qq.com

---

## 许可证

MIT License

---

**🦞 享受本地 AI 的强大能力！**
