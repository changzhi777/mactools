#!/bin/bash
#
# MacClaw Installer - oMLX 安装脚本
# 作者: 外星动物（常智）
# 版本: V1.0.1
#

# 加载日志模块
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/logger.sh"

OMLX_VERSION="0.2.24"

# 检测架构
detect_arch() {
    local arch=$(uname -m)
    case "$arch" in
        arm64)
            echo "arm64"
            ;;
        x86_64)
            echo "x64"
            ;;
        *)
            echo ""
            ;;
    esac
}

# 下载 oMLX
download_omlx() {
    log_info "📥 下载 oMLX..."

    local arch=$(detect_arch)
    if [ -z "$arch" ]; then
        log_error "❌ 不支持的架构"
        return 1
    fi

    local dmg_file="/tmp/omlx.dmg"
    local download_url="https://github.com/jundot/omlx/releases/download/v${OMLX_VERSION}/oMLX-${OMLX_VERSION}.${arch}.dmg"

    log_info "从 GitHub 下载 oMLX ${OMLX_VERSION} (${arch})..."

    if curl -L -o "$dmg_file" "$download_url"; then
        log_success "✅ 下载完成"
        return 0
    else
        log_error "❌ 下载失败"
        return 1
    fi
}

# 安装 oMLX
install_omlx() {
    log_info "📦 安装 oMLX..."

    local dmg_file="/tmp/omlx.dmg"

    # 检查是否已安装
    if [ -d "/Applications/oMLX.app" ]; then
        log_success "✅ oMLX 已安装"
        return 0
    fi

    # 挂载 DMG
    log_info "挂载 DMG 文件..."
    hdiutil attach "$dmg_file" -readonly -quiet

    if [ $? -ne 0 ]; then
        log_error "❌ DMG 挂载失败"
        return 1
    fi

    # 复制到 Applications
    log_info "复制 oMLX.app 到 /Applications..."
    cp -r /Volumes/oMLX/oMLX.app /Applications/

    if [ $? -eq 0 ]; then
        log_success "✅ oMLX 安装完成"
    else
        log_error "❌ oMLX 安装失败"
        hdiutil detach /Volumes/oMLX -quiet
        return 1
    fi

    # 卸载 DMG
    hdiutil detach /Volumes/oMLX -quiet

    # 清理 DMG 文件
    rm -f "$dmg_file"

    return 0
}

# 启动 oMLX
start_omlx() {
    log_info "🚀 启动 oMLX..."

    open -a oMLX

    # 等待服务启动
    log_info "等待 oMLX 服务启动..."
    sleep 5

    # 验证服务
    if curl -s http://127.0.0.1:8008/health &>/dev/null; then
        log_success "✅ oMLX 服务运行正常"
        return 0
    else
        log_warning "⚠️  oMLX 服务未响应，请手动启动"
        return 1
    fi
}

# 主函数
main() {
    # 检查是否已安装
    if [ -d "/Applications/oMLX.app" ]; then
        log_success "✅ oMLX 已安装"
        start_omlx
        return 0
    fi

    download_omlx || return 1
    install_omlx || return 1
    start_omlx || return 1

    return 0
}

main "$@"
