#!/bin/bash
#
# ==============================================================================
# RustDesk Server - 配置管理脚本
# ==============================================================================
#
# 功能说明：
#   管理 RustDesk 服务配置，包括环境变量、密钥、重启等
#
# 使用方法：
#   chmod +x config.sh
#   ./config.sh
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
# 菜单显示
# ==============================================================================

show_menu() {
    clear
    log_banner "RustDesk Server 配置管理"
    echo ""
    echo "  1) 查看当前配置"
    echo "  2) 编辑配置文件"
    echo "  3) 重新生成密钥对"
    echo "  4) 重启服务"
    echo "  5) 更新 Docker 镜像"
    echo "  6) 查看服务日志"
    echo "  7) 返回主菜单"
    echo "  0) 退出"
    echo ""
}

# ==============================================================================
# 查看当前配置
# ==============================================================================

view_config() {
    log_blank
    log_title "当前配置"

    local env_file="${INSTALL_DIR}/.env"

    if [[ -f "$env_file" ]]; then
        echo "📄 环境变量配置："
        cat "$env_file"
        echo ""
    else
        log_warning "配置文件不存在: .env"
    fi

    echo "📂 数据目录: $DATA_DIR"
    if [[ -d "$DATA_DIR" ]]; then
        echo "📊 数据大小: $(get_dir_size "$DATA_DIR")"
        echo "📁 数据文件:"
        ls -lh "$DATA_DIR" 2>/dev/null || echo "  (空)"
    fi

    pause
}

# ==============================================================================
# 编辑配置文件
# ==============================================================================

edit_config() {
    log_blank
    log_title "编辑配置文件"

    local env_file="${INSTALL_DIR}/.env"

    if [[ ! -f "$env_file" ]]; then
        log_warning "配置文件不存在，从示例创建..."
        cp "${INSTALL_DIR}/.env.example" "$env_file"
    fi

    # 确定编辑器
    local editor="${EDITOR:-nano}"
    if ! command_exists "$editor"; then
        editor="vi"
    fi

    "$editor" "$env_file"

    log_blank
    log_success "配置文件已更新"
    log_warning "修改配置后需要重启服务才能生效"
    echo ""

    if prompt_yes_no "是否现在重启服务？" "y"; then
        restart_services
    fi
}

# ==============================================================================
# 重新生成密钥对
# ==============================================================================

regenerate_keys() {
    log_blank
    log_title "重新生成密钥对"

    log_warning "此操作将覆盖现有密钥对"
    log_warning "所有客户端需要重新配置才能连接"

    if ! prompt_yes_no "确定要重新生成密钥对吗？" "n"; then
        log_info "操作已取消"
        return 0
    fi

    # 备份现有密钥
    local id_ed25519="${DATA_DIR}/id_ed25519"
    local id_ed25519_pub="${DATA_DIR}/id_ed25519.pub"

    if [[ -f "$id_ed25519" ]]; then
        local backup=$(backup_file "$id_ed25519")
        log_info "已备份私钥: $backup"
    fi

    if [[ -f "$id_ed25519_pub" ]]; then
        local backup=$(backup_file "$id_ed25519_pub")
        log_info "已备份公钥: $backup"
    fi

    # 生成新密钥
    if command_exists ssh-keygen; then
        ssh-keygen -t ed25519 -f "$id_ed25519" -N "" -C "rustdesk@server" &>/dev/null
        if [[ $? -eq 0 ]]; then
            log_success "新密钥对生成成功"

            echo ""
            echo "🔑 新公钥内容："
            cat "$id_ed25519_pub"
            echo ""

            log_warning "请更新所有客户端的公钥配置"
        else
            log_error "密钥生成失败"
            return 1
        fi
    else
        log_error "ssh-keygen 未安装"
        return 1
    fi

    pause
}

# ==============================================================================
# 重启服务
# ==============================================================================

restart_services() {
    log_blank
    log_title "重启服务"

    if ! prompt_yes_no "确定要重启服务吗？" "y"; then
        log_info "操作已取消"
        return 0
    fi

    cd "$INSTALL_DIR"

    # 检测 Docker Compose 命令
    detect_docker_compose
    local compose_cmd="${DETECTION_RESULTS[compose_command]}"

    if [[ "$compose_cmd" == "N/A" ]]; then
        log_error "Docker Compose 未安装"
        return 1
    fi

    log_step "停止服务..."
    $compose_cmd down

    log_step "启动服务..."
    $compose_cmd up -d

    if [[ $? -eq 0 ]]; then
        log_success "服务重启成功"
    else
        log_error "服务重启失败"
        return 1
    fi

    pause
}

# ==============================================================================
# 更新 Docker 镜像
# ==============================================================================

update_image() {
    log_blank
    log_title "更新 Docker 镜像"

    log_warning "此操作将下载最新的 RustDesk 镜像"
    log_warning "更新后需要重启服务"

    if ! prompt_yes_no "确定要更新镜像吗？" "y"; then
        log_info "操作已取消"
        return 0
    fi

    cd "$INSTALL_DIR"

    # 检测 Docker Compose 命令
    detect_docker_compose
    local compose_cmd="${DETECTION_RESULTS[compose_command]}"

    if [[ "$compose_cmd" == "N/A" ]]; then
        log_error "Docker Compose 未安装"
        return 1
    fi

    log_step "拉取最新镜像..."
    $compose_cmd pull

    if [[ $? -eq 0 ]]; then
        log_success "镜像更新成功"

        echo ""
        if prompt_yes_no "是否现在重启服务？" "y"; then
            restart_services
        fi
    else
        log_error "镜像更新失败"
        return 1
    fi

    pause
}

# ==============================================================================
# 查看服务日志
# ==============================================================================

view_logs() {
    log_blank
    log_title "查看服务日志"

    echo "请选择要查看的日志："
    echo ""
    echo "  1) HBBS 日志"
    echo "  2) HBBR 日志"
    echo "  3) 返回"
    echo ""
    read -p "请选择 [1-3]: " choice

    case "$choice" in
        1)
            echo ""
            log_step "显示 HBBS 日志（按 Ctrl+C 退出）..."
            echo ""
            docker logs -f rustdesk-hbbs
            ;;
        2)
            echo ""
            log_step "显示 HBBR 日志（按 Ctrl+C 退出）..."
            echo ""
            docker logs -f rustdesk-hbbr
            ;;
        3)
            return 0
            ;;
        *)
            log_error "无效选择"
            ;;
    esac
}

# ==============================================================================
# 主循环
# ==============================================================================

main() {
    while true; do
        show_menu
        read -p "请输入选择: " choice

        case "$choice" in
            1)
                view_config
                ;;
            2)
                edit_config
                ;;
            3)
                regenerate_keys
                ;;
            4)
                restart_services
                ;;
            5)
                update_image
                ;;
            6)
                view_logs
                ;;
            7)
                return 0
                ;;
            0)
                log_info "退出配置管理"
                exit 0
                ;;
            *)
                log_error "无效选择，请重新输入"
                pause
                ;;
        esac
    done
}

# ==============================================================================
# 执行主流程
# ==============================================================================

main "$@"
