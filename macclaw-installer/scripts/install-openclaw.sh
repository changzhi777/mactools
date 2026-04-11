#!/bin/bash
#
# MacClaw Installer - OpenClaw 安装脚本
# 作者: 外星动物（常智）
# 版本: V1.0.1
#

# 加载日志模块
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/logger.sh"

# 安装 OpenClaw CLI
install_openclaw() {
    log_info "📦 安装 OpenClaw CLI..."

    # 检查是否已安装
    if command -v openclaw &>/dev/null; then
        local version=$(openclaw --version 2>/dev/null | head -1)
        log_success "✅ OpenClaw 已安装 ($version)"
        return 0
    fi

    # 使用 npm 全局安装
    npm install -g openclaw

    if [ $? -eq 0 ]; then
        log_success "✅ OpenClaw 安装完成"
        return 0
    else
        log_error "❌ OpenClaw 安装失败"
        return 1
    fi
}

# 初始化配置
init_openclaw() {
    log_info "⚙️  初始化 OpenClaw..."

    # 运行 onboard
    openclaw onboard --non-interactive

    if [ $? -eq 0 ]; then
        log_success "✅ OpenClaw 初始化完成"
        return 0
    else
        log_warning "⚠️  初始化失败，可能需要手动配置"
        return 1
    fi
}

# 验证安装
verify_installation() {
    log_info "🔍 验证安装..."

    if command -v openclaw &>/dev/null; then
        local version=$(openclaw --version 2>/dev/null | head -1)
        log_success "✅ OpenClaw CLI: $version"

        # 运行诊断
        openclaw doctor

        return 0
    else
        log_error "❌ OpenClaw 未正确安装"
        return 1
    fi
}

# 主函数
main() {
    install_openclaw || return 1
    init_openclaw || return 1
    verify_installation || return 1

    return 0
}

main "$@"
