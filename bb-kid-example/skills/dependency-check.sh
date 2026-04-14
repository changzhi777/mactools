#!/bin/bash
# BB小子依赖检查和安装模块 v2.0
# 兼容 bash 3.x+ 和 zsh

# ==============================================================================
# 依赖定义和配置
# ==============================================================================

# 核心依赖（必须）
CORE_DEPS="curl,jq,osascript"

# 可选依赖
OPTIONAL_DEPS="python3,perl,git"

# Homebrew 包映射
get_brew_package() {
    case "$1" in
        curl) echo "curl" ;;
        jq) echo "jq" ;;
        python3) echo "python@3" ;;
        perl) echo "perl" ;;
        git) echo "git" ;;
        *) echo "$1" ;;
    esac
}

# 最低版本要求
get_min_version() {
    case "$1" in
        jq) echo "1.5" ;;
        python3) echo "3.6" ;;
        git) echo "2.0" ;;
        *) echo "" ;;
    esac
}

# 依赖描述
get_dep_description() {
    case "$1" in
        curl) echo "命令行HTTP客户端" ;;
        jq) echo "JSON处理工具" ;;
        osascript) echo "macOS自动化工具" ;;
        python3) echo "Python解释器（路径规范化）" ;;
        perl) echo "Perl解释器（备选路径处理）" ;;
        git) echo "版本控制工具" ;;
        *) echo "未知工具" ;;
    esac
}

# ==============================================================================
# 颜色定义
# ==============================================================================

COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[1;33m'
COLOR_BLUE='\033[0;34m'
COLOR_CYAN='\033[0;36m'
COLOR_NC='\033[0m'

# ==============================================================================
# 版本比较函数
# ==============================================================================

# 比较版本号
version_compare() {
    local version="$1"
    local required="$2"

    # 移除 'v' 前缀和非数字字符
    version=$(echo "${version}" | sed 's/^v//; s/[^0-9.]*$//')
    required=$(echo "${required}" | sed 's/^v//; s/[^0-9.]*$//')

    # 分割版本号
    local i=1
    while true; do
        local v_part=$(echo "${version}" | cut -d. -f${i})
        local r_part=$(echo "${required}" | cut -d. -f${i})

        [[ -z "${v_part}" && -z "${r_part}" ]] && break

        v_part=${v_part:-0}
        r_part=${r_part:-0}

        if [[ ${v_part} -gt ${r_part} ]]; then
            return 0  # 版本足够
        elif [[ ${v_part} -lt ${r_part} ]]; then
            return 1  # 版本不足
        fi
        ((i++))
    done

    return 0  # 版本足够
}

# ==============================================================================
# 依赖检查函数
# ==============================================================================

# 检查命令是否存在
check_command() {
    command -v "$1" >/dev/null 2>&1
}

# 获取命令版本
get_version() {
    local cmd="$1"

    case "${cmd}" in
        curl)
            curl --version 2>/dev/null | head -1 | awk '{print $2}'
            ;;
        jq)
            jq --version 2>/dev/null | sed 's/jq-//'
            ;;
        python3)
            python3 --version 2>/dev/null | awk '{print $2}'
            ;;
        perl)
            perl --version 2>/dev/null | head -2 | tail -1 | awk '{print $9}' | sed 's/v//;s/(//'
            ;;
        git)
            git --version 2>/dev/null | awk '{print $3}'
            ;;
        osascript)
            echo "系统内置"
            ;;
        *)
            echo "未知"
            ;;
    esac
}

# 检查单个依赖
check_dependency() {
    local dep="$1"
    local is_optional="${2:-false}"

    local status="missing"
    local version=""
    local message=""

    if check_command "${dep}"; then
        version=$(get_version "${dep}")
        status="installed"

        # 检查版本要求
        local min_ver=$(get_min_version "${dep}")
        if [[ -n "${min_ver}" ]]; then
            if version_compare "${version}" "${min_ver}"; then
                status="ok"
                message="版本 ${version}"
            else
                status="outdated"
                message="版本 ${version} (需要 ${min_ver}+)"
            fi
        else
            message="版本 ${version}"
        fi
    else
        if ${is_optional}; then
            status="optional_missing"
        else
            status="required_missing"
        fi
        message="未安装"
    fi

    echo "${status}|${version}|${message}"
}

# ==============================================================================
# 依赖安装函数
# ==============================================================================

# 安装Homebrew（如果未安装）
install_homebrew() {
    if ! check_command brew; then
        echo -e "${COLOR_YELLOW}📦 Homebrew 未安装，正在安装...${COLOR_NC}"

        if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
            echo -e "${COLOR_GREEN}✅ Homebrew 安装成功${COLOR_NC}"

            # 设置 PATH
            if [[ -f "/opt/homebrew/bin/brew" ]]; then
                export PATH="/opt/homebrew/bin:${PATH}"
            elif [[ -f "/usr/local/bin/brew" ]]; then
                export PATH="/usr/local/bin:${PATH}"
            fi

            return 0
        else
            echo -e "${COLOR_RED}❌ Homebrew 安装失败${COLOR_NC}"
            return 1
        fi
    else
        echo -e "${COLOR_GREEN}✅ Homebrew 已安装${COLOR_NC}"
        return 0
    fi
}

# 安装单个依赖
install_dependency() {
    local dep="$1"

    echo -e "${COLOR_CYAN}📦 正在安装 ${dep}...${COLOR_NC}"

    # 优先使用 Homebrew
    if check_command brew; then
        local package=$(get_brew_package "${dep}")

        if brew install "${package}" 2>&1; then
            echo -e "${COLOR_GREEN}✅ ${dep} 安装成功${COLOR_NC}"
            return 0
        else
            echo -e "${COLOR_RED}❌ ${dep} 安装失败${COLOR_NC}"
            return 1
        fi
    else
        echo -e "${COLOR_YELLOW}⚠️  Homebrew 未安装，请手动安装 ${dep}${COLOR_NC}"
        return 1
    fi
}

# ==============================================================================
# 依赖状态报告
# ==============================================================================

# 显示依赖状态
show_dependency_status() {
    local dep="$1"
    local status_info="$2"
    local is_optional="${3:-false}"

    IFS='|' read -r status version message <<< "${status_info}"
    local description=$(get_dep_description "${dep}")

    case "${status}" in
        ok)
            echo -e "  ${COLOR_GREEN}✓${COLOR_NC} ${dep}: ${message}"
            ;;
        installed)
            echo -e "  ${COLOR_GREEN}✓${COLOR_NC} ${dep}: ${message}"
            ;;
        outdated)
            echo -e "  ${COLOR_YELLOW}⚠️${COLOR_NC} ${dep}: ${message}"
            ;;
        optional_missing)
            echo -e "  ${COLOR_BLUE}○${COLOR_NC} ${dep}: ${message} (可选)"
            ;;
        required_missing)
            echo -e "  ${COLOR_RED}✗${COLOR_NC} ${dep}: ${message} ${COLOR_RED}[必需]${COLOR_NC}"
            ;;
        *)
            echo -e "  ${COLOR_RED}?${COLOR_NC} ${dep}: 未知状态"
            ;;
    esac
}

# 生成完整依赖报告
generate_dependency_report() {
    echo -e "${COLOR_CYAN}📋 BB小子 依赖状态报告${COLOR_NC}"
    echo "========================"
    echo ""

    # 检查核心依赖
    echo -e "${COLOR_BLUE}核心依赖（必需）：${COLOR_NC}"
    local core_ok=true
    local core_missing=0

    IFS=',' read -ra DEPS_ARRAY <<< "${CORE_DEPS}"
    for dep in "${DEPS_ARRAY[@]}"; do
        local status_info=$(check_dependency "${dep}" false)
        show_dependency_status "${dep}" "${status_info}" false

        IFS='|' read -r status version message <<< "${status_info}"
        if [[ "${status}" == "required_missing" ]]; then
            core_ok=false
            ((core_missing++))
        fi
    done

    echo ""

    # 检查可选依赖
    echo -e "${COLOR_BLUE}可选依赖（增强功能）：${COLOR_NC}"

    IFS=',' read -ra OPT_DEPS_ARRAY <<< "${OPTIONAL_DEPS}"
    for dep in "${OPT_DEPS_ARRAY[@]}"; do
        local status_info=$(check_dependency "${dep}" true)
        show_dependency_status "${dep}" "${status_info}" true
    done

    echo ""

    # 系统信息
    echo -e "${COLOR_BLUE}系统信息：${COLOR_NC}"
    echo "  操作系统: $(sw_vers -productName 2>/dev/null || echo "Unknown")"
    echo "  系统版本: $(sw_vers -productVersion 2>/dev/null || echo "Unknown")"
    echo "  架构: $(uname -m)"
    echo "  Shell: ${SHELL}"
    echo ""

    # 总结
    if ${core_ok}; then
        echo -e "${COLOR_GREEN}✅ 所有核心依赖已满足${COLOR_NC}"
        return 0
    else
        echo -e "${COLOR_RED}❌ 缺少 ${core_missing} 个核心依赖${COLOR_NC}"
        return 1
    fi
}

# ==============================================================================
# 自动修复依赖
# ==============================================================================

# 自动安装缺失依赖
auto_fix_dependencies() {
    echo -e "${COLOR_CYAN}🔧 自动修复依赖${COLOR_NC}"
    echo "=================="
    echo ""

    local fixed_count=0
    local failed_count=0

    # 确保Homebrew已安装
    if ! install_homebrew; then
        echo -e "${COLOR_RED}❌ 无法安装 Homebrew，手动修复失败${COLOR_NC}"
        return 1
    fi

    echo ""

    # 修复核心依赖
    IFS=',' read -ra DEPS_ARRAY <<< "${CORE_DEPS}"
    for dep in "${DEPS_ARRAY[@]}"; do
        local status_info=$(check_dependency "${dep}" false)
        IFS='|' read -r status version message <<< "${status_info}"

        if [[ "${status}" == "required_missing" ]] || [[ "${status}" == "outdated" ]]; then
            if install_dependency "${dep}"; then
                ((fixed_count++))
            else
                ((failed_count++))
            fi
        fi
    done

    echo ""

    # 尝试修复可选依赖
    IFS=',' read -ra OPT_DEPS_ARRAY <<< "${OPTIONAL_DEPS}"
    for dep in "${OPT_DEPS_ARRAY[@]}"; do
        local status_info=$(check_dependency "${dep}" true)
        IFS='|' read -r status version message <<< "${status_info}"

        if [[ "${status}" == "optional_missing" ]] || [[ "${status}" == "outdated" ]]; then
            echo -e "${COLOR_BLUE}💡 尝试安装可选依赖: ${dep}${COLOR_NC}"
            if install_dependency "${dep}"; then
                ((fixed_count++))
            else
                ((failed_count++))
            fi
        fi
    done

    echo ""
    echo -e "${COLOR_CYAN}修复结果：${COLOR_NC}"
    echo "  成功: ${fixed_count}"
    echo "  失败: ${failed_count}"
    echo ""

    if [[ ${fixed_count} -gt 0 ]]; then
        echo -e "${COLOR_GREEN}✅ 依赖修复完成${COLOR_NC}"
        return 0
    else
        echo -e "${COLOR_YELLOW}⚠️  没有修复任何依赖${COLOR_NC}"
        return 1
    fi
}

# ==============================================================================
# 快速检查（用于脚本启动）
# ==============================================================================

# 快速检查核心依赖
quick_check() {
    local missing=0

    IFS=',' read -ra DEPS_ARRAY <<< "${CORE_DEPS}"
    for dep in "${DEPS_ARRAY[@]}"; do
        if ! check_command "${dep}"; then
            ((missing++))
        fi
    done

    return ${missing}
}

# 显示快速检查结果
show_quick_check_result() {
    if quick_check; then
        echo -e "${COLOR_GREEN}✅ 所有核心依赖可用${COLOR_NC}"
        return 0
    else
        local missing=$?
        echo -e "${COLOR_YELLOW}⚠️  缺少 ${missing} 个核心依赖${COLOR_NC}"
        echo "运行 'bash $0 check' 查看详情"
        return 1
    fi
}

# ==============================================================================
# 主函数
# ==============================================================================

main() {
    local action="${1:-check}"

    case "${action}" in
        check)
            generate_dependency_report
            ;;
        fix)
            auto_fix_dependencies
            echo ""
            echo "重新检查依赖状态..."
            echo ""
            generate_dependency_report
            ;;
        quick)
            show_quick_check_result
            ;;
        help|--help|-h)
            echo "BB小子依赖检查工具"
            echo ""
            echo "用法: $0 [check|fix|quick]"
            echo ""
            echo "命令:"
            echo "  check  - 显示完整依赖报告"
            echo "  fix    - 自动安装缺失依赖"
            echo "  quick  - 快速检查核心依赖"
            echo ""
            echo "示例:"
            echo "  $0 check    # 查看依赖状态"
            echo "  $0 fix      # 自动修复依赖"
            echo "  $0 quick    # 快速检查"
            ;;
        *)
            echo "未知命令: ${action}"
            echo "使用 '$0 help' 查看帮助"
            exit 1
            ;;
    esac
}

# 如果直接运行脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
