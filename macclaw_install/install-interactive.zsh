#!/usr/bin/env zsh
# ==============================================================================
# MacClaw Install - 交互式安装主入口脚本
# ==============================================================================
#
# 作者: 外星动物（常智） / IoTchange / 14455975@qq.com
# 版权: Copyright (C) 2026 IoTchange - All Rights Reserved
#
# 版本信息：
#   当前版本：1.0.0
#   发布日期：2026-04-13
#
# 功能说明：
#   交互式 omlx + OpenClaw 安装脚本
#   支持 macOS 原生对话框和浏览器集成
#
# 使用方法：
#   chmod +x install-interactive.zsh
#   ./install-interactive.zsh
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
LOG_FILE="${HOME}/macclaw_interactive_install.log"

# ==============================================================================
# 全局变量
# ==============================================================================

typeset -g VERSION="1.0.0"
typeset -g INSTALL_MODE="interactive"

# 颜色定义
typeset -g COLOR_RED='\033[0;31m'
typeset -g COLOR_GREEN='\033[0;32m'
types_t -g COLOR_YELLOW='\033[0;33m'
typeset -g COLOR_BLUE='\033[0;34m'
typeset -g COLOR_CYAN='\033[0;36m'
typeset -g COLOR_WHITE='\033[0;37m'
typeset -g COLOR_NC='\033[0m' # No Color

# ==============================================================================
# 日志函数
# ==============================================================================

# 初始化日志
init_log() {
    echo "" > "${LOG_FILE}"
    echo "====================================" >> "${LOG_FILE}"
    echo "MacClaw 交互式安装日志" >> "${LOG_FILE}"
    echo "开始时间: $(date +'%Y-%m-%d %H:%M:%S')" >> "${LOG_FILE}"
    echo "====================================" >> "${LOG_FILE}"
    echo "" >> "${LOG_FILE}"
}

# 关闭日志
close_log() {
    echo "" >> "${LOG_FILE}"
    echo "====================================" >> "${LOG_FILE}"
    echo "结束时间: $(date +'%Y-%m-%d %H:%M:%S')" >> "${LOG_FILE}"
    echo "====================================" >> "${LOG_FILE}"
}

# 记录日志
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date +'%Y-%m-%d %H:%M:%S')

    echo "[${timestamp}] [${level}] ${message}" >> "${LOG_FILE}"
}

log_info() {
    log "INFO" "$1"
    echo -e "${COLOR_CYAN}ℹ️  $1${COLOR_NC}"
}

log_success() {
    log "SUCCESS" "$1"
    echo -e "${COLOR_GREEN}✅ $1${COLOR_NC}"
}

log_warning() {
    log "WARNING" "$1"
    echo -e "${COLOR_YELLOW}⚠️  $1${COLOR_NC}"
}

log_error() {
    log "ERROR" "$1"
    echo -e "${COLOR_RED}❌ $1${COLOR_NC}"
}

log_section() {
    log "SECTION" "$1"
    echo ""
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_NC}"
    echo -e "${COLOR_CYAN}  $1${COLOR_NC}"
    echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_NC}"
    echo ""
}

log_title() {
    log "TITLE" "$1"
    echo ""
    echo -e "${COLOR_WHITE}╔══════════════════════════════════════════════════════════════════════════════╗${COLOR_NC}"
    echo -e "${COLOR_WHITE}║  $1${COLOR_NC}" | sed 's/./ /g' | head -c 78; echo "${COLOR_WHITE}║${COLOR_NC}"
    echo -e "${COLOR_WHITE}╚══════════════════════════════════════════════════════════════════════════════╝${COLOR_NC}"
    echo ""
}

# ==============================================================================
# 显示函数
# ==============================================================================

# 显示 Banner
print_banner() {
    echo ""
    echo -e "${COLOR_CYAN}████████╗███████╗███████╗████████╗██╗   ██╗██████╗ ███████╗██████╗${COLOR_NC}"
    echo -e "${COLOR_CYAN}╚══██╔══╝██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗██╔════╝██╔══██╗${COLOR_NC}"
    echo -e "${COLOR_CYAN}   ██║   █████╗  █████╗     ██║   ██║   ██║██████╔╝█████╗  ██████╔╝${COLOR_NC}"
    echo -e "${COLOR_CYAN}   ██║   ██╔══╝  ██╔══╝     ██║   ██║   ██║██╔══██╗██╔══╝  ██╔══██╗${COLOR_NC}"
    echo -e "${COLOR_CYAN}   ██║   ███████╗███████╗   ██║   ╚██████╔╝██║  ██║███████╗██║  ██║${COLOR_NC}"
    echo -e "${COLOR_CYAN}   ╚═╝   ╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝${COLOR_NC}"
    echo ""
    echo -e "${COLOR_WHITE}              交互式安装脚本 v${VERSION}${COLOR_NC}"
    echo -e "${COLOR_WHITE}              for Apple Silicon macOS${COLOR_NC}"
    echo ""
}

# 显示版权信息
print_copyright() {
    echo -e "${COLOR_WHITE}Copyright (C) 2026 IoTchange - All Rights Reserved${COLOR_NC}"
    echo -e "${COLOR_WHITE}作者：外星动物（常智）${COLOR_NC}"
    echo -e "${COLOR_WHITE}GitHub：https://github.com/changzhi777/mactools${COLOR_NC}"
    echo ""
}

# 显示欢迎信息
show_welcome() {
    clear
    print_banner
    print_copyright

    echo -e "${COLOR_WHITE}════════════════════════════════════════════════════════════════════════════════${COLOR_NC}"
    echo -e "${COLOR_WHITE}                           欢迎使用${COLOR_NC}"
    echo -e "${COLOR_WHITE}════════════════════════════════════════════════════════════════════════════════${COLOR_NC}"
    echo ""
    echo "此脚本将帮助您交互式安装以下组件："
    echo ""
    echo "  📦 omlx - Apple Silicon 优化推理引擎"
    echo "  🤖 AI 模型 - gemma-4-e4b-it-4bit"
    echo "  🦊 OpenClaw - 本地 AI 开发工具"
    echo "  🔌 技能插件 - 扩展功能"
    echo ""
    echo -e "${COLOR_WHITE}════════════════════════════════════════════════════════════════════════════════${COLOR_NC}"
    echo ""
}

# 显示使用说明
show_usage() {
    echo -e "${COLOR_WHITE}用法：${COLOR_NC}"
    echo "  $0 [选项]"
    echo ""
    echo -e "${COLOR_WHITE}选项：${COLOR_NC}"
    echo "  --help, -h     显示此帮助信息"
    echo "  --version, -v  显示版本信息"
    echo "  --auto         自动模式（减少交互）"
    echo ""
    echo -e "${COLOR_WHITE}示例：${COLOR_NC}"
    echo "  $0              # 交互式安装"
    echo "  $0 --auto       # 自动模式"
    echo ""
}

# 显示版本信息
show_version() {
    echo "MacClaw 交互式安装脚本 v${VERSION}"
    echo "发布日期: 2026-04-13"
    echo ""
    print_copyright
}

# ==============================================================================
# 加载模块
# ==============================================================================

# 加载所有必需模块
load_all_modules() {
    log_info "加载模块..."

    # 加载配置
    if [[ -f "${CONFIG_DIR}/interactive.conf" ]]; then
        source "${CONFIG_DIR}/interactive.conf"
        log_success "配置文件加载完成"
    else
        log_error "找不到配置文件: ${CONFIG_DIR}/interactive.conf"
        return 1
    fi

    # 加载对话框工具
    if [[ -f "${LIB_DIR}/interactive/dialog-helper.zsh" ]]; then
        source "${LIB_DIR}/interactive/dialog-helper.zsh"
        log_success "对话框工具加载完成"
    else
        log_error "找不到对话框工具: ${LIB_DIR}/interactive/dialog-helper.zsh"
        return 1
    fi

    # 加载浏览器工具
    if [[ -f "${LIB_DIR}/interactive/browser-helper.zsh" ]]; then
        source "${LIB_DIR}/interactive/browser-helper.zsh"
        log_success "浏览器工具加载完成"
    else
        log_error "找不到浏览器工具: ${LIB_DIR}/interactive/browser-helper.zsh"
        return 1
    fi

    # 加载环境检测
    if [[ -f "${LIB_DIR}/core/env-detector-interactive.zsh" ]]; then
        source "${LIB_DIR}/core/env-detector-interactive.zsh"
        log_success "环境检测模块加载完成"
    else
        log_error "找不到环境检测模块: ${LIB_DIR}/core/env-detector-interactive.zsh"
        return 1
    fi

    # 加载工作流步骤
    if [[ -f "${LIB_DIR}/interactive/workflow-steps.zsh" ]]; then
        source "${LIB_DIR}/interactive/workflow-steps.zsh"
        log_success "工作流步骤模块加载完成"
    else
        log_error "找不到工作流步骤模块: ${LIB_DIR}/interactive/workflow-steps.zsh"
        return 1
    fi

    log_success "✅ 所有模块加载完成"
    return 0
}

# ==============================================================================
# 主菜单
# ==============================================================================

# 显示主菜单
show_main_menu() {
    while true; do
        clear
        print_banner
        echo -e "${COLOR_WHITE}════════════════════════════════════════════════════════════════════════════════${COLOR_NC}"
        echo -e "${COLOR_WHITE}                            主菜单${COLOR_NC}"
        echo -e "${COLOR_WHITE}════════════════════════════════════════════════════════════════════════════════${COLOR_NC}"
        echo ""
        echo "  1. 🚀 开始安装（推荐）"
        echo "  2. 📋 查看系统信息"
        echo "  3. 📊 查看工作流状态"
        echo "  4. ℹ️  关于"
        echo "  0. 🚪 退出"
        echo ""

        read -k1 choice
        echo ""

        case "${choice}" in
            1)
                start_installation
                ;;
            2)
                detect_all_environments
                show_environment_report
                press_enter_continue
                ;;
            3)
                show_workflow_status
                press_enter_continue
                ;;
            4)
                show_about
                press_enter_continue
                ;;
            0)
                exit_installation
                ;;
            *)
                log_error "无效选项"
                press_enter_continue
                ;;
        esac
    done
}

# 开始安装
start_installation() {
    clear
    print_banner

    log_title "开始交互式安装"

    # 最后确认
    if ! show_confirm_dialog "即将开始交互式安装流程。\n\n整个过程大约需要 20-30 分钟。\n\n是否开始？" "确认安装"; then
        log_info "用户取消安装"
        return 1
    fi

    # 执行所有工作流步骤
    if run_all_workflow_steps; then
        # 安装成功
        show_completion_summary
    else
        # 安装失败
        show_failure_summary
    fi
}

# 显示完成摘要
show_completion_summary() {
    clear
    print_banner

    echo -e "${COLOR_GREEN}════════════════════════════════════════════════════════════════════════════════${COLOR_NC}"
    echo -e "${COLOR_GREEN}                      🎉 安装完成！${COLOR_NC}"
    echo -e "${COLOR_GREEN}════════════════════════════════════════════════════════════════════════════════${COLOR_NC}"
    echo ""

    echo -e "${COLOR_WHITE}【已安装组件】${COLOR_NC}"
    detect_all_environments

    if ${OMLX_INSTALLED}; then
        echo "  ✅ omlx: ${OMLX_VERSION}"
    else
        echo "  ⏸️  omlx: 未安装"
    fi

    if ${OPENCLAW_INSTALLED}; then
        echo "  ✅ OpenClaw: ${OPENCLAW_VERSION}"
    else
        echo "  ⏸️  OpenClaw: 未安装"
    fi

    echo ""
    echo -e "${COLOR_WHITE}【快速开始】${COLOR_NC}"
    echo ""
    echo "  # 1. 查看 OpenClaw 版本"
    echo "  openclaw --version"
    echo ""
    echo "  # 2. 查看系统信息"
    echo "  openclaw system info"
    echo ""
    echo "  # 3. 测试推理"
    echo "  openclaw infer model run --model omlx/gemma-4-e4b-it-4bit --prompt '你好'"
    echo ""
    echo "  # 4. 查看所有命令"
    echo "  openclaw --help"
    echo ""

    echo -e "${COLOR_WHITE}【获取帮助】${COLOR_NC}"
    echo "  项目主页: https://github.com/changzhi777/mactools"
    echo "  问题反馈: https://github.com/changzhi777/mactools/issues"
    echo ""
    echo -e "${COLOR_WHITE}【日志文件】${COLOR_NC}"
    echo "  ${LOG_FILE}"
    echo ""

    press_enter_continue
}

# 显示失败摘要
show_failure_summary() {
    clear
    print_banner

    echo -e "${COLOR_RED}════════════════════════════════════════════════════════════════════════════════${COLOR_NC}"
    echo -e "${COLOR_RED}                      ❌ 安装失败${COLOR_NC}"
    echo -e "${COLOR_RED}════════════════════════════════════════════════════════════════════════════════${COLOR_NC}"
    echo ""

    echo "安装过程中出现问题，请查看："
    echo ""
    echo "  1. 日志文件: ${LOG_FILE}"
    echo "  2. 项目问题反馈: https://github.com/changzhi777/mactools/issues"
    echo ""

    press_enter_continue
}

# 显示关于信息
show_about() {
    clear
    print_banner

    echo -e "${COLOR_WHITE}════════════════════════════════════════════════════════════════════════════════${COLOR_NC}"
    echo -e "${COLOR_WHITE}                          关于${COLOR_NC}"
    echo -e "${COLOR_WHITE}════════════════════════════════════════════════════════════════════════════════${COLOR_NC}"
    echo ""

    echo "项目名称：MacClaw 交互式安装"
    echo "当前版本：${VERSION}"
    echo "发布日期：2026-04-13"
    echo ""

    print_copyright

    echo ""
    echo -e "${COLOR_WHITE}致谢：${COLOR_NC}"
    echo "  • omlx - https://omlx.ai"
    echo "  • OpenClaw - https://openclaw.ai"
    echo "  • ModelScope - https://modelscope.cn"
    echo ""
}

# 退出安装
exit_installation() {
    log_info "退出安装"

    # 关闭日志
    close_log

    clear
    print_banner
    echo ""
    echo "感谢使用 MacClaw 交互式安装！"
    echo ""
    exit 0
}

# 等待用户按回车继续
press_enter_continue() {
    echo ""
    echo -e "${COLOR_CYAN}按回车键继续...${COLOR_NC}"
    read
    echo ""
}

# ==============================================================================
# 命令行参数处理
# ==============================================================================

# 解析命令行参数
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help|-h)
                show_welcome
                show_usage
                exit 0
                ;;
            --version|-v)
                show_version
                exit 0
                ;;
            --auto)
                INSTALL_MODE="auto"
                shift
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
# 主函数
# ==============================================================================

# 主函数
main() {
    # 解析命令行参数
    parse_arguments "$@"

    # 初始化日志
    init_log

    # 显示欢迎信息
    show_welcome

    # 加载所有模块
    if ! load_all_modules; then
        log_error "模块加载失败"
        show_error_dialog "模块加载失败，请检查脚本文件完整性。" "加载失败"
        exit 1
    fi

    # 根据模式执行
    case "${INSTALL_MODE}" in
        auto)
            log_info "自动模式"
            run_all_workflow_steps
            ;;
        interactive|*)
            show_main_menu
            ;;
    esac

    # 关闭日志
    close_log
}

# ==============================================================================
# 运行主函数
# ==============================================================================

main "$@"
