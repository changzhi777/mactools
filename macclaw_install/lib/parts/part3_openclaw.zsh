#!/usr/bin/env zsh
# ==============================================================================
# MacClaw Install - 第3部分：OpenClaw 安装
# ==============================================================================
#
# 功能说明：
#   - 使用 npm 安装 OpenClaw CLI
#   - 支持三种验证级别（快速/标准/完整）
#   - 服务状态检测
#   - 完善的错误处理和日志记录
#
# 使用方法：
#   source "${LIB_DIR}/parts/part3_openclaw.zsh"
#   install_part3_openclaw
#
# ==============================================================================

# ==============================================================================
# 加载依赖
# ==============================================================================

# 加载错误处理模块（如果可用）
if [[ -f "${LIB_DIR}/core/error-handler.zsh" ]]; then
    source "${LIB_DIR}/core/error-handler.zsh}"
fi

# ==============================================================================
# 全局变量
# ==============================================================================

typeset -g OPENCLAW_INSTALLED=false
typeset -g OPENCLAW_VERSION=""
typeset -g VERIFICATION_LEVEL="standard"  # quick, standard, full

# ==============================================================================
# OpenClaw 安装
# ==============================================================================

# 安装 OpenClaw CLI
install_openclaw_cli() {
    log_section "安装 OpenClaw CLI"

    # 检查是否已安装
    if command -v openclaw >/dev/null 2>&1; then
        OPENCLAW_VERSION=$(openclaw --version 2>/dev/null | head -1)
        log_success "OpenClaw 已安装: ${OPENCLAW_VERSION}"
        OPENCLAW_INSTALLED=true

        # 询问是否重新安装
        if [[ "${INSTALL_MODE}" != "auto" ]]; then
            if confirm_action "OpenClaw 已安装，是否重新安装？"; then
                log_info "卸载旧版本..."
                npm uninstall -g @iotchange/openclaw 2>&1 | tee -a "${LOG_FILE}"
                OPENCLAW_INSTALLED=false
            else
                return 0
            fi
        else
            return 0
        fi
    fi

    # 开始安装
    log_info "开始安装 OpenClaw CLI..."

    # 使用 npm 淘宝镜像安装
    local npm_registry="${NPM_REGISTRY:-https://registry.npmmirror.com}"
    log_info "使用 npm 镜像: ${npm_registry}"

    if npm install -g @iotchange/openclaw --registry="${npm_registry}" 2>&1 | tee -a "${LOG_FILE}"; then
        log_success "OpenClaw 安装成功"
        OPENCLAW_INSTALLED=true

        # 获取版本
        if command -v openclaw >/dev/null 2>&1; then
            OPENCLAW_VERSION=$(openclaw --version 2>/dev/null | head -1)
            log_success "OpenClaw 版本: ${OPENCLAW_VERSION}"
        fi

        return 0
    else
        local exit_code=$?
        if type throw_error >/dev/null 2>&1; then
            throw_error ${ERR_OPENCLAW_INSTALL} "OpenClaw 安装失败" "退出码: ${exit_code}"
        else
            log_error "OpenClaw 安装失败（退出码: ${exit_code}）"
            increment_error_count
        fi
        return 1
    fi
}

# ==============================================================================
# 服务验证
# ==============================================================================

# 选择验证级别
select_verification_level() {
    if [[ "${INSTALL_MODE}" == "auto" ]]; then
        VERIFICATION_LEVEL="standard"
        return 0
    fi

    log_section "选择验证级别"

    local options=(
        "1" "快速验证（命令可用性）"
        "2" "标准验证（+ Gateway 状态）" ✅ 推荐
        "3" "完整验证（+ 推理测试 + Web UI）"
    )

    print_menu "请选择验证级别" "${options[@]}"
    read -k1 choice
    echo ""

    case "${choice}" in
        1)
            VERIFICATION_LEVEL="quick"
            log_info "选择: 快速验证"
            ;;
        2)
            VERIFICATION_LEVEL="standard"
            log_info "选择: 标准验证"
            ;;
        3)
            VERIFICATION_LEVEL="full"
            log_info "选择: 完整验证"
            ;;
        *)
            log_warning "无效选择，使用标准验证"
            VERIFICATION_LEVEL="standard"
            ;;
    esac
}

# 快速验证
verify_quick() {
    log_info "执行快速验证..."

    local all_ok=true

    # 验证命令可用性
    echo -n "验证 OpenClaw 命令... "
    if command -v openclaw >/dev/null 2>&1; then
        echo -e "${COLOR_GREEN}✓${COLOR_NC}"
        log_list_item "success" "OpenClaw 命令可用"
    else
        echo -e "${COLOR_RED}✗${COLOR_NC}"
        log_list_item "error" "OpenClaw 命令不可用"
        all_ok=false
    fi

    # 验证版本输出
    echo -n "验证版本输出... "
    if openclaw --version >/dev/null 2>&1; then
        echo -e "${COLOR_GREEN}✓${COLOR_NC}"
        local version=$(openclaw --version | head -1)
        log_list_item "success" "版本: ${version}"
    else
        echo -e "${COLOR_RED}✗${COLOR_NC}"
        log_list_item "error" "版本输出失败"
        all_ok=false
    fi

    return ${all_ok}
}

# 标准验证
verify_standard() {
    log_info "执行标准验证..."

    # 先执行快速验证
    if ! verify_quick; then
        return 1
    fi

    echo ""

    # 验证系统信息
    echo -n "验证系统信息... "
    if openclaw system info >/dev/null 2>&1; then
        echo -e "${COLOR_GREEN}✓${COLOR_NC}"
        log_list_item "success" "系统信息正常"
    else
        echo -e "${COLOR_YELLOW}!${COLOR_NC}"
        log_list_item "warning" "系统信息获取失败（可能正常）"
    fi

    # 验证 Gateway 状态
    echo -n "验证 Gateway 状态... "
    if openclaw gateway status >/dev/null 2>&1; then
        echo -e "${COLOR_GREEN}✓${COLOR_NC}"
        log_list_item "success" "Gateway 状态正常"
    else
        echo -e "${COLOR_YELLOW}!${COLOR_NC}"
        log_list_item "warning" "Gateway 未运行（需要手动启动）"
        log_info "启动命令: openclaw gateway start"
    fi

    # 验证 Agent 列表
    echo -n "验证 Agent 功能... "
    if openclaw agents list >/dev/null 2>&1; then
        echo -e "${COLOR_GREEN}✓${COLOR_NC}"
        log_list_item "success" "Agent 功能正常"
    else
        echo -e "${COLOR_YELLOW}!${COLOR_NC}"
        log_list_item "warning" "Agent 功能可能有问题"
    fi

    return 0
}

# 完整验证
verify_full() {
    log_info "执行完整验证..."

    # 先执行标准验证
    verify_standard

    echo ""

    # 推理测试（如果 oMLX 已安装）
    if [[ "${OMLX_INSTALLED}" == true ]]; then
        log_info "执行推理测试..."

        echo -n "测试推理功能... "
        if timeout 30 openclaw infer model run --model omlx/gemma-4-e4b-it-4bit --prompt "Hello" >/dev/null 2>&1; then
            echo -e "${COLOR_GREEN}✓${COLOR_NC}"
            log_list_item "success" "推理测试通过"
        else
            echo -e "${COLOR_YELLOW}!${COLOR_NC}"
            log_list_item "warning" "推理测试超时或失败（模型可能未下载）"
        fi
    else
        log_info "oMLX 未安装，跳过推理测试"
    fi

    # Web UI 可访问性测试
    echo -n "验证 Web UI... "
    if curl -s http://127.0.0.1:18789 >/dev/null 2>&1; then
        echo -e "${COLOR_GREEN}✓${COLOR_NC}"
        log_list_item "success" "Web UI 可访问: http://127.0.0.1:18789"
    else
        echo -e "${COLOR_YELLOW}!${COLOR_NC}"
        log_list_item "info" "Web UI 未启动（需要手动启动 Gateway）"
    fi

    return 0
}

# 执行验证
perform_verification() {
    log_section "OpenClaw 服务验证"

    # 选择验证级别
    select_verification_level

    echo ""

    # 根据级别执行验证
    case "${VERIFICATION_LEVEL}" in
        quick)
            verify_quick
            ;;
        standard)
            verify_standard
            ;;
        full)
            verify_full
            ;;
    esac

    local result=$?

    echo ""

    if [[ ${result} -eq 0 ]]; then
        log_success "✅ 验证通过（级别: ${VERIFICATION_LEVEL}）"
    else
        log_warning "⚠️  验证发现问题，但不影响后续安装"
        # 记录错误但继续
        increment_error_count
    fi

    return 0
}

# ==============================================================================
# 主函数
# ==============================================================================

# 安装第3部分：OpenClaw
install_part3_openclaw() {
    log_title "第3部分：OpenClaw 安装"

    # 安装 OpenClaw CLI
    if ! install_openclaw_cli; then
        log_error "OpenClaw 安装失败"

        # 询问是否继续
        if [[ "${INSTALL_MODE}" != "auto" ]]; then
            if ! confirm_action "OpenClaw 安装失败，是否继续后续步骤？"; then
                log_error "用户取消安装"
                return 1
            fi
        fi
    fi

    # 执行验证
    perform_verification

    log_success "✅ 第3部分完成：OpenClaw 安装"
    return 0
}

# ==============================================================================
# 导出函数
# ==============================================================================

export -f install_openclaw_cli
export -f select_verification_level
export -f verify_quick
export -f verify_standard
export -f verify_full
export -f perform_verification
export -f install_part3_openclaw
