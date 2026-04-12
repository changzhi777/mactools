#!/usr/bin/env zsh
# ==============================================================================
# MacClaw Install - 核心日志模块
# ==============================================================================
#
# 功能说明：
#   - 支持多种日志级别（DEBUG/INFO/SUCCESS/WARNING/ERROR）
#   - 彩色控制台输出
#   - 文件日志记录
#   - 时间戳记录
#
# 使用方法：
#   source "${LIB_DIR}/core/logger.zsh"
#   init_log                    # 初始化日志系统
#   log_debug "调试信息"
#   log_info "一般信息"
#   log_success "成功信息"
#   log_warning "警告信息"
#   log_error "错误信息"
#
# ==============================================================================

# ==============================================================================
# 日志配置
# ==============================================================================

# 日志级别
typeset -g LOG_LEVEL_DEBUG=0
typeset -g LOG_LEVEL_INFO=1
typeset -g LOG_LEVEL_SUCCESS=2
typeset -g LOG_LEVEL_WARNING=3
typeset -g LOG_LEVEL_ERROR=4
typeset -g LOG_LEVEL_MINIMAL=5  # 简洁模式：只显示关键步骤和错误

# 输出模式：minimal（简洁，默认）| verbose（详细）| silent（静默）
typeset -g OUTPUT_MODE="minimal"

# 当前日志级别（可通过环境变量 LOG_LEVEL 设置）
typeset -g CURRENT_LOG_LEVEL=${LOG_LEVEL_MINIMAL}  # 默认简洁模式
if [[ -n "${LOG_LEVEL}" ]]; then
    case "${LOG_LEVEL}" in
        DEBUG|debug)   CURRENT_LOG_LEVEL=${LOG_LEVEL_DEBUG}; OUTPUT_MODE="verbose" ;;
        INFO|info)     CURRENT_LOG_LEVEL=${LOG_LEVEL_INFO}; OUTPUT_MODE="verbose" ;;
        SUCCESS|success) CURRENT_LOG_LEVEL=${LOG_LEVEL_SUCCESS} ;;
        WARNING|warning) CURRENT_LOG_LEVEL=${LOG_LEVEL_WARNING} ;;
        ERROR|error)   CURRENT_LOG_LEVEL=${LOG_LEVEL_ERROR} ;;
        MINIMAL|minimal) CURRENT_LOG_LEVEL=${LOG_LEVEL_MINIMAL}; OUTPUT_MODE="minimal" ;;
    esac
fi

# 日志文件路径
typeset -g LOG_FILE="${HOME}/macclaw_install.log"

# 颜色定义
typeset -g COLOR_RED='\033[0;31m'
typeset -g COLOR_GREEN='\033[0;32m'
typeset -g COLOR_YELLOW='\033[1;33m'
typeset -g COLOR_BLUE='\033[0;34m'
typeset -g COLOR_CYAN='\033[0;36m'
typeset -g COLOR_MAGENTA='\033[0;35m'
typeset -g COLOR_GRAY='\033[0;90m'
typeset -g COLOR_NC='\033[0m' # No Color

# 图标定义
typeset -g ICON_DEBUG="🔍"
typeset -g ICON_INFO="ℹ️ "
typeset -g ICON_SUCCESS="✅"
typeset -g ICON_WARNING="⚠️ "
typeset -g ICON_ERROR="❌"

# ==============================================================================
# 日志函数
# ==============================================================================

# 初始化日志系统
init_log() {
    local log_dir=$(dirname "${LOG_FILE}")

    # 创建日志目录
    if [[ ! -d "${log_dir}" ]]; then
        mkdir -p "${log_dir}"
    fi

    # 初始化日志文件
    {
        echo "=============================================================================="
        echo "  MacClaw Install - 安装日志"
        echo "=============================================================================="
        echo "  开始时间: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "  用户: ${USER}"
        echo "  主机: $(hostname)"
        echo "  系统: $(sw_vers -productVersion) $(uname -m)"
        echo "=============================================================================="
        echo ""
    } > "${LOG_FILE}"
}

# 关闭日志系统
close_log() {
    {
        echo ""
        echo "=============================================================================="
        echo "  日志结束时间: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "=============================================================================="
    } >> "${LOG_FILE}"
}

# 写入日志到文件
_log_write() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    echo "[${timestamp}] [${level}] ${message}" >> "${LOG_FILE}"
}

# DEBUG 级别日志
log_debug() {
    if [[ ${CURRENT_LOG_LEVEL} -le ${LOG_LEVEL_DEBUG} ]]; then
        local message="$*"
        echo -e "${COLOR_GRAY}[DEBUG]${COLOR_NC} ${ICON_DEBUG} ${message}"
        _log_write "DEBUG" "${message}"
    fi
}

# INFO 级别日志
log_info() {
    if [[ ${CURRENT_LOG_LEVEL} -le ${LOG_LEVEL_INFO} ]]; then
        local message="$*"
        echo -e "${COLOR_BLUE}[INFO]${COLOR_NC} ${ICON_INFO} ${message}"
        _log_write "INFO" "${message}"
    fi
}

# SUCCESS 级别日志
log_success() {
    if [[ ${CURRENT_LOG_LEVEL} -le ${LOG_LEVEL_SUCCESS} ]]; then
        local message="$*"
        echo -e "${COLOR_GREEN}[SUCCESS]${COLOR_NC} ${ICON_SUCCESS} ${message}"
        _log_write "SUCCESS" "${message}"
    fi
}

# WARNING 级别日志
log_warning() {
    if [[ ${CURRENT_LOG_LEVEL} -le ${LOG_LEVEL_WARNING} ]]; then
        local message="$*"
        echo -e "${COLOR_YELLOW}[WARNING]${COLOR_NC} ${ICON_WARNING} ${message}"
        _log_write "WARNING" "${message}"
    fi
}

# ERROR 级别日志
log_error() {
    if [[ ${CURRENT_LOG_LEVEL} -le ${LOG_LEVEL_ERROR} ]]; then
        local message="$*"
        echo -e "${COLOR_RED}[ERROR]${COLOR_NC} ${ICON_ERROR} ${message}" >&2
        _log_write "ERROR" "${message}"
    fi
}

# ==============================================================================
# 简洁模式日志函数（只在简洁和详细模式下显示）
# ==============================================================================

# 关键步骤（简洁模式专用）
log_step() {
    local step="$1"
    local detail="${2:-}"

    # 总是显示步骤信息（在所有非静默模式下）
    if [[ "${OUTPUT_MODE}" != "silent" ]]; then
        if [[ -n "${detail}" ]]; then
            echo -e "${COLOR_CYAN}▶${COLOR_NC} ${step} - ${detail}"
        else
            echo -e "${COLOR_CYAN}▶${COLOR_NC} ${step}"
        fi
    fi
    _log_write "STEP" "${step}: ${detail}"
}

# 进度信息（简洁模式专用）
log_progress() {
    local message="$*"

    # 只在详细模式下显示详细进度
    if [[ "${OUTPUT_MODE}" == "verbose" ]]; then
        echo -e "${COLOR_GRAY}  ${message}${COLOR_NC}"
    fi
    _log_write "PROGRESS" "${message}"
}

# 完成信息（简洁模式专用）
log_complete() {
    local message="$*"

    # 总是显示完成信息（在所有非静默模式下）
    if [[ "${OUTPUT_MODE}" != "silent" ]]; then
        echo -e "${COLOR_GREEN}✓${COLOR_NC} ${message}"
    fi
    _log_write "COMPLETE" "${message}"
}

# 跳过信息（简洁模式专用）
log_skip() {
    local message="$*"

    # 只在详细模式下显示跳过信息
    if [[ "${OUTPUT_MODE}" == "verbose" ]]; then
        echo -e "${COLOR_YELLOW}⊘${COLOR_NC} ${message}"
    fi
    _log_write "SKIP" "${message}"
}

# 空行
log_blank() {
    echo ""
    echo "" >> "${LOG_FILE}"
}

# 分隔线
log_separator() {
    local char="${1:-=}"
    local length="${2:-80}"
    local line=""
    for ((i=0; i<length; i++)); do
        line+="${char}"
    done
    echo "${line}"
    echo "${line}" >> "${LOG_FILE}"
}

# 标题
log_title() {
    local title="$*"
    local length=${#title}
    local padding=$(( (80 - length) / 2 ))
    local line=""
    for ((i=0; i<padding; i++)); do
        line+=" "
    done
    line+="${title}"
    echo ""
    echo -e "${COLOR_CYAN}${line}${COLOR_NC}"
    echo "${line}" >> "${LOG_FILE}"
}

# 段落标题
log_section() {
    local section="$*"
    echo ""
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_NC}"
    echo -e "${COLOR_CYAN}  ${section}${COLOR_NC}"
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_NC}"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >> "${LOG_FILE}"
    echo "  ${section}" >> "${LOG_FILE}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >> "${LOG_FILE}"
    echo "" >> "${LOG_FILE}"
}

# 列表项
log_list_item() {
    local item_status="$1"
    local message="$2"

    case "${item_status}" in
        success)
            echo -e "  ${COLOR_GREEN}${ICON_SUCCESS}${COLOR_NC} ${message}"
            echo "  [✓] ${message}" >> "${LOG_FILE}"
            ;;
        error)
            echo -e "  ${COLOR_RED}${ICON_ERROR}${COLOR_NC} ${message}"
            echo "  [✗] ${message}" >> "${LOG_FILE}"
            ;;
        warning)
            echo -e "  ${COLOR_YELLOW}${ICON_WARNING}${COLOR_NC} ${message}"
            echo "  [!] ${message}" >> "${LOG_FILE}"
            ;;
        info)
            echo -e "  ${COLOR_BLUE}${ICON_INFO}${COLOR_NC} ${message}"
            echo "  [i] ${message}" >> "${LOG_FILE}"
            ;;
        *)
            echo -e "  • ${message}"
            echo "  • ${message}" >> "${LOG_FILE}"
            ;;
    esac
}

# 进度显示
log_progress() {
    local current=$1
    local total=$2
    local message="$3"

    local percent=$(( current * 100 / total ))
    local filled=$(( percent / 5 ))
    local empty=$(( 20 - filled ))

    local bar="["
    for ((i=0; i<filled; i++)); do
        bar+="▓"
    done
    for ((i=0; i<empty; i++)); do
        bar+="░"
    done
    bar+="]"

    printf "\r${COLOR_BLUE}[PROGRESS]${COLOR_NC} ${bar} ${percent}%% (${current}/${total}) ${message}"
    echo "[PROGRESS] ${bar} ${percent}% (${current}/${total}) ${message}" >> "${LOG_FILE}"

    if [[ ${current} -eq ${total} ]]; then
        echo ""  # 换行
        echo "" >> "${LOG_FILE}"
    fi
}

# 显示日志文件路径
show_log_location() {
    log_info "日志文件: ${LOG_FILE}"
}

# 查看日志
view_log() {
    if [[ -f "${LOG_FILE}" ]]; then
        less "${LOG_FILE}"
    else
        log_warning "日志文件不存在"
    fi
}

# 清理日志
clear_log() {
    if [[ -f "${LOG_FILE}" ]]; then
        rm -f "${LOG_FILE}"
        log_success "日志文件已清理"
    fi
}

# ==============================================================================
# 导出函数
# ==============================================================================

export LOG_FILE
export -f init_log
export -f close_log
export -f log_debug
export -f log_info
export -f log_success
export -f log_warning
export -f log_error
export -f log_blank
export -f log_separator
export -f log_title
export -f log_section
export -f log_list_item
export -f log_progress
export -f show_log_location
export -f view_log
export -f clear_log
