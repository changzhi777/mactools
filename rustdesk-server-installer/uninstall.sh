#!/bin/bash
#
# ==============================================================================
# RustDesk Server - 卸载脚本
# ==============================================================================
#
# 功能说明：
#   完全卸载 RustDesk 服务，包括容器、镜像、配置和数据
#
# 使用方法：
#   chmod +x uninstall.sh
#   sudo ./uninstall.sh
#
# ==============================================================================

set -e

# 脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/lib"
INSTALL_DIR="${SCRIPT_DIR}"
DATA_DIR="${INSTALL_DIR}/data"

# 加载功能模块
source "${LIB_DIR}/logger.sh"
source "${LIB_DIR}/utils.sh"
source "${LIB_DIR}/detector.sh"

# ==============================================================================
# 卸载选项菜单
# ==============================================================================

show_uninstall_menu() {
    log_blank
    log_title "卸载选项"

    echo "请选择卸载方式："
    echo ""
    echo "  1) 保留数据，仅删除容器"
    echo "     - 停止并删除 Docker 容器"
    echo "     - 保留配置和数据文件"
    echo "     - 可通过重新安装恢复服务"
    echo ""
    echo "  2) 完全卸载（删除所有数据）"
    echo "     - 删除容器、镜像、配置和数据"
    echo "     - 无法恢复，请谨慎选择"
    echo ""
    echo "  3) 取消"
    echo ""
    read -p "请输入选择 [1-3]: " choice

    case "$choice" in
        1)
            return 1
            ;;
        2)
            return 2
            ;;
        3)
            log_info "取消卸载"
            exit 0
            ;;
        *)
            log_error "无效选择"
            exit 1
            ;;
    esac
}

# ==============================================================================
# 停止并删除容器
# ==============================================================================

stop_and_remove_containers() {
    log_blank
    log_title "停止并删除容器"

    cd "$INSTALL_DIR"

    # 检测 Docker Compose 命令
    detect_docker_compose
    local compose_cmd="${DETECTION_RESULTS[compose_command]}"

    if [[ "$compose_cmd" == "N/A" ]]; then
        log_error "Docker Compose 未安装"
        return 1
    fi

    # 停止服务
    log_step "停止服务..."
    $compose_cmd down

    if [[ $? -eq 0 ]]; then
        log_success "容器已停止并删除"
    else
        log_warning "停止容器时出现错误（可能已经停止）"
    fi

    # 手动检查并删除残留容器
    local containers=$(docker ps -a --format "{{.Names}}" | grep -E "rustdesk-hbbs|rustdesk-hbbr" || true)

    if [[ -n "$containers" ]]; then
        log_step "清理残留容器..."
        echo "$containers" | xargs -r docker rm -f
        log_success "残留容器已清理"
    fi

    return 0
}

# ==============================================================================
# 删除防火墙规则
# ==============================================================================

remove_firewall() {
    log_blank
    log_title "删除防火墙规则"

    # 重新检测环境以获取防火墙类型
    detect_firewall

    if prompt_yes_no "是否删除防火墙规则？" "y"; then
        remove_firewall_rules
    else
        log_info "保留防火墙规则"
    fi
}

# ==============================================================================
# 保留数据卸载
# ==============================================================================

uninstall_keep_data() {
    log_blank
    log_title "保留数据卸载"

    echo "此操作将："
    echo "  • 停止并删除 Docker 容器"
    echo "  • 保留以下文件："
    echo "    - 配置文件 (.env)"
    echo "    - 数据目录 (./data)"
    echo "    - Docker Compose 配置 (docker-compose.yml)"
    echo "    - 管理脚本 (install.sh, config.sh, status.sh, uninstall.sh)"
    echo ""

    if ! prompt_yes_no "确定要继续吗？" "n"; then
        log_info "取消卸载"
        return 0
    fi

    # 停止容器
    stop_and_remove_containers

    # 防火墙规则
    remove_firewall

    log_blank
    log_success "卸载完成！数据已保留"
    echo ""
    echo "💡 如需重新安装，运行："
    echo "   ./install.sh"
    echo ""

    return 0
}

# ==============================================================================
# 完全卸载
# ==============================================================================

uninstall_complete() {
    log_blank
    log_title "完全卸载"

    echo "⚠️  警告：此操作将删除以下所有内容："
    echo ""
    echo "  • Docker 容器"
    echo "  • Docker 镜像"
    echo "  • 配置文件 (.env)"
    echo "  • 数据目录 (./data)"
    echo "  • 所有脚本和配置"
    echo ""
    echo "❗ 此操作不可逆，所有数据将永久丢失！"
    echo ""

    if ! confirm_dangerous_operation "完全卸载 RustDesk 服务"; then
        log_info "取消卸载"
        return 0
    fi

    # 停止容器
    stop_and_remove_containers

    # 删除 Docker 镜像
    log_step "删除 Docker 镜像..."
    local images=$(docker images | grep "rustdesk/rustdesk-server" | awk '{print $3}' || true)
    if [[ -n "$images" ]]; then
        echo "$images" | xargs -r docker rmi -f
        log_success "Docker 镜像已删除"
    else
        log_info "没有找到 RustDesk 镜像"
    fi

    # 防火墙规则
    remove_firewall

    # 删除数据文件
    log_step "删除数据文件..."
    if [[ -d "$DATA_DIR" ]]; then
        rm -rf "$DATA_DIR"
        log_success "数据目录已删除: $DATA_DIR"
    fi

    if [[ -f "${INSTALL_DIR}/.env" ]]; then
        rm -f "${INSTALL_DIR}/.env"
        log_success "配置文件已删除"
    fi

    log_blank
    log_success "完全卸载完成！"
    echo ""
    echo "💡 如需重新安装，请重新下载安装脚本"
    echo ""

    return 0
}

# ==============================================================================
# 主流程
# ==============================================================================

main() {
    # 检查 root 权限
    if ! is_root; then
        log_error "此脚本需要 root 权限运行"
        echo ""
        echo "请使用以下方式之一运行："
        echo "  sudo ./uninstall.sh"
        echo "  sudo bash uninstall.sh"
        echo ""
        exit 1
    fi

    # 显示欢迎信息
    clear
    log_banner "RustDesk Server 卸载程序"
    echo ""

    # 检查服务是否正在运行
    if docker ps --format "{{.Names}}" | grep -q "rustdesk"; then
        log_warning "检测到 RustDesk 服务正在运行"
    else
        log_info "未检测到运行中的服务"
    fi

    # 显示卸载菜单
    show_uninstall_menu
    local uninstall_choice=$?

    # 执行卸载
    if [[ $uninstall_choice -eq 1 ]]; then
        uninstall_keep_data
    elif [[ $uninstall_choice -eq 2 ]]; then
        uninstall_complete
    fi

    # 询问是否删除脚本自身
    if [[ $uninstall_choice -eq 2 ]]; then
        echo ""
        if prompt_yes_no "是否删除卸载脚本自身？" "n"; then
            log_info "删除脚本..."
            rm -f "$0"
            log_success "脚本已删除"
        fi
    fi

    log_blank
}

# ==============================================================================
# 执行主流程
# ==============================================================================

main "$@"
