#!/usr/bin/env zsh
# ==============================================================================
# MacClaw Install - 主入口脚本
# ==============================================================================
#
# 项目名称：MacClaw Install
# 文件名称：install.zsh
#
# 作者信息：
#   作者：外星动物（常智）
#   组织：IoTchange
#   邮箱：14455975@qq.com
#   GitHub：https://github.com/changzhi777
#
# 版本信息：
#   当前版本：1.0.0
#   发布日期：2026-04-12
#
# 版权声明：
#   Copyright (C) 2026 IoTchange - All Rights Reserved
#
# 功能说明：
#   一键安装 OpenClaw + oMLX 本地 AI 环境
#   支持 macOS 12+ 系统（兼容模式支持更低版本）
#
# 使用方法：
#   chmod +x install.zsh
#   ./install.zsh
#
# 命令行参数：
#   --auto       自动安装模式（无交互）
#   --silent     静默模式（最小输出）
#   --help       显示帮助信息
#
# ==============================================================================

# ==============================================================================
# Zsh 严格模式
# ==============================================================================

set -o EXTENDED_GLOB
set -o NULL_GLOB
set -o NOTIFY

# ==============================================================================
# 脚本目录
# ==============================================================================

# 获取脚本目录
SCRIPT_DIR="${0:A:h}"
LIB_DIR="${SCRIPT_DIR}/lib"
CONFIG_DIR="${SCRIPT_DIR}/config"

# ==============================================================================
# 一键安装自举机制（Bootstrap）
# ==============================================================================

# 检测是否在正确的目录下运行
if [[ ! -f "${LIB_DIR}/core/logger.zsh" ]]; then
    # 不在正确的目录，需要下载完整仓库
    REPO_URL="https://github.com/changzhi777/macclaw-installer.git"
    TEMP_DIR="${HOME}/.macclaw_installer_tmp"

    echo "🔄 检测到需要下载完整安装包..."
    echo "📦 临时目录：${TEMP_DIR}"

    # 删除旧的临时目录（如果存在）
    if [[ -d "${TEMP_DIR}" ]]; then
        echo "🧹 清理旧的临时文件..."
        rm -rf "${TEMP_DIR}"
    fi

    # 下载仓库
    echo "⬇️  正在下载 MacClaw Installer..."
    if command -v git &> /dev/null; then
        # 使用 git clone（更快，支持增量更新）
        git clone --depth 1 "${REPO_URL}" "${TEMP_DIR}" 2>/dev/null || {
            echo "❌ Git clone 失败，尝试使用 curl 下载..."
            bootstrap_fallback_curl
        }
    else
        # 使用 curl 下载（需要 git 不可用时）
        bootstrap_fallback_curl
    fi

    # 检查下载是否成功
    if [[ ! -f "${TEMP_DIR}/install.zsh" ]]; then
        echo "❌ 下载失败！请检查网络连接或手动下载："
        echo "   ${REPO_URL}"
        exit 1
    fi

    echo "✅ 下载完成！"
    echo ""

    # 切换到临时目录并重新执行脚本
    cd "${TEMP_DIR}"
    exec zsh install.zsh "$@"
fi

# ==============================================================================
# 辅助函数（备用下载方法）
# ==============================================================================

# 使用 curl 下载单个文件（备用方案）
bootstrap_fallback_curl() {
    mkdir -p "${TEMP_DIR}"

    # 下载主要文件
    echo "📥 下载核心文件..."

    # 下载 install.zsh
    curl -fsSL "https://raw.githubusercontent.com/changzhi777/macclaw-installer/main/install.zsh" -o "${TEMP_DIR}/install.zsh" || {
        echo "❌ 无法下载 install.zsh"
        exit 1
    }

    # 创建必要的目录结构
    mkdir -p "${TEMP_DIR}/lib/core"
    mkdir -p "${TEMP_DIR}/lib/parts"
    mkdir -p "${TEMP_DIR}/lib/sources"
    mkdir -p "${TEMP_DIR}/config"
    mkdir -p "${TEMP_DIR}/scripts"
    mkdir -p "${TEMP_DIR}/tests"

    # 下载核心模块
    local core_modules=(
        "logger.zsh"
        "utils.zsh"
        "detector.zsh"
        "validator.zsh"
        "error-handler.zsh"
    )

    for module in "${core_modules[@]}"; do
        echo "  📄 下载 ${module}..."
        curl -fsSL "https://raw.githubusercontent.com/changzhi777/macclaw-installer/main/lib/core/${module}" \
            -o "${TEMP_DIR}/lib/core/${module}" 2>/dev/null || echo "  ⚠️  警告：${module} 下载失败"
    done

    # 下载安装部分
    local part_modules=(
        "part1_env.zsh"
        "part2_compute.zsh"
        "part3_openclaw.zsh"
        "part4_test_plugins.zsh"
    )

    for module in "${part_modules[@]}"; do
        echo "  📄 下载 ${module}..."
        curl -fsSL "https://raw.githubusercontent.com/changzhi777/macclaw-installer/main/lib/parts/${module}" \
            -o "${TEMP_DIR}/lib/parts/${module}" 2>/dev/null || echo "  ⚠️  警告：${module} 下载失败"
    done

    # 下载配置文件
    local config_files=(
        "sources.conf"
        "versions.conf"
        "plugins.conf"
        "compute.conf"
    )

    for config in "${config_files[@]}"; do
        echo "  📄 下载 ${config}..."
        curl -fsSL "https://raw.githubusercontent.com/changzhi777/macclaw-installer/main/config/${config}" \
            -o "${TEMP_DIR}/config/${config}" 2>/dev/null || echo "  ⚠️  警告：${config} 下载失败"
    done

    # 下载国内源配置
    local source_modules=(
        "homebrew.zsh"
        "nodejs.zsh"
        "openclaw.zsh"
    )

    for module in "${source_modules[@]}"; do
        echo "  📄 下载 ${module}..."
        curl -fsSL "https://raw.githubusercontent.com/changzhi777/macclaw-installer/main/lib/sources/${module}" \
            -o "${TEMP_DIR}/lib/sources/${module}" 2>/dev/null || echo "  ⚠️  警告：${module} 下载失败"
    done

    echo "✅ 核心文件下载完成！"
}

# ==============================================================================
# 全局变量
# ==============================================================================

typeset -g VERSION="1.0.0"
typeset -g INSTALL_MODE="interactive"  # interactive, auto, silent

# 安装步骤
typeset -ga INSTALL_STEPS=(
    "part1_env"
    "part2_compute"
    "part3_openclaw"
    "part4_test_plugins"
)

# 步骤名称
typeset -gA STEP_NAMES=(
    part1_env       "环境配置"
    part2_compute   "算力配置"
    part3_openclaw  "OpenClaw 安装"
    part4_test_plugins "测试和插件"
)

# ==============================================================================
# 加载核心模块
# ==============================================================================

# 加载日志模块
if [[ -f "${LIB_DIR}/core/logger.zsh" ]]; then
    source "${LIB_DIR}/core/logger.zsh"
else
    echo "错误：找不到日志模块"
    exit 1
fi

# 加载工具函数模块
if [[ -f "${LIB_DIR}/core/utils.zsh" ]]; then
    source "${LIB_DIR}/core/utils.zsh"
else
    echo "错误：找不到工具函数模块"
    exit 1
fi

# 加载环境检测模块
if [[ -f "${LIB_DIR}/core/detector.zsh" ]]; then
    source "${LIB_DIR}/core/detector.zsh"
else
    echo "错误：找不到环境检测模块"
    exit 1
fi

# 加载错误处理模块
if [[ -f "${LIB_DIR}/core/error-handler.zsh" ]]; then
    source "${LIB_DIR}/core/error-handler.zsh"
else
    echo "错误：找不到错误处理模块"
    exit 1
fi

# ==============================================================================
# 命令行参数处理
# ==============================================================================

# 显示帮助信息
show_help() {
    cat << EOF
${COLOR_CYAN}MacClaw Install ${VERSION} - OpenClaw 本地 AI 环境安装工具${COLOR_NC}

${COLOR_WHITE}用法：${COLOR_NC}
  $0 [选项]

${COLOR_WHITE}选项：${COLOR_NC}
  --auto       自动安装模式（无交互）
  --silent     静默模式（只显示错误）
  --verbose    详细模式（显示所有日志）
  --help       显示此帮助信息

${COLOR_WHITE}示例：${COLOR_NC}
  $0              # 交互式安装（简洁输出）
  $0 --auto       # 自动安装（简洁输出）
  $0 --silent     # 静默安装（只显示错误）
  $0 --verbose    # 详细安装（显示所有日志）

${COLOR_WHITE}更多信息：${COLOR_NC}
  项目主页：https://github.com/changzhi777/macclaw-installer
  文档：https://github.com/changzhi777/macclaw-installer/blob/main/README.md

EOF
}

# 解析命令行参数
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --auto)
                INSTALL_MODE="auto"
                shift
                ;;
            --silent)
                INSTALL_MODE="silent"
                OUTPUT_MODE="silent"
                shift
                ;;
            --verbose)
                OUTPUT_MODE="verbose"
                CURRENT_LOG_LEVEL=${LOG_LEVEL_DEBUG}
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                echo "未知选项: $1"
                echo "使用 --help 查看帮助信息"
                exit 1
                ;;
        esac
    done
}

# ==============================================================================
# 菜单系统
# ==============================================================================

# 显示主菜单
show_main_menu() {
    clear
    print_banner
    print_copyright

    local options=(
        "1" "🚀 快速安装（推荐）"
        "2" "⚙️  自定义安装"
        "3" "📋 查看系统信息"
        "4" "🔧 高级选项"
        "5" "ℹ️  关于"
        "0" "🚪 退出"
    )

    print_menu "请选择安装模式" "${options[@]}"
    read -k1 choice
    echo ""

    case "${choice}" in
        1)
            quick_install
            ;;
        2)
            custom_install
            ;;
        3)
            show_system_info
            press_enter_continue
            show_main_menu
            ;;
        4)
            advanced_options
            ;;
        5)
            show_about
            press_enter_continue
            show_main_menu
            ;;
        0)
            log_info "退出安装"
            exit 0
            ;;
        *)
            log_error "无效选项"
            press_enter_continue
            show_main_menu
            ;;
    esac
}

# 快速安装
quick_install() {
    clear
    print_banner
    echo ""
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_NC}"
    echo -e "${COLOR_CYAN}  🚀 快速安装模式${COLOR_NC}"
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_NC}"
    echo ""

    echo "将自动安装以下组件："
    echo ""
    echo "  ✅ Homebrew（包管理器）"
    echo "  ✅ Node.js 20.x LTS"
    echo "  ✅ OpenClaw CLI"
    echo "  ✅ oMLX 推理引擎（Apple Silicon）"
    echo "  ✅ gemma-4-e4b-it-4bit AI 模型"
    echo "  ✅ 开发者工具、编程助手插件"
    echo ""
    echo "所有组件将从国内镜像源下载，速度更快！"
    echo ""

    if confirm_action "确认开始快速安装？"; then
        log_step "开始安装 OpenClaw + oMLX 本地 AI 环境"
        echo ""

        # 执行所有安装步骤
        run_all_steps

        log_complete "安装完成！"
        show_completion_info
    else
        echo "已取消安装"
    fi

    press_enter_continue
}

# 自定义安装
custom_install() {
    clear
    print_banner
    echo ""
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_NC}"
    echo -e "${COLOR_CYAN}  ⚙️  自定义安装模式${COLOR_NC}"
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_NC}"
    echo ""

    # TODO: 实现自定义安装菜单
    log_warning "自定义安装功能开发中..."
    press_enter_continue
    show_main_menu
}

# 显示系统信息
show_system_info() {
    clear
    print_banner
    echo ""
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_NC}"
    echo -e "${COLOR_CYAN}  📋 系统信息${COLOR_NC}"
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_NC}"
    echo ""

    echo -e "${COLOR_WHITE}操作系统：${COLOR_NC}"
    echo "  • macOS: $(sw_vers -productVersion) $(uname -m)"
    echo "  • 内核: $(uname -r)"
    echo ""

    echo -e "${COLOR_WHITE}硬件配置：${COLOR_NC}"
    echo "  • CPU: $(sysctl -n machdep.cpu.brand_string)"
    echo "  • 内存: $(format_bytes $(sysctl -n hw.memsize))"
    echo "  • 磁盘: $(get_disk_space)"
    echo ""

    echo -e "${COLOR_WHITE}已安装组件：${COLOR_NC}"
    if command -v brew >/dev/null 2>&1; then
        echo "  ${COLOR_GREEN}✅${COLOR_NC} Homebrew: $(brew --version | head -1)"
    else
        echo "  ${COLOR_GRAY}⏸️${COLOR_NC} Homebrew (未安装)"
    fi

    if command -v node >/dev/null 2>&1; then
        echo "  ${COLOR_GREEN}✅${COLOR_NC} Node.js: $(node --version)"
    else
        echo "  ${COLOR_GRAY}⏸️${COLOR_NC} Node.js (未安装)"
    fi

    if command -v openclaw >/dev/null 2>&1; then
        echo "  ${COLOR_GREEN}✅${COLOR_NC} OpenClaw: $(openclaw --version 2>/dev/null | head -1)"
    else
        echo "  ${COLOR_GRAY}⏸️${COLOR_NC} OpenClaw (未安装)"
    fi

    echo ""
}

# 高级选项
advanced_options() {
    clear
    print_banner
    echo ""
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_NC}"
    echo -e "${COLOR_CYAN}  🔧 高级选项${COLOR_NC}"
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_NC}"
    echo ""

    local options=(
        "1" "仅安装环境配置（第1部分）"
        "2" "仅安装算力配置（第2部分）"
        "3" "仅安装 OpenClaw（第3部分）"
        "4" "仅安装测试和插件（第4部分）"
        "5" "查看日志"
        "6" "清理缓存"
        "B" "返回主菜单"
    )

    print_menu "请选择选项" "${options[@]}"
    read -k1 choice
    echo ""

    case "${choice}" in
        1)
            run_step part1_env
            press_enter_continue
            advanced_options
            ;;
        2)
            run_step part2_compute
            press_enter_continue
            advanced_options
            ;;
        3)
            run_step part3_openclaw
            press_enter_continue
            advanced_options
            ;;
        4)
            run_step part4_test_plugins
            press_enter_continue
            advanced_options
            ;;
        5)
            view_log
            press_enter_continue
            advanced_options
            ;;
        6)
            clean_cache
            press_enter_continue
            advanced_options
            ;;
        b|B)
            show_main_menu
            ;;
        *)
            log_error "无效选项"
            press_enter_continue
            advanced_options
            ;;
    esac
}

# 显示关于信息
show_about() {
    clear
    print_banner
    echo ""
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_NC}"
    echo -e "${COLOR_CYAN}  ℹ️  关于${COLOR_NC}"
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_NC}"
    echo ""

    echo "项目名称：MacClaw Install"
    echo "当前版本：${VERSION}"
    echo "发布日期：2026-04-12"
    echo ""

    print_copyright

    echo ""
    echo -e "${COLOR_WHITE}项目主页：${COLOR_NC}https://github.com/changzhi777/mactools"
    echo -e "${COLOR_WHITE}问题反馈：${COLOR_NC}https://github.com/changzhi777/mactools/issues"
    echo ""

    echo -e "${COLOR_WHITE}致谢：${COLOR_NC}"
    echo "  • OpenClaw - https://github.com/openclaw-dev/openclaw"
    echo "  • oMLX - https://github.com/jundot/omlx"
    echo "  • ModelScope - https://modelscope.cn"
    echo ""
}

# ==============================================================================
# 安装步骤执行
# ==============================================================================

# 运行单个步骤
run_step() {
    local step=$1
    local step_name="${STEP_NAMES[${step}]}"

    log_section "执行：${step_name}"

    # 加载对应的模块
    local module_file="${LIB_DIR}/parts/${step}.zsh"
    if [[ ! -f "${module_file}" ]]; then
        log_error "找不到模块: ${module_file}"
        return 1
    fi

    source "${module_file}"

    # 执行安装函数
    local install_function="install_${step}"
    if type "${install_function}" >/dev/null 2>&1; then
        if ${install_function}; then
            log_success "✅ ${step_name} 完成"
            return 0
        else
            log_error "❌ ${step_name} 失败"
            return 1
        fi
    else
        log_error "找不到函数: ${install_function}"
        return 1
    fi
}

# 运行所有步骤
run_all_steps() {
    local total=${#INSTALL_STEPS[@]}
    local current=0

    for step in "${INSTALL_STEPS[@]}"; do
        ((current++))
        local step_name="${STEP_NAMES[${step}]}"

        log_step "第 ${current}/${total} 步" "${step_name}"

        if run_step "${step}"; then
            log_complete "${step_name} 完成"
        else
            echo -e "${COLOR_RED}✗${COLOR_NC} ${step_name} 失败"

            # 询问是否继续
            if [[ "${INSTALL_MODE}" != "auto" ]]; then
                if ! confirm_action "${step_name} 失败，是否继续？"; then
                    echo "安装已取消" >&2
                    return 1
                fi
            fi
        fi
        echo ""
    done

    return 0
}

# ==============================================================================
# 工具函数
# ==============================================================================

# 清理缓存
clean_cache() {
    log_info "清理缓存..."

    # 清理 Homebrew 缓存
    if command -v brew >/dev/null 2>&1; then
        brew cleanup >/dev/null 2>&1
        log_success "Homebrew 缓存已清理"
    fi

    # 清理 npm 缓存
    if command -v npm >/dev/null 2>&1; then
        npm cache clean --force >/dev/null 2>&1
        log_success "npm 缓存已清理"
    fi

    # 清理临时文件
    rm -rf /tmp/macclaw-* 2>/dev/null
    log_success "临时文件已清理"

    log_success "✅ 缓存清理完成"
}

# 显示完成信息
show_completion_info() {
    clear
    print_banner
    echo ""
    echo -e "${COLOR_GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_NC}"
    echo -e "${COLOR_GREEN}  🎉 安装完成！${COLOR_NC}"
    echo -e "${COLOR_GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_NC}"
    echo ""

    echo -e "${COLOR_WHITE}✅ 已安装组件：${COLOR_NC}"
    echo "  • Homebrew"
    if command -v brew >/dev/null 2>&1; then
        echo "    版本: $(brew --version | head -1)"
    fi

    echo "  • Node.js"
    if command -v node >/dev/null 2>&1; then
        echo "    版本: $(node --version)"
    fi

    echo "  • OpenClaw CLI"
    if command -v openclaw >/dev/null 2>&1; then
        echo "    版本: $(openclaw --version 2>/dev/null | head -1)"
    fi

    echo "  • 算力支持"
    echo "  • AI 模型"
    echo "  • 开发者工具、编程助手插件"
    echo ""

    echo -e "${COLOR_WHITE}📚 快速开始：${COLOR_NC}"
    echo ""
    echo "  # 查看 OpenClaw 版本"
    echo "  openclaw --version"
    echo ""
    echo "  # 测试推理"
    echo "  openclaw infer model run --model omlx/gemma-4-e4b-it-4bit --prompt '你好'"
    echo ""
    echo "  # 查看所有命令"
    echo "  openclaw --help"
    echo ""

    echo -e "${COLOR_WHITE}📞 获取帮助：${COLOR_NC}"
    echo "  项目地址: https://github.com/changzhi777/mactools"
    echo "  问题反馈: https://github.com/changzhi777/mactools/issues"
    echo ""

    echo -e "${COLOR_WHITE}📝 日志文件：${COLOR_NC}"
    echo "  ${LOG_FILE}"
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

# 主函数
main() {
    # 解析命令行参数
    parse_arguments "$@"

    # 初始化日志
    init_log

    # 检查环境
    detect_all_environments

    # 根据模式执行
    case "${INSTALL_MODE}" in
        auto)
            echo "🚀 自动安装模式"
            run_all_steps
            show_completion_info
            ;;
        silent)
            # 静默模式不输出任何信息
            run_all_steps
            ;;
        interactive|*)
            show_main_menu
            ;;
    esac

    # 显示错误统计
    show_error_statistics

    # 关闭日志
    close_log
}

# ==============================================================================
# 运行主函数
# ==============================================================================

main "$@"
