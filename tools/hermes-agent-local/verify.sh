#!/bin/bash
#
# Hermes Agent 安装验证脚本
#
# 作者: 外星动物（常智）
# 组织: IoTchange
# 邮箱: 14455975@qq.com
# 版权: Copyright (C) 2026 IoTchange - All Rights Reserved
#
# 描述: 验证 Hermes Agent 安装是否成功
#

set -e

# ============================================================================
# 脚本信息
# ============================================================================

VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ============================================================================
# 配置参数
# ============================================================================

HERMES_HOME="${HOME}/.hermes"
INSTALL_DIR="${HERMES_INSTALL_DIR:-${HERMES_HOME}/hermes-agent}"
BIN_DIR="${HOME}/.local/bin"

# 验证模式
VERIFY_MODE="${1:-all}"

# ============================================================================
# 加载功能模块
# ============================================================================

# shellcheck source=lib/logger.sh
source "${SCRIPT_DIR}/lib/logger.sh"
# shellcheck source=lib/detector.sh
source "${SCRIPT_DIR}/lib/detector.sh"

# ============================================================================
# 显示验证结果
# ============================================================================

print_result() {
    local status="$1"
    local message="$2"
    local details="${3:-}"

    if [[ "$status" == "ok" ]]; then
        echo -e "${COLOR_GREEN}✓${COLOR_RESET} ${message}"
        if [[ -n "$details" ]]; then
            echo -e "  ${COLOR_GRAY}${details}${COLOR_RESET}"
        fi
    elif [[ "$status" == "fail" ]]; then
        echo -e "${COLOR_RED}✗${COLOR_RESET} ${message}"
        if [[ -n "$details" ]]; then
            echo -e "  ${COLOR_RED}${details}${COLOR_RESET}"
        fi
    elif [[ "$status" == "warn" ]]; then
        echo -e "${COLOR_YELLOW}⚠${COLOR_RESET} ${message}"
        if [[ -n "$details" ]]; then
            echo -e "  ${COLOR_GRAY}${details}${COLOR_RESET}"
        fi
    fi
}

# ============================================================================
# 环境验证
# ============================================================================

verify_environment() {
    log_step "环境验证"

    local errors=0

    # 检查操作系统
    echo ""
    echo "操作系统："
    DETECTED_OS="$(uname -s)"
    DETECTED_ARCH="$(uname -m)"
    print_result "ok" "$DETECTED_OS $DETECTED_ARCH"

    # 检查 Python
    echo ""
    echo "Python 环境："
    if command -v python3 &> /dev/null; then
        local py_version=$(python3 --version 2>&1 | awk '{print $2}')
        print_result "ok" "Python $py_version"
    else
        print_result "fail" "Python 未安装"
        ((errors++))
    fi

    # 检查 uv
    echo ""
    echo "包管理器："
    if command -v uv &> /dev/null; then
        local uv_version=$(uv --version 2>&1 | awk '{print $2}')
        print_result "ok" "uv $uv_version"
    else
        print_result "warn" "uv 未安装（可选）"
    fi

    # 检查 Git
    if command -v git &> /dev/null; then
        local git_version=$(git --version 2>&1 | awk '{print $3}')
        print_result "ok" "Git $git_version"
    else
        print_result "warn" "Git 未安装（可选）"
    fi

    echo ""
    return $errors
}

# ============================================================================
# 安装验证
# ============================================================================

verify_installation() {
    log_step "安装验证"

    local errors=0

    # 检查安装目录
    echo ""
    echo "安装目录："
    if [ -d "$INSTALL_DIR" ]; then
        print_result "ok" "安装目录存在" "$INSTALL_DIR"

        # 检查关键文件
        if [ -f "$INSTALL_DIR/pyproject.toml" ]; then
            print_result "ok" "项目配置文件"
        else
            print_result "fail" "缺少 pyproject.toml"
            ((errors++))
        fi
    else
        print_result "fail" "安装目录不存在" "$INSTALL_DIR"
        ((errors++))
    fi

    # 检查虚拟环境
    echo ""
    echo "虚拟环境："
    if [ -d "$INSTALL_DIR/.venv" ]; then
        print_result "ok" "虚拟环境已创建"

        # 检查 Python 版本
        if [ -x "$INSTALL_DIR/.venv/bin/python" ]; then
            local venv_python_version=$("$INSTALL_DIR/.venv/bin/python" --version 2>&1)
            print_result "ok" "虚拟环境 Python" "$venv_python_version"
        fi
    else
        print_result "fail" "虚拟环境不存在"
        ((errors++))
    fi

    # 检查 hermes 命令
    echo ""
    echo "hermes 命令："
    if [ -L "$BIN_DIR/hermes" ]; then
        local link_target=$(readlink "$BIN_DIR/hermes")
        print_result "ok" "符号链接存在" "→ $link_target"

        # 检查是否可执行
        if [ -x "$BIN_DIR/hermes" ]; then
            print_result "ok" "hermes 可执行"
        else
            print_result "fail" "hermes 不可执行"
            ((errors++))
        fi
    else
        print_result "fail" "符号链接不存在" "$BIN_DIR/hermes"
        ((errors++))
    fi

    echo ""
    return $errors
}

# ============================================================================
# 功能验证
# ============================================================================

verify_functionality() {
    log_step "功能验证"

    local errors=0

    # 检查 hermes 命令是否可用
    echo ""
    echo "基本功能："

    if command -v hermes &> /dev/null; then
        # 检查版本
        local hermes_version=$(hermes --version 2>&1 || echo "unknown")
        if [[ "$hermes_version" != "unknown" ]]; then
            print_result "ok" "hermes --version" "$hermes_version"
        else
            print_result "warn" "无法获取版本信息"
        fi

        # 检查帮助命令
        if hermes --help &> /dev/null; then
            print_result "ok" "hermes --help"
        else
            print_result "fail" "帮助命令失败"
            ((errors++))
        fi

        # 检查配置目录
        echo ""
        echo "配置目录："
        if [ -d "$HERMES_HOME/config" ]; then
            print_result "ok" "配置目录存在" "$HERMES_HOME/config"

            # 检查配置文件
            if [ -f "$HERMES_HOME/config/SOUL.md" ]; then
                print_result "ok" "SOUL.md 存在"
            else
                print_result "warn" "SOUL.md 不存在（首次运行时会创建）"
            fi
        else
            print_result "warn" "配置目录不存在（首次运行时会创建）"
        fi

    else
        print_result "fail" "hermes 命令不可用"
        ((errors++))
    fi

    echo ""
    return $errors
}

# ============================================================================
# 完整验证
# ============================================================================

verify_all() {
    local total_errors=0

    log_separator 60 "="
    echo -e "${COLOR_BOLD}${COLOR_CYAN}Hermes Agent 安装验证${COLOR_RESET}"
    log_separator 60 "="
    echo ""

    # 根据模式执行验证
    case "$VERIFY_MODE" in
        env)
            verify_environment || ((total_errors+=$?))
            ;;
        install)
            verify_installation || ((total_errors+=$?))
            ;;
        function)
            verify_functionality || ((total_errors+=$?))
            ;;
        all)
            verify_environment || ((total_errors+=$?))
            verify_installation || ((total_errors+=$?))
            verify_functionality || ((total_errors+=$?))
            ;;
        *)
            log_error "无效的验证模式: $VERIFY_MODE"
            echo ""
            echo "可用模式："
            echo "  all       - 完整验证（默认）"
            echo "  env       - 仅验证环境"
            echo "  install   - 仅验证安装"
            echo "  function  - 仅验证功能"
            exit 1
            ;;
    esac

    # 总结
    echo ""
    log_separator 60 "="

    if [[ $total_errors -eq 0 ]]; then
        echo -e "${COLOR_BOLD}${COLOR_GREEN}✓ 所有验证通过${COLOR_RESET}"
        log_separator 60 "="
        echo ""
        return 0
    else
        echo -e "${COLOR_BOLD}${COLOR_RED}✗ 发现 $total_errors 个问题${COLOR_RESET}"
        log_separator 60 "="
        echo ""
        return 1
    fi
}

# ============================================================================
# 主程序入口
# ============================================================================

main() {
    verify_all
}

# 运行主程序
main "$@"
