#!/usr/bin/env zsh
# ==============================================================================
# MacClaw Install - 卸载脚本
# ==============================================================================
#
# 项目名称：MacClaw Install
# 文件名称：uninstall.zsh
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
#   完全卸载 MacClaw Install 安装的所有组件
#   包括：OpenClaw、Node.js、Homebrew、配置文件、插件、模型
#
# 使用方法：
#   chmod +x uninstall.zsh
#   ./uninstall.zsh
#
# ==============================================================================

# ==============================================================================
# Zsh 严格模式
# ==============================================================================

set -o EXTENDED_GLOB
set -o NULL_GLOB

# ==============================================================================
# 脚本目录
# ==============================================================================

SCRIPT_DIR="${0:A:h}"
LIB_DIR="${SCRIPT_DIR}/lib"

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

# 加载错误处理模块（如果可用）
if [[ -f "${LIB_DIR}/core/error-handler.zsh" ]]; then
    source "${LIB_DIR}/core/error-handler.zsh"
fi

# ==============================================================================
# 全局变量
# ==============================================================================

typeset -g UNINSTALL_MODE="full"  # full, partial, custom
typeset -ga COMPONENTS_TO_UNINSTALL
typeset -g CONFIRMED=false

# ==============================================================================
# 显示横幅
# ==============================================================================

print_uninstall_banner() {
    clear
    cat << EOF
${COLOR_RED}╔════════════════════════════════════════════════════════════╗
║                                                              ║
║       🗑️  MacClaw Install - 卸载工具                          ║
║                                                              ║
║       警告：此操作将卸载所有已安装的组件                      ║
║                                                              ║
╚════════════════════════════════════════════════════════════╝
${COLOR_NC}
EOF

    print_copyright
}

# ==============================================================================
# 卸载函数
# ==============================================================================

# 卸载 OpenClaw
uninstall_openclaw() {
    log_section "卸载 OpenClaw"

    if command -v openclaw >/dev/null 2>&1; then
        log_info "正在卸载 OpenClaw CLI..."

        if npm uninstall -g @iotchange/openclaw 2>&1 | tee -a "${LOG_FILE}"; then
            log_success "✅ OpenClaw CLI 已卸载"
        else
            log_warning "⚠️  OpenClaw CLI 卸载失败"
            increment_error_count
        fi
    else
        log_info "OpenClaw CLI 未安装，跳过"
    fi

    # 清理配置文件
    local openclaw_dir="${HOME}/.openclaw"
    if [[ -d "${openclaw_dir}" ]]; then
        log_info "清理 OpenClaw 配置文件..."
        rm -rf "${openclaw_dir}"
        log_success "✅ 配置文件已清理"
    fi
}

# 卸载 Node.js 和 nvm
uninstall_nodejs() {
    log_section "卸载 Node.js 和 nvm"

    # 卸载全局 npm 包
    if command -v npm >/dev/null 2>&1; then
        log_info "正在卸载全局 npm 包..."
        npm cache clean --force >/dev/null 2>&1
        log_success "✅ npm 缓存已清理"
    fi

    # 卸载 nvm
    local nvm_dir="${NVM_DIR:-${HOME}/.nvm}"
    if [[ -d "${nvm_dir}" ]]; then
        log_info "正在卸载 nvm..."
        rm -rf "${nvm_dir}"
        log_success "✅ nvm 已卸载"
    else
        log_info "nvm 未安装，跳过"
    fi

    # 清理 shell 配置
    log_info "清理 shell 配置..."

    if [[ $SHELL == *"zsh"* ]]; then
        # 清理 .zshrc
        if [[ -f ~/.zshrc ]]; then
            sed -i.backup '/NVM_DIR/d' ~/.zshrc
            sed -i.backup '/nvm.sh/d' ~/.zshrc
            log_success "✅ .zshrc 已清理"
        fi

        # 清理 .zprofile
        if [[ -f ~/.zprofile ]]; then
            sed -i.backup '/NVM_DIR/d' ~/.zprofile
            sed -i.backup '/nvm.sh/d' ~/.zprofile
            log_success "✅ .zprofile 已清理"
        fi
    elif [[ $SHELL == *"bash"* ]]; then
        # 清理 .bash_profile
        if [[ -f ~/.bash_profile ]]; then
            sed -i.backup '/NVM_DIR/d' ~/.bash_profile
            sed -i.backup '/nvm.sh/d' ~/.bash_profile
            log_success "✅ .bash_profile 已清理"
        fi
    fi
}

# 卸载 Homebrew
uninstall_homebrew() {
    log_section "卸载 Homebrew"

    if command -v brew >/dev/null 2>&1; then
        log_info "正在卸载 Homebrew..."
        log_warning "⚠️  Homebrew 卸载需要手动确认"

        if confirm_action "确认卸载 Homebrew？这将删除所有通过 Homebrew 安装的软件"; then
            # 下载并运行卸载脚本
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)" 2>&1 | tee -a "${LOG_FILE}"
            log_success "✅ Homebrew 已卸载"
        else
            log_info "跳过 Homebrew 卸载"
        fi
    else
        log_info "Homebrew 未安装，跳过"
    fi

    # 清理 Homebrew 配置
    local homebrew_dir=""
    if [[ $(uname -m) == "arm64" ]]; then
        homebrew_dir="/opt/homebrew"
    else
        homebrew_dir="/usr/local"
    fi

    if [[ -d "${homebrew_dir}" ]]; then
        log_info "清理 Homebrew 目录..."
        rm -rf "${homebrew_dir}"
        log_success "✅ Homebrew 目录已清理"
    fi
}

# 卸载 oMLX
uninstall_omlx() {
    log_section "卸载 oMLX"

    if pip3 show omlx &>/dev/null; then
        log_info "正在卸载 oMLX..."
        pip3 uninstall -y omlx 2>&1 | tee -a "${LOG_FILE}"
        log_success "✅ oMLX 已卸载"
    else
        log_info "oMLX 未安装，跳过"
    fi
}

# 卸载 AI 模型
uninstall_models() {
    log_section "卸载 AI 模型"

    local model_dir="${HOME}/.openclaw/models"
    if [[ -d "${model_dir}" ]]; then
        local model_size=$(du -sh "${model_dir}" | cut -f1)
        log_info "正在删除 AI 模型（大小: ${model_size}）..."

        if confirm_action "确认删除所有 AI 模型？"; then
            rm -rf "${model_dir}"
            log_success "✅ AI 模型已删除"
        else
            log_info "跳过模型删除"
        fi
    else
        log_info "模型目录不存在，跳过"
    fi
}

# 清理配置文件
cleanup_config_files() {
    log_section "清理配置文件"

    local config_dirs=(
        "${HOME}/.openclaw"
        "${HOME}/.omlx"
        "${HOME}/.nvm"
        "${HOME}/.npm"
    )

    local cleaned_count=0

    for dir in "${config_dirs[@]}"; do
        if [[ -d "${dir}" ]]; then
            log_info "删除: ${dir}"
            rm -rf "${dir}"
            ((cleaned_count++))
        fi
    done

    if [[ ${cleaned_count} -gt 0 ]]; then
        log_success "✅ 已清理 ${cleaned_count} 个配置目录"
    else
        log_info "没有需要清理的配置文件"
    fi
}

# 清理日志文件
cleanup_logs() {
    log_section "清理日志文件"

    local log_file="${HOME}/macclaw_install.log"
    if [[ -f "${log_file}" ]]; then
        log_info "删除日志文件..."
        rm -f "${log_file}"
        log_success "✅ 日志文件已删除"
    else
        log_info "日志文件不存在"
    fi
}

# ==============================================================================
# 卸载模式选择
# ==============================================================================

# 选择卸载模式
select_uninstall_mode() {
    echo ""
    local options=(
        "1" "完全卸载（推荐）"
        "2" "部分卸载"
        "3" "自定义卸载"
        "0" "取消"
    )

    print_menu "请选择卸载模式" "${options[@]}"
    read -k1 choice
    echo ""

    case "${choice}" in
        1)
            UNINSTALL_MODE="full"
            log_info "选择: 完全卸载"
            ;;
        2)
            UNINSTALL_MODE="partial"
            log_info "选择: 部分卸载"
            ;;
        3)
            UNINSTALL_MODE="custom"
            log_info "选择: 自定义卸载"
            ;;
        0)
            log_info "取消卸载"
            exit 0
            ;;
        *)
            log_error "无效选择"
            select_uninstall_mode
            ;;
    esac
}

# 部分卸载
partial_uninstall() {
    log_section "部分卸载"

    echo ""
    echo "请选择要卸载的组件（可多选）："
    echo ""
    echo "  [1] OpenClaw CLI"
    echo "  [2] Node.js 和 nvm"
    echo "  [3] Homebrew"
    echo "  [4] oMLX"
    echo "  [5] AI 模型"
    echo "  [6] 配置文件"
    echo ""
    echo "  [A] 全选"
    echo "  [N] 取消所有选择"
    echo "  [B] 返回"
    echo ""
    echo -n "请输入选项（用空格分隔多个选项）: "

    read -a choices

    for choice in "${choices[@]}"; do
        case "${choice}" in
            1)
                COMPONENTS_TO_UNINSTALL+=("openclaw")
                log_success "已选择: OpenClaw CLI"
                ;;
            2)
                COMPONENTS_TO_UNINSTALL+=("nodejs")
                log_success "已选择: Node.js 和 nvm"
                ;;
            3)
                COMPONENTS_TO_UNINSTALL+=("homebrew")
                log_success "已选择: Homebrew"
                ;;
            4)
                COMPONENTS_TO_UNINSTALL+=("omlx")
                log_success "已选择: oMLX"
                ;;
            5)
                COMPONENTS_TO_UNINSTALL+=("models")
                log_success "已选择: AI 模型"
                ;;
            6)
                COMPONENTS_TO_UNINSTALL+=("config")
                log_success "已选择: 配置文件"
                ;;
            a|A)
                COMPONENTS_TO_UNINSTALL=("openclaw" "nodejs" "homebrew" "omlx" "models" "config")
                log_success "已选择: 所有组件"
                ;;
            n|N)
                COMPONENTS_TO_UNINSTALL=()
                log_info "已取消所有选择"
                ;;
            b|B)
                return 1
                ;;
        esac
    done

    if [[ ${#COMPONENTS_TO_UNINSTALL[@]} -eq 0 ]]; then
        log_warning "未选择任何组件"
        return 1
    fi

    return 0
}

# 执行卸载
perform_uninstall() {
    log_title "开始卸载"

    # 根据模式执行卸载
    case "${UNINSTALL_MODE}" in
        full)
            log_info "执行完全卸载..."
            uninstall_openclaw
            uninstall_omlx
            uninstall_models
            uninstall_nodejs
            uninstall_homebrew
            cleanup_config_files
            cleanup_logs
            ;;
        partial)
            log_info "执行部分卸载..."
            for component in "${COMPONENTS_TO_UNINSTALL[@]}"; do
                case "${component}" in
                    openclaw)
                        uninstall_openclaw
                        ;;
                    nodejs)
                        uninstall_nodejs
                        ;;
                    homebrew)
                        uninstall_homebrew
                        ;;
                    omlx)
                        uninstall_omlx
                        ;;
                    models)
                        uninstall_models
                        ;;
                    config)
                        cleanup_config_files
                        ;;
                esac
            done
            ;;
        custom)
            log_info "自定义卸载模式（开发中）"
            ;;
    esac

    echo ""
    log_success "✅ 卸载完成"
}

# ==============================================================================
# 主函数
# ==============================================================================

# 主函数
main() {
    # 初始化日志
    local uninstall_log="${HOME}/macclaw_uninstall.log"
    echo "=== MacClaw Uninstall Log ===" > "${uninstall_log}"
    echo "开始时间: $(date '+%Y-%m-%d %H:%M:%S')" >> "${uninstall_log}"
    echo "================================" >> "${uninstall_log}"

    # 显示横幅
    print_uninstall_banner

    # 最终确认
    echo ""
    if ! confirm_action "⚠️  警告：此操作将删除所有组件，是否继续？"; then
        echo "卸载已取消"
        exit 0
    fi

    # 选择卸载模式
    select_uninstall_mode

    # 如果是部分卸载，显示选择菜单
    if [[ "${UNINSTALL_MODE}" == "partial" ]]; then
        if ! partial_uninstall; then
            select_uninstall_mode
        fi
    fi

    # 最终确认
    echo ""
    if ! confirm_action "最后确认：是否开始卸载？"; then
        echo "卸载已取消"
        exit 0
    fi

    # 执行卸载
    perform_uninstall

    # 显示错误统计
    show_error_statistics

    echo ""
    echo "感谢使用 MacClaw Install！"
    echo ""
}

# ==============================================================================
# 运行主函数
# ==============================================================================

main "$@"
