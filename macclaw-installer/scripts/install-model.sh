#!/bin/bash
#
# MacClaw Installer - AI 模型下载脚本
# 作者: 外星动物（常智）
# 版本: V1.0.1
#

# 加载日志模块
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/logger.sh"

MODEL_NAME="mlx-community/gemma-4-e4b-it-4bit"

# 安装 ModelScope
install_modelscope() {
    log_info "📦 安装 ModelScope..."

    # 检查是否已安装
    if pip3 show modelscope &>/dev/null; then
        log_success "✅ ModelScope 已安装"
        return 0
    fi

    pip3 install modelscope

    if [ $? -eq 0 ]; then
        log_success "✅ ModelScope 安装完成"
        return 0
    else
        log_error "❌ ModelScope 安装失败"
        return 1
    fi
}

# 下载模型
download_model() {
    log_info "📥 下载 AI 模型: $MODEL_NAME"
    log_info "模型大小约 4GB，下载可能需要一些时间..."

    modelscope download --model "$MODEL_NAME"

    if [ $? -eq 0 ]; then
        log_success "✅ 模型下载完成"
        return 0
    else
        log_error "❌ 模型下载失败"
        return 1
    fi
}

# 验证模型
verify_model() {
    log_info "🔍 验证模型..."

    local model_path="$HOME/.modelscope/hub/mlx-community/gemma-4-e4b-it-4bit"

    if [ -d "$model_path" ]; then
        local size=$(du -sh "$model_path" | cut -f1)
        log_success "✅ 模型已下载 ($size)"
        return 0
    else
        log_error "❌ 模型文件不存在"
        return 1
    fi
}

# 主函数
main() {
    install_modelscope || return 1
    download_model || return 1
    verify_model || return 1

    return 0
}

main "$@"
