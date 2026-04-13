#!/usr/bin/env zsh
# ==============================================================================
# MacClaw Install - 第2部分：算力配置
# ==============================================================================
#
# 功能说明：
#   - 检测 Apple Silicon 芯片类型（M1-M5）
#   - 检测内存大小
#   - 智能推荐 AI 模型
#   - 安装 oMLX 推理引擎
#   - 下载推荐的 AI 模型
#   - 完善的错误处理和日志记录
#
# 使用方法：
#   source "${LIB_DIR}/parts/part2_compute.zsh"
#   install_part2_compute
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

typeset -g DETECTED_CHIP=""
typeset -g DETECTED_CHIP_NAME=""
typeset -g DETECTED_MEMORY_GB=0
typeset -g RECOMMENDED_MODEL=""
typeset -g OMLX_INSTALLED=false
typeset -g MODEL_DOWNLOADED=false

# ==============================================================================
# 加载配置
# ==============================================================================

load_compute_config() {
    if [[ -f "${SCRIPT_DIR}/config/compute.conf" ]]; then
        source "${SCRIPT_DIR}/config/compute.conf"
    else
        log_warning "算力配置文件不存在，使用默认配置"
    fi
}

# ==============================================================================
# 芯片检测
# ==============================================================================

# 检测 Apple Silicon 芯片类型
detect_apple_silicon_chip() {
    log_info "检测 Apple Silicon 芯片..."

    # 获取 CPU 型号
    local cpu_string=$(sysctl -n machdep.cpu.brand_string)

    # 提取芯片类型
    if [[ "${cpu_string}" =~ "Apple M([1-5])( Pro| Max| Ultra)?" ]]; then
        local generation="${match[1]}"
        local variant="${match[2]}"

        case "${generation}" in
            1)
                if [[ "${variant}" == "Pro" ]]; then
                    DETECTED_CHIP="M1_PRO"
                    DETECTED_CHIP_NAME="${CHIP_M1_PRO_NAME}"
                elif [[ "${variant}" == "Max" ]]; then
                    DETECTED_CHIP="M1_MAX"
                    DETECTED_CHIP_NAME="${CHIP_M1_MAX_NAME}"
                else
                    DETECTED_CHIP="M1"
                    DETECTED_CHIP_NAME="${CHIP_M1_NAME}"
                fi
                ;;
            2)
                if [[ "${variant}" == "Pro" ]]; then
                    DETECTED_CHIP="M2_PRO"
                    DETECTED_CHIP_NAME="${CHIP_M2_PRO_NAME}"
                elif [[ "${variant}" == "Max" ]]; then
                    DETECTED_CHIP="M2_MAX"
                    DETECTED_CHIP_NAME="${CHIP_M2_MAX_NAME}"
                elif [[ "${variant}" == "Ultra" ]]; then
                    DETECTED_CHIP="M2_ULTRA"
                    DETECTED_CHIP_NAME="${CHIP_M2_ULTRA_NAME}"
                else
                    DETECTED_CHIP="M2"
                    DETECTED_CHIP_NAME="${CHIP_M2_NAME}"
                fi
                ;;
            3)
                if [[ "${variant}" == "Pro" ]]; then
                    DETECTED_CHIP="M3_PRO"
                    DETECTED_CHIP_NAME="${CHIP_M3_PRO_NAME}"
                elif [[ "${variant}" == "Max" ]]; then
                    DETECTED_CHIP="M3_MAX"
                    DETECTED_CHIP_NAME="${CHIP_M3_MAX_NAME}"
                else
                    DETECTED_CHIP="M3"
                    DETECTED_CHIP_NAME="${CHIP_M3_NAME}"
                fi
                ;;
            4)
                if [[ "${variant}" == "Pro" ]]; then
                    DETECTED_CHIP="M4_PRO"
                    DETECTED_CHIP_NAME="${CHIP_M4_PRO_NAME}"
                else
                    DETECTED_CHIP="M4"
                    DETECTED_CHIP_NAME="${CHIP_M4_NAME}"
                fi
                ;;
            5)
                DETECTED_CHIP="M5"
                DETECTED_CHIP_NAME="${CHIP_M5_NAME}"
                ;;
            *)
                DETECTED_CHIP="M1"
                DETECTED_CHIP_NAME="${CHIP_M1_NAME}"
                ;;
        esac

        log_success "检测到: ${DETECTED_CHIP_NAME}"
        return 0
    else
        log_warning "无法识别芯片类型，使用默认配置"
        DETECTED_CHIP="M1"
        DETECTED_CHIP_NAME="${CHIP_M1_NAME}"
        return 1
    fi
}

# 检测内存大小
detect_memory_size() {
    log_info "检测内存大小..."

    # 获取内存字节数
    local memory_bytes=$(sysctl -n hw.memsize)

    # 转换为 GB
    DETECTED_MEMORY_GB=$(( memory_bytes / 1024 / 1024 / 1024 ))

    log_success "检测到: ${DETECTED_MEMORY_GB}GB 内存"

    # 内存警告
    if [[ ${DETECTED_MEMORY_GB} -lt 16 ]]; then
        log_warning "内存较小，推荐使用 4-bit 模型"
    elif [[ ${DETECTED_MEMORY_GB} -ge 32 ]]; then
        log_success "内存充足，可以使用 8-bit 或 16-bit 模型"
    fi
}

# ==============================================================================
# 智能模型推荐
# ==============================================================================

# 智能推荐模型
recommend_model() {
    log_section "智能模型推荐"

    # 加载推荐规则
    load_compute_config

    # 查找匹配的推荐规则
    local recommended_model=""
    for rule in "${MODEL_RECOMMENDATION_RULES[@]}"; do
        local chip_pattern="${rule%%:*}"
        local rest="${rule#*:}"
        local memory_pattern="${rest%%:*}"
        local model="${rest##*:}"

        # 检查芯片是否匹配
        if [[ "${DETECTED_CHIP}" == "${chip_pattern}" ]]; then
            # 检查内存是否满足要求
            local required_memory="${memory_pattern}"
            if [[ ${DETECTED_MEMORY_GB} -ge ${required_memory} ]]; then
                recommended_model="${model}"
                break
            fi
        fi
    done

    # 如果没有找到匹配的规则，使用默认模型
    if [[ -z "${recommended_model}" ]]; then
        log_warning "未找到匹配的推荐规则，使用默认模型"
        recommended_model="${MODEL_DEFAULT}"
    fi

    RECOMMENDED_MODEL="${recommended_model}"

    # 显示推荐信息
    echo ""
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_NC}"
    echo -e "${COLOR_CYAN}  🤖 智能模型推荐${COLOR_NC}"
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_NC}"
    echo ""
    echo -e "${COLOR_WHITE}检测到的硬件：${COLOR_NC}"
    echo "  • 芯片: ${DETECTED_CHIP_NAME}"
    echo "  • 内存: ${DETECTED_MEMORY_GB}GB"
    echo ""
    echo -e "${COLOR_WHITE}推荐模型：${COLOR_NC}"
    echo "  • ${COLOR_GREEN}${RECOMMENDED_MODEL}${COLOR_NC}"
    echo ""

    # 获取模型信息
    local model_info=$(get_model_info "${RECOMMENDED_MODEL}")
    if [[ -n "${model_info}" ]]; then
        echo -e "${COLOR_WHITE}模型信息：${COLOR_NC}"
        echo "  ${model_info}"
        echo ""
    fi

    # 询问用户是否接受推荐
    if [[ "${INSTALL_MODE}" != "auto" ]]; then
        if ! confirm_action "是否使用推荐的模型？"; then
            # 显示可选模型列表
            show_available_models
            read_input "请输入模型名称" RECOMMENDED_MODEL "${MODEL_DEFAULT}"
        fi
    fi

    log_success "已选择模型: ${RECOMMENDED_MODEL}"
}

# 获取模型信息
get_model_info() {
    local model="$1"

    for model_def in "${MODELS_AVAILABLE[@]}"; do
        local model_name="${model_def%%:*}"
        local rest="${model_def#*:}"
        local size="${rest%%:*}"
        local rest2="${rest#*:}"
        local memory="${rest2%%:*}"
        local chips="${rest2##*:}"

        if [[ "${model}" == "${model_name}" ]]; then
            echo "大小: ${size}GB | 最低内存: ${memory}GB | 支持芯片: ${chips}"
            return 0
        fi
    done

    return 1
}

# 显示可用模型列表
show_available_models() {
    echo ""
    echo -e "${COLOR_WHITE}可用模型列表：${COLOR_NC}"
    echo ""

    local index=1
    for model_def in "${MODELS_AVAILABLE[@]}"; do
        local model_name="${model_def%%:*}"
        local rest="${model_def#*:}"
        local size="${rest%%:*}"
        local rest2="${rest#*:}"
        local memory="${rest2%%:*}"
        local chips="${rest2##*:}"

        # 检查是否支持当前芯片
        if [[ ",${chips}," == *",${DETECTED_CHIP},"* ]] || [[ "${chips}" == *"M5"* ]]; then
            # 检查内存是否满足
            if [[ ${DETECTED_MEMORY_GB} -ge ${memory} ]]; then
                echo -e "  ${COLOR_GREEN}[${index}]${COLOR_NC} ${model_name}"
                echo "      大小: ${size}GB | 最低内存: ${memory}GB"
            else
                echo -e "  ${COLOR_GRAY}[${index}]${COLOR_NC} ${model_name}"
                echo "      ${COLOR_YELLOW}⚠️  内存不足（需要 ${memory}GB，当前 ${DETECTED_MEMORY_GB}GB）${COLOR_NC}"
            fi
        fi

        ((index++))
    done

    echo ""
}

# ==============================================================================
# oMLX 安装
# ==============================================================================

# 安装 oMLX
install_omlx() {
    log_section "安装 oMLX 推理引擎"

    # 检查是否已安装
    if pip3 show omlx &>/dev/null; then
        local version=$(pip3 show omlx | grep Version | cut -d' ' -f2)
        log_success "oMLX 已安装: ${version}"
        OMLX_INSTALLED=true
        return 0
    fi

    log_info "开始安装 oMLX..."

    # 使用清华镜像安装
    local pip_index_url="${PIP_INDEX_URL:-https://pypi.tuna.tsinghua.edu.cn/simple}"

    if pip3 install --upgrade omlx -i "${pip_index_url}" 2>&1 | tee -a "${LOG_FILE}"; then
        log_success "oMLX 安装成功"
        OMLX_INSTALLED=true
        return 0
    else
        local exit_code=$?
        if type throw_error >/dev/null 2>&1; then
            throw_error ${ERR_OMLX_INSTALL} "oMLX 安装失败" "退出码: ${exit_code}"
        else
            log_error "oMLX 安装失败（退出码: ${exit_code}）"
            increment_error_count
        fi
        return 1
    fi
        # 安装失败，提供选项
        log_error "oMLX 安装失败"

        if [[ "${INSTALL_MODE}" == "auto" ]]; then
            return 1
        fi

        # 询问用户
        echo ""
        local options=(
            "R" "重试安装"
            "S" "跳过 oMLX（继续安装 OpenClaw）"
            "A" "中止安装"
        )

        print_menu "请选择操作" "${options[@]}"
        read -k1 choice
        echo ""

        case "${choice}" in
            r|R)
                log_info "重试安装 oMLX..."
                if retry_command 3 "pip3 install --upgrade omlx -i ${pip_index_url}" "oMLX 安装失败"; then
                    OMLX_INSTALLED=true
                    return 0
                else
                    return 1
                fi
                ;;
            s|S)
                log_warning "跳过 oMLX 安装"
                return 0
                ;;
            a|A)
                log_error "中止安装"
                return 1
                ;;
            *)
                log_error "无效选择，中止安装"
                return 1
                ;;
        esac
    fi
}

# ==============================================================================
# 模型下载
# ==============================================================================

# 下载 AI 模型
download_model() {
    log_section "下载 AI 模型"

    # 检查 OpenClaw 是否可用
    if ! command -v openclaw >/dev/null 2>&1; then
        log_warning "OpenClaw 未安装，跳过模型下载"
        return 0
    fi

    log_info "开始下载模型: ${RECOMMENDED_MODEL}"
    log_info "模型大小: $(get_model_size "${RECOMMENDED_MODEL}")"

    # 使用 OpenClaw 下载模型
    local model_path="omlx/${RECOMMENDED_MODEL}"

    # 重试逻辑
    local max_attempts=${MODEL_DOWNLOAD_RETRY:-3}
    local attempt=1

    while [[ ${attempt} -le ${max_attempts} ]]; do
        log_info "下载尝试 ${attempt}/${max_attempts}..."

        if openclaw model pull "${model_path}" 2>&1 | tee -a "${LOG_FILE}"; then
            log_success "模型下载成功"
            MODEL_DOWNLOADED=true
            return 0
        else
            local exit_code=$?
            log_error "模型下载失败（尝试 ${attempt}/${max_attempts}）"
            increment_error_count
        fi

        if [[ ${attempt} -lt ${max_attempts} ]]; then
            local wait_time=$((attempt * 5))
            log_warning "等待 ${wait_time} 秒后重试..."
            sleep ${wait_time}
        fi

        ((attempt++))
    done

    # 下载失败
    log_error "模型下载失败"

    if [[ "${INSTALL_MODE}" == "auto" ]]; then
        log_warning "将跳过模型下载，您可以稍后手动下载"
        return 0
    fi

    # 提供选项
    echo ""
    local options=(
        "R" "使用其他下载源重试"
        "S" "跳过模型下载（稍后手动下载）"
        "M" "手动下载指引"
        "A" "中止安装"
    )

    print_menu "请选择操作" "${options[@]}"
    read -k1 choice
    echo ""

    case "${choice}" in
        r|R)
            # 尝试备用下载源
            log_info "使用备用下载源..."
            # TODO: 实现备用源下载
            return 1
            ;;
        s|S)
            log_warning "跳过模型下载"
            log_info "稍后可手动运行: openclaw model pull ${model_path}"
            return 0
            ;;
        m|M)
            show_manual_download_guide "${model_path}"
            return 0
            ;;
        a|A)
            log_error "中止安装"
            return 1
            ;;
        *)
            log_error "无效选择"
            return 1
            ;;
    esac
}

# 获取模型大小
get_model_size() {
    local model="$1"

    for model_def in "${MODELS_AVAILABLE[@]}"; do
        local model_name="${model_def%%:*}"
        local rest="${model_def#*:}"
        local size="${rest%%:*}"

        if [[ "${model}" == "${model_name}" ]]; then
            echo "${size}GB"
            return 0
        fi
    done

    echo "未知大小"
}

# 显示手动下载指引
show_manual_download_guide() {
    local model_path="$1"

    cat << EOF
${COLOR_YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_NC}
${COLOR_YELLOW}  手动下载模型指引${COLOR_NC}
${COLOR_YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_NC}

模型: ${model_path}

${COLOR_WHITE}方法 1: 使用 OpenClaw CLI${COLOR_NC}
  openclaw model pull ${model_path}

${COLOR_WHITE}方法 2: 从 ModelScope 下载${COLOR_NC}
  1. 访问: https://modelscope.cn
  2. 搜索: ${model_path}
  3. 下载模型到: ${MODEL_CACHE_DIR}

${COLOR_WHITE}方法 3: 使用 Hugging Face Mirror${COLOR_NC}
  1. 访问: https://hf-mirror.com
  2. 搜索模型并下载

${COLOR_WHITE}验证下载：${COLOR_NC}
  openclaw model list

${COLOR_YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_NC}

EOF
}

# ==============================================================================
# 验证安装
# ==============================================================================

# 验证第2部分安装
verify_part2() {
    log_section "验证算力配置"

    local all_ok=true

    # 验证芯片检测
    if [[ -n "${DETECTED_CHIP}" ]]; then
        log_list_item "success" "芯片检测: ${DETECTED_CHIP_NAME}"
    else
        log_list_item "error" "芯片检测失败"
        all_ok=false
    fi

    # 验证 oMLX
    if ${OMLX_INSTALLED}; then
        if pip3 show omlx &>/dev/null; then
            local version=$(pip3 show omlx | grep Version | cut -d' ' -f2)
            log_list_item "success" "oMLX: ${version}"
        else
            log_list_item "warning" "oMLX 安装可能有问题"
        fi
    else
        log_list_item "info" "oMLX: 未安装（已跳过）"
    fi

    # 验证模型
    if ${MODEL_DOWNLOADED}; then
        log_list_item "success" "模型: ${RECOMMENDED_MODEL}"
    else
        log_list_item "info" "模型: 未下载（可稍后手动下载）"
    fi

    echo ""

    if ${all_ok}; then
        log_success "✅ 算力配置验证通过"
        return 0
    else
        log_warning "⚠️  算力配置部分完成"
        return 0
    fi
}

# ==============================================================================
# 主函数
# ==============================================================================

# 安装第2部分：算力配置
install_part2_compute() {
    log_title "第2部分：算力配置"

    # 加载配置
    load_compute_config

    # 检测 CPU 架构
    if [[ "${CPU_ARCHITECTURE}" != "arm64" ]]; then
        log_warning "检测到 Intel CPU，跳过算力配置"
        log_info "Intel Mac 将使用 CPU 推理"
        return 0
    fi

    # 检测硬件
    detect_apple_silicon_chip
    detect_memory_size

    # 智能推荐模型
    recommend_model

    # 安装 oMLX
    if ! install_omlx; then
        if [[ "${INSTALL_MODE}" != "auto" ]]; then
            if ! confirm_action "oMLX 安装失败，是否继续？"; then
                log_error "用户取消安装"
                return 1
            fi
        fi
    fi

    # 下载模型
    if ! download_model; then
        log_warning "模型下载失败，但不影响后续安装"
    fi

    # 验证安装
    verify_part2

    log_success "✅ 第2部分完成：算力配置"
    return 0
}

# ==============================================================================
# 导出函数
# ==============================================================================

export -f load_compute_config
export -f detect_apple_silicon_chip
export -f detect_memory_size
export -f recommend_model
export -f get_model_info
export -f show_available_models
export -f install_omlx
export -f download_model
export -f get_model_size
export -f show_manual_download_guide
export -f verify_part2
export -f install_part2_compute
