#!/bin/bash
#
# MacClaw Installer - 配置管理模块
# 作者: 外星动物（常智）
# 组织: IoTchange
# 邮箱: 14455975@qq.com
# 版本: V1.0.1
# 版权: Copyright (C) 2026 IoTchange - All Rights Reserved
#
# 说明: 管理国内源配置和各种配置文件
#

# 加载日志模块
source "$(dirname "$0")/logger.sh"

# 配置 npm 淘宝镜像
configure_npm_source() {
    log_info "⚙️  配置 npm 淘宝镜像..."

    npm config set registry https://registry.npmmirror.com

    if [ $? -eq 0 ]; then
        log_success "✅ npm 淘宝镜像配置完成"
        npm config get registry
        return 0
    else
        log_error "❌ npm 镜像配置失败"
        return 1
    fi
}

# 配置 pip 清华镜像
configure_pip_source() {
    log_info "⚙️  配置 pip 清华镜像..."

    mkdir -p "$HOME/.pip"

    cat > "$HOME/.pip/pip.conf" << 'EOF'
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
trusted-host = pypi.tuna.tsinghua.edu.cn
EOF

    if [ $? -eq 0 ]; then
        log_success "✅ pip 清华镜像配置完成"
        return 0
    else
        log_error "❌ pip 镜像配置失败"
        return 1
    fi
}

# 配置 ModelScope 镜像
configure_modelscope_source() {
    log_info "⚙️  配置 ModelScope 镜像..."

    # 设置环境变量
    export HF_ENDPOINT=https://hf-mirror.com

    # 添加到 shell 配置
    local shell_config="$HOME/.zshrc"
    if [ ! -f "$shell_config" ]; then
        shell_config="$HOME/.bashrc"
    fi

    if ! grep -q "HF_ENDPOINT" "$shell_config" 2>/dev/null; then
        echo "" >> "$shell_config"
        echo "# ModelScope 镜像配置" >> "$shell_config"
        echo "export HF_ENDPOINT=https://hf-mirror.com" >> "$shell_config"
    fi

    log_success "✅ ModelScope 镜像配置完成"
    return 0
}

# 配置 Git 代理（可选）
configure_git_proxy() {
    log_info "⚙️  配置 Git 代理..."

    # 这里可以配置 Git 代理或镜像
    # 暂时跳过，用户可根据需要配置

    log_info "💡 如需配置 Git 代理，请手动执行:"
    echo "  git config --global http.proxy http://127.0.0.1:7890"
    echo "  git config --global https.proxy https://127.0.0.1:7890"

    return 0
}

# 配置 OpenClaw
configure_openclaw() {
    log_info "⚙️  配置 OpenClaw..."

    local openclaw_config="$HOME/.openclaw/openclaw.json"

    if [ ! -f "$openclaw_config" ]; then
        log_warning "⚠️  OpenClaw 配置文件不存在，将创建新配置"
    else
        backup_file "$openclaw_config"
    fi

    # 创建配置目录
    ensure_dir "$(dirname "$openclaw_config")"

    # 写入配置
    cat > "$openclaw_config" << 'EOF'
{
  "gateway": {
    "mode": "local",
    "auth": {
      "mode": "token",
      "token": "9712011c9be25654b06174c1f85cf3d36e8fad303b8614be"
    },
    "port": 18789,
    "bind": "loopback"
  },
  "agents": {
    "defaults": {
      "workspace": "$HOME/.openclaw/workspace",
      "model": {
        "primary": "omlx/gemma-4-e4b-it-4bit"
      }
    }
  },
  "models": {
    "mode": "merge",
    "providers": {
      "omlx": {
        "baseUrl": "http://127.0.0.1:8008/v1",
        "apiKey": "ak47",
        "api": "openai-completions",
        "models": [
          {
            "id": "gemma-4-e4b-it-4bit",
            "name": "Gemma 4 4B Instruct 4bit",
            "reasoning": false,
            "input": ["text"],
            "cost": {
              "input": 0,
              "output": 0,
              "cacheRead": 0,
              "cacheWrite": 0
            },
            "contextWindow": 32768,
            "maxTokens": 4096,
            "compat": {
              "supportsTools": false,
              "requiresStringContent": true
            }
          }
        ]
      }
    }
  }
}
EOF

    if [ $? -eq 0 ]; then
        log_success "✅ OpenClaw 配置完成"
        return 0
    else
        log_error "❌ OpenClaw 配置失败"
        return 1
    fi
}

# 配置 oMLX API Key
configure_omlx_apikey() {
    log_info "⚙️  配置 oMLX API Key..."

    local omlx_config="$HOME/.omlx/settings.json"

    if [ ! -f "$omlx_config" ]; then
        log_warning "⚠️  oMLX 配置文件不存在"
        return 1
    fi

    # 读取现有 API Key
    local current_key=$(grep '"api_key"' "$omlx_config" | cut -d'"' -f4)

    if [ "$current_key" == "ak47" ]; then
        log_success "✅ oMLX API Key 已正确配置"
        return 0
    else
        log_warning "⚠️  oMLX API Key 不匹配"
        log_info "请确保 ~/.omlx/settings.json 中的 api_key 为: ak47"
        return 1
    fi
}

# 配置所有国内源
configure_all_sources() {
    log_info "⚙️  配置所有国内源..."
    show_separator

    configure_npm_source
    configure_pip_source
    configure_modelscope_source

    show_separator
    log_success "✅ 所有国内源配置完成"
}

# 导出函数
export -f configure_npm_source
export -f configure_pip_source
export -f configure_modelscope_source
export -f configure_git_proxy
export -f configure_openclaw
export -f configure_omlx_apikey
export -f configure_all_sources
