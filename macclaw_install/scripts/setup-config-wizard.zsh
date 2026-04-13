#!/usr/bin/env zsh
# ==============================================================================
# MacClaw Install - 配置向导脚本
# ==============================================================================
#
# 功能说明：
#   - 引导用户创建第一个 Agent
#   - 配置推理参数
#   - 配置插件
#   - 测试 AI 功能
#
# 使用方法：
#   source "${SCRIPT_DIR}/scripts/setup-config-wizard.zsh"
#   run_wizard
#
# ==============================================================================

# ==============================================================================
# 全局变量
# ==============================================================================

typeset -g WIZARD_AGENT_NAME=""
typeset -g WIZARD_AGENT_WORKSPACE=""
typeset -g WIZARD_AGENT_MODEL=""
typeset -g WIZARD_SELECTED_SKILLS=()

# ==============================================================================
# 向导步骤
# ==============================================================================

# 欢迎页面
wizard_welcome() {
    clear
    cat << EOF
${COLOR_CYAN}╔════════════════════════════════════════════════════════════╗
║                                                              ║
║       🧙 MacClaw 配置向导                                    ║
║                                                              ║
║       欢迎使用 OpenClaw！让我们开始配置你的第一个 AI Agent。     ║
║                                                              ║
╚════════════════════════════════════════════════════════════╝
${COLOR_NC}
EOF

    echo ""
    echo "此向导将帮助你："
    echo "  1. 创建你的第一个 AI Agent"
    echo "  2. 配置推理参数"
    echo "  3. 选择并安装插件"
    echo "  4. 测试 AI 功能"
    echo ""
    echo "预计用时：3-5 分钟"
    echo ""

    if ! confirm_action "是否开始配置？"; then
        return 1
    fi

    return 0
}

# 步骤 1：创建 Agent
wizard_create_agent() {
    clear
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_NC}"
    echo -e "${COLOR_CYAN}  步骤 1/4：创建 AI Agent${COLOR_NC}"
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_NC}"
    echo ""

    echo "Agent 是你与 AI 交互的助手。"
    echo "每个 Agent 都有自己的配置和工作空间。"
    echo ""

    # 输入 Agent 名称
    while true; do
        read_input "请输入 Agent 名称" WIZARD_AGENT_NAME "myagent"

        if [[ -z "${WIZARD_AGENT_NAME}" ]]; then
            log_error "Agent 名称不能为空"
            continue
        fi

        # 检查名称格式
        if [[ ! "${WIZARD_AGENT_NAME}" =~ ^[a-zA-Z0-9_-]+$ ]]; then
            log_error "Agent 名称只能包含字母、数字、下划线和连字符"
            continue
        fi

        break
    done

    # 输入工作空间路径
    local default_workspace="${HOME}/.openclaw/workspace-${WIZARD_AGENT_NAME}"
    read_input "工作空间路径" WIZARD_AGENT_WORKSPACE "${default_workspace}"

    echo ""
    log_info "将创建 Agent: ${WIZARD_AGENT_NAME}"
    log_info "工作空间: ${WIZARD_AGENT_WORKSPACE}"
    echo ""

    if confirm_action "确认创建？"; then
        # 创建 Agent
        if openclaw agents add "${WIZARD_AGENT_NAME}" --workspace "${WIZARD_AGENT_WORKSPACE}" 2>&1 | tee -a "${LOG_FILE}"; then
            log_success "✅ Agent 创建成功"
        else
            log_error "❌ Agent 创建失败"
            return 1
        fi
    else
        log_info "已取消创建"
        return 1
    fi

    press_enter_continue
    return 0
}

# 步骤 2：配置模型
wizard_configure_model() {
    clear
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_NC}"
    echo -e "${COLOR_CYAN}  步骤 2/4：配置推理模型${COLOR_NC}"
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_NC}"
    echo ""

    echo "你的 Agent 需要一个 AI 模型来进行推理。"
    echo ""

    # 显示可用模型
    echo "可用模型："
    echo "  1. omlx/gemma-4-e4b-it-4bit (推荐，轻量级)"
    echo "  2. omlx/gemma-4-9b-it-4bit (平衡)"
    echo "  3. omlx/gemma-4-e4b-it-8bit (高质量)"
    echo ""

    # 选择模型
    local model_choice=""
    echo -n "请选择模型 [1-3]: "
    read -k1 choice
    echo ""

    case "${choice}" in
        1)
            WIZARD_AGENT_MODEL="omlx/gemma-4-e4b-it-4bit"
            ;;
        2)
            WIZARD_AGENT_MODEL="omlx/gemma-4-9b-it-4bit"
            ;;
        3)
            WIZARD_AGENT_MODEL="omlx/gemma-4-e4b-it-8bit"
            ;;
        *)
            log_warning "无效选择，使用默认模型"
            WIZARD_AGENT_MODEL="omlx/gemma-4-e4b-it-4bit"
            ;;
    esac

    echo ""
    log_info "已选择模型: ${WIZARD_AGENT_MODEL}"
    echo ""

    # 配置 Agent
    if confirm_action "确认配置模型？"; then
        if openclaw agents config "${WIZARD_AGENT_NAME}" --model "${WIZARD_AGENT_MODEL}" 2>&1 | tee -a "${LOG_FILE}"; then
            log_success "✅ 模型配置成功"
        else
            log_warning "⚠️  模型配置失败，可以稍后手动配置"
        fi
    fi

    press_enter_continue
    return 0
}

# 步骤 3：选择插件
wizard_select_skills() {
    clear
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_NC}"
    echo -e "${COLOR_CYAN}  步骤 3/4：选择插件${COLOR_NC}"
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_NC}"
    echo ""

    echo "插件可以为你的 Agent 添加特殊功能。"
    echo ""

    # 显示可用插件
    echo "已安装的插件："
    if openclaw skills list 2>/dev/null | grep -q "developer"; then
        echo "  ${COLOR_GREEN}✅${COLOR_NC} developer - 开发者工具"
        WIZARD_SELECTED_SKILLS+=("developer")
    fi

    if openclaw skills list 2>/dev/null | grep -q "coder"; then
        echo "  ${COLOR_GREEN}✅${COLOR_NC} coder - 编程助手"
        WIZARD_SELECTED_SKILLS+=("coder")
    fi

    echo ""
    echo "是否为 Agent 安装这些插件？"

    if confirm_action "确认安装插件？"; then
        for skill in "${WIZARD_SELECTED_SKILLS[@]}"; do
            log_info "安装插件: ${skill}"
            if openclaw agents skills attach "${WIZARD_AGENT_NAME}" "${skill}" 2>&1 | tee -a "${LOG_FILE}"; then
                log_success "✅ ${skill} 已安装"
            else
                log_warning "⚠️  ${skill} 安装失败"
            fi
        done
    fi

    press_enter_continue
    return 0
}

# 步骤 4：测试功能
wizard_test_functionality() {
    clear
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_NC}"
    echo -e "${COLOR_CYAN}  步骤 4/4：测试 AI 功能${COLOR_NC}"
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_NC}"
    echo ""

    echo "让我们测试一下你的 Agent！"
    echo ""

    if confirm_action "是否运行测试推理？"; then
        echo ""
        echo "正在测试推理功能..."
        echo "提示：这可能需要几秒钟..."
        echo ""

        if timeout 30 openclaw agents run "${WIZARD_AGENT_NAME}" --prompt "Hello, please introduce yourself" 2>&1 | tee -a "${LOG_FILE}"; then
            echo ""
            log_success "✅ 测试成功！"
        else
            echo ""
            log_warning "⚠️  测试超时或失败"
            log_info "这可能是因为："
            echo "  1. AI 模型未完全下载"
            echo "  2. oMLX 服务未启动"
            echo "  3. 推理引擎配置问题"
            echo ""
            log_info "你可以稍后手动测试："
            echo "  openclaw agents run ${WIZARD_AGENT_NAME} --prompt '你好'"
        fi
    fi

    press_enter_continue
    return 0
}

# 完成页面
wizard_complete() {
    clear
    cat << EOF
${COLOR_GREEN}╔════════════════════════════════════════════════════════════╗
║                                                              ║
║       🎉 配置完成！${COLOR_NC}
║                                                              ║
║       你的 AI Agent 已准备就绪！                                ║
║                                                              ║
╚════════════════════════════════════════════════════════════╝
${COLOR_NC}
EOF

    echo ""
    echo -e "${COLOR_WHITE}=== Agent 信息 ===${COLOR_NC}"
    echo "  名称: ${WIZARD_AGENT_NAME}"
    echo "  工作空间: ${WIZARD_AGENT_WORKSPACE}"
    echo "  模型: ${WIZARD_AGENT_MODEL}"
    echo "  插件: ${WIZARD_SELECTED_SKILLS[@]}"
    echo ""

    echo -e "${COLOR_WHITE}=== 快速开始 ===${COLOR_NC}"
    echo ""
    echo "  # 使用 Agent"
    echo "  openclaw agents use ${WIZARD_AGENT_NAME}"
    echo ""
    echo "  # 运行推理"
    echo "  openclaw agents run ${WIZARD_AGENT_NAME} --prompt '你的问题'"
    echo ""
    echo "  # 查看 Agent 配置"
    echo "  openclaw agents config ${WIZARD_AGENT_NAME}"
    echo ""

    echo -e "${COLOR_WHITE}=== 下一步 ===${COLOR_NC}"
    echo ""
    echo "  1. 阅读 OpenClaw 文档"
    echo "  2. 创建更多 Agents"
    echo "  3. 安装更多插件"
    echo "  4. 开始构建你的 AI 应用！"
    echo ""

    press_enter_continue
}

# ==============================================================================
# 主向导函数
# ==============================================================================

# 运行向导
run_wizard() {
    # 欢迎页面
    if ! wizard_welcome; then
        return 1
    fi

    # 步骤 1：创建 Agent
    if ! wizard_create_agent; then
        log_warning "Agent 创建失败，但向导将继续"
    fi

    # 步骤 2：配置模型
    if ! wizard_configure_model; then
        log_warning "模型配置失败，但向导将继续"
    fi

    # 步骤 3：选择插件
    if ! wizard_select_skills; then
        log_warning "插件选择失败，但向导将继续"
    fi

    # 步骤 4：测试功能
    if ! wizard_test_functionality; then
        log_warning "功能测试失败，但向导将继续"
    fi

    # 完成页面
    wizard_complete

    return 0
}

# ==============================================================================
# 导出函数
# ==============================================================================

export -f wizard_welcome
export -f wizard_create_agent
export -f wizard_configure_model
export -f wizard_select_skills
export -f wizard_test_functionality
export -f wizard_complete
export -f run_wizard
