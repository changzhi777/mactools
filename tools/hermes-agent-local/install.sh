#!/bin/bash
#
# Hermes Agent 本地安装脚本
#
# 作者: 外星动物（常智）
# 组织: IoTchange
# 邮箱: 14455975@qq.com
# 版权: Copyright (C) 2026 IoTchange - All Rights Reserved
#
# 描述: Hermes Agent 本地安装主脚本（macOS/Linux/WSL2）
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

# 仓库配置
REPO_URL="${HERMES_REPO_URL:-https://github.com/NousResearch/hermes-agent.git}"
REPO_BRANCH="${HERMES_REPO_BRANCH:-main}"

# 安装目录
HERMES_HOME="${HOME}/.hermes"
INSTALL_DIR="${HERMES_INSTALL_DIR:-${HERMES_HOME}/hermes-agent}"
BIN_DIR="${HOME}/.local/bin"

# Python 配置
PYTHON_MIN_VERSION="3.11"
PYTHON_VERSION="${HERMES_PYTHON_VERSION:-3.11}"

# 选项
USE_VENV=true
RUN_SETUP=true
SKIP_DEPS=false
VERBOSE=false

# ============================================================================
# 加载功能模块
# ============================================================================

# shellcheck source=lib/logger.sh
source "${SCRIPT_DIR}/lib/logger.sh"
# shellcheck source=lib/detector.sh
source "${SCRIPT_DIR}/lib/detector.sh"
# shellcheck source=lib/validator.sh
source "${SCRIPT_DIR}/lib/validator.sh"
# shellcheck source=lib/utils.sh
source "${SCRIPT_DIR}/lib/utils.sh"

# ============================================================================
# 显示欢迎信息
# ============================================================================

show_welcome() {
    clear
    echo ""
    log_separator 60 "="
    echo -e "${COLOR_BOLD}${COLOR_CYAN}            ⚕  Hermes Agent 本地安装器${COLOR_RESET}"
    echo -e "${COLOR_BOLD}${COLOR_CYAN}               版本: ${VERSION}${COLOR_RESET}"
    log_separator 60 "="
    echo ""
    echo -e "${COLOR_GRAY}Hermes Agent - Nous Research 开发的开源 AI Agent${COLOR_RESET}"
    echo ""
    echo -e "${COLOR_GRAY}作者: 外星动物（常智）${COLOR_RESET}"
    echo -e "${COLOR_GRAY}组织: IoTchange${COLOR_RESET}"
    echo -e "${COLOR_GRAY}邮箱: 14455975@qq.com${COLOR_RESET}"
    echo -e "${COLOR_GRAY}版权: Copyright (C) 2026 IoTchange - All Rights Reserved${COLOR_RESET}"
    echo ""
    log_separator 60 "="
    echo ""
}

# ============================================================================
# 解析命令行参数
# ============================================================================

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --no-venv)
                USE_VENV=false
                shift
                ;;
            --skip-setup)
                RUN_SETUP=false
                shift
                ;;
            --skip-deps)
                SKIP_DEPS=true
                shift
                ;;
            --branch)
                REPO_BRANCH="$2"
                shift 2
                ;;
            --dir)
                INSTALL_DIR="$2"
                shift 2
                ;;
            --verbose)
                VERBOSE=true
                export DEBUG=1
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "未知选项: $1"
                echo "使用 -h 或 --help 查看帮助"
                exit 1
                ;;
        esac
    done
}

# ============================================================================
# 显示帮助信息
# ============================================================================

show_help() {
    cat << EOF
Hermes Agent 本地安装器 v${VERSION}

用法: $0 [选项]

选项:
  --no-venv      不创建虚拟环境（使用系统 Python）
  --skip-setup   跳过交互式配置向导
  --skip-deps    跳过依赖检查（不推荐）
  --branch NAME  指定 Git 分支（默认: main）
  --dir PATH     指定安装目录（默认: ~/.hermes/hermes-agent）
  --verbose      显示详细输出
  -h, --help     显示此帮助信息

示例:
  $0                          # 默认安装
  $0 --branch develop         # 安装开发分支
  $0 --skip-setup --verbose   # 跳过向导，详细输出

更多信息请访问: https://github.com/NousResearch/hermes-agent
EOF
}

# ============================================================================
# 检查是否为 Termux
# ============================================================================

is_termux() {
    [ -n "${TERMUX_VERSION:-}" ] || [[ "${PREFIX:-}" == *"com.termux/files/usr"* ]]
}

# ============================================================================
# 安装 uv 包管理器
# ============================================================================

install_uv() {
    if is_termux; then
        log_info "Termux 环境 - 使用 Python venv + pip"
        UV_CMD=""
        return 0
    fi

    log_substep "检查 uv 包管理器"

    # 检查 uv 是否已安装
    if command -v uv &> /dev/null; then
        UV_CMD="uv"
        UV_VERSION=$(uv --version 2>/dev/null)
        log_success "uv 已安装: $UV_VERSION"
        return 0
    fi

    # 检查 ~/.local/bin
    if [ -x "$HOME/.local/bin/uv" ]; then
        UV_CMD="$HOME/.local/bin/uv"
        UV_VERSION=$($UV_CMD --version 2>/dev/null)
        log_success "uv 已安装: $UV_VERSION"
        return 0
    fi

    # 安装 uv
    log_info "正在安装 uv 包管理器..."
    if curl -LsSf https://astral.sh/uv/install.sh | sh 2>/dev/null; then
        if [ -x "$HOME/.local/bin/uv" ]; then
            UV_CMD="$HOME/.local/bin/uv"
        elif command -v uv &> /dev/null; then
            UV_CMD="uv"
        else
            log_error "uv 安装失败"
            log_info "请手动安装: https://docs.astral.sh/uv/getting-started/installation/"
            exit 1
        fi
        UV_VERSION=$($UV_CMD --version 2>/dev/null)
        log_success "uv 安装成功: $UV_VERSION"
    else
        log_error "uv 安装失败"
        exit 1
    fi
}

# ============================================================================
# 检查并安装 Python
# ============================================================================

check_python() {
    log_substep "检查 Python 环境"

    if is_termux; then
        if command -v python &> /dev/null; then
            PYTHON_PATH="$(command -v python)"
            PYTHON_VERSION=$($PYTHON_PATH --version 2>&1 | awk '{print $2}')
            log_success "Python 已安装: $PYTHON_VERSION"
            return 0
        fi

        log_info "正在通过 pkg 安装 Python..."
        pkg install -y python > /dev/null
        PYTHON_PATH="$(command -v python)"
        PYTHON_VERSION=$($PYTHON_PATH --version 2>&1 | awk '{print $2}')
        log_success "Python 安装成功: $PYTHON_VERSION"
        return 0
    fi

    # 使用 uv 管理 Python
    if $UV_CMD python find "$PYTHON_VERSION" &> /dev/null; then
        PYTHON_PATH=$($UV_CMD python find "$PYTHON_VERSION")
        PYTHON_VERSION=$($PYTHON_PATH --version 2>&1 | awk '{print $2}')
        log_success "Python 已安装: $PYTHON_VERSION"
        return 0
    fi

    # 安装 Python
    log_info "正在通过 uv 安装 Python $PYTHON_VERSION..."
    if $UV_CMD python install "$PYTHON_VERSION"; then
        PYTHON_PATH=$($UV_CMD python find "$PYTHON_VERSION")
        PYTHON_VERSION=$($PYTHON_PATH --version 2>&1 | awk '{print $2}')
        log_success "Python 安装成功: $PYTHON_VERSION"
    else
        log_error "Python 安装失败"
        log_info "请手动安装 Python $PYTHON_VERSION 后重试"
        exit 1
    fi
}

# ============================================================================
# 检查并安装 Git
# ============================================================================

check_git() {
    log_substep "检查 Git"

    if command -v git &> /dev/null; then
        GIT_VERSION=$(git --version | awk '{print $3}')
        log_success "Git 已安装: $GIT_VERSION"
        return 0
    fi

    log_error "Git 未安装"

    if is_termux; then
        log_info "正在通过 pkg 安装 Git..."
        pkg install -y git > /dev/null
        if command -v git &> /dev/null; then
            GIT_VERSION=$(git --version | awk '{print $3}')
            log_success "Git 安装成功: $GIT_VERSION"
            return 0
        fi
    fi

    log_info "请安装 Git："
    case "$DETECTED_OS" in
        Darwin*)
            echo "  brew install git"
            echo "  或: xcode-select --install"
            ;;
        Linux*)
            echo "  sudo apt install git   # Debian/Ubuntu"
            echo "  sudo yum install git   # CentOS/RHEL"
            echo "  sudo dnf install git   # Fedora"
            ;;
    esac

    exit 1
}

# ============================================================================
# 克隆仓库
# ============================================================================

clone_repository() {
    log_step "克隆 Hermes Agent 仓库"

    # 如果目录已存在，询问是否更新
    if [ -d "$INSTALL_DIR" ]; then
        if ask_yes_no "安装目录已存在，是否更新？"; then
            log_info "更新现有安装..."

            if ! cd "$INSTALL_DIR"; then
                log_error "无法进入安装目录: $INSTALL_DIR"
                exit 1
            fi

            if ! git fetch origin; then
                log_error "Git fetch 失败"
                exit 1
            fi

            if ! git checkout "$REPO_BRANCH"; then
                log_error "Git checkout 失败: $REPO_BRANCH"
                exit 1
            fi

            if ! git pull origin "$REPO_BRANCH"; then
                log_error "Git pull 失败"
                exit 1
            fi

            log_success "仓库更新成功"
        else
            log_warning "跳过仓库克隆"
        fi
        return 0
    fi

    # 克隆仓库
    log_info "正在克隆仓库: $REPO_URL"
    log_info "分支: $REPO_BRANCH"
    log_info "目标目录: $INSTALL_DIR"

    if ! git clone -b "$REPO_BRANCH" "$REPO_URL" "$INSTALL_DIR"; then
        log_error "仓库克隆失败"
        log_info "请检查网络连接和仓库地址"
        exit 1
    fi

    log_success "仓库克隆成功"

    if ! cd "$INSTALL_DIR"; then
        log_error "无法进入安装目录: $INSTALL_DIR"
        exit 1
    fi
}

# ============================================================================
# 安装 Python 依赖
# ============================================================================

install_python_packages() {
    log_step "安装 Python 依赖"

    if ! cd "$INSTALL_DIR"; then
        log_error "无法进入安装目录: $INSTALL_DIR"
        exit 1
    fi

    if is_termux; then
        # Termux 使用标准 venv
        log_info "创建虚拟环境..."
        if ! python -m venv .venv; then
            log_error "虚拟环境创建失败"
            exit 1
        fi

        if ! source .venv/bin/activate; then
            log_error "虚拟环境激活失败"
            exit 1
        fi

        log_info "安装依赖包..."
        if ! pip install -e .[cli]; then
            log_error "依赖包安装失败"
            exit 1
        fi
    else
        # 使用 uv 安装
        log_info "使用 uv 安装依赖..."
        if ! $UV_CMD sync --extra cli; then
            log_error "依赖安装失败"
            log_info "请检查网络连接和 Python 版本"
            exit 1
        fi
    fi

    log_success "依赖安装完成"
}

# ============================================================================
# 配置环境变量
# ============================================================================

setup_environment() {
    log_step "配置环境"

    # 确保 bin 目录存在
    if ! mkdir -p "$BIN_DIR"; then
        log_error "无法创建 bin 目录: $BIN_DIR"
        exit 1
    fi

    # 创建符号链接
    local hermes_link="$BIN_DIR/hermes"
    local hermes_target="$INSTALL_DIR/.venv/bin/hermes"

    # 检查目标是否存在
    if [ ! -e "$hermes_target" ]; then
        log_error "hermes 可执行文件不存在: $hermes_target"
        log_info "请检查虚拟环境是否正确安装"
        exit 1
    fi

    # 删除现有链接（如果存在）
    if [ -L "$hermes_link" ]; then
        log_info "删除现有符号链接"
        rm -f "$hermes_link"
    fi

    # 创建新链接
    if ! ln -sf "$hermes_target" "$hermes_link"; then
        log_error "符号链接创建失败"
        exit 1
    fi

    log_success "符号链接已创建: $hermes_link"

    # 检查 PATH
    if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
        log_warning "⚠️  $BIN_DIR 不在 PATH 中"
        echo ""
        log_info "请将以下内容添加到 ~/.bashrc 或 ~/.zshrc："
        echo ""
        echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
        echo ""
        log_info "然后执行: source ~/.bashrc (或 source ~/.zshrc)"
    else
        log_success "PATH 配置正确"
    fi
}

# ============================================================================
# 运行配置向导
# ============================================================================

run_setup_wizard() {
    if [ "$RUN_SETUP" = false ]; then
        return 0
    fi

    log_step "配置向导"

    echo ""
    log_info "Hermes Agent 配置向导将帮助您完成初始配置"
    echo ""

    if ask_yes_no "是否现在运行配置向导？"; then
        # 激活虚拟环境并运行 hermes setup
        if is_termux; then
            source "$INSTALL_DIR/.venv/bin/activate"
        else
            source "$INSTALL_DIR/.venv/bin/activate"
        fi

        if command -v hermes &> /dev/null; then
            hermes setup
            log_success "配置完成"
        else
            log_warning "hermes 命令不可用，跳过配置向导"
        fi
    else
        log_info "跳过配置向导"
        echo ""
        log_info "您可以稍后运行: hermes setup"
    fi
}

# ============================================================================
# 验证安装
# ============================================================================

verify_installation() {
    log_step "验证安装"

    local success=true

    # 检查目录
    if [ -d "$INSTALL_DIR" ]; then
        log_check "ok" "安装目录存在"
    else
        log_check "fail" "安装目录不存在"
        success=false
    fi

    # 检查虚拟环境
    if [ -d "$INSTALL_DIR/.venv" ]; then
        log_check "ok" "虚拟环境已创建"
    else
        log_check "fail" "虚拟环境不存在"
        success=false
    fi

    # 检查 hermes 命令
    if command -v hermes &> /dev/null; then
        local hermes_version=$(hermes --version 2>&1 || echo "unknown")
        log_check "ok" "hermes 命令可用 ($hermes_version)"
    else
        log_check "fail" "hermes 命令不可用"
        success=false
    fi

    echo ""

    if [ "$success" = true ]; then
        log_success "✅ 安装验证成功"
        return 0
    else
        log_error "❌ 安装验证失败"
        return 1
    fi
}

# ============================================================================
# 显示后续步骤
# ============================================================================

show_next_steps() {
    echo ""
    log_separator 60 "="
    echo -e "${COLOR_BOLD}${COLOR_GREEN}✓ 安装完成！${COLOR_RESET}"
    log_separator 60 "="
    echo ""
    echo -e "${COLOR_CYAN}快速开始：${COLOR_RESET}"
    echo ""
    echo "  1. 重新加载 shell 配置："
    echo "     ${COLOR_YELLOW}source ~/.bashrc${COLOR_RESET}   (或 ~/.zshrc)"
    echo ""
    echo "  2. 验证安装："
    echo "     ${COLOR_YELLOW}hermes --version${COLOR_RESET}"
    echo ""
    echo "  3. 启动交互式界面："
    echo "     ${COLOR_YELLOW}hermes${COLOR_RESET}"
    echo ""
    echo "  4. 运行配置向导（如果之前跳过）："
    echo "     ${COLOR_YELLOW}hermes setup${COLOR_RESET}"
    echo ""
    echo -e "${COLOR_CYAN}安装信息：${COLOR_RESET}"
    echo ""
    echo "  安装目录: ${INSTALL_DIR}"
    echo "  配置目录: ${HERMES_HOME}/config"
    echo "  数据目录: ${HERMES_HOME}/data"
    echo ""
    echo -e "${COLOR_CYAN}获取帮助：${COLOR_RESET}"
    echo ""
    echo "  hermes --help"
    echo "  hermes --help-all"
    echo ""
    echo -e "${COLOR_CYAN}更多信息：${COLOR_RESET}"
    echo ""
    echo "  GitHub: https://github.com/NousResearch/hermes-agent"
    echo "  文档: https://docs.nousresearch.com"
    echo ""
    log_separator 60 "="
    echo ""
    echo -e "${COLOR_GRAY}如有问题，请访问：${COLOR_RESET}"
    echo "  https://github.com/NousResearch/hermes-agent/issues"
    echo ""
}

# ============================================================================
# 主程序入口
# ============================================================================

main() {
    # 解析参数
    parse_arguments "$@"

    # 显示欢迎信息
    show_welcome

    # 环境检测
    if [ "$SKIP_DEPS" = false ]; then
        detect_environment
        echo ""

        # 安装依赖
        install_uv
        check_python
        check_git
        echo ""
    fi

    # 克隆仓库
    clone_repository
    echo ""

    # 安装 Python 依赖
    install_python_packages
    echo ""

    # 配置环境
    setup_environment
    echo ""

    # 运行配置向导
    run_setup_wizard
    echo ""

    # 验证安装
    verify_installation

    # 显示后续步骤
    show_next_steps
}

# 运行主程序
main "$@"
