#!/usr/bin/env zsh
# ==============================================================================
# MacClaw Install - 错误处理模块
# ==============================================================================
#
# 功能说明：
#   - 统一的错误处理接口
#   - 错误码定义和管理
#   - 错误信息格式化
#   - 错误解决建议生成
#   - 错误日志记录
#
# 使用方法：
#   source "${LIB_DIR}/core/error-handler.zsh"
#   throw_error "ERR_FILE_NOT_FOUND" "文件不存在: /path/to/file"
#   handle_error $? "操作失败"
#
# ==============================================================================

# ==============================================================================
# 错误码定义
# ==============================================================================

# 系统错误 (1-99)
typeset -g ERR_SYSTEM_BASE=1
typeset -g ERR_MACOS_VERSION=1          # macOS 版本不符合要求
typeset -g ERR_DISK_SPACE=2             # 磁盘空间不足
typeset -g ERR_MEMORY_INSUFFICIENT=3    # 内存不足
typeset -g ERR_CPU_ARCHITECTURE=4       # CPU 架构不支持

# 网络错误 (100-199)
typeset -g ERR_NETWORK_BASE=100
typeset -g ERR_NETWORK_UNAVAILABLE=100  # 网络不可用
typeset -g ERR_DOWNLOAD_FAILED=101      # 下载失败
typeset -g ERR_MIRROR_UNAVAILABLE=102   # 镜像源不可用
typeset -g ERR_PROXY_ERROR=103          # 代理配置错误

# 文件系统错误 (200-299)
typeset -g ERR_FILE_BASE=200
typeset -g ERR_FILE_NOT_FOUND=200       # 文件不存在
typeset -g ERR_FILE_PERMISSION=201      # 文件权限错误
typeset -g ERR_FILE_CORRUPTED=202       # 文件损坏
typeset -g ERR_DIRECTORY_CREATE=203     # 创建目录失败

# 组件安装错误 (300-399)
typeset -g ERR_INSTALL_BASE=300
typeset -g ERR_HOMEBREW_INSTALL=300     # Homebrew 安装失败
typeset -g ERR_NODEJS_INSTALL=301       # Node.js 安装失败
typeset -g ERR_NVM_INSTALL=302          # nvm 安装失败
typeset -g ERR_OPENCLAW_INSTALL=303     # OpenClaw 安装失败
typeset -g ERR_OMLX_INSTALL=304         # oMLX 安装失败
typeset -g ERR_MODEL_DOWNLOAD=305       # 模型下载失败
typeset -g ERR_PLUGIN_INSTALL=306       # 插件安装失败

# 配置错误 (400-499)
typeset -g ERR_CONFIG_BASE=400
typeset -g ERR_CONFIG_NOT_FOUND=400     # 配置文件不存在
typeset -g ERR_CONFIG_INVALID=401       # 配置无效
typeset -g ERR_VERSION_MISMATCH=402     # 版本不匹配

# 验证错误 (500-599)
typeset -g ERR_VERIFY_BASE=500
typeset -g ERR_VERIFY_FAILED=500        # 验证失败
typeset -g ERR_SERVICE_NOT_RUNNING=501  # 服务未运行
typeset -g ERR_PORT_OCCUPIED=502        # 端口被占用

# 用户中断 (900-999)
typeset -g ERR_USER_BASE=900
typeset -g ERR_USER_CANCELLED=900       # 用户取消
typeset -g ERR_USER_DECLINED=901        # 用户拒绝

# ==============================================================================
# 错误信息映射
# ==============================================================================

typeset -gA ERROR_MESSAGES
ERROR_MESSAGES=(
    $ERR_MACOS_VERSION            "macOS 版本不符合要求"
    $ERR_DISK_SPACE               "磁盘空间不足"
    $ERR_MEMORY_INSUFFICIENT      "内存不足"
    $ERR_CPU_ARCHITECTURE         "CPU 架构不支持"
    $ERR_NETWORK_UNAVAILABLE      "网络不可用"
    $ERR_DOWNLOAD_FAILED          "下载失败"
    $ERR_MIRROR_UNAVAILABLE       "镜像源不可用"
    $ERR_PROXY_ERROR              "代理配置错误"
    $ERR_FILE_NOT_FOUND           "文件不存在"
    $ERR_FILE_PERMISSION          "文件权限错误"
    $ERR_FILE_CORRUPTED           "文件损坏"
    $ERR_DIRECTORY_CREATE         "创建目录失败"
    $ERR_HOMEBREW_INSTALL         "Homebrew 安装失败"
    $ERR_NODEJS_INSTALL           "Node.js 安装失败"
    $ERR_NVM_INSTALL              "nvm 安装失败"
    $ERR_OPENCLAW_INSTALL         "OpenClaw 安装失败"
    $ERR_OMLX_INSTALL             "oMLX 安装失败"
    $ERR_MODEL_DOWNLOAD           "模型下载失败"
    $ERR_PLUGIN_INSTALL           "插件安装失败"
    $ERR_CONFIG_NOT_FOUND         "配置文件不存在"
    $ERR_CONFIG_INVALID           "配置无效"
    $ERR_VERSION_MISMATCH         "版本不匹配"
    $ERR_VERIFY_FAILED            "验证失败"
    $ERR_SERVICE_NOT_RUNNING      "服务未运行"
    $ERR_PORT_OCCUPIED            "端口被占用"
    $ERR_USER_CANCELLED           "用户取消操作"
    $ERR_USER_DECLINED            "用户拒绝操作"
)

# ==============================================================================
# 错误解决建议
# ==============================================================================

# 获取错误解决建议
get_error_solution() {
    local error_code=$1
    local solution=""

    case ${error_code} in
        ${ERR_MACOS_VERSION})
            solution="建议：升级到 macOS 12 或更高版本，或使用兼容模式"
            ;;
        ${ERR_DISK_SPACE})
            solution="建议：清理磁盘空间，至少需要 20GB 可用空间"
            ;;
        ${ERR_MEMORY_INSUFFICIENT})
            solution="建议：关闭其他应用释放内存，或使用最小化安装"
            ;;
        ${ERR_NETWORK_UNAVAILABLE})
            solution="建议：检查网络连接，确保可以访问互联网"
            ;;
        ${ERR_DOWNLOAD_FAILED})
            solution="建议：检查网络连接，尝试更换镜像源或使用代理"
            ;;
        ${ERR_HOMEBREW_INSTALL})
            solution="建议：检查网络连接，手动运行 /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            ;;
        ${ERR_NODEJS_INSTALL})
            solution="建议：检查 nvm 安装，尝试手动运行: nvm install 20.11.0"
            ;;
        ${ERR_OMLX_INSTALL})
            solution="建议：检查 Python 和 pip 安装，运行: pip3 install omlx -i https://pypi.tuna.tsinghua.edu.cn/simple"
            ;;
        ${ERR_MODEL_DOWNLOAD})
            solution="建议：检查网络连接，稍后手动下载: openclaw model pull omlx/gemma-4-e4b-it-4bit"
            ;;
        ${ERR_PORT_OCCUPIED})
            solution="建议：检查端口占用: lsof -i :18789，停止占用进程或重启系统"
            ;;
        *)
            solution="建议：查看详细日志: ${LOG_FILE}，或访问 https://github.com/changzhi777/mactools/issues 寻求帮助"
            ;;
    esac

    echo "${solution}"
}

# ==============================================================================
# 错误处理函数
# ==============================================================================

# 抛出错误（记录日志并显示）
throw_error() {
    local error_code=$1
    local error_message="$2"
    local context="${3:-}"

    # 获取标准错误信息
    local std_message="${ERROR_MESSAGES[${error_code}]:-未知错误}"

    # 构建完整错误信息
    local full_message="${std_message}"
    if [[ -n "${error_message}" ]]; then
        full_message="${full_message}: ${error_message}"
    fi

    # 记录错误日志
    log_error "[${error_code}] ${full_message}"

    # 如果有上下文，记录上下文
    if [[ -n "${context}" ]]; then
        log_error "上下文: ${context}"
    fi

    # 获取并显示解决建议
    local solution=$(get_error_solution ${error_code})
    if [[ -n "${solution}" ]]; then
        echo -e "${COLOR_YELLOW}💡 ${solution}${COLOR_NC}"
        log_error "建议: ${solution}"
    fi

    # 显示日志位置
    echo ""
    log_info "详细日志: ${LOG_FILE}"

    return ${error_code}
}

# 处理命令执行错误
handle_error() {
    local exit_code=$1
    local operation="$2"
    local error_code=$3

    # 如果退出码为0，表示成功
    if [[ ${exit_code} -eq 0 ]]; then
        return 0
    fi

    # 如果没有提供错误码，使用通用错误
    if [[ -z "${error_code}" ]]; then
        case ${exit_code} in
            1) error_code=${ERR_VERIFY_FAILED} ;;
            2) error_code=${ERR_CONFIG_INVALID} ;;
            126) error_code=${ERR_FILE_PERMISSION} ;;
            127) error_code=${ERR_FILE_NOT_FOUND} ;;
            *) error_code=${ERR_INSTALL_BASE} ;;
        esac
    fi

    # 抛出错误
    throw_error ${error_code} "${operation} 失败（退出码: ${exit_code}）"
}

# 捕获错误并处理
catch_error() {
    local exit_code=$?

    if [[ ${exit_code} -ne 0 ]]; then
        log_error "命令执行失败（退出码: ${exit_code}）"
        return ${exit_code}
    fi

    return 0
}

# 重试逻辑
retry_command() {
    local max_attempts=$1
    local command="$2"
    local error_message="$3"
    local attempt=1

    while [[ ${attempt} -le ${max_attempts} ]]; do
        log_info "尝试 ${attempt}/${max_attempts}: ${command}"

        if eval "${command}"; then
            log_success "操作成功"
            return 0
        fi

        if [[ ${attempt} -lt ${max_attempts} ]]; then
            local wait_time=$((attempt * 2))
            log_warning "等待 ${wait_time} 秒后重试..."
            sleep ${wait_time}
        fi

        ((attempt++))
    done

    log_error "${error_message}"
    return 1
}

# 错误恢复选项
ask_error_recovery() {
    local error_code=$1
    local operation="$2"

    echo ""
    echo -e "${COLOR_YELLOW}❌ 操作失败: ${operation}${COLOR_NC}"
    echo ""

    local options=(
        "R" "重试"
        "S" "跳过"
        "A" "中止"
    )

    print_menu "请选择操作" "${options[@]}"
    read -k1 choice
    echo ""

    case "${choice}" in
        r|R)
            return 1  # 重试
            ;;
        s|S)
            return 0  # 跳过
            ;;
        a|A)
            return 2  # 中止
            ;;
        *)
            log_error "无效选择，中止操作"
            return 2
            ;;
    esac
}

# ==============================================================================
# 错误统计
# ==============================================================================

# 错误计数器
typeset -g ERROR_COUNT=0
typeset -g WARNING_COUNT=0

# 增加错误计数
increment_error_count() {
    ((ERROR_COUNT++))
}

# 增加警告计数
increment_warning_count() {
    ((WARNING_COUNT++))
}

# 显示错误统计
show_error_statistics() {
    if [[ ${ERROR_COUNT} -eq 0 && ${WARNING_COUNT} -eq 0 ]]; then
        return 0
    fi

    echo ""
    log_section "错误统计"

    if [[ ${ERROR_COUNT} -gt 0 ]]; then
        echo -e "${COLOR_RED}❌ 错误: ${ERROR_COUNT}${COLOR_NC}"
    fi

    if [[ ${WARNING_COUNT} -gt 0 ]]; then
        echo -e "${COLOR_YELLOW}⚠️  警告: ${WARNING_COUNT}${COLOR_NC}"
    fi

    echo ""
}

# ==============================================================================
# 导出函数和变量
# ==============================================================================

export ERROR_COUNT
export WARNING_COUNT

export -f throw_error
export -f handle_error
export -f catch_error
export -f retry_command
export -f ask_error_recovery
export -f get_error_solution
export -f increment_error_count
export -f increment_warning_count
export -f show_error_statistics
