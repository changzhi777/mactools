#!/usr/bin/env zsh
# ==============================================================================
# MacClaw Install - 核心工具函数模块
# ==============================================================================
#
# 功能说明：
#   - UI 显示函数（banner、菜单、表格）
#   - 用户输入函数（确认、选择、输入）
#   - 进度显示函数
#   - 文本处理函数
#
# 使用方法：
#   source "${LIB_DIR}/core/utils.zsh"
#   print_banner
#   confirm_action "确认？" && echo "已确认"
#   read_input "请输入" variable
#
# ==============================================================================

# ==============================================================================
# 颜色定义（已定义，这里重新导出）
# ==============================================================================

typeset -g COLOR_RED='\033[0;31m'
typeset -g COLOR_GREEN='\033[0;32m'
typeset -g COLOR_YELLOW='\033[1;33m'
typeset -g COLOR_BLUE='\033[0;34m'
typeset -g COLOR_CYAN='\033[0;36m'
typeset -g COLOR_MAGENTA='\033[0;35m'
typeset -g COLOR_GRAY='\033[0;90m'
typeset -g COLOR_WHITE='\033[1;37m'
typeset -g COLOR_NC='\033[0m' # No Color

# ==============================================================================
# UI 显示函数
# ==============================================================================

# 打印项目 Banner
print_banner() {
    clear
    cat << EOF
${COLOR_CYAN}
╔════════════════════════════════════════════════════════════╗
║                                                            ║
║       🦞 MacClaw Install - macOS 安装工具                  ║
║                                                            ║
║       一键安装 OpenClaw + oMLX 本地 AI 环境                ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝
${COLOR_NC}
EOF
}

# 打印版权信息
print_copyright() {
    cat << EOF
${COLOR_GRAY}
版本: 1.0.0
作者: 外星动物（常智）
组织: IoTchange
邮箱: 14455975@qq.com
项目: https://github.com/changzhi777/mactools
${COLOR_NC}
EOF
}

# 打印菜单
print_menu() {
    local title="$1"
    shift
    local options=("$@")

    echo ""
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_NC}"
    echo -e "${COLOR_CYAN}  ${title}${COLOR_NC}"
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_NC}"
    echo ""

    local i=1
    while [[ $i -le ${#options[@]} ]]; do
        local option="${options[$i]}"
        if [[ $i -eq ${#options[@]} ]]; then
            echo -e "  ${COLOR_GRAY}${option}${COLOR_NC}"
        else
            echo -e "  ${COLOR_WHITE}${option}${COLOR_NC}"
        fi
        ((i++))
    done

    echo ""
    echo -n -e "${COLOR_CYAN}请选择 [${COLOR_WHITE}0-${#options[@]}${COLOR_CYAN}]: ${COLOR_NC}"
}

# 打印分隔线
print_separator() {
    local char="${1:-=}"
    local length="${2:-80}"
    local line=""
    for ((i=0; i<length; i++)); do
        line+="${char}"
    done
    echo -e "${COLOR_CYAN}${line}${COLOR_NC}"
}

# 打印步骤状态
print_step() {
    local step="$1"
    local total="$2"
    local message="$3"
    local step_status="${4:-pending}"

    local step_num="(${step}/${total})"

    case "${step_status}" in
        pending)
            echo -e "${COLOR_CYAN}⏳${COLOR_NC} ${step_num} ${message}"
            ;;
        running)
            echo -e "${COLOR_BLUE}🔄${COLOR_NC} ${step_num} ${message}"
            ;;
        success)
            echo -e "${COLOR_GREEN}✅${COLOR_NC} ${step_num} ${message}"
            ;;
        warning)
            echo -e "${COLOR_YELLOW}⚠️${COLOR_NC} ${step_num} ${message}"
            ;;
        error)
            echo -e "${COLOR_RED}❌${COLOR_NC} ${step_num} ${message}"
            ;;
        *)
            echo -e "${COLOR_GRAY}•${COLOR_NC} ${step_num} ${message}"
            ;;
    esac
}

# ==============================================================================
# 用户输入函数
# ==============================================================================

# 确认操作
confirm_action() {
    local message="$1"
    local default="${2:-n}"

    echo -n -e "${COLOR_YELLOW}${message} [y/N]: ${COLOR_NC}"
    read -k1 choice
    echo ""

    case "${choice}" in
        y|Y)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# 读取用户输入
read_input() {
    local prompt="$1"
    local varname="$2"
    local default="${3:-}"

    if [[ -n "${default}" ]]; then
        echo -n -e "${COLOR_CYAN}${prompt} [${default}]: ${COLOR_NC}"
    else
        echo -n -e "${COLOR_CYAN}${prompt}: ${COLOR_NC}"
    fi

    read input

    if [[ -z "${input}" && -n "${default}" ]]; then
        eval "${varname}='${default}'"
    else
        eval "${varname}='${input}'"
    fi
}

# 选择菜单
read_choice() {
    local prompt="$1"
    local varname="$2"
    shift 2
    local options=("$@")

    echo ""
    local i=1
    for opt in "${options[@]}"; do
        echo -e "  ${COLOR_WHITE}[${i}]${COLOR_NC} ${opt}"
        ((i++))
    done
    echo ""

    local max=${#options[@]}
    echo -n -e "${COLOR_CYAN}${prompt} [1-${max}]: ${COLOR_NC}"
    read choice

    # 验证输入
    if [[ ! "${choice}" =~ ^[0-9]+$ ]] || [[ ${choice} -lt 1 ]] || [[ ${choice} -gt ${max} ]]; then
        echo -e "${COLOR_RED}无效选择${COLOR_NC}"
        return 1
    fi

    local selected="${options[$((choice-1))]}"
    eval "${varname}='${selected}'"
    return 0
}

# 多选菜单
read_multiple_choice() {
    local prompt="$1"
    local varname="$2"
    shift 2
    local options=("$@")

    echo ""
    local i=1
    for opt in "${options[@]}"; do
        echo -e "  ${COLOR_WHITE}[${i}]${COLOR_NC} ${opt}"
        ((i++))
    done
    echo -e "  ${COLOR_WHITE}[A]${COLOR_NC} 全选"
    echo -e "  ${COLOR_WHITE}[N]${COLOR_NC} 取消所有选择"
    echo ""
    echo -e "  ${COLOR_GRAY}提示: 可以输入多个数字，用空格分隔${COLOR_NC}"
    echo ""

    echo -n -e "${COLOR_CYAN}${prompt}: ${COLOR_NC}"
    read input

    local selected=()

    case "${input}" in
        a|A)
            # 全选
            selected=("${options[@]}")
            ;;
        n|N)
            # 不选
            selected=()
            ;;
        *)
            # 解析输入
            for num in ${=input}; do
                if [[ "${num}" =~ ^[0-9]+$ ]] && [[ ${num} -ge 1 ]] && [[ ${num} -le ${#options[@]} ]]; then
                    selected+=("${options[$((num-1))]}")
                fi
            done
            ;;
    esac

    # 返回选中的项（数组）
    eval "${varname}=('\${selected[@]}')"
}

# 等待按键
press_enter_continue() {
    echo ""
    echo -n -e "${COLOR_GRAY}按 Enter 继续...${COLOR_NC}"
    read
    echo ""
}

# ==============================================================================
# 进度显示函数
# ==============================================================================

# 显示进度条
show_progress_bar() {
    local current=$1
    local total=$2
    local width="${3:-40}"

    local percent=$(( current * 100 / total ))
    local filled=$(( width * current / total ))
    local empty=$(( width - filled ))

    echo -n "["
    for ((i=0; i<filled; i++)); do
        echo -n "▓"
    done
    for ((i=0; i<empty; i++)); do
        echo -n "░"
    done
    echo -n "] ${percent}%"
}

# 显示旋转加载动画
show_spinner() {
    local message="$1"
    local pid="$2"
    local delay=0.1

    local spinners=('|' '/' '-' '\')
    local i=0

    while kill -0 ${pid} 2>/dev/null; do
        i=$(( (i + 1) % 4 ))
        printf "\r${COLOR_BLUE}%s${COLOR_NC} ${message}" "${spinners[$i]}"
        sleep ${delay}
    done

    printf "\r"  # 清除 spinner
}

# ==============================================================================
# 文本处理函数
# ==============================================================================

# 文本截断
truncate_text() {
    local text="$1"
    local max_length="${2:-50}"

    if [[ ${#text} -gt ${max_length} ]]; then
        echo "${text:0:${max_length}}..."
    else
        echo "${text}"
    fi
}

# 文本居中
center_text() {
    local text="$1"
    local width="${2:-80}"

    local text_length=${#text}
    local padding=$(( (width - text_length) / 2 ))

    local spaces=""
    for ((i=0; i<padding; i++)); do
        spaces+=" "
    done

    echo "${spaces}${text}"
}

# 格式化字节大小
format_bytes() {
    local bytes=$1

    if [[ ${bytes} -lt 1024 ]]; then
        echo "${bytes} B"
    elif [[ ${bytes} -lt 1048576 ]]; then
        echo "$(( bytes / 1024 )) KB"
    elif [[ ${bytes} -lt 1073741824 ]]; then
        echo "$(( bytes / 1048576 )) MB"
    else
        echo "$(( bytes / 1073741824 )) GB"
    fi
}

# 格式化时间
format_duration() {
    local seconds=$1

    if [[ ${seconds} -lt 60 ]]; then
        echo "${seconds}秒"
    elif [[ ${seconds} -lt 3600 ]]; then
        echo "$(( seconds / 60 ))分$(( seconds % 60 ))秒"
    else
        echo "$(( seconds / 3600 ))小时$(( (seconds % 3600) / 60 ))分"
    fi
}

# ==============================================================================
# 系统信息函数
# ==============================================================================

# 获取系统信息
get_system_info() {
    echo "macOS $(sw_vers -productVersion) $(uname -m)"
}

# 获取内存大小
get_memory_size() {
    local bytes=$(sysctl -n hw.memsize)
    format_bytes ${bytes}
}

# 获取磁盘空间
get_disk_space() {
    local path="${1:-/}"
    df -h "${path}" | tail -1 | awk '{print $4}'
}

# ==============================================================================
# 导出函数
# ==============================================================================

export -f print_banner
export -f print_copyright
export -f print_menu
export -f print_separator
export -f print_step
export -f confirm_action
export -f read_input
export -f read_choice
export -f read_multiple_choice
export -f press_enter_continue
export -f show_progress_bar
export -f show_spinner
export -f truncate_text
export -f center_text
export -f format_bytes
export -f format_duration
export -f get_system_info
export -f get_memory_size
export -f get_disk_space
