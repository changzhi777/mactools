#!/usr/bin/env zsh
# ==============================================================================
# MacClaw Install - 第4部分：测试和插件
# ==============================================================================
#
# 功能说明：
#   - 基础安装验证（版本 + 插件列表）
#   - 安装默认插件（developer + coder）
#   - 智能插件安装错误处理
#   - 详细的安装完成报告
#   - 可选的配置向导
#
# 使用方法：
#   source "${LIB_DIR}/parts/part4_test_plugins.zsh"
#   install_part4_test_plugins
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

typeset -ga PLUGINS_TO_INSTALL=()
typeset -ga PLUGINS_INSTALLED=()
typeset -ga PLUGINS_FAILED=()

# ==============================================================================
# 基础测试
# ==============================================================================

# 执行基础测试
run_basic_tests() {
    log_section "基础安装验证"

    local all_ok=true

    # 测试 1: OpenClaw 版本
    echo "测试 1: OpenClaw 版本检查"
    if command -v openclaw >/dev/null 2>&1; then
        local version=$(openclaw --version 2>/dev/null | head -1)
        log_list_item "success" "OpenClaw 版本: ${version}"
    else
        log_list_item "error" "OpenClaw 未安装"
        all_ok=false
        increment_error_count
    fi

    echo ""

    # 测试 2: 插件列表
    echo "测试 2: 插件列表检查"
    if openclaw skills list >/dev/null 2>&1; then
        local skill_count=$(openclaw skills list 2>/dev/null | wc -l)
        log_list_item "success" "插件列表正常（已安装 ${skill_count} 个插件）"
    else
        log_list_item "warning" "插件列表为空或命令不可用"
        increment_warning_count
    fi

    echo ""

    # 测试 3: 配置文件
    echo "测试 3: 配置文件检查"
    local config_dir="${HOME}/.openclaw"
    if [[ -d "${config_dir}" ]]; then
        log_list_item "success" "配置目录存在: ${config_dir}"
    else
        log_list_item "warning" "配置目录不存在"
        increment_warning_count
    fi

    echo ""

    if ${all_ok}; then
        log_success "✅ 基础测试通过"
    else
        log_warning "⚠️  部分测试失败"
    fi

    return 0
}

# ==============================================================================
# 插件安装
# ==============================================================================

# 加载插件列表
load_plugin_list() {
    local config_file="${SCRIPT_DIR}/config/plugins.conf"

    if [[ ! -f "${config_file}" ]]; then
        log_warning "插件配置文件不存在: ${config_file}"
        # 使用默认插件
        PLUGINS_TO_INSTALL=(
            "@iotchange/skill-developer"
            "@iotchange/skill-coder"
        )
        return 0
    fi

    # 读取插件列表
    PLUGINS_TO_INSTALL=()
    while IFS= read -r line; do
        # 跳过注释和空行
        [[ "${line}" =~ "^#" ]] && continue
        [[ "${line}" =~ "^\s*$" ]] && continue

        # 添加插件
        PLUGINS_TO_INSTALL+=("${line}")
    done < "${config_file}"

    log_info "已加载 ${#PLUGINS_TO_INSTALL[@]} 个插件"

    return 0
}

# 安装单个插件
install_single_plugin() {
    local plugin="$1"

    log_info "安装插件: ${plugin}"

    # 使用 npm 淘宝镜像安装
    local npm_registry="${NPM_REGISTRY:-https://registry.npmmirror.com}"

    if npm install -g "${plugin}" --registry="${npm_registry}" 2>&1 | tee -a "${LOG_FILE}"; then
        log_success "✅ ${plugin} 安装成功"
        PLUGINS_INSTALLED+=("${plugin}")
        return 0
    else
        local exit_code=$?
        log_error "❌ ${plugin} 安装失败（退出码: ${exit_code}）"

        # 智能错误处理
        local error_type=$(analyze_plugin_error "${exit_code}" "${plugin}")

        case "${error_type}" in
            network)
                log_warning "网络问题，尝试重试..."
                if retry_command 3 "npm install -g ${plugin} --registry=${npm_registry}" "插件重试安装失败"; then
                    PLUGINS_INSTALLED+=("${plugin}")
                    return 0
                else
                    PLUGINS_FAILED+=("${plugin}")
                    return 1
                fi
                ;;
            permission)
                log_error "权限不足，尝试使用 sudo..."
                if sudo npm install -g "${plugin}" --registry="${npm_registry}" 2>&1 | tee -a "${LOG_FILE}"; then
                    PLUGINS_INSTALLED+=("${plugin}")
                    return 0
                else
                    PLUGINS_FAILED+=("${plugin}")
                    return 1
                fi
                ;;
            dependency)
                log_warning "依赖问题，跳过此插件"
                PLUGINS_FAILED+=("${plugin}")
                return 1
                ;;
            *)
                PLUGINS_FAILED+=("${plugin}")
                return 1
                ;;
        esac
    fi
}

# 分析插件安装错误
analyze_plugin_error() {
    local exit_code="$1"
    local plugin="$2"

    # 检查日志中的错误信息
    if grep -q "ECONNREFUSED" "${LOG_FILE}" 2>/dev/null; then
        echo "network"
    elif grep -q "EACCES" "${LOG_FILE}" 2>/dev/null; then
        echo "permission"
    elif grep -q "ENOENT" "${LOG_FILE}" 2>/dev/null; then
        echo "not_found"
    elif grep -q "dependency" "${LOG_FILE}" 2>/dev/null; then
        echo "dependency"
    else
        echo "unknown"
    fi
}

# 安装所有插件
install_all_plugins() {
    log_section "安装默认插件"

    # 加载插件列表
    load_plugin_list

    if [[ ${#PLUGINS_TO_INSTALL[@]} -eq 0 ]]; then
        log_warning "没有需要安装的插件"
        return 0
    fi

    # 显示待安装插件
    echo ""
    echo "将安装以下插件："
    for plugin in "${PLUGINS_TO_INSTALL[@]}"; do
        echo "  • ${plugin}"
    done
    echo ""

    # 询问确认（非自动模式）
    if [[ "${INSTALL_MODE}" != "auto" ]]; then
        if ! confirm_action "确认安装这些插件？"; then
            log_info "跳过插件安装"
            return 0
        fi
    fi

    # 安装每个插件
    local total=${#PLUGINS_TO_INSTALL[@]}
    local current=0

    for plugin in "${PLUGINS_TO_INSTALL[@]}"; do
        ((current++))
        print_step ${current} ${total} "安装 ${plugin}" running

        if install_single_plugin "${plugin}"; then
            print_step ${current} ${total} "安装 ${plugin}" success
        else
            print_step ${current} ${total} "安装 ${plugin}" error
            increment_error_count
        fi
    done

    echo ""

    # 显示安装结果
    show_plugin_installation_results
}

# 显示插件安装结果
show_plugin_installation_results() {
    echo ""
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_NC}"
    echo -e "${COLOR_CYAN}  插件安装结果${COLOR_NC}"
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_NC}"
    echo ""

    if [[ ${#PLUGINS_INSTALLED[@]} -gt 0 ]]; then
        echo -e "${COLOR_GREEN}✅ 成功安装 (${#PLUGINS_INSTALLED[@]}):${COLOR_NC}"
        for plugin in "${PLUGINS_INSTALLED[@]}"; do
            echo "  • ${plugin}"
        done
        echo ""
    fi

    if [[ ${#PLUGINS_FAILED[@]} -gt 0 ]]; then
        echo -e "${COLOR_RED}❌ 安装失败 (${#PLUGINS_FAILED[@]}):${COLOR_NC}"
        for plugin in "${PLUGINS_FAILED[@]}"; do
            echo "  • ${plugin}"
        done
        echo ""
        log_info "您可以稍后手动安装失败的插件："
        echo "  npm install -g <plugin-name> --registry=https://registry.npmmirror.com"
        echo ""
    fi
}

# ==============================================================================
# 配置向导
# ==============================================================================

# 运行配置向导
run_config_wizard() {
    if [[ "${INSTALL_MODE}" == "auto" ]]; then
        log_info "自动模式，跳过配置向导"
        return 0
    fi

    log_section "配置向导"

    if ! confirm_action "是否运行配置向导？"; then
        log_info "跳过配置向导"
        return 0
    fi

    # 检查配置向导脚本
    local wizard_script="${SCRIPT_DIR}/scripts/setup-config-wizard.zsh"
    if [[ -f "${wizard_script}" ]]; then
        source "${wizard_script}"
        if type run_wizard >/dev/null 2>&1; then
            run_wizard
        else
            log_warning "配置向导功能开发中"
        fi
    else
        log_info "配置向导脚本不存在，跳过"
    fi

    return 0
}

# ==============================================================================
# 完成报告
# ==============================================================================

# 显示完成报告
show_completion_report() {
    clear
    print_banner
    echo ""
    echo -e "${COLOR_GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_NC}"
    echo -e "${COLOR_GREEN}  🎉 安装完成！${COLOR_NC}"
    echo -e "${COLOR_GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_NC}"
    echo ""

    echo -e "${COLOR_WHITE}=== 环境信息 ===${COLOR_NC}"
    echo "  • macOS: ${MACOS_VERSION} ${CPU_ARCHITECTURE}"
    echo "  • CPU: ${CPU_MODEL}"
    echo "  • 内存: $(format_bytes ${MEMORY_SIZE})"
    echo "  • 磁盘可用: $(get_disk_space)"
    echo ""

    echo -e "${COLOR_WHITE}=== 已安装组件 ===${COLOR_NC}"

    # Homebrew
    if command -v brew >/dev/null 2>&1; then
        echo "  ${COLOR_GREEN}✅${COLOR_NC} Homebrew $(brew --version | head -1)"
    else
        echo "  ${COLOR_GRAY}⏸️${COLOR_NC} Homebrew (未安装)"
    fi

    # Node.js
    if command -v node >/dev/null 2>&1; then
        echo "  ${COLOR_GREEN}✅${COLOR_NC} Node.js $(node --version)"
    else
        echo "  ${COLOR_GRAY}⏸️${COLOR_NC} Node.js (未安装)"
    fi

    # OpenClaw
    if command -v openclaw >/dev/null 2>&1; then
        echo "  ${COLOR_GREEN}✅${COLOR_NC} OpenClaw CLI"
    else
        echo "  ${COLOR_GRAY}⏸️${COLOR_NC} OpenClaw CLI (未安装)"
    fi

    # oMLX
    if ${OMLX_INSTALLED}; then
        echo "  ${COLOR_GREEN}✅${COLOR_NC} oMLX 推理引擎"
    else
        echo "  ${COLOR_GRAY}⏸️${COLOR_NC} oMLX (未安装)"
    fi

    # AI 模型
    if [[ -n "${RECOMMENDED_MODEL}" ]]; then
        if ${MODEL_DOWNLOADED}; then
            echo "  ${COLOR_GREEN}✅${COLOR_NC} AI 模型: ${RECOMMENDED_MODEL}"
        else
            echo "  ${COLOR_YELLOW}⚠️${COLOR_NC} AI 模型: ${RECOMMENDED_MODEL} (未下载)"
        fi
    fi

    # 插件
    if [[ ${#PLUGINS_INSTALLED[@]} -gt 0 ]]; then
        echo "  ${COLOR_GREEN}✅${COLOR_NC} 插件: ${#PLUGINS_INSTALLED[@]} 个"
        for plugin in "${PLUGINS_INSTALLED[@]}"; do
            echo "      • ${plugin}"
        done
    fi

    echo ""

    echo -e "${COLOR_WHITE}=== 快速开始 ===${COLOR_NC}"
    echo ""
    echo "  # 1. 查看 OpenClaw 版本"
    echo "  openclaw --version"
    echo ""
    echo "  # 2. 查看系统信息"
    echo "  openclaw system info"
    echo ""
    echo "  # 3. 测试推理（如果已下载模型）"
    echo "  openclaw infer model run --model omlx/${RECOMMENDED_MODEL} --prompt '你好'"
    echo ""
    echo "  # 4. 查看所有命令"
    echo "  openclaw --help"
    echo ""

    echo -e "${COLOR_WHITE}=== 常用命令 ===${COLOR_NC}"
    echo ""
    echo "  # Gateway 管理"
    echo "  openclaw gateway status"
    echo "  openclaw gateway start"
    echo "  openclaw gateway restart"
    echo ""
    echo "  # Agent 管理"
    echo "  openclaw agents list"
    echo "  openclaw agents add <name>"
    echo ""
    echo "  # Skills 管理"
    echo "  openclaw skills list"
    echo "  openclaw skills install <skill-name>"
    echo ""

    echo -e "${COLOR_WHITE}=== 获取帮助 ===${COLOR_NC}"
    echo ""
    echo "  • 项目主页: https://github.com/changzhi777/mactools"
    echo "  • 问题反馈: https://github.com/changzhi777/mactools/issues"
    echo "  • 文档中心: https://github.com/changzhi777/mactools/blob/main/macclaw_install/README.md"
    echo ""

    echo -e "${COLOR_WHITE}=== 下一步 ===${COLOR_NC}"
    echo ""
    echo "  1. 查看 README.md 了解更多功能"
    echo "  2. 运行配置向导创建第一个 Agent"
    echo "  3. 开始使用 OpenClaw 构建你的 AI 应用！"
    echo ""

    # 显示错误统计
    show_error_statistics

    # 日志位置
    echo -e "${COLOR_WHITE}=== 日志文件 ===${COLOR_NC}"
    echo "  详细日志: ${LOG_FILE}"
    echo ""

    # 尝试打开项目页面
    if command -v open >/dev/null 2>&1; then
        sleep 2
        open https://github.com/changzhi777/mactools
    fi
}

# ==============================================================================
# 主函数
# ==============================================================================

# 安装第4部分：测试和插件
install_part4_test_plugins() {
    log_title "第4部分：测试和插件"

    # 执行基础测试
    run_basic_tests

    # 安装插件
    install_all_plugins

    # 运行配置向导
    run_config_wizard

    # 显示完成报告
    show_completion_report

    log_success "✅ 第4部分完成：测试和插件安装"
    return 0
}

# ==============================================================================
# 导出函数
# ==============================================================================

export -f run_basic_tests
export -f load_plugin_list
export -f install_single_plugin
export -f analyze_plugin_error
export -f install_all_plugins
export -f show_plugin_installation_results
export -f run_config_wizard
export -f show_completion_report
export -f install_part4_test_plugins
