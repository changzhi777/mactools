#!/bin/bash
#
# 日志和彩色输出模块
#
# 作者: 外星动物（常智）
# 组织: IoTchange
# 邮箱: 14455975@qq.com
# 版权: Copyright (C) 2026 IoTchange - All Rights Reserved
#
# 描述: 提供统一的日志输出和彩色终端显示功能
#

# ============================================================================
# 颜色定义
# ============================================================================

# 检测是否支持彩色输出
if [[ -t 1 ]] && [[ $(tput colors 2>/dev/null || echo 0) -ge 8 ]]; then
    COLOR_RED='\033[0;31m'
    COLOR_GREEN='\033[0;32m'
    COLOR_YELLOW='\033[0;33m'
    COLOR_BLUE='\033[0;34m'
    COLOR_CYAN='\033[0;36m'
    COLOR_GRAY='\033[0;90m'
    COLOR_BOLD='\033[1m'
    COLOR_RESET='\033[0m'
else
    COLOR_RED=''
    COLOR_GREEN=''
    COLOR_YELLOW=''
    COLOR_BLUE=''
    COLOR_CYAN=''
    COLOR_GRAY=''
    COLOR_BOLD=''
    COLOR_RESET=''
fi

# ============================================================================
# 日志函数
# ============================================================================

# 信息日志
log_info() {
    echo -e "${COLOR_BLUE}[INFO]${COLOR_RESET} $*"
}

# 成功日志
log_success() {
    echo -e "${COLOR_GREEN}[SUCCESS]${COLOR_RESET} $*"
}

# 警告日志
log_warning() {
    echo -e "${COLOR_YELLOW}[WARNING]${COLOR_RESET} $*" >&2
}

# 错误日志
log_error() {
    echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} $*" >&2
}

# 调试日志
log_debug() {
    if [[ "${DEBUG:-0}" == "1" ]]; then
        echo -e "${COLOR_GRAY}[DEBUG]${COLOR_RESET} $*"
    fi
}

# ============================================================================
# 进度显示
# ============================================================================

# 显示步骤标题
log_step() {
    local step="$1"
    shift
    echo -e "\n${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
    echo -e "${COLOR_BOLD}${step}${COLOR_RESET}"
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
}

# 显示子步骤
log_substep() {
    echo -e "${COLOR_YELLOW}▶${COLOR_RESET} $*"
}

# ============================================================================
# 状态指示器
# ============================================================================

# 显示检查结果
log_check() {
    local status="$1"
    local message="$2"

    if [[ "$status" == "ok" ]]; then
        echo -e "${COLOR_GREEN}✓${COLOR_RESET} ${message}"
    elif [[ "$status" == "fail" ]]; then
        echo -e "${COLOR_RED}✗${COLOR_RESET} ${message}"
    elif [[ "$status" == "skip" ]]; then
        echo -e "${COLOR_GRAY}○${COLOR_RESET} ${message}"
    else
        echo -e "• ${message}"
    fi
}

# ============================================================================
# 用户交互
# ============================================================================

# 询问用户确认
ask_yes_no() {
    local prompt="$1"
    local default="${2:-n}"

    local yes_no="y/N"
    if [[ "$default" == "y" ]]; then
        yes_no="Y/n"
    fi

    while true; do
        echo -en "${COLOR_CYAN}${prompt} [${yes_no}]${COLOR_RESET} "
        read -r answer

        # 使用默认值
        if [[ -z "$answer" ]]; then
            answer="$default"
        fi

        case "$answer" in
            [Yy]|[Yy][Ee][Ss])
                return 0
                ;;
            [Nn]|[Nn][Oo])
                return 1
                ;;
            *)
                echo -e "${COLOR_YELLOW}请输入 y 或 n${COLOR_RESET}"
                ;;
        esac
    done
}

# ============================================================================
# 分隔符
# ============================================================================

# 显示分隔线
log_separator() {
    local width="${1:-60}"
    local char="${2:-─}"

    local line=""
    for ((i=0; i<width; i++)); do
        line+="$char"
    done
    echo -e "${COLOR_GRAY}${line}${COLOR_RESET}"
}
