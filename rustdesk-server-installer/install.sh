#!/bin/bash
#
# ==============================================================================
# RustDesk Server - Docker 一键安装脚本
# ==============================================================================
#
# 项目名称：RustDesk Server Installer
# 文件名称：install.sh
#
# 作者信息：
#   作者：外星动物（常智）
#   组织：IoTchange
#   邮箱：14455975@qq.com
#   GitHub：https://github.com/changzhi777
#
# 版本信息：
#   当前版本：V1.0.0
#   发布日期：2026-04-12
#   修订历史：
#     V1.0.0 (2026-04-12): 初始版本
#
# 版权声明：
#   Copyright (C) 2026 IoTchange - All Rights Reserved
#
# 许可证：
#   MIT License
#
# 功能说明：
#   一键在 Debian 服务器上部署 RustDesk 中继服务（HBBS + HBBR）
#   使用 Docker 容器化部署，支持自动配置防火墙
#   交互式菜单选择，操作简单易用
#
# 使用方法：
#   chmod +x install.sh
#   sudo ./install.sh
#
# 或直接执行：
#   bash install.sh
#
# 依赖要求：
#   - Debian 11 或更高版本
#   - root 权限
#   - Docker
#   - Docker Compose
#   - curl（下载文件）
#
# 支持的功能：
#   - 自动检测系统环境和依赖
#   - 交互式配置菜单
#   - 自动生成密钥对
#   - 自动配置防火墙规则
#   - Docker Compose 一键部署
#   - 健康检查和状态显示
#   - 完整的卸载功能
#
# 文档地址：
#   - 项目主页：https://github.com/changzhi777/mactools
#   - RustDesk 官网：https://rustdesk.com/
#   - 问题反馈：https://github.com/changzhi777/mactools/issues
#
# 免责声明：
#   本脚本仅供学习和个人使用。使用本脚本安装的软件和组件请遵守其
#   各自的许可证条款。作者不对本脚本的使用结果承担任何责任。
#
# ==============================================================================

set -e  # 遇到错误立即退出

# ==============================================================================
# 脚本目录和路径配置
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/lib"
PROJECT_NAME="rustdesk-server"
INSTALL_DIR="${SCRIPT_DIR}"
DATA_DIR="${INSTALL_DIR}/data"

# ==============================================================================
# 加载功能模块
# ==============================================================================

# 加载日志模块
if [[ -f "${LIB_DIR}/logger.sh" ]]; then
    source "${LIB_DIR}/logger.sh"
else
    echo "错误: 找不到日志模块 ${LIB_DIR}/logger.sh"
    exit 1
fi

# 加载工具函数模块
if [[ -f "${LIB_DIR}/utils.sh" ]]; then
    source "${LIB_DIR}/utils.sh"
else
    log_error "找不到工具模块 ${LIB_DIR}/utils.sh"
    exit 1
fi

# 加载环境检测模块
if [[ -f "${LIB_DIR}/detector.sh" ]]; then
    source "${LIB_DIR}/detector.sh"
else
    log_error "找不到检测模块 ${LIB_DIR}/detector.sh"
    exit 1
fi

# 加载防火墙配置模块
if [[ -f "${LIB_DIR}/firewall.sh" ]]; then
    source "${LIB_DIR}/firewall.sh"
else
    log_error "找不到防火墙模块 ${LIB_DIR}/firewall.sh"
    exit 1
fi

# ==============================================================================
# 欢迎信息和权限检查
# ==============================================================================

show_welcome() {
    clear
    log_banner "RustDesk Server Docker 安装器"
    echo ""
    echo "版本: V1.0.0"
    echo "作者: 外星动物（常智）"
    echo "日期: 2026-04-12"
    echo ""
    log_separator
    echo ""
    echo "本脚本将帮助您在 Debian 服务器上部署 RustDesk 中继服务"
    echo ""
    echo "部署组件："
    echo "  • HBBS (ID/Rendezvous Server)"
    echo "  • HBBR (Relay Server)"
    echo ""
    echo "功能特性："
    echo "  • Docker 容器化部署"
    echo "  • 自动配置防火墙"
    echo "  • 持久化数据存储"
    echo "  • 自动重启保护"
    echo ""
    log_separator
    echo ""
}

check_root() {
    if ! is_root; then
        log_error "此脚本需要 root 权限运行"
        echo ""
        echo "请使用以下方式之一运行："
        echo "  sudo ./install.sh"
        echo "  sudo bash install.sh"
        echo ""
        exit 1
    fi
}

# ==============================================================================
# 交互式配置菜单
# ==============================================================================

show_config_menu() {
    log_blank
    log_title "配置选择"

    echo "请选择配置方式："
    echo ""
    echo "  1) 使用默认配置（推荐）"
    echo "     - 网络模式: host"
    echo "     - 强制中继: 否（自动模式）"
    echo "     - 数据目录: ./data"
    echo ""
    echo "  2) 自定义配置"
    echo ""
    echo "  3) 退出安装"
    echo ""

    read -p "请输入选择 [1-3]: " choice

    case "$choice" in
        1)
            return 0
            ;;
        2)
            return 1
            ;;
        3)
            log_info "用户取消安装"
            exit 0
            ;;
        *)
            log_error "无效选择"
            exit 1
            ;;
    esac
}

custom_config() {
    log_blank
    log_title "自定义配置"

    # 是否强制使用中继
    echo ""
    if prompt_yes_no "是否强制使用中继服务器？" "n"; then
        ALWAYS_USE_RELAY="Y"
    else
        ALWAYS_USE_RELAY="N"
    fi

    # 数据目录
    echo ""
    read -p "数据目录路径 [${DATA_DIR}]: " custom_data_dir
    if [[ -n "$custom_data_dir" ]]; then
        DATA_DIR="$custom_data_dir"
    fi

    # 端口偏移
    echo ""
    read -p "端口偏移量 [0]: " port_offset
    PORT_OFFSET="${port_offset:-0}"

    log_success "配置已保存"
}

# ==============================================================================
# 创建项目文件
# ==============================================================================

create_project_structure() {
    log_step "创建项目目录结构..."

    # 创建数据目录
    if [[ ! -d "$DATA_DIR" ]]; then
        mkdir -p "$DATA_DIR"
        log_success "创建数据目录: $DATA_DIR"
    else
        log_info "数据目录已存在: $DATA_DIR"
    fi

    # 创建 .env 文件
    if [[ ! -f "${INSTALL_DIR}/.env" ]]; then
        cp "${INSTALL_DIR}/.env.example" "${INSTALL_DIR}/.env"
        log_success "创建配置文件: .env"
    else
        log_info "配置文件已存在: .env"
    fi

    # 更新 .env 文件
    update_env_file
}

update_env_file() {
    log_step "更新配置文件..."

    local env_file="${INSTALL_DIR}/.env"

    if [[ -f "$env_file" ]]; then
        # 更新配置
        if [[ -n "${ALWAYS_USE_RELAY:-}" ]]; then
            sed -i "s/^ALWAYS_USE_RELAY=.*/ALWAYS_USE_RELAY=$ALWAYS_USE_RELAY/" "$env_file"
        fi

        if [[ -n "${DATA_DIR:-}" ]]; then
            sed -i "s|^DATA_DIR=.*|DATA_DIR=$DATA_DIR|" "$env_file"
        fi

        if [[ -n "${PORT_OFFSET:-}" ]]; then
            sed -i "s/^PORT_OFFSET=.*/PORT_OFFSET=$PORT_OFFSET/" "$env_file"
        fi

        log_success "配置文件已更新"
    fi
}

# ==============================================================================
# 生成密钥对
# ==============================================================================

generate_keys() {
    log_step "生成密钥对..."

    local id_ed25519="${DATA_DIR}/id_ed25519"
    local id_ed25519_pub="${DATA_DIR}/id_ed25519.pub"

    if [[ -f "$id_ed25519" ]] && [[ -f "$id_ed25519_pub" ]]; then
        log_info "密钥对已存在，跳过生成"
        return 0
    fi

    if command_exists ssh-keygen; then
        ssh-keygen -t ed25519 -f "$id_ed25519" -N "" -C "rustdesk@server" &>/dev/null
        if [[ $? -eq 0 ]]; then
            log_success "密钥对生成成功"
            log_info "私钥: $id_ed25519"
            log_info "公钥: $id_ed25519_pub"
            return 0
        else
            log_error "密钥对生成失败"
            return 1
        fi
    else
        log_warning "ssh-keygen 未安装，密钥将在容器首次启动时自动生成"
        return 0
    fi
}

# ==============================================================================
# 启动服务
# ==============================================================================

start_services() {
    log_blank
    log_title "启动 RustDesk 服务"

    cd "$INSTALL_DIR"

    # 检查 docker-compose.yml 是否存在
    if [[ ! -f "docker-compose.yml" ]]; then
        log_error "找不到 docker-compose.yml 文件"
        return 1
    fi

    # 确定使用的命令
    local compose_cmd="${DETECTION_RESULTS[compose_command]}"
    if [[ "$compose_cmd" == "N/A" ]]; then
        log_error "Docker Compose 未安装"
        return 1
    fi

    log_step "拉取 Docker 镜像..."
    $compose_cmd pull

    log_step "启动容器..."
    $compose_cmd up -d

    if [[ $? -eq 0 ]]; then
        log_success "服务启动成功"
        return 0
    else
        log_error "服务启动失败"
        return 1
    fi
}

# ==============================================================================
# 验证安装
# ==============================================================================

verify_installation() {
    log_blank
    log_title "验证安装"

    local compose_cmd="${DETECTION_RESULTS[compose_command]}"

    # 检查容器状态
    log_step "检查容器状态..."
    local hbbs_status=$(docker ps --filter "name=rustdesk-hbbs" --format "{{.Status}}")
    local hbbr_status=$(docker ps --filter "name=rustdesk-hbbr" --format "{{.Status}}")

    if [[ -n "$hbbs_status" ]]; then
        log_success "HBBS 容器运行中: $hbbs_status"
    else
        log_error "HBBS 容器未运行"
    fi

    if [[ -n "$hbbr_status" ]]; then
        log_success "HBBR 容器运行中: $hbbr_status"
    else
        log_error "HBBR 容器未运行"
    fi

    # 检查端口监听
    echo ""
    log_step "检查端口监听..."
    local ports=(21114 21115 21116 21117)
    for port in "${ports[@]}"; do
        if is_port_in_use "$port" "tcp"; then
            log_success "端口 $port/tcp 监听中"
        else
            log_warning "端口 $port/tcp 未监听"
        fi
    done

    # 检查日志
    echo ""
    log_step "检查容器日志..."
    echo ""
    echo "=== HBBS 最近日志 ==="
    docker logs --tail 10 rustdesk-hbbs 2>&1 || true
    echo ""
    echo "=== HBBR 最近日志 ==="
    docker logs --tail 10 rustdesk-hbbr 2>&1 || true
}

# ==============================================================================
# 显示连接信息
# ==============================================================================

show_connection_info() {
    log_blank
    log_title "连接信息"

    local server_ip=$(get_server_ip)
    local id_pub="${DATA_DIR}/id_ed25519.pub"

    echo "📡 服务器信息："
    echo ""
    echo "   服务器 IP: ${server_ip:-<请手动获取>}"
    echo "   HBBS 端口: 21116 (TCP/UDP)"
    echo "   HBBR 端口: 21117 (TCP)"
    echo ""

    if [[ -f "$id_pub" ]]; then
        echo "🔑 公钥内容："
        echo ""
        cat "$id_pub"
        echo ""
        echo "💡 客户端配置方法："
        echo ""
        echo "   1. 打开 RustDesk 客户端"
        echo "   2. 点击右上角三条菜单 -> ID 服务器"
        echo "   3. 输入以下信息："
        echo "      - ID 服务器: ${server_ip:-<服务器IP>}"
        echo "      - 上述公钥内容"
        echo "   4. 保存并重启 RustDesk"
        echo ""
    else
        echo "⚠️  公钥文件未找到，请检查容器日志"
        echo "   命令: docker logs rustdesk-hbbs"
    fi
}

# ==============================================================================
# 显示后续操作指引
# ==============================================================================

show_next_steps() {
    log_blank
    log_title "后续操作"

    echo "✅ 安装完成！以下是后续操作指引："
    echo ""
    echo "📋 常用命令："
    echo "   ./status.sh      - 查看服务状态"
    echo "   ./config.sh      - 管理配置"
    echo "   ./uninstall.sh   - 卸载服务"
    echo ""
    echo "📊 监控日志："
    echo "   docker logs -f rustdesk-hbbs    # 查看 HBBS 日志"
    echo "   docker logs -f rustdesk-hbbr    # 查看 HBBR 日志"
    echo ""
    echo "🔄 重启服务："
    echo "   docker restart rustdesk-hbbs rustdesk-hbbr"
    echo ""
    echo "📚 文档地址："
    echo "   - RustDesk 官网: https://rustdesk.com/"
    echo "   - 项目主页: https://github.com/changzhi777/mactools"
    echo ""
    echo "🐛 问题反馈："
    echo "   - GitHub Issues: https://github.com/changzhi777/mactools/issues"
    echo ""
}

# ==============================================================================
# 主安装流程
# ==============================================================================

main() {
    # 显示欢迎信息
    show_welcome

    # 检查 root 权限
    check_root

    # 环境检测
    detect_environment
    show_environment_report

    # 检查依赖
    if ! check_install_requirements; then
        log_blank
        log_error "环境检查未通过，请先解决上述问题"
        echo ""
        show_dependency_recommendations
        exit 1
    fi

    # 配置菜单
    if show_config_menu; then
        # 使用默认配置
        log_info "使用默认配置"
        ALWAYS_USE_RELAY="N"
        PORT_OFFSET="0"
    else
        # 自定义配置
        custom_config
    fi

    # 创建项目文件
    create_project_structure

    # 生成密钥对
    generate_keys

    # 配置防火墙
    configure_firewall

    # 启动服务
    if ! start_services; then
        log_error "服务启动失败"
        exit 1
    fi

    # 等待服务启动
    log_step "等待服务启动..."
    sleep 5

    # 验证安装
    verify_installation

    # 显示连接信息
    show_connection_info

    # 显示后续操作
    show_next_steps

    log_blank
    log_success "安装完成！"
    log_blank
}

# ==============================================================================
# 执行主流程
# ==============================================================================

main "$@"
