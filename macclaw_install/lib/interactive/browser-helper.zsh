#!/usr/bin/env zsh
# ==============================================================================
# MacClaw Install - 浏览器工具模块
# ==============================================================================
#
# 作者: 外星动物（常智） / IoTchange / 14455975@qq.com
# 版权: Copyright (C) 2026 IoTchange - All Rights Reserved
#
# 功能说明：
#   提供浏览器打开和用户交互等待功能
#   使用 macOS open 命令打开默认浏览器
#
# 使用方法：
#   source "${LIB_DIR}/interactive/browser-helper.zsh"
#   open_browser_with_prompt "https://example.com" "提示信息"
#
# ==============================================================================

# ==============================================================================
# 全局变量
# ==============================================================================

# 浏览器配置（从配置文件加载）
typeset -g BROWSER_OPEN_CMD="${BROWSER_OPEN_CMD:-open}"
typeset -g BROWSER_OPENInBackground="${BROWSER_OPENInBackground:-false}"

# 对话框模块依赖
if [[ -f "${LIB_DIR}/interactive/dialog-helper.zsh" ]]; then
    source "${LIB_DIR}/interactive/dialog-helper.zsh"
else
    echo "错误：找不到 dialog-helper.zsh 模块"
    exit 1
fi

# ==============================================================================
# 浏览器操作函数
# ==============================================================================

# 打开 URL 并显示提示
# 参数：url, message
# 返回：0（成功），1（失败）
open_browser_with_prompt() {
    local url="$1"
    local message="${2:-已在浏览器中打开页面，请查看...}"

    # 打开浏览器
    if [[ "${BROWSER_OPENInBackground}" == "true" ]]; then
        ${BROWSER_OPEN_CMD} -g "${url}" >/dev/null 2>&1 &
    else
        ${BROWSER_OPEN_CMD} "${url}" >/dev/null 2>&1 &
    fi

    local exit_code=$?

    # 等待一下，让浏览器有时间启动
    sleep 1

    if [[ ${exit_code} -eq 0 ]]; then
        # 显示提示对话框
        show_info_dialog "${message}" "浏览器已打开"
        return 0
    else
        show_error_dialog "无法打开浏览器\nURL: ${url}" "打开失败"
        return 1
    fi
}

# 打开 URL 并等待用户确认
# 参数：url, confirm_message
# 返回：0（用户确认完成），1（用户取消）
open_browser_and_wait() {
    local url="$1"
    local confirm_message="${2:-请确认您已在浏览器中完成操作后，点击"我已完成"继续。}"
    local prompt_message="正在打开浏览器..."
    local instructions=""

    # 根据不同的 URL 提供不同的说明
    if [[ "${url}" == *"omlx.ai"* ]]; then
        instructions="
请在浏览器中执行以下操作：
1. 下载并安装 omlx 应用
2. 下载模型：${MODEL_NAME:-mlx-community/gemma-4-e4b-it-4bit}
3. 完成安装后返回此处点击"我已完成"
"
    elif [[ "${url}" == *"openclaw.ai"* ]]; then
        instructions="
请在浏览器中执行以下操作：
1. 查看 OpenClaw 的安装说明
2. 下载并安装 OpenClaw CLI
3. 完成安装后返回此处点击"我已完成"
"
    fi

    # 构建完整的提示消息
    local full_message="${prompt_message}${instructions}\n\n${confirm_message}"

    # 打开浏览器
    if [[ "${BROWSER_OPENInBackground}" == "true" ]]; then
        ${BROWSER_OPEN_CMD} -g "${url}" >/dev/null 2>&1 &
    else
        ${BROWSER_OPEN_CMD} "${url}" >/dev/null 2>&1 &
    fi

    local exit_code=$?

    # 等待一下，让浏览器有时间启动
    sleep 2

    if [[ ${exit_code} -ne 0 ]]; then
        show_error_dialog "无法打开浏览器\nURL: ${url}" "打开失败"
        return 1
    fi

    # 显示等待对话框
    show_wait_dialog "${full_message}"

    return $?
}

# 打开 URL 并显示详细指引
# 参数：url, title, instructions_array
# 返回：0（用户确认完成），1（用户取消）
open_browser_with_guide() {
    local url="$1"
    local title="$2"
    shift 2
    local instructions=("$@")

    # 构建指引文本
    local guide_text="请在浏览器中执行以下操作：\n\n"
    local index=1
    for instruction in "${instructions[@]}"; do
        guide_text="${guide_text}${index}. ${instruction}\n"
        ((index++))
    done

    guide_text="${guide_text}\n完成后点击"我已完成"继续。"

    # 打开浏览器并等待
    open_browser_and_wait "${url}" "${guide_text}"

    return $?
}

# 检查浏览器是否已打开指定 URL
# 参数：url
# 返回：0（已打开），1（未打开）
check_browser_open() {
    local url="$1"

    # 尝试使用 pgrep 查找浏览器进程
    if pgrep -f "Safari\|Chrome\|Firefox" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# 获取默认浏览器名称
# 返回：浏览器名称
get_default_browser() {
    # 使用 defaults 命令读取系统默认浏览器设置
    local browser_bundle_id=$(defaults read com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers | grep -A 1 "LSHandlerURLScheme = http" | grep "LSHandlerRoleAll" | head -1 | cut -d'"' -f4)

    case "${browser_bundle_id}" in
        "com.apple.Safari")
            echo "Safari"
            ;;
        "com.google.Chrome")
            echo "Google Chrome"
            ;;
        "org.mozilla.firefox")
            echo "Firefox"
            ;;
        *)
            echo "默认浏览器"
            ;;
    esac
}

# 在浏览器中搜索并打开
# 参数：search_query, search_engine
# 返回：0（成功），1（失败）
search_in_browser() {
    local query="$1"
    local engine="${2:-google}"

    local search_url=""

    case "${engine}" in
        google)
            search_url="https://www.google.com/search?q=${query}"
            ;;
        bing)
            search_url="https://www.bing.com/search?q=${query}"
            ;;
        duckduckgo)
            search_url="https://duckduckgo.com/?q=${query}"
            ;;
        *)
            search_url="https://www.google.com/search?q=${query}"
            ;;
    esac

    open_browser_with_prompt "${search_url}" "正在搜索：${query}"
    return $?
}

# ==============================================================================
# 辅助函数
# ==============================================================================

# URL 编码
# 参数：string
# 返回：编码后的字符串
url_encode() {
    local string="$1"
    local strlen=${#string}
    local encoded=""
    local pos c o

    for ((pos=0; pos<strlen; pos++)); do
        c=${string:$pos:1}
        case "$c" in
            [-_.~a-zA-Z0-9])
                o="${c}"
                ;;
            *)
                printf -v o '%%%02x' "'$c"
                ;;
        esac
        encoded="${encoded}${o}"
    done

    echo "${encoded}"
}

# ==============================================================================
# 导出函数
# ==============================================================================

export -f open_browser_with_prompt
export -f open_browser_and_wait
export -f open_browser_with_guide
export -f check_browser_open
export -f get_default_browser
export -f search_in_browser
export -f url_encode
