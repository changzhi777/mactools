#!/usr/bin/env zsh
# ==============================================================================
# MacClaw Install - OpenClaw 测试模块
# ==============================================================================
#
# 作者: 外星动物（常智） / IoTchange / 14455975@qq.com
# 版权: Copyright (C) 2026 IoTchange - All Rights Reserved
#
# 功能说明：
#   测试 OpenClaw 提示词生成功能
#   验证安装是否成功
#
# 使用方法：
#   source "${LIB_DIR}/interactive/openclaw-tester.zsh"
#   test_prompt_generation
#
# ==============================================================================

# ==============================================================================
# 加载依赖模块
# ==============================================================================

# 加载配置
if [[ -f "${SCRIPT_DIR}/config/interactive.conf" ]]; then
    source "${SCRIPT_DIR}/config/interactive.conf"
fi

# 加载对话框工具
if [[ -f "${LIB_DIR}/interactive/dialog-helper.zsh" ]]; then
    source "${LIB_DIR}/interactive/dialog-helper.zsh"
fi

# 加载环境检测
if [[ -f "${LIB_DIR}/core/env-detector-interactive.zsh" ]]; then
    source "${LIB_DIR}/core/env-detector-interactive.zsh"
fi

# ==============================================================================
# 全局变量
# ==============================================================================

# 测试配置
typeset -g OPENCLAW_TEST_PROMPT="${OPENCLAW_TEST_PROMPT:-你好，请做一个自我介绍。}"
typeset -g OPENCLAW_TEST_TIMEOUT="${OPENCLAW_TEST_TIMEOUT:-30}"

# 测试结果
typeset -g TEST_RESULT=""
typeset -g TEST_SUCCESS=false
typeset -g TEST_OUTPUT=""
typeset -g TEST_ERROR=""

# ==============================================================================
# 测试函数
# ==============================================================================

# 生成测试提示词
generate_test_prompt() {
    echo "${OPENCLAW_TEST_PROMPT}"
}

# 执行测试命令
execute_test_command() {
    local prompt="$1"
    local timeout="${2:-${OPENCLAW_TEST_TIMEOUT}}"

    # 检查 OpenClaw 是否可用
    if ! command -v openclaw >/dev/null 2>&1; then
        TEST_ERROR="OpenClaw 命令不可用"
        TEST_SUCCESS=false
        return 1
    fi

    # 执行测试命令
    log_info "执行 OpenClaw 测试..."
    log_info "提示词: ${prompt}"

    # 使用 timeout 命令防止卡死
    local output=$(timeout ${timeout} openclaw infer model run --model omlx/gemma-4-e4b-it-4bit --prompt "${prompt}" 2>&1)
    local exit_code=$?

    if [[ ${exit_code} -eq 0 ]]; then
        TEST_OUTPUT="${output}"
        TEST_SUCCESS=true
        TEST_ERROR=""
        return 0
    elif [[ ${exit_code} -eq 124 ]]; then
        TEST_ERROR="测试超时（${timeout}秒）"
        TEST_SUCCESS=false
        return 1
    else
        TEST_ERROR="命令执行失败（退出码: ${exit_code}）"
        TEST_OUTPUT="${output}"
        TEST_SUCCESS=false
        return 1
    fi
}

# 分析测试结果
analyze_test_result() {
    local output="$1"

    # 检查输出是否为空
    if [[ -z "${output}" ]]; then
        TEST_RESULT="❌ 测试失败：无输出"
        return 1
    fi

    # 检查是否包含错误信息
    if [[ "${output}" == *"error"* ]] || [[ "${output}" == *"Error"* ]] || [[ "${output}" == *"ERROR"* ]]; then
        TEST_RESULT="❌ 测试失败：检测到错误信息"
        return 1
    fi

    # 检查输出长度
    local output_length=${#output}
    if [[ ${output_length} -lt 10 ]]; then
        TEST_RESULT="❌ 测试失败：输出过短（${output_length} 字符）"
        return 1
    fi

    # 测试成功
    TEST_RESULT="✅ 测试成功：生成 ${output_length} 字符"
    return 0
}

# 显示测试结果
show_test_result() {
    local result_message="OpenClaw 提示词生成测试结果：\n\n"

    if ${TEST_SUCCESS}; then
        result_message="${result_message}状态：✅ 成功\n\n"
        result_message="${result_message}输出预览（前 200 字符）：\n"
        result_message="${result_message}└─ ${TEST_OUTPUT:0:200}\n"
        if [[ ${#TEST_OUTPUT} -gt 200 ]]; then
            result_message="${result_message}...（共 ${#TEST_OUTPUT} 字符）\n"
        fi
    else
        result_message="${result_message}状态：❌ 失败\n\n"
        result_message="${result_message}错误信息：\n"
        result_message="${result_message}└─ ${TEST_ERROR}\n"
        if [[ -n "${TEST_OUTPUT}" ]]; then
            result_message="${result_message}\n输出内容：\n"
            result_message="${result_message}└─ ${TEST_OUTPUT}\n"
        fi
    fi

    result_message="${result_message}\n══════════════════════════════════════"

    # 显示结果
    echo "${result_message}"

    # 在对话框中显示
    if ${TEST_SUCCESS}; then
        show_info_dialog "${result_message}" "测试成功"
    else
        show_error_dialog "${result_message}" "测试失败"
    fi
}

# 交互式测试
interactive_test() {
    # 显示测试说明
    local test_info="即将测试 OpenClaw 提示词生成功能\n\n"
    test_info="${test_info}测试提示词：\n"
    test_info="${test_info}「${OPENCLAW_TEST_PROMPT}」\n\n"
    test_info="${test_info}超时时间：${OPENCLAW_TEST_TIMEOUT} 秒\n\n"
    test_info="${test_info}是否开始测试？"

    if ! show_confirm_dialog "${test_info}" "开始测试"; then
        log_info "用户取消测试"
        return 1
    fi

    # 生成测试提示词
    local prompt=$(generate_test_prompt)

    # 显示进度
    show_progress_dialog "正在测试 OpenClaw..." 3

    # 执行测试
    execute_test_command "${prompt}"

    # 分析结果
    if ${TEST_SUCCESS}; then
        analyze_test_result "${TEST_OUTPUT}"
    else
        TEST_RESULT="❌ 测试失败：${TEST_ERROR}"
    fi

    # 显示结果
    show_test_result

    # 返回测试是否成功
    if ${TEST_SUCCESS}; then
        return 0
    else
        # 询问是否重试
        if show_confirm_dialog "测试失败，是否重试？" "重试测试"; then
            interactive_test
            return $?
        else
            return 1
        fi
    fi
}

# 自定义提示词测试
custom_prompt_test() {
    # 获取自定义提示词
    show_input_dialog "请输入您想要测试的提示词：" "自定义测试" "${OPENCLAW_TEST_PROMPT}"

    local exit_code=$?
    if [[ ${exit_code} -ne 0 ]]; then
        log_info "用户取消自定义测试"
        return 1
    fi

    local custom_prompt="${DIALOG_INPUT_RESULT}"

    # 确认测试
    if ! show_confirm_dialog "即将使用以下提示词测试：\n\n「${custom_prompt}」\n\n是否开始？" "确认测试"; then
        log_info "用户取消测试"
        return 1
    fi

    # 显示进度
    show_progress_dialog "正在测试 OpenClaw..." 3

    # 执行测试
    execute_test_command "${custom_prompt}"

    # 分析结果
    if ${TEST_SUCCESS}; then
        analyze_test_result "${TEST_OUTPUT}"
    else
        TEST_RESULT="❌ 测试失败：${TEST_ERROR}"
    fi

    # 显示结果
    show_test_result

    return ${TEST_SUCCESS}
}

# 完整测试流程（包括标准测试和自定义测试）
full_test_flow() {
    log_section "OpenClaw 提示词生成测试"

    # 标准测试
    if ! interactive_test; then
        log_error "标准测试失败"
        return 1
    fi

    # 询问是否进行自定义测试
    if show_confirm_dialog "标准测试成功！\n\n是否进行自定义提示词测试？" "自定义测试"; then
        custom_prompt_test
    fi

    return 0
}

# 快速测试（无交互，仅返回结果）
quick_test() {
    # 生成测试提示词
    local prompt=$(generate_test_prompt)

    # 执行测试
    execute_test_command "${prompt}"

    # 返回结果
    if ${TEST_SUCCESS}; then
        analyze_test_result "${TEST_OUTPUT}"
        return 0
    else
        return 1
    fi
}

# ==============================================================================
# 导出函数
# ==============================================================================

export -f generate_test_prompt
export -f execute_test_command
export -f analyze_test_result
export -f show_test_result
export -f interactive_test
export -f custom_prompt_test
export -f full_test_flow
export -f quick_test
