#!/usr/bin/env zsh
# ==============================================================================
# MacClaw Install - 环境检测模块
# ==============================================================================
#
# 功能说明：
#   - macOS 版本检测（兼容模式支持）
#   - 磁盘空间检测（智能推荐）
#   - 网络环境检测（自动测速选源）
#   - 已安装组件检测（版本智能判断）
#   - 代理设置检测
#
# 使用方法：
#   source "${LIB_DIR}/core/detector.zsh"
#   detect_all_environments    # 检测所有环境
#
# ==============================================================================

# ==============================================================================
# 全局变量（存储检测结果）
# ==============================================================================

typeset -g MACOS_VERSION=""
typeset -g MACOS_MAJOR_VERSION=0
typeset -g MACOS_COMPATIBLE_MODE=false

typeset -g DISK_TOTAL_SPACE=0
typeset -g DISK_AVAILABLE_SPACE=0
typeset -g DISK_RECOMMENDATION=""

typeset -g NETWORK_AVAILABLE=false
typeset -g NETWORK_FASTEST_SOURCE=""

typeset -g HOMEBREW_INSTALLED=false
typeset -g HOMEBREW_VERSION=""
typeset -g HOMEBREW_NEED_UPDATE=false

typeset -g NODEJS_INSTALLED=false
typeset -g NODEJS_VERSION=""
typeset -g NODEJS_NEED_UPDATE=false

typeset -g NVM_INSTALLED=false
typeset -g NVM_VERSION=""

typeset -g PROXY_ENABLED=false
typeset -g PROXY_HOST=""
typeset -g PROXY_PORT=""

typeset -g CPU_ARCHITECTURE=""
typeset -g CPU_MODEL=""
typeset -g MEMORY_SIZE=0

# ==============================================================================
# 系统检测
# ==============================================================================

# 检测 macOS 版本
detect_macos_version() {
    MACOS_VERSION=$(sw_vers -productVersion)
    MACOS_MAJOR_VERSION=$(echo "${MACOS_VERSION}" | cut -d. -f1)

    log_info "检测到 macOS 版本: ${MACOS_VERSION}"

    # 检查是否需要兼容模式
    if [[ ${MACOS_MAJOR_VERSION} -lt 12 ]]; then
        log_warning "macOS 版本较低（< 12），将启用兼容模式"
        MACOS_COMPATIBLE_MODE=true
    else
        MACOS_COMPATIBLE_MODE=false
        log_success "macOS 版本符合要求"
    fi
}

# 检测磁盘空间
detect_disk_space() {
    local path="${1:-/}"

    # 获取磁盘空间（单位：KB）
    local disk_info=$(df -k "${path}" | tail -1)
    DISK_AVAILABLE_SPACE=$(echo "${disk_info}" | awk '{print $4}')
    DISK_TOTAL_SPACE=$(echo "${disk_info}" | awk '{print $2}')

    # 转换为 GB
    local available_gb=$(( DISK_AVAILABLE_SPACE / 1024 / 1024 ))
    local total_gb=$(( DISK_TOTAL_SPACE / 1024 / 1024 ))

    log_info "磁盘空间: 总计 ${total_gb}GB, 可用 ${available_gb}GB"

    # 智能推荐
    if [[ ${available_gb} -lt 5 ]]; then
        DISK_RECOMMENDATION="insufficient"
        log_error "磁盘空间不足，至少需要 5GB"
        return 1
    elif [[ ${available_gb} -lt 20 ]]; then
        DISK_RECOMMENDATION="minimal"
        log_warning "磁盘空间有限，建议使用最小化安装"
        return 0
    else
        DISK_RECOMMENDATION="full"
        log_success "磁盘空间充足，可以进行完整安装"
        return 0
    fi
}

# 检测 CPU 架构
detect_cpu_architecture() {
    CPU_ARCHITECTURE=$(uname -m)
    CPU_MODEL=$(sysctl -n machdep.cpu.brand_string)

    log_info "CPU 架构: ${CPU_ARCHITECTURE}"
    log_info "CPU 型号: ${CPU_MODEL}"

    case "${CPU_ARCHITECTURE}" in
        arm64)
            log_success "检测到 Apple Silicon 处理器"
            ;;
        x86_64)
            log_info "检测到 Intel 处理器"
            ;;
        *)
            log_warning "未知 CPU 架构"
            ;;
    esac
}

# 检测内存大小
detect_memory_size() {
    MEMORY_SIZE=$(sysctl -n hw.memsize)
    local memory_gb=$(( MEMORY_SIZE / 1024 / 1024 / 1024 ))

    log_info "内存大小: ${memory_gb}GB"

    if [[ ${memory_gb} -lt 16 ]]; then
        log_warning "内存较小，建议至少 16GB"
    elif [[ ${memory_gb} -ge 32 ]]; then
        log_success "内存充足，可以运行大型模型"
    fi
}

# ==============================================================================
# 网络检测
# ==============================================================================

# 检测网络连接
detect_network_connection() {
    log_info "检测网络连接..."

    # 尝试连接到国内镜像
    if curl -s --connect-timeout 5 https://mirrors.ustc.edu.cn >/dev/null 2>&1; then
        NETWORK_AVAILABLE=true
        log_success "网络连接正常"
        return 0
    else
        NETWORK_AVAILABLE=false
        log_error "网络连接失败"
        return 1
    fi
}

# 测试源速度
test_source_speed() {
    local source_url="$1"
    local source_name="$2"

    local start_time=$(date +%s)
    if curl -s --connect-timeout 3 --max-time 5 "${source_url}" >/dev/null 2>&1; then
        local end_time=$(date +%s)
        local duration=$(( end_time - start_time ))
        echo "${source_name}:${duration}"
        return 0
    else
        echo "${source_name}:9999"
        return 1
    fi
}

# 检测最快的镜像源
detect_fastest_source() {
    log_info "检测最快的镜像源..."

    local sources=(
        "https://mirrors.ustc.edu.cn:中科大镜像"
        "https://mirrors.tuna.tsinghua.edu.cn:清华镜像"
        "https://mirrors.aliyun.com:阿里云镜像"
    )

    local fastest_source=""
    local fastest_time=9999

    for source in "${sources[@]}"; do
        local url="${source%%:*}"
        local name="${source##*:}"

        log_info "测试 ${name}..."
        local result=$(test_source_speed "${url}" "${name}")
        local time="${result##*:}"

        if [[ ${time} -lt ${fastest_time} ]]; then
            fastest_time=${time}
            fastest_source="${name}"
        fi
    done

    if [[ -n "${fastest_source}" ]]; then
        NETWORK_FASTEST_SOURCE="${fastest_source}"
        log_success "最快的镜像源: ${fastest_source} (${fastest_time}s)"
    else
        log_warning "无法检测到可用的镜像源"
        NETWORK_FASTEST_SOURCE="官方源"
    fi
}

# ==============================================================================
# 组件检测
# ==============================================================================

# 检测 Homebrew
detect_homebrew() {
    if command -v brew >/dev/null 2>&1; then
        HOMEBREW_INSTALLED=true
        HOMEBREW_VERSION=$(brew --version | head -1 | awk '{print $2}')
        log_success "Homebrew 已安装: ${HOMEBREW_VERSION}"

        # 检查版本是否需要更新（假设 4.0 以下需要更新）
        local major_version=$(echo "${HOMEBREW_VERSION}" | cut -d. -f1)
        if [[ ${major_version} -lt 4 ]]; then
            HOMEBREW_NEED_UPDATE=true
            log_warning "Homebrew 版本较旧，建议更新"
        fi
    else
        HOMEBREW_INSTALLED=false
        log_info "Homebrew 未安装"
    fi
}

# 检测 Node.js
detect_nodejs() {
    if command -v node >/dev/null 2>&1; then
        NODEJS_INSTALLED=true
        NODEJS_VERSION=$(node --version)
        log_success "Node.js 已安装: ${NODEJS_VERSION}"

        # 检查版本是否需要更新（假设 18.0 以下需要更新）
        local major_version=$(echo "${NODEJS_VERSION}" | cut -d. -f1 | sed 's/v//')
        if [[ ${major_version} -lt 18 ]]; then
            NODEJS_NEED_UPDATE=true
            log_warning "Node.js 版本较旧，建议更新到 20.x LTS"
        fi
    else
        NODEJS_INSTALLED=false
        log_info "Node.js 未安装"
    fi
}

# 检测 nvm
detect_nvm() {
    if [[ -f "${HOME}/.nvm/nvm.sh" ]] || command -v nvm >/dev/null 2>&1; then
        NVM_INSTALLED=true
        log_success "nvm 已安装"
    else
        NVM_INSTALLED=false
        log_info "nvm 未安装"
    fi
}

# ==============================================================================
# 代理检测
# ==============================================================================

# 检测系统代理
detect_proxy() {
    # 检测 HTTP_PROXY
    if [[ -n "${HTTP_PROXY}" || -n "${http_proxy}" ]]; then
        PROXY_ENABLED=true
        local proxy="${HTTP_PROXY:-${http_proxy}}"
        log_info "检测到 HTTP 代理: ${proxy}"

        # 解析代理地址和端口
        if [[ "${proxy}" =~ "://" ]]; then
            PROXY_HOST=$(echo "${proxy}" | sed -E 's|^[^:]+://([^:]+).*|\1|')
            PROXY_PORT=$(echo "${proxy}" | sed -E 's|^[^:]+://[^:]+:([0-9]+).*|\1|')
        fi
    fi

    # 检测 HTTPS_PROXY
    if [[ -n "${HTTPS_PROXY}" || -n "${https_proxy}" ]]; then
        PROXY_ENABLED=true
        local proxy="${HTTPS_PROXY:-${https_proxy}}"
        log_info "检测到 HTTPS 代理: ${proxy}"
    fi

    # 检测 macOS 系统代理
    local system_proxy=$(scutil --proxy 2>/dev/null)
    if echo "${system_proxy}" | grep -q "HTTPEnable : 1"; then
        PROXY_ENABLED=true
        log_info "检测到 macOS 系统代理已启用"
    fi

    if [[ ${PROXY_ENABLED} == false ]]; then
        log_info "未检测到代理设置"
    fi
}

# ==============================================================================
# 综合检测
# ==============================================================================

# 检测所有环境
detect_all_environments() {
    log_section "系统环境检测"

    # 系统检测
    detect_macos_version
    detect_cpu_architecture
    detect_memory_size
    detect_disk_space

    echo ""

    # 网络检测
    if detect_network_connection; then
        detect_fastest_source
    fi

    echo ""

    # 组件检测
    log_info "检测已安装组件..."
    detect_homebrew
    detect_nodejs
    detect_nvm

    echo ""

    # 代理检测
    detect_proxy

    echo ""

    # 显示总结
    show_detection_summary
}

# 显示检测总结
show_detection_summary() {
    log_title "环境检测总结"

    echo -e "${COLOR_CYAN}系统信息:${COLOR_NC}"
    echo "  • macOS: ${MACOS_VERSION} $(uname -m)"
    echo "  • CPU: ${CPU_MODEL}"
    echo "  • 内存: $(format_bytes ${MEMORY_SIZE})"
    echo "  • 磁盘可用: $(format_bytes $(( DISK_AVAILABLE_SPACE * 1024 )))"

    echo ""
    echo -e "${COLOR_CYAN}已安装组件:${COLOR_NC}"

    if [[ ${HOMEBREW_INSTALLED} == true ]]; then
        echo "  ${COLOR_GREEN}✅${COLOR_NC} Homebrew ${HOMEBREW_VERSION}"
    else
        echo "  ${COLOR_GRAY}⏸️${COLOR_NC} Homebrew (未安装)"
    fi

    if [[ ${NODEJS_INSTALLED} == true ]]; then
        echo "  ${COLOR_GREEN}✅${COLOR_NC} Node.js ${NODEJS_VERSION}"
    else
        echo "  ${COLOR_GRAY}⏸️${COLOR_NC} Node.js (未安装)"
    fi

    if [[ ${NVM_INSTALLED} == true ]]; then
        echo "  ${COLOR_GREEN}✅${COLOR_NC} nvm"
    else
        echo "  ${COLOR_GRAY}⏸️${COLOR_NC} nvm (未安装)"
    fi

    echo ""

    # 兼容模式警告
    if [[ ${MACOS_COMPATIBLE_MODE} == true ]]; then
        echo -e "${COLOR_YELLOW}⚠️  兼容模式已启用${COLOR_NC}"
        echo "  部分功能可能受限，建议升级到 macOS 12 或更高版本"
        echo ""
    fi

    # 磁盘空间警告
    if [[ "${DISK_RECOMMENDATION}" == "minimal" ]]; then
        echo -e "${COLOR_YELLOW}⚠️  磁盘空间有限${COLOR_NC}"
        echo "  将使用最小化安装选项"
        echo ""
    fi
}

# ==============================================================================
# 导出函数
# ==============================================================================

export -f detect_macos_version
export -f detect_disk_space
export -f detect_cpu_architecture
export -f detect_memory_size
export -f detect_network_connection
export -f detect_fastest_source
export -f detect_homebrew
export -f detect_nodejs
export -f detect_nvm
export -f detect_proxy
export -f detect_all_environments
export -f show_detection_summary
