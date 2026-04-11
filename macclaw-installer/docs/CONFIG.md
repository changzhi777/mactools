# MacClaw Installer - 配置说明

**版本:** V1.0.1  
**作者:** 外星动物（常智）

---

## ⚙️ 配置文件位置

### OpenClaw 配置
```bash
~/.openclaw/openclaw.json
```

### oMLX 配置
```bash
~/.omlx/settings.json
```

### 安装器配置
```bash
config/sources.conf      # 国内源配置
config/versions.conf     # 版本配置
```

---

## 🔧 OpenClaw 配置详解

### 基础配置

```json
{
  "gateway": {
    "mode": "local",
    "auth": {
      "mode": "token",
      "token": "your-token-here"
    },
    "port": 18789,
    "bind": "loopback"
  },
  "agents": {
    "defaults": {
      "workspace": "~/.openclaw/workspace",
      "model": {
        "primary": "omlx/gemma-4-eb-it-4bit"
      }
    }
  }
}
```

### oMLX Provider 配置

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
            "maxTokens": 4096
          }
        ]
      }
    }
  }
}
```

---

## 🔑 oMLX 配置详解

### 基础配置

```json
{
  "server": {
    "host": "127.0.0.1",
    "port": 8008
  },
  "model": {
    "model_dirs": ["~/.omlx/models"],
    "max_model_memory": "auto"
  },
  "auth": {
    "api_key": "ak47",
    "skip_api_key_verification": false
  }
}
```

### 重要配置项

- **api_key:** OpenClaw 连接 oMLX 的密钥，必须为 `ak47`
- **port:** oMLX 服务端口，默认 8008
- **max_model_memory:** 最大模型内存，建议设为 `auto`

---

## 🌐 国内源配置

### npm 淘宝镜像

```bash
npm config set registry https://registry.npmmirror.com
```

### pip 清华镜像

创建 `~/.pip/pip.conf`:
```ini
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
trusted-host = pypi.tuna.tsinghua.edu.cn
```

### ModelScope 镜像

```bash
export HF_ENDPOINT=https://hf-mirror.com
```

添加到 `~/.zshrc` 或 `~/.bashrc`:
```bash
echo "export HF_ENDPOINT=https://hf-mirror.com" >> ~/.zshrc
```

---

## 🤖 Agent 配置

### 创建新 Agent

```bash
openclaw agents add myagent \
  --workspace ~/.openclaw/workspace-myagent \
  --non-interactive
```

### 配置 Agent 模型

```bash
openclaw agents config myagent \
  --model omlx/gemma-4-eb-it-4bit
```

### 绑定 Skills

```bash
openclaw agents skills attach myagent file-operations
openclaw agents skills attach myagent web-search
```

---

## 📦 Skills 配置

### 安装 Skill

```bash
openclaw skills install <skill-name>
```

### 列出已安装 Skills

```bash
openclaw skills list
```

### 查看 Agent Skills

```bash
openclaw agents skills list --agent <agent-name>
```

---

## 🔍 配置验证

### 验证 OpenClaw 配置

```bash
openclaw doctor
```

### 验证 oMLX 连接

```bash
curl http://127.0.0.1:8008/health
```

### 验证 Agent 配置

```bash
openclaw agents list
openclaw agents config <agent-name>
```

---

## 🛠️ 高级配置

### 自定义端口

修改 `~/.openclaw/openclaw.json`:
```json
{
  "gateway": {
    "port": 18889  # 自定义端口
  }
}
```

### 启用外网访问

修改 `~/.openclaw/openclaw.json`:
```json
{
  "gateway": {
    "bind": "0.0.0.0"  # 允许外网访问
  }
}
```

⚠️ **注意:** 启用外网访问需注意安全风险。

### 配置代理

如果需要使用代理：

```bash
# HTTP 代理
export HTTP_PROXY="http://127.0.0.1:7890"
export HTTPS_PROXY="https://127.0.0.1:7890"

# Git 代理
git config --global http.proxy http://127.0.0.1:7890
git config --global https.proxy https://127.0.0.1:7890
```

---

## 📝 配置文件示例

完整配置示例请参考：
- `config/sources.conf` - 国内源配置
- `config/versions.conf` - 版本配置
- `config/agents.conf` - Agent 配置模板

---

## 🔄 更新配置

### 重新加载配置

```bash
# 重启 OpenClaw Gateway
openclaw gateway restart

# 重启 oMLX
killall oMLX
open -a oMLX
```

---

## 🐛 常见配置问题

### Q1: API Key 不匹配？

确保 `~/.omlx/settings.json` 中的 `api_key` 为 `ak47`

### Q2: 端口冲突？

修改 `~/.openclaw/openclaw.json` 和 `~/.omlx/settings.json` 中的端口配置

### Q3: 模型未加载？

检查 oMLX 应用，确保模型已正确加载

---

## 📞 获取帮助

- **项目文档:** https://github.com/IoTchange/macclaw-installer
- **问题反馈:** https://github.com/IoTchange/macclaw-installer/issues

---

**🦞 祝您配置顺利！**
