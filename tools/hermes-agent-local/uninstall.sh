#!/bin/bash
#
# Hermes Agent 卸载脚本
#
# 作者: 外星动物（常智）
# 组织: IoTchange
# 邮箱: 14455975@qq.com
# 版权: Copyright (C) 2026 IoTchange - All Rights Reserved
#
# 描述: 卸载已安装的 Hermes Agent
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

# 选项
KEEP_CONFIG=false
KEEP_DATA=false
FORCE=false

# ============================================================================
# 加载功能模块
# ============================================================================

# shellcheck source=lib/logger.sh
source "${SCRIPT_DIR}/lib/logger.sh"

# ============================================================================
# 解析命令行参数
# ============================================================================

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --keep-config)
                KEEP_CONFIG=true
                shift
                ;;
            --keep-data)
                KEEP_DATA=true
                shift
                ;;
            --force)
                FORCE=true
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
Hermes Agent 卸载脚本 v${VERSION}

用法: $0 [选项]

选项:
  --keep-config  保留配置文件（~/.hermes/config）
  --keep-data    保留数据文件（~/.hermes/data）
  --force        强制卸载，不询问确认
  -h, --help     显示此帮助信息

卸载的内容:
  - 安装目录: $INSTALL_DIR
  - 符号链接: $BIN_DIR/hermes
  - 配置目录: $HERMES_HOME/config (使用 --keep-config 保留)
  - 数据目录: $HERMES_HOME/data (使用 --keep-data 保留)

示例:
  $0                  # 标准卸载
  $0 --keep-config    # 保留配置文件
  $0 --force          # 强制卸载
EOF
}

# ============================================================================
# 显示卸载信息
# ============================================================================

show_uninstall_info() {
    echo ""
    log_separator 60 "="
    echo -e "${COLOR_BOLD}${COLOR_YELLOW}⚠ Hermes Agent 卸载程序${COLOR_RESET}"
    log_separator 60 "="
    echo ""
    echo -e "${COLOR_RED}警告：此操作将卸载 Hermes Agent！${COLOR_RESET}"
    echo ""
    echo -e "${COLOR_CYAN}将删除以下内容：${COLOR_RESET}"
    echo ""
    echo "  • 安装目录: $INSTALL_DIR"
    echo "  • 符号链接: $BIN_DIR/hermes"

    if [ "$KEEP_CONFIG" = false ]; then
        echo "  • 配置目录: $HERMES_HOME/config"
    else
        echo "  • 配置目录: $HERMES_HOME/config ${COLOR_GREEN}(保留)${COLOR_RESET}"
    fi

    if [ "$KEEP_DATA" = false ]; then
        echo "  • 数据目录: $HERMES_HOME/data"
    else
        echo "  • 数据目录: $HERMES_HOME/data ${COLOR_GREEN}(保留)${COLOR_RESET}"
    fi

    echo ""
    log_separator 60 "="
    echo ""
}

# ============================================================================
# 询问确认
# ============================================================================

ask_confirmation() {
    if [ "$FORCE" = true ]; then
        return 0
    fi

    if ! ask_yes_no "确认要卸载 Hermes Agent 吗？"; then
        log_info "取消卸载"
        exit 0
    fi

    # 二次确认
    echo ""
    if ! ask_yes_no "再次确认：所有数据将永久删除，是否继续？"; then
        log_info "取消卸载"
        exit 0
    fi
}

# ============================================================================
# 停止运行中的进程
# ============================================================================

stop_processes() {
    log_step "停止运行中的进程"

    # 查找 hermes 进程
    local hermes_processes=$(pgrep -f "hermes" || true)

    if [ -n "$hermes_processes" ]; then
        log_info "发现运行中的 hermes 进程"
        echo "$hermes_processes"

        if ask_yes_no "是否停止这些进程？"; then
            pkill -f "hermes" || true
            sleep 2
            log_success "进程已停止"
        fi
    else
        log_info "未发现运行中的进程"
    fi

    echo ""
}

# ============================================================================
# 删除符号链接
# ============================================================================

remove_symlink() {
    log_step "删除符号链接"

    local hermes_link="$BIN_DIR/hermes"

    if [ -L "$hermes_link" ]; then
        log_info "删除: $hermes_link"
        rm -f "$hermes_link"
        log_success "符号链接已删除"
    else
        log_info "符号链接不存在"
    fi

    echo ""
}

# ============================================================================
# 删除安装目录
# ============================================================================

remove_installation() {
    log_step "删除安装目录"

    if [ -d "$INSTALL_DIR" ]; then
        log_info "删除: $INSTALL_DIR"
        rm -rf "$INSTALL_DIR"
        log_success "安装目录已删除"
    else
        log_warning "安装目录不存在: $INSTALL_DIR"
    fi

    echo ""
}

# ============================================================================
# 删除配置目录
# ============================================================================

remove_config() {
    if [ "$KEEP_CONFIG" = true ]; then
        log_step "保留配置目录"
        log_info "配置目录已保留: $HERMES_HOME/config"
        echo ""
        return 0
    fi

    log_step "删除配置目录"

    if [ -d "$HERMES_HOME/config" ]; then
        log_info "删除: $HERMES_HOME/config"
        rm -rf "$HERMES_HOME/config"
        log_success "配置目录已删除"
    else
        log_info "配置目录不存在"
    fi

    echo ""
}

# ============================================================================
# 删除数据目录
# ============================================================================

remove_data() {
    if [ "$KEEP_DATA" = true ]; then
        log_step "保留数据目录"
        log_info "数据目录已保留: $HERMES_HOME/data"
        echo ""
        return 0
    fi

    log_step "删除数据目录"

    if [ -d "$HERMES_HOME/data" ]; then
        log_info "删除: $HERMES_HOME/data"
        rm -rf "$HERMES_HOME/data"
        log_success "数据目录已删除"
    else
        log_info "数据目录不存在"
    fi

    echo ""
}

# ============================================================================
# 清理空目录
# ============================================================================

cleanup_empty_dirs() {
    log_step "清理空目录"

    # 如果 ~/.hermes 为空，则删除它
    if [ -d "$HERMES_HOME" ]; then
        local remaining_files=$(find "$HERMES_HOME" -mindepth 1 -maxdepth 1 2>/dev/null | wc -l)

        if [[ $remaining_files -eq 0 ]]; then
            log_info "删除空目录: $HERMES_HOME"
            rmdir "$HERMES_HOME" 2>/dev/null || true
            log_success "空目录已清理"
        else
            log_info "保留 ~/.hermes 目录（包含其他文件）"
        fi
    fi

    echo ""
}

# ============================================================================
# 显示卸载完成信息
# ============================================================================

show_completion_info() {
    echo ""
    log_separator 60 "="
    echo -e "${COLOR_BOLD}${COLOR_GREEN}✓ 卸载完成！${COLOR_RESET}"
    log_separator 60 "="
    echo ""
    echo -e "${COLOR_CYAN}感谢使用 Hermes Agent！${COLOR_RESET}"
    echo ""

    if [ "$KEEP_CONFIG" = true ] || [ "$KEEP_DATA" = true ]; then
        echo -e "${COLOR_YELLOW}保留的文件：${COLOR_RESET}"
        [ "$KEEP_CONFIG" = true ] && echo "  • $HERMES_HOME/config"
        [ "$KEEP_DATA" = true ] && echo "  • $HERMES_HOME/data"
        echo ""
    fi

    echo -e "${COLOR_CYAN}重新安装：${COLOR_RESET}"
    echo ""
    echo "  cd $(dirname "$INSTALL_DIR")"
    echo "  bash $(basename "$SCRIPT_DIR")/install.sh"
    echo ""
    echo -e "${COLOR_CYAN}反馈：${COLOR_RESET}"
    echo ""
    echo "  如有问题，请访问: https://github.com/NousResearch/hermes-agent/issues"
    echo ""
    log_separator 60 "="
    echo ""
}

# ============================================================================
# 主程序入口
# ============================================================================

main() {
    # 解析参数
    parse_arguments "$@"

    # 显示卸载信息
    show_uninstall_info

    # 询问确认
    ask_confirmation

    # 停止进程
    stop_processes

    # 删除符号链接
    remove_symlink

    # 删除安装目录
    remove_installation

    # 删除配置
    remove_config

    # 删除数据
    remove_data

    # 清理空目录
    cleanup_empty_dirs

    # 显示完成信息
    show_completion_info
}

# 运行主程序
main "$@"
