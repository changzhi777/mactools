# Hermes Agent 本地安装执行总结

**执行时间**: 2026-04-12
**执行环境**: macOS (Darwin arm64)
**安装版本**: Hermes Agent v0.8.0

---

## ✅ 安装成功

Hermes Agent 已成功安装到本地环境！

---

## 📊 安装详情

### 环境信息
- **操作系统**: macOS (Darwin arm64)
- **系统 Python**: 3.9.6
- **虚拟环境 Python**: 3.13.12
- **包管理器**: uv 0.11.6
- **Git**: 2.50.1

### 安装位置
- **安装目录**: ~/.hermes/hermes-agent
- **配置目录**: ~/.hermes/config
- **数据目录**: ~/.hermes/data
- **符号链接**: ~/.local/bin/hermes
- **安装大小**: 234 MB

### 已安装组件
- **Python 包**: 127 个
- **Hermes Agent**: v0.8.0 (2026.4.8)
- **OpenAI SDK**: v2.24.0
- **虚拟环境**: 已创建并激活

---

## 🚀 快速使用

### 方法 1：使用完整路径（推荐用于首次使用）

```bash
# 查看版本
~/.local/bin/hermes --version

# 查看帮助
~/.local/bin/hermes --help

# 查看状态
~/.local/bin/hermes status

# 运行配置向导
~/.local/bin/hermes setup

# 启动交互式聊天
~/.local/bin/hermes chat
```

### 方法 2：配置 PATH 后使用（推荐用于日常使用）

#### 临时配置（当前会话）
```bash
export PATH="$HOME/.local/bin:$PATH"
hermes --version
```

#### 永久配置（推荐）

**对于 Zsh 用户（macOS 默认）**：
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

**对于 Bash 用户**：
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

配置后可以直接使用：
```bash
hermes --version
hermes status
hermes chat
```

---

## 📋 可用命令

### 核心命令
```bash
hermes chat              # 交互式聊天
hermes setup             # 配置向导
hermes status            # 查看状态
hermes model             # 选择模型
hermes config            # 查看配置
```

### 高级命令
```bash
hermes skills            # 技能管理
hermes memory            # 记忆配置
hermes tools             # 工具配置
hermes sessions          # 会话管理
hermes plugins           # 插件管理
hermes doctor            # 诊断检查
```

### 实用命令
```bash
hermes --help            # 查看帮助
hermes --help-all        # 查看所有帮助
hermes --version         # 查看版本
hermes dump              # 导出配置摘要
hermes backup            # 备份数据
```

---

## 🔧 配置 API Keys

Hermes Agent 需要配置至少一个 API Provider 才能正常工作。

### 支持的 Provider

1. **OpenRouter** (推荐)
   - 支持多种模型
   - 访问: https://openrouter.ai/

2. **OpenAI**
   - 官方 API
   - 访问: https://platform.openai.com/

3. **Anthropic (Claude)**
   - 通过 OpenRouter 或直接 API

4. **国内服务商**
   - Z.AI/GLM (智谱)
   - Kimi (月之暗面)
   - MiniMax

### 配置方法

#### 方法 1：交互式配置（推荐）
```bash
~/.local/bin/hermes setup
```

#### 方法 2：命令行配置
```bash
~/.local/bin/hermes login
# 按提示选择 Provider 并输入 API Key
```

#### 方法 3：环境变量配置
```bash
# OpenAI
export OPENAI_API_KEY="sk-..."

# OpenRouter
export OPENROUTER_API_KEY="sk-or-..."

# 或添加到 ~/.zshrc 或 ~/.bashrc
echo 'export OPENAI_API_KEY="sk-..."' >> ~/.zshrc
```

---

## ✅ 验证安装

### 基本验证
```bash
# 1. 版本检查
~/.local/bin/hermes --version
# 预期输出: Hermes Agent v0.8.0

# 2. 帮助信息
~/.local/bin/hermes --help
# 预期输出: 命令列表

# 3. 状态检查
~/.local/bin/hermes status
# 预期输出: 系统状态信息
```

### 完整验证
```bash
# 运行验证脚本
bash /Users/mac/cz_code/mactools/tools/hermes-agent-local/verify.sh all
# 预期输出: ✓ 所有验证通过
```

---

## 🎯 下一步操作

### 1. 配置 PATH（推荐）
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### 2. 配置 API Provider
```bash
hermes setup
# 或
hermes login
```

### 3. 测试基本功能
```bash
# 启动聊天（需要先配置 API Key）
hermes chat

# 或查看状态
hermes status
```

### 4. 探索更多功能
```bash
# 查看所有可用命令
hermes --help-all

# 管理技能
hermes skills

# 配置工具
hermes tools
```

---

## 📚 文档和帮助

### 官方文档
- **GitHub**: https://github.com/NousResearch/hermes-agent
- **文档**: https://docs.nousresearch.com
- **问题反馈**: https://github.com/NousResearch/hermes-agent/issues

### 本地帮助
```bash
hermes --help           # 基本帮助
hermes --help-all       # 所有命令帮助
hermes <command> --help # 特定命令帮助
```

### 本地安装文档
- **README**: /Users/mac/cz_code/mactools/tools/hermes-agent-local/README.md
- **测试报告**: /Users/mac/cz_code/mactools/tools/hermes-agent-local/INSTALL_REPORT.md

---

## 🛠️ 故障排查

### 问题 1：hermes 命令找不到

**解决方案**：
```bash
# 使用完整路径
~/.local/bin/hermes --version

# 或配置 PATH
export PATH="$HOME/.local/bin:$PATH"
```

### 问题 2：API Key 未配置

**解决方案**：
```bash
# 运行配置向导
hermes setup

# 或登录
hermes login
```

### 问题 3：依赖包问题

**解决方案**：
```bash
# 重新安装依赖
cd ~/.hermes/hermes-agent
uv sync --extra cli
```

### 问题 4：版本更新

**解决方案**：
```bash
# 更新到最新版本
hermes update
```

---

## 📞 获取帮助

### 本地支持
- **安装脚本位置**: /Users/mac/cz_code/mactools/tools/hermes-agent-local/
- **验证脚本**: bash /Users/mac/cz_code/mactools/tools/hermes-agent-local/verify.sh
- **卸载脚本**: bash /Users/mac/cz_code/mactools/tools/hermes-agent-local/uninstall.sh

### 社区支持
- **GitHub Issues**: https://github.com/NousResearch/hermes-agent/issues
- **Discord**: https://discord.gg/nous-research

### 联系作者
- **作者**: 外星动物（常智）
- **邮箱**: 14455975@qq.com
- **组织**: IoTchange

---

## ✅ 安装确认

### 安装成功标志
- ✅ hermes 命令可用
- ✅ 版本信息正确
- ✅ 所有验证通过
- ✅ 虚拟环境正常
- ✅ 依赖包完整

### 测试结果
```
✓ 环境验证: 通过
✓ 安装验证: 通过
✓ 功能验证: 通过
✓ 版本信息: Hermes Agent v0.8.0
✓ Python 环境: 3.13.12
✓ 包管理器: uv 0.11.6
```

---

## 🎉 安装完成！

**Hermes Agent 已成功安装到您的系统！**

**下一步**：
1. 配置 PATH（可选但推荐）
2. 配置 API Provider
3. 运行 `hermes setup` 或 `hermes chat`

**祝您使用愉快！** 🚀

---

**安装时间**: 2026-04-12
**安装版本**: v1.0.0
**作者**: 外星动物（常智）
**版权**: Copyright (C) 2026 IoTchange - All Rights Reserved
