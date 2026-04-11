#!/bin/bash
#
# MacClaw Installer - Node.js 安装脚本
# 作者: 外星动物（常智）
# 版本: V1.0.1
#

# 加载日志模块
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/logger.sh"

NVM_DIR="$HOME/.nvm"

# 安装 nvm
install_nvm() {
    log_info "📦 安装 nvm (Node.js 版本管理器)..."

    # 检查是否已安装
    if [ -d "$NVM_DIR" ]; then
        log_success "✅ nvm 已安装"
        return 0
    fi

    # 下载并安装 nvm（使用 Gitee 镜像）
    log_info "从 Gitee 镜像下载 nvm..."
    curl -o- https://gitee.com/mirrors/nvm/raw/master/install.sh | bash

    if [ $? -eq 0 ]; then
        log_success "✅ nvm 安装完成"
        return 0
    else
        log_error "❌ nvm 安装失败"
        return 1
    fi
}

# 加载 nvm
load_nvm() {
    log_info "加载 nvm..."

    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

    if command -v nvm &>/dev/null; then
        log_success "✅ nvm 加载成功"
        return 0
    else
        log_error "❌ nvm 加载失败"
        return 1
    fi
}

# 安装 Node.js LTS
install_nodejs() {
    log_info "📦 安装 Node.js LTS..."

    nvm install --lts

    if [ $? -eq 0 ]; then
        nvm use --lts
        nvm alias default lts/*

        local version=$(node --version)
        log_success "✅ Node.js $version 安装完成"
        return 0
    else
        log_error "❌ Node.js 安装失败"
        return 1
    fi
}

# 验证安装
verify_installation() {
    log_info "🔍 验证安装..."

    if command -v node &>/dev/null && command -v npm &>/dev/null; then
        local node_version=$(node --version)
        local npm_version=$(npm --version)

        log_success "✅ Node.js $node_version"
        log_success "✅ npm $npm_version"
        return 0
    else
        log_error "❌ 验证失败"
        return 1
    fi
}

# 主函数
main() {
    install_nvm || return 1
    load_nvm || return 1
    install_nodejs || return 1
    verify_installation || return 1

    return 0
}

main "$@"
