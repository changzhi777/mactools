#!/bin/bash
#
# ==============================================================================
# RustDesk Server - 状态检查脚本
# ==============================================================================
#
# 功能说明：
#   检查 RustDesk 服务运行状态和健康情况
#
# 使用方法：
#   chmod +x status.sh
#   ./status.sh
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

# ==============================================================================
# 容器状态检查
# ==============================================================================

check_container_status() {
    log_title "容器状态"

    local hbbs_running=false
    local hbbr_running=false

    # 检查 HBBS
    if docker ps --format "{{.Names}}" | grep -q "rustdesk-hbbs"; then
        hbbs_running=true
        local hbbs_status=$(docker ps --filter "name=rustdesk-hbbs" --format "{{.Status}}")
        echo "✅ HBBS 容器: $hbbs_status"
    else
        echo "❌ HBBS 容器: 未运行"
    fi

    # 检查 HBBR
    if docker ps --format "{{.Names}}" | grep -q "rustdesk-hbbr"; then
        hbbr_running=true
        local hbbr_status=$(docker ps --filter "name=rustdesk-hbbr" --format "{{.Status}}")
        echo "✅ HBBR 容器: $hbbr_status"
    else
        echo "❌ HBBR 容器: 未运行"
    fi

    echo ""

    if [[ "$hbbs_running" == "true" ]] && [[ "$hbbr_running" == "true" ]]; then
        return 0
    else
        return 1
    fi
}

# ==============================================================================
# 端口监听检查
# ==============================================================================

check_port_listening() {
    log_title "端口监听状态"

    local ports=(21114 21115 21116 21117 21118 21119)
    local all_ok=true

    echo "HBBS 端口："
    echo "  21114/tcp (Web 控制台):     $(is_port_in_use 21114 tcp && echo "✅ 监听中" || echo "❌ 未监听")"
    echo "  21115/tcp (NAT 测试):       $(is_port_in_use 21115 tcp && echo "✅ 监听中" || echo "❌ 未监听")"
    echo "  21116/tcp (ID 注册):        $(is_port_in_use 21116 tcp && echo "✅ 监听中" || echo "❌ 未监听")"
    echo "  21116/udp (心跳):           $(is_port_in_use 21116 udp && echo "✅ 监听中" || echo "❌ 未监听")"
    echo "  21118/tcp (Web 客户端):     $(is_port_in_use 21118 tcp && echo "✅ 监听中" || echo "❌ 未监听")"
    echo ""
    echo "HBBR 端口："
    echo "  21117/tcp (中继服务):       $(is_port_in_use 21117 tcp && echo "✅ 监听中" || echo "❌ 未监听")"
    echo "  21119/tcp (Web 客户端):     $(is_port_in_use 21119 tcp && echo "✅ 监听中" || echo "❌ 未监听")"

    echo ""
}

# ==============================================================================
# 容器资源使用
# ==============================================================================

check_resource_usage() {
    log_title "资源使用情况"

    echo "容器资源使用："
    docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" \
        $(docker ps --format "{{.Names}}" | grep -E "rustdesk-hbbs|rustdesk-hbbr") 2>/dev/null || \
        echo "  无法获取资源使用信息"

    echo ""
}

# ==============================================================================
# 查看最近日志
# ==============================================================================

check_recent_logs() {
    log_title "最近日志"

    echo "=== HBBS 最近日志（最后 10 行）==="
    docker logs --tail 10 rustdesk-hbbs 2>&1 || echo "  无法获取日志"
    echo ""
    echo "=== HBBR 最近日志（最后 10 行）==="
    docker logs --tail 10 rustdesk-hbbr 2>&1 || echo "  无法获取日志"
    echo ""
}

# ==============================================================================
# 显示连接信息
# ==============================================================================

show_connection_info() {
    log_title "连接信息"

    local server_ip=$(get_server_ip)
    local id_pub="${DATA_DIR}/id_ed25519.pub"

    echo "📡 服务器地址："
    echo "   IP 地址: ${server_ip:-<请手动获取>}"
    echo "   ID 服务器端口: 21116"
    echo "   中继服务器端口: 21117"
    echo ""

    if [[ -f "$id_pub" ]]; then
        echo "🔑 公钥内容："
        cat "$id_pub"
    else
        echo "⚠️  公钥文件不存在: $id_pub"
    fi

    echo ""
}

# ==============================================================================
# 显示数据目录信息
# ==============================================================================

show_data_info() {
    log_title "数据目录信息"

    echo "📂 数据目录: $DATA_DIR"

    if [[ -d "$DATA_DIR" ]]; then
        echo "📊 目录大小: $(get_dir_size "$DATA_DIR")"
        echo ""
        echo "📁 数据文件："
        ls -lh "$DATA_DIR" 2>/dev/null || echo "  (空目录)"
    else
        echo "❌ 数据目录不存在"
    fi

    echo ""
}

# ==============================================================================
# 综合健康检查
# ==============================================================================

health_check() {
    log_title "健康检查报告"

    local issues=0

    # 检查容器
    if docker ps --format "{{.Names}}" | grep -q "rustdesk-hbbs"; then
        echo "✅ HBBS 容器运行正常"
    else
        echo "❌ HBBS 容器未运行"
        ((issues++))
    fi

    if docker ps --format "{{.Names}}" | grep -q "rustdesk-hbbr"; then
        echo "✅ HBBR 容器运行正常"
    else
        echo "❌ HBBR 容器未运行"
        ((issues++))
    fi

    # 检查端口
    if is_port_in_use 21116 tcp; then
        echo "✅ HBBS 端口监听正常"
    else
        echo "❌ HBBS 端口未监听"
        ((issues++))
    fi

    if is_port_in_use 21117 tcp; then
        echo "✅ HBBR 端口监听正常"
    else
        echo "❌ HBBR 端口未监听"
        ((issues++))
    fi

    # 检查密钥
    if [[ -f "${DATA_DIR}/id_ed25519" ]] && [[ -f "${DATA_DIR}/id_ed25519.pub" ]]; then
        echo "✅ 密钥对完整"
    else
        echo "⚠️  密钥对不完整"
        ((issues++))
    fi

    echo ""

    if [[ $issues -eq 0 ]]; then
        log_success "所有检查通过，服务运行正常！"
        return 0
    else
        log_warning "发现 $issues 个问题，请检查上述详情"
        return 1
    fi
}

# ==============================================================================
# 主菜单
# ==============================================================================

show_menu() {
    clear
    log_banner "RustDesk Server 状态检查"
    echo ""
    echo "  1) 完整状态报告"
    echo "  2) 容器状态"
    echo "  3) 端口监听状态"
    echo "  4) 资源使用情况"
    echo "  5) 查看最近日志"
    echo "  6) 连接信息"
    echo "  7) 数据目录信息"
    echo "  8) 健康检查"
    echo "  0) 退出"
    echo ""
}

# ==============================================================================
# 主流程
# ==============================================================================

main() {
    # 如果有命令行参数，直接执行对应功能
    if [[ $# -gt 0 ]]; then
        case "$1" in
            health|check)
                health_check
                exit $?
                ;;
            logs)
                check_recent_logs
                exit 0
                ;;
            *)
                echo "用法: $0 [health|logs]"
                exit 1
                ;;
        esac
    fi

    # 交互式菜单
    while true; do
        show_menu
        read -p "请输入选择: " choice

        case "$choice" in
            1)
                check_container_status
                check_port_listening
                check_resource_usage
                show_connection_info
                show_data_info
                pause
                ;;
            2)
                check_container_status
                pause
                ;;
            3)
                check_port_listening
                pause
                ;;
            4)
                check_resource_usage
                pause
                ;;
            5)
                check_recent_logs
                pause
                ;;
            6)
                show_connection_info
                pause
                ;;
            7)
                show_data_info
                pause
                ;;
            8)
                health_check
                pause
                ;;
            0)
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
