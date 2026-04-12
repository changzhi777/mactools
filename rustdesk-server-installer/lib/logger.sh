#!/bin/bash
#
# ==============================================================================
# RustDesk Server Installer - 日志输出模块
# ==============================================================================
#
# 功能说明：
#   提供统一的日志输出接口，支持彩色显示和日志级别
#
# 使用方法：
#   source lib/logger.sh
#   log_info "这是一条信息"
#   log_success "操作成功"
#   log_warning "警告信息"
#   log_error "错误信息"
#   log_step "执行步骤"
#
# ==============================================================================

# 颜色定义
readonly COLOR_RED='\033[0;31m'      # 错误
readonly COLOR_GREEN='\033[0;32m'    # 成功
readonly COLOR_YELLOW='\033[1;33m'   # 警告
readonly COLOR_BLUE='\033[0;34m'     # 信息
readonly COLOR_CYAN='\033[0;36m'     # 步骤
readonly COLOR_RESET='\033[0m'       # 重置

# 日志级别前缀
readonly PREFIX_INFO="ℹ️ "
readonly PREFIX_SUCCESS="✅ "
readonly PREFIX_WARNING="⚠️  "
readonly PREFIX_ERROR="❌ "
readonly PREFIX_STEP="🔷 "

# 检测是否支持彩色输出
if [[ -t 1 ]] && [[ $(tput colors 2>/dev/null || echo 0) -ge 8 ]]; then
    SUPPORT_COLOR=true
else
    SUPPORT_COLOR=false
fi

#
# 输出彩色日志
# 参数：$1=颜色, $2=前缀, $3=消息
#
_log() {
    local color="$1"
    local prefix="$2"
    local message="$3"

    if [[ "$SUPPORT_COLOR" == "true" ]]; then
        echo -e "${color}${prefix}${message}${COLOR_RESET}"
    else
        echo "${prefix}${message}"
    fi
}

#
# 信息日志（蓝色）
# 参数：$1=消息内容
#
log_info() {
    _log "$COLOR_BLUE" "$PREFIX_INFO" "$1"
}

#
# 成功日志（绿色）
# 参数：$1=消息内容
#
log_success() {
    _log "$COLOR_GREEN" "$PREFIX_SUCCESS" "$1"
}

#
# 警告日志（黄色）
# 参数：$1=消息内容
#
log_warning() {
    _log "$COLOR_YELLOW" "$PREFIX_WARNING" "$1"
}

#
# 错误日志（红色）
# 参数：$1=消息内容
#
log_error() {
    _log "$COLOR_RED" "$PREFIX_ERROR" "$1"
}

#
# 步骤提示（青色）
# 参数：$1=消息内容
#
log_step() {
    _log "$COLOR_CYAN" "$PREFIX_STEP" "$1"
}

#
# 空行输出
#
log_blank() {
    echo ""
}

#
# 分隔线
# 参数：$1=分隔符（默认 "-"）
#
log_separator() {
    local char="${1:-}"
    local width=60
    if [[ -z "$char" ]]; then
        echo ""
    else
        printf '%*s\n' "$width" | tr ' ' "$char"
    fi
}

#
# 标题输出
# 参数：$1=标题内容
#
log_title() {
    local title="$1"
    log_blank
    log_separator "="
    echo "  $title"
    log_separator "="
    log_blank
}

#
# 列表输出
# 参数：$1=列表项内容
#
log_list_item() {
    echo "  • $1"
}

#
# 带缩进的输出
# 参数：$1=缩进级别, $2=消息内容
#
log_indent() {
    local level="${1:-1}"
    local message="$2"
    local indent=""

    for ((i=0; i<level; i++)); do
        indent+="  "
    done

    echo "${indent}${message}"
}

#
# 调试日志（仅在 DEBUG 模式下显示）
# 参数：$1=消息内容
#
log_debug() {
    if [[ "${DEBUG:-false}" == "true" ]]; then
        _log "$COLOR_CYAN" "[DEBUG] " "$1"
    fi
}

#
# 横幅输出
# 参数：$1=横幅文本
#
log_banner() {
    local text="$1"
    local len=${#text}
    local padding=3
    local total_width=$((len + padding * 2))
    local border=""

    for ((i=0; i<total_width; i++)); do
        border+="="
    done

    echo ""
    echo "$border"
    echo "$(printf '%*s' "$padding")$text"
    echo "$border"
    echo ""
}
