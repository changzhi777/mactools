#!/usr/bin/env zsh
# ==============================================================================
# MacClaw Install - macOS Dialog 工具模块
# ==============================================================================
#
# 作者: 外星动物（常智） / IoTchange / 14455975@qq.com
# 版权: Copyright (C) 2026 IoTchange - All Rights Reserved
#
# 功能说明：
#   提供各种 macOS 对话框的显示函数
#   使用 osascript 实现原生对话框
#
# 使用方法：
#   source "${LIB_DIR}/interactive/dialog-helper.zsh"
#   show_info_dialog "消息内容" "标题"
#
# ==============================================================================

# ==============================================================================
# 全局变量
# ==============================================================================

# 对话框配置（从配置文件加载）
typeset -g DIALOG_TITLE="${DIALOG_TITLE:-MacClaw 交互式安装}"
typeset -g DIALOG_ICON="${DIALOG_ICON:-note}"
typeset -g DIALOG_BUTTON_OK="${DIALOG_BUTTON_OK:-确定}"
typeset -g DIALOG_BUTTON_CANCEL="${DIALOG_BUTTON_CANCEL:-取消}"
typeset -g DIALOG_BUTTON_RETRY="${DIALOG_BUTTON_RETRY:-重试}"
typeset -g DIALOG_BUTTON_LATER="${DIALOG_BUTTON_LATER:-稍后提醒}"

# ==============================================================================
# 辅助函数
# ==============================================================================

# osascript 转义函数（处理特殊字符）
osascript_escape() {
    local text="$1"
    # 转义双引号和反斜杠
    echo "${text//\\/\\\\}"
    echo "${text//\"/\\\"}"
}

# ==============================================================================
# 对话框函数
# ==============================================================================

# 显示信息对话框
# 参数：message, title
# 返回：0（用户点击确定）
show_info_dialog() {
    local message="$1"
    local title="${2:-${DIALOG_TITLE}}"
    local escaped_message=$(osascript_escape "${message}")
    local escaped_title=$(osascript_escape "${title}")

    osascript -e "tell application \"System Events\" to display dialog \"${escaped_message}\" buttons {\"${DIALOG_BUTTON_OK}\"} default button \"${DIALOG_BUTTON_OK}\" with title \"${escaped_title}\" with icon ${DIALOG_ICON}" >/dev/null 2>&1

    return 0
}

# 显示确认对话框（是/否）
# 参数：message, title
# 返回：0（是），1（否）
show_confirm_dialog() {
    local message="$1"
    local title="${2:-${DIALOG_TITLE}}"
    local escaped_message=$(osascript_escape "${message}")
    local escaped_title=$(osascript_escape "${title}")

    local result=$(osascript -e "tell application \"System Events\" to display dialog \"${escaped_message}\" buttons {\"${DIALOG_BUTTON_CANCEL}\", \"${DIALOG_BUTTON_OK}\"} default button \"${DIALOG_BUTTON_CANCEL}\" with title \"${escaped_title}\" with icon ${DIALOG_ICON}" 2>&1)

    if [[ "${result}" == *"button returned:${DIALOG_BUTTON_OK}"* ]]; then
        return 0
    else
        return 1
    fi
}

# 显示确认对话框（是/否/稍后）
# 参数：message, title
# 返回：0（是），1（否），2（稍后）
show_confirm_dialog_with_later() {
    local message="$1"
    local title="${2:-${DIALOG_TITLE}}"
    local escaped_message=$(osascript_escape "${message}")
    local escaped_title=$(osascript_escape "${title}")

    local result=$(osascript -e "tell application \"System Events\" to display dialog \"${escaped_message}\" buttons {\"${DIALOG_BUTTON_CANCEL}\", \"${DIALOG_BUTTON_LATER}\", \"${DIALOG_BUTTON_OK}\"} default button \"${DIALOG_BUTTON_OK}\" with title \"${escaped_title}\" with icon ${DIALOG_ICON}" 2>&1)

    if [[ "${result}" == *"button returned:${DIALOG_BUTTON_OK}"* ]]; then
        return 0
    elif [[ "${result}" == *"button returned:${DIALOG_BUTTON_LATER}"* ]]; then
        return 2
    else
        return 1
    fi
}

# 显示输入对话框
# 参数：message, title, default_answer
# 返回：用户输入（通过全局变量 DIALOG_INPUT_RESULT）
show_input_dialog() {
    local message="$1"
    local title="${2:-${DIALOG_TITLE}}"
    local default_answer="${3:-}"
    local escaped_message=$(osascript_escape "${message}")
    local escaped_title=$(osascript_escape "${title}")
    local escaped_default=$(osascript_escape "${default_answer}")

    local result=$(osascript -e "tell application \"System Events\" to display dialog \"${escaped_message}\" default answer \"${escaped_default}\" buttons {\"${DIALOG_BUTTON_CANCEL}\", \"${DIALOG_BUTTON_OK}\"} default button \"${DIALOG_BUTTON_OK}\" with title \"${escaped_title}\" with icon ${DIALOG_ICON} hidden answer" 2>&1)

    if [[ "${result}" == *"button returned:${DIALOG_BUTTON_OK}"* ]]; then
        # 提取用户输入
        DIALOG_INPUT_RESULT=$(echo "${result}" | sed -n 's/.*text returned:\(.*\)/\1/p')
        export DIALOG_INPUT_RESULT
        return 0
    else
        DIALOG_INPUT_RESULT=""
        export DIALOG_INPUT_RESULT
        return 1
    fi
}

# 显示选择对话框（单选）
# 参数：message, title, choices_array
# 返回：用户选择的索引（从1开始，通过全局变量 DIALOG_CHOICE_RESULT）
show_choice_dialog() {
    local message="$1"
    local title="${2:-${DIALOG_TITLE}}"
    shift 2
    local choices=("$@")

    local escaped_message=$(osascript_escape "${message}")
    local escaped_title=$(osascript_escape "${title}")

    # 构建选择列表
    local choices_list=""
    for choice in "${choices[@]}"; do
        choices_list="${choices_list}\"${choice}\", "
    done
    choices_list="${choices_list%, }"  # 移除最后的逗号和空格

    local result=$(osascript -e "tell application \"System Events\" to choose from list {${choices_list}} with prompt \"${escaped_message}\" with title \"${escaped_title}\"" 2>&1)

    if [[ "${result}" == *"Cancel"* ]] || [[ -z "${result}" ]]; then
        DIALOG_CHOICE_RESULT=0
        export DIALOG_CHOICE_RESULT
        return 1
    else
        # 查找用户选择的索引
        local index=1
        for choice in "${choices[@]}"; do
            if [[ "${result}" == *"${choice}"* ]]; then
                DIALOG_CHOICE_RESULT=${index}
                export DIALOG_CHOICE_RESULT
                return 0
            fi
            ((index++))
        done
    fi

    DIALOG_CHOICE_RESULT=0
    export DIALOG_CHOICE_RESULT
    return 1
}

# 显示进度对话框（模拟）
# 参数：message, duration_seconds
show_progress_dialog() {
    local message="$1"
    local duration="${2:-5}"

    # 在终端显示进度信息
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  ${message}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # 显示进度条
    local progress=0
    while [[ ${progress} -le 100 ]]; do
        local filled=$((progress / 5))
        local empty=$((20 - filled))
        printf "\r["
        printf "%${filled}s" | tr ' ' '█'
        printf "%${empty}s" | tr ' ' '░'
        printf "] %d%%" ${progress}
        sleep $(echo "scale=2; ${duration} / 20" | bc)
        ((progress += 5))
    done
    printf "\n"
    echo ""
}

# 显示等待对话框（带取消按钮）
# 参数：message
# 返回：0（用户点击继续），1（用户点击取消）
show_wait_dialog() {
    local message="$1"
    local escaped_message=$(osascript_escape "${message}")

    local result=$(osascript -e "tell application \"System Events\" to display dialog \"${escaped_message}\" buttons {\"${DIALOG_BUTTON_CANCEL}\", \"我已完成\"} default button \"我已完成\" with title \"${DIALOG_TITLE}\" with icon ${DIALOG_ICON} giving up after ${STEP_TIMEOUT:-3600}" 2>&1)

    if [[ "${result}" == *"button returned:我已完成"* ]] || [[ "${result}" == *"gave up:true"* ]]; then
        return 0
    else
        return 1
    fi
}

# 显示错误对话框
# 参数：message, title
show_error_dialog() {
    local message="$1"
    local title="${2:-错误}"
    local escaped_message=$(osascript_escape "${message}")
    local escaped_title=$(osascript_escape "${title}")

    osascript -e "tell application \"System Events\" to display dialog \"${escaped_message}\" buttons {\"${DIALOG_BUTTON_OK}\"} default button \"${DIALOG_BUTTON_OK}\" with title \"${escaped_title}\" with icon stop" >/dev/null 2>&1

    return 0
}

# 显示警告对话框
# 参数：message, title
show_warning_dialog() {
    local message="$1"
    local title="${2:-警告}"
    local escaped_message=$(osascript_escape "${message}")
    local escaped_title=$(osascript_escape "${title}")

    osascript -e "tell application \"System Events\" to display dialog \"${escaped_message}\" buttons {\"${DIALOG_BUTTON_OK}\"} default button \"${DIALOG_BUTTON_OK}\" with title \"${escaped_title}\" with icon caution" >/dev/null 2>&1

    return 0
}

# ==============================================================================
# 导出函数
# ==============================================================================

export -f show_info_dialog
export -f show_confirm_dialog
export -f show_confirm_dialog_with_later
export -f show_input_dialog
export -f show_choice_dialog
export -f show_progress_dialog
export -f show_wait_dialog
export -f show_error_dialog
export -f show_warning_dialog
