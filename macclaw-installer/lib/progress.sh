#!/bin/bash
#
# MacClaw Installer - 进度显示模块
# 作者: 外星动物（常智）
# 版本: V1.0.1
#

# 加载日志模块
source "$(dirname "$0")/logger.sh"

# 进度条配置
PROGRESS_BAR_WIDTH=50
PROGRESS_COMPLETED="█"
PROGRESS_EMPTY="░"

# 显示进度条
show_progress_bar() {
    local current=$1
    local total=$2
    local message=${3:-"处理中"}

    local percent=$((current * 100 / total))
    local filled=$((percent * PROGRESS_BAR_WIDTH / 100))
    local empty=$((PROGRESS_BAR_WIDTH - filled))

    # 构建进度条
    local bar=""
    for ((i=0; i<filled; i++)); do
        bar+="${PROGRESS_COMPLETED}"
    done
    for ((i=0; i<empty; i++)); do
        bar+="${PROGRESS_EMPTY}"
    done

    # 显示进度
    printf "\r[%s] %d%% (%s)" "$bar" "$percent" "$message"

    # 完成时换行
    if [ $current -eq $total ]; then
        echo ""
    fi
}

# 显示步骤进度
show_step_progress() {
    local step=$1
    local total=$2
    local step_name=$3
    local status=$4  # pending, running, completed, failed

    local icons=("⏳" "🔄" "✅" "❌")
    local icon="${icons[$status]}"

    printf "\r[%d/%d] %s %s" "$step" "$total" "$icon" "$step_name"

    if [ "$status" -eq 2 ] || [ "$status" -eq 3 ]; then
        echo ""
    fi
}

# 显示总体进度
show_overall_progress() {
    local current_step=$1
    local total_steps=$2
    local step_name=$3

    clear
    cat << "EOF"
╔════════════════════════════════════════════════════════════╗
║              🦞 MacClaw 安装进度                             ║
╚════════════════════════════════════════════════════════════╝

[$current_step/$total_steps] $step_name

EOF
}

# 显示完成状态
show_complete_status() {
    local component=$1
    local success=$2
    local message=${3:-""}

    if [ "$success" = "true" ]; then
        log_success "✅ $component 完成"
    else
        log_error "❌ $component 失败"
        if [ -n "$message" ]; then
            log_error "   原因: $message"
        fi
    fi
}

# 旋转加载动画
show_spinner() {
    local message=$1
    local pid=$2
    local delay=0.1
    local spinstr='|/-\'

    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c] %s" "$spinstr" "$message"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\r"
    done
    printf "    \r"
}

# 导出函数
export -f show_progress_bar
export -f show_step_progress
export -f show_overall_progress
export -f show_complete_status
export -f show_spinner
