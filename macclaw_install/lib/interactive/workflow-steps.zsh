#!/usr/bin/env zsh
# ==============================================================================
# MacClaw Install - 工作流步骤模块
# ==============================================================================
#
# 作者: 外星动物（常智） / IoTchange / 14455975@qq.com
# 版权: Copyright (C) 2026 IoTchange - All Rights Reserved
#
# 功能说明：
#   定义交互式安装的各个步骤
#   包括：环境确认、omlx 安装、OpenClaw 安装、测试等
#
# 使用方法：
#   source "${LIB_DIR}/interactive/workflow-steps.zsh"
#   step1_confirm_environment
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

# 加载浏览器工具
if [[ -f "${LIB_DIR}/interactive/browser-helper.zsh" ]]; then
    source "${LIB_DIR}/interactive/browser-helper.zsh"
fi

# 加载环境检测
if [[ -f "${LIB_DIR}/core/env-detector-interactive.zsh" ]]; then
    source "${LIB_DIR}/core/env-detector-interactive.zsh"
fi

# ==============================================================================
# 全局变量
# ==============================================================================

# 步骤状态
typeset -g STEP1_COMPLETED=false
typeset -g STEP2_COMPLETED=false
typeset -g STEP3_COMPLETED=false
typeset -g STEP4_COMPLETED=false
typeset -g STEP5_COMPLETED=false
typeset -g STEP6_COMPLETED=false

# 当前步骤
typeset -g CURRENT_STEP=0

# 配置变量
typeset -g OMLX_URL="${OMLX_URL:-https://omlx.ai/}"
typeset -g OPENCLAW_URL="${OPENCLAW_URL:-https://openclaw.ai/}"
typeset -g MODEL_NAME="${MODEL_NAME:-mlx-community/gemma-4-e4b-it-4bit}"

# ==============================================================================
# 步骤 1: 部署环境确认
# ==============================================================================

# 步骤 1: 部署环境确认
step1_confirm_environment() {
    CURRENT_STEP=1
    log_section "步骤 1: 部署环境确认"

    # 检测环境
    detect_all_environments

    # 显示环境报告
    show_environment_report

    # 环境检查
    if ! show_environment_check; then
        # 环境检查失败
        if ! show_confirm_dialog "环境检测发现问题，是否继续安装？" "确认继续"; then
            log_error "用户取消安装"
            return 1
        fi
    fi

    # 确认开始安装
    if ! show_confirm_dialog "环境检测完成，是否开始安装 omlx 和 OpenClaw？" "确认安装"; then
        log_error "用户取消安装"
        return 1
    fi

    STEP1_COMPLETED=true
    log_success "✅ 步骤 1 完成：部署环境确认"
    return 0
}

# ==============================================================================
# 步骤 2: 安装 omlx app
# ==============================================================================

# 步骤 2: 安装 omlx app
step2_install_omlx() {
    CURRENT_STEP=2
    log_section "步骤 2: 安装 omlx app"

    # 检查是否已安装
    detect_omlx
    if ${OMLX_INSTALLED}; then
        if show_confirm_dialog "检测到 omlx 已安装（版本 ${OMLX_VERSION}）\n\n是否跳过此步骤？" "已安装"; then
            STEP2_COMPLETED=true
            log_success "✅ 步骤 2 完成：omlx 已安装"
            return 0
        fi
    fi

    # 显示说明
    local instructions="即将在浏览器中打开 omlx.ai 官网\n\n请按照以下步骤操作：\n"
    instructions="${instructions}1. 下载并安装 omlx 应用\n"
    instructions="${instructions}2. 下载模型：${MODEL_NAME}\n"
    instructions="${instructions}3. 完成安装后返回此处"

    show_info_dialog "${instructions}" "安装 omlx"

    # 打开浏览器并等待
    open_browser_and_wait "${OMLX_URL}" "请确认您已在浏览器中完成 omlx 安装和模型下载后，点击"我已完成"继续。"

    local result=$?

    if [[ ${result} -eq 0 ]]; then
        # 验证安装
        detect_omlx
        if ${OMLX_INSTALLED}; then
            show_info_dialog "✅ omlx 安装成功！\n\n版本：${OMLX_VERSION}" "安装成功"
            STEP2_COMPLETED=true
            log_success "✅ 步骤 2 完成：omlx 安装成功"
            return 0
        else
            # 未检测到安装
            if show_confirm_dialog "未检测到 omlx 安装。\n\n是否继续后续步骤？" "安装确认"; then
                STEP2_COMPLETED=true
                log_warning "⚠️  步骤 2 完成：omlx 未检测到，但用户选择继续"
                return 0
            else
                log_error "用户取消安装"
                return 1
            fi
        fi
    else
        # 用户取消
        log_error "用户取消安装"
        return 1
    fi
}

# ==============================================================================
# 步骤 3: 环境检测（omlx）
# ==============================================================================

# 步骤 3: 环境检测（omlx）
step3_detect_omlx() {
    CURRENT_STEP=3
    log_section "步骤 3: 环境检测（omlx）"

    # 检测 omlx
    detect_omlx

    local detection_result="omlx 安装检测：\n\n"

    if ${OMLX_INSTALLED}; then
        detection_result="${detection_result}✅ omlx 已安装\n"
        detection_result="${detection_result}   版本：${OMLX_VERSION}\n"
        detection_result="${detection_result}   路径：$(pip3 show omlx | grep Location | cut -d' ' -f2)"
    else
        detection_result="${detection_result}❌ 未检测到 omlx 安装\n\n"
        detection_result="${detection_result}请确保：\n"
        detection_result="${detection_result}1. omlx 应用已正确安装\n"
        detection_result="${detection_result}2. 已使用 pip3 安装 omlx 包"
    fi

    show_info_dialog "${detection_result}" "omlx 检测结果"

    if ${OMLX_INSTALLED}; then
        STEP3_COMPLETED=true
        log_success "✅ 步骤 3 完成：omlx 环境检测通过"
        return 0
    else
        if show_confirm_dialog "omlx 未检测到，是否继续？" "检测失败"; then
            STEP3_COMPLETED=true
            log_warning "⚠️  步骤 3 完成：omlx 未检测到，但用户选择继续"
            return 0
        else
            log_error "用户取消安装"
            return 1
        fi
    fi
}

# ==============================================================================
# 步骤 4: 安装 OpenClaw
# ==============================================================================

# 步骤 4: 安装 OpenClaw
step4_install_openclaw() {
    CURRENT_STEP=4
    log_section "步骤 4: 安装 OpenClaw"

    # 检查是否已安装
    detect_openclaw
    if ${OPENCLAW_INSTALLED}; then
        if show_confirm_dialog "检测到 OpenClaw 已安装\n${OPENCLAW_VERSION}\n\n是否跳过此步骤？" "已安装"; then
            STEP4_COMPLETED=true
            log_success "✅ 步骤 4 完成：OpenClaw 已安装"
            return 0
        fi
    fi

    # 显示说明
    local instructions="即将在浏览器中打开 OpenClaw 官网\n\n请按照以下步骤操作：\n"
    instructions="${instructions}1. 查看 OpenClaw 的安装说明\n"
    instructions="${instructions}2. 使用 npm 安装 OpenClaw CLI\n"
    instructions="${instructions}3. 完成安装后返回此处"

    show_info_dialog "${instructions}" "安装 OpenClaw"

    # 打开浏览器并等待
    open_browser_and_wait "${OPENCLAW_URL}" "请确认您已在浏览器中完成 OpenClaw 安装后，点击"我已完成"继续。"

    local result=$?

    if [[ ${result} -eq 0 ]]; then
        # 验证安装
        detect_openclaw
        if ${OPENCLAW_INSTALLED}; then
            show_info_dialog "✅ OpenClaw 安装成功！\n\n${OPENCLAW_VERSION}" "安装成功"
            STEP4_COMPLETED=true
            log_success "✅ 步骤 4 完成：OpenClaw 安装成功"
            return 0
        else
            # 未检测到安装
            if show_confirm_dialog "未检测到 OpenClaw 安装。\n\n是否继续后续步骤？" "安装确认"; then
                STEP4_COMPLETED=true
                log_warning "⚠️  步骤 4 完成：OpenClaw 未检测到，但用户选择继续"
                return 0
            else
                log_error "用户取消安装"
                return 1
            fi
        fi
    else
        # 用户取消
        log_error "用户取消安装"
        return 1
    fi
}

# ==============================================================================
# 步骤 5: 执行算力配置脚本（占位）
# ==============================================================================

# 步骤 5: 执行算力配置脚本
step5_configure_compute_api() {
    CURRENT_STEP=5
    log_section "步骤 5: 配置本地算力 API"

    # 显示占位信息
    local placeholder="本地算力 API 配置脚本\n\n此功能待后续补充。\n\n当前跳过此步骤。"

    show_info_dialog "${placeholder}" "功能开发中"

    # 询问是否继续
    if show_confirm_dialog "算力配置脚本尚未开发。\n\n是否继续后续步骤？" "跳过步骤"; then
        STEP5_COMPLETED=true
        log_warning "⚠️  步骤 5 完成：算力配置脚本待开发"
        return 0
    else
        log_error "用户取消安装"
        return 1
    fi
}

# ==============================================================================
# 步骤 6: 命令行测试
# ==============================================================================

# 步骤 6: 命令行测试
step6_test_openclaw() {
    CURRENT_STEP=6
    log_section "步骤 6: 命令行测试"

    # 加载测试模块
    if [[ -f "${LIB_DIR}/interactive/openclaw-tester.zsh" ]]; then
        source "${LIB_DIR}/interactive/openclaw-tester.zsh"
    else
        log_error "找不到测试模块"
        return 1
    fi

    # 检查 OpenClaw 是否安装
    detect_openclaw
    if ! ${OPENCLAW_INSTALLED}; then
        show_error_dialog "未检测到 OpenClaw 安装。\n\n无法进行测试。" "测试失败"
        log_error "OpenClaw 未安装"
        return 1
    fi

    # 执行完整测试流程
    if full_test_flow; then
        STEP6_COMPLETED=true
        log_success "✅ 步骤 6 完成：OpenClaw 测试成功"
        return 0
    else
        # 测试失败，询问是否继续
        if show_confirm_dialog "OpenClaw 测试失败。\n\n是否继续后续步骤？" "测试失败"; then
            STEP6_COMPLETED=true
            log_warning "⚠️  步骤 6 完成：测试失败，但用户选择继续"
            return 0
        else
            log_error "用户取消安装"
            return 1
        fi
    fi
}

# ==============================================================================
# 步骤 7: 跳转技能安装菜单
# ==============================================================================

# 步骤 7: 跳转技能安装菜单
step7_goto_skills_menu() {
    CURRENT_STEP=7
    log_section "步骤 7: 技能安装菜单"

    # 显示完成信息
    local completion="🎉 交互式安装流程已完成！\n\n"
    completion="${completion}══════════════════════════════════════════════════════════════════════════════\n\n"
    completion="${completion}【已完成步骤】\n"
    completion="${completion}✅ 步骤 1: 部署环境确认\n"
    completion="${completion}✅ 步骤 2: omlx 安装\n"
    completion="${completion}✅ 步骤 3: omlx 环境检测\n"
    completion="${completion}✅ 步骤 4: OpenClaw 安装\n"
    completion="${completion}✅ 步骤 5: 算力 API 配置（待开发）\n"
    completion="${completion}✅ 步骤 6: OpenClaw 测试\n\n"
    completion="${completion}══════════════════════════════════════════════════════════════════════════════\n\n"
    completion="${completion}【下一步】\n\n"
    completion="${completion}是否继续安装技能插件？\n\n"
    completion="${completion}• 技能插件可以扩展 OpenClaw 的功能\n"
    completion="${completion}• 包括开发者工具、编程助手等\n"
    completion="${completion}• 您可以稍后手动安装"

    show_info_dialog "${completion}" "安装完成"

    # 询问是否跳转技能安装
    if show_confirm_dialog "是否现在安装技能插件？" "技能安装"; then
        # 调用技能安装菜单
        local skills_script="${SKILLS_MENU_SCRIPT:-${SCRIPT_DIR}/install.zsh}"

        if [[ -f "${skills_script}" ]]; then
            log_info "跳转到技能安装菜单..."
            source "${skills_script}"

            # 尝试调用主菜单函数
            if type show_main_menu >/dev/null 2>&1; then
                show_main_menu
            else
                log_warning "未找到 show_main_menu 函数"
            fi
        else
            log_error "找不到技能安装脚本: ${skills_script}"
            show_error_dialog "找不到技能安装脚本。\n\n您可以稍后手动运行：\n./install.zsh" "未找到脚本"
        fi
    else
        # 显示结束信息
        local ending="安装流程结束。\n\n"
        ending="${ending}您可以稍后运行以下命令安装技能：\n"
        ending="${ending}./install.zsh\n\n"
        ending="${ending}或查看 OpenClaw 命令：\n"
        ending="${ending}openclaw --help"

        show_info_dialog "${ending}" "安装完成"
    fi

    STEP7_COMPLETED=true
    log_success "✅ 步骤 7 完成：技能安装菜单"
    return 0
}

# ==============================================================================
# 工作流控制函数
# ==============================================================================

# 执行所有步骤
run_all_workflow_steps() {
    log_title "开始交互式安装流程"

    # 步骤 1: 环境确认
    if ! step1_confirm_environment; then
        log_error "步骤 1 失败，安装中止"
        return 1
    fi

    # 步骤 2: omlx 安装
    if ! step2_install_omlx; then
        log_error "步骤 2 失败，安装中止"
        return 1
    fi

    # 步骤 3: omlx 检测
    if ! step3_detect_omlx; then
        log_error "步骤 3 失败，安装中止"
        return 1
    fi

    # 步骤 4: OpenClaw 安装
    if ! step4_install_openclaw; then
        log_error "步骤 4 失败，安装中止"
        return 1
    fi

    # 步骤 5: 算力配置（占位）
    if ! step5_configure_compute_api; then
        log_error "步骤 5 失败，安装中止"
        return 1
    fi

    # 步骤 6: 测试
    if ! step6_test_openclaw; then
        log_error "步骤 6 失败，安装中止"
        return 1
    fi

    # 步骤 7: 技能菜单
    if ! step7_goto_skills_menu; then
        log_error "步骤 7 失败"
        return 1
    fi

    log_success "🎉 所有步骤完成！"
    return 0
}

# 显示工作流状态
show_workflow_status() {
    local status="════════════════════════════════════════════════════════════════════════════════
                        工作流状态
════════════════════════════════════════════════════════════════════════════════

"

    status="${status}步骤 1: 部署环境确认"
    if ${STEP1_COMPLETED}; then
        status="${status} ✅\n"
    else
        status="${status} ⏸️\n"
    fi

    status="${status}步骤 2: omlx 安装"
    if ${STEP2_COMPLETED}; then
        status="${status} ✅\n"
    else
        status="${status} ⏸️\n"
    fi

    status="${status}步骤 3: omlx 环境检测"
    if ${STEP3_COMPLETED}; then
        status="${status} ✅\n"
    else
        status="${status} ⏸️\n"
    fi

    status="${status}步骤 4: OpenClaw 安装"
    if ${STEP4_COMPLETED}; then
        status="${status} ✅\n"
    else
        status="${status} ⏸️\n"
    fi

    status="${status}步骤 5: 算力 API 配置"
    if ${STEP5_COMPLETED}; then
        status="${status} ✅\n"
    else
        status="${status} ⏸️\n"
    fi

    status="${status}步骤 6: OpenClaw 测试"
    if ${STEP6_COMPLETED}; then
        status="${status} ✅\n"
    else
        status="${status} ⏸️\n"
    fi

    status="${status}步骤 7: 技能安装菜单"
    if ${STEP7_COMPLETED}; then
        status="${status} ✅\n"
    else
        status="${status} ⏸️\n"
    fi

    status="${status}════════════════════════════════════════════════════════════════════════════════"

    echo "${status}"
    show_info_dialog "${status}" "工作流状态"
}

# ==============================================================================
# 导出函数（完整版）
# ==============================================================================

export -f step1_confirm_environment
export -f step2_install_omlx
export -f step3_detect_omlx
export -f step4_install_openclaw
export -f step5_configure_compute_api
export -f step6_test_openclaw
export -f step7_goto_skills_menu
export -f run_all_workflow_steps
export -f show_workflow_status
