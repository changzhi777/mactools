#!/bin/bash
#
# ==============================================================================
# RustDesk Server Installer - 环境检测模块
# ==============================================================================
#
# 功能说明：
#   检测系统环境、Docker、端口占用等情况
#
# 使用方法：
#   source lib/detector.sh
#   detect_environment
#   show_environment_report
#
# ==============================================================================

# 检测结果存储
declare -A DETECTION_RESULTS

#
# 检测操作系统信息
#
detect_os_info() {
    local os_id=$(detect_os)
    local os_version=$(detect_os_version)

    DETECTION_RESULTS[os_id]="$os_id"
    DETECTION_RESULTS[os_version]="$os_version"

    # 检查是否为 Debian
    if [[ "$os_id" == "debian" ]]; then
        DETECTION_RESULTS[os_is_debian]="true"
        DETECTION_RESULTS[os_name]="Debian $os_version"
    else
        DETECTION_RESULTS[os_is_debian]="false"
        DETECTION_RESULTS[os_name]="$os_id $os_version"
    fi
}

#
# 检测 Docker 安装状态
#
detect_docker() {
    if command_exists docker; then
        DETECTION_RESULTS[docker_installed]="true"
        DETECTION_RESULTS[docker_version]=$(docker --version 2>/dev/null | awk '{print $3}' | sed 's/,//')

        # 检查 Docker 服务状态
        if systemctl is-active --quiet docker 2>/dev/null || service docker status &>/dev/null; then
            DETECTION_RESULTS[docker_running]="true"
        else
            DETECTION_RESULTS[docker_running]="false"
        fi
    else
        DETECTION_RESULTS[docker_installed]="false"
        DETECTION_RESULTS[docker_version]="N/A"
        DETECTION_RESULTS[docker_running]="false"
    fi
}

#
# 检测 Docker Compose 安装状态
#
detect_docker_compose() {
    # 检查 docker compose（v2 版本，作为 Docker 插件）
    if docker compose version &>/dev/null; then
        DETECTION_RESULTS[compose_installed]="true"
        DETECTION_RESULTS[compose_version]="v2 $(docker compose version --short 2>/dev/null)"
        DETECTION_RESULTS[compose_command]="docker compose"
    # 检查 docker-compose（v1 版本，独立命令）
    elif command_exists docker-compose; then
        DETECTION_RESULTS[compose_installed]="true"
        DETECTION_RESULTS[compose_version]="v1 $(docker-compose --version 2>/dev/null | awk '{print $3}' | sed 's/,//')"
        DETECTION_RESULTS[compose_command]="docker-compose"
    else
        DETECTION_RESULTS[compose_installed]="false"
        DETECTION_RESULTS[compose_version]="N/A"
        DETECTION_RESULTS[compose_command]="N/A"
    fi
}

#
# 检测端口占用情况
#
detect_ports() {
    local ports=(21114 21115 21116 21117 21118 21119)
    local occupied_ports=()

    for port in "${ports[@]}"; do
        if is_port_in_use "$port" "tcp"; then
            occupied_ports+=("$port/tcp")
        fi
        if [[ "$port" == "21116" ]] && is_port_in_use "$port" "udp"; then
            occupied_ports+=("$port/udp")
        fi
    done

    if [[ ${#occupied_ports[@]} -gt 0 ]]; then
        DETECTION_RESULTS[ports_available]="false"
        DETECTION_RESULTS[occupied_ports]="${occupied_ports[*]}"
    else
        DETECTION_RESULTS[ports_available]="true"
        DETECTION_RESULTS[occupied_ports]=""
    fi
}

#
# 检测防火墙类型
#
detect_firewall() {
    local firewall_type="none"

    # 检测 UFW
    if command_exists ufw; then
        if ufw status | grep -q "Status: active"; then
            firewall_type="ufw"
        fi
    fi

    # 检测 firewalld
    if [[ "$firewall_type" == "none" ]] && command_exists firewall-cmd; then
        if systemctl is-active --quiet firewalld 2>/dev/null; then
            firewall_type="firewalld"
        fi
    fi

    # 检测 iptables
    if [[ "$firewall_type" == "none" ]] && command_exists iptables; then
        if iptables -L -n 2>/dev/null | grep -q "Chain"; then
            firewall_type="iptables"
        fi
    fi

    DETECTION_RESULTS[firewall_type]="$firewall_type"
}

#
# 检测网络连接
#
detect_network() {
    if check_network "8.8.8.8" "53"; then
        DETECTION_RESULTS[network_available]="true"
    else
        DETECTION_RESULTS[network_available]="false"
    fi
}

#
# 检测系统资源
#
detect_system_resources() {
    # 检查磁盘空间（当前目录）
    local available_space=$(df -BG . 2>/dev/null | tail -1 | awk '{print $4}' | sed 's/G//')
    DETECTION_RESULTS[disk_space_gb]="$available_space"

    # 检查内存
    if [[ -f /proc/meminfo ]]; then
        local total_mem_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
        local total_mem_gb=$((total_mem_kb / 1024 / 1024))
        DETECTION_RESULTS[memory_gb]="$total_mem_gb"
    else
        DETECTION_RESULTS[memory_gb]="N/A"
    fi

    # 检查 CPU 核心数
    if command_exists nproc; then
        DETECTION_RESULTS[cpu_cores]=$(nproc)
    else
        DETECTION_RESULTS[cpu_cores]="N/A"
    fi
}

#
# 执行完整环境检测
#
detect_environment() {
    log_step "正在检测系统环境..."

    detect_os_info
    detect_docker
    detect_docker_compose
    detect_ports
    detect_firewall
    detect_network
    detect_system_resources

    log_success "环境检测完成"
}

#
# 获取检测结果
# 参数：$1=结果键名
#
get_detection_result() {
    local key="$1"
    echo "${DETECTION_RESULTS[$key]}"
}

#
# 显示环境检测结果
#
show_environment_report() {
    log_blank
    log_title "环境检测报告"

    # 操作系统信息
    echo "📋 操作系统："
    echo "   - 类型: ${DETECTION_RESULTS[os_name]}"
    echo "   - Debian: $([ "${DETECTION_RESULTS[os_is_debian]}" == "true" ] && echo "✅ 是" || echo "❌ 否")"

    # Docker 信息
    echo ""
    echo "🐳 Docker 环境："
    echo "   - Docker: $([ "${DETECTION_RESULTS[docker_installed]}" == "true" ] && echo "✅ 已安装 (${DETECTION_RESULTS[docker_version]})" || echo "❌ 未安装")"
    echo "   - Docker 运行: $([ "${DETECTION_RESULTS[docker_running]}" == "true" ] && echo "✅ 运行中" || echo "❌ 未运行")"
    echo "   - Docker Compose: $([ "${DETECTION_RESULTS[compose_installed]}" == "true" ] && echo "✅ 已安装 (${DETECTION_RESULTS[compose_version]})" || echo "❌ 未安装")"

    # 端口信息
    echo ""
    echo "🔌 端口状态："
    if [[ "${DETECTION_RESULTS[ports_available]}" == "true" ]]; then
        echo "   - 状态: ✅ 所有必需端口可用"
        echo "   - 需要的端口: 21114-21119/TCP, 21116/UDP"
    else
        echo "   - 状态: ⚠️  部分端口已被占用"
        echo "   - 占用端口: ${DETECTION_RESULTS[occupied_ports]}"
    fi

    # 防火墙信息
    echo ""
    echo "🛡️  防火墙："
    local fw="${DETECTION_RESULTS[firewall_type]}"
    case "$fw" in
        ufw)
            echo "   - 类型: UFW"
            echo "   - 状态: ✅ 检测到 UFW"
            ;;
        firewalld)
            echo "   - 类型: firewalld"
            echo "   - 状态: ✅ 检测到 firewalld"
            ;;
        iptables)
            echo "   - 类型: iptables"
            echo "   - 状态: ✅ 检测到 iptables"
            ;;
        none)
            echo "   - 类型: 无"
            echo "   - 状态: ⚠️  未检测到防火墙"
            ;;
    esac

    # 网络信息
    echo ""
    echo "🌐 网络："
    echo "   - 外网连接: $([ "${DETECTION_RESULTS[network_available]}" == "true" ] && echo "✅ 正常" || echo "❌ 异常")"
    local server_ip=$(get_server_ip)
    if [[ -n "$server_ip" ]]; then
        echo "   - 服务器 IP: $server_ip"
    fi

    # 系统资源
    echo ""
    echo "💻 系统资源："
    echo "   - 磁盘空间: ${DETECTION_RESULTS[disk_space_gb]} GB 可用"
    echo "   - 内存: ${DETECTION_RESULTS[memory_gb]} GB"
    echo "   - CPU 核心: ${DETECTION_RESULTS[cpu_cores]}"

    log_blank
}

#
# 显示安装依赖建议
#
show_dependency_recommendations() {
    local needs_recommendation=false

    log_blank
    log_title "依赖安装建议"

    # Docker 检查
    if [[ "${DETECTION_RESULTS[docker_installed]}" == "false" ]]; then
        echo "❌ Docker 未安装"
        echo ""
        echo "📦 安装 Docker（Debian）："
        cat << 'EOF'
    # 1. 更新包索引
    sudo apt-get update

    # 2. 安装依赖
    sudo apt-get install -y ca-certificates curl gnupg lsb-release

    # 3. 添加 Docker 官方 GPG 密钥
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    # 4. 设置 Docker 仓库
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # 5. 安装 Docker Engine
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # 6. 启动 Docker
    sudo systemctl start docker
    sudo systemctl enable docker
EOF
        needs_recommendation=true
    fi

    # Docker Compose 检查
    if [[ "${DETECTION_RESULTS[docker_installed]}" == "true" ]] && [[ "${DETECTION_RESULTS[compose_installed]}" == "false" ]]; then
        echo ""
        echo "❌ Docker Compose 未安装"
        echo ""
        echo "📦 安装 Docker Compose："
        cat << 'EOF'
    # Docker Compose v2 作为 Docker 插件包含在 Docker 安装中
    # 如果未安装，请重新安装 Docker 或单独安装：

    # 方法 1: 使用 apt（推荐）
    sudo apt-get install -y docker-compose-plugin

    # 方法 2: 手动下载
    sudo curl -SL https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
EOF
        needs_recommendation=true
    fi

    if [[ "$needs_recommendation" == "false" ]]; then
        log_success "所有依赖已满足！"
    else
        echo ""
        log_warning "请先安装缺失的依赖，然后重新运行此脚本"
        return 1
    fi

    return 0
}

#
# 检查环境是否满足安装要求
# 返回：0=满足, 1=不满足
#
check_install_requirements() {
    local errors=0

    # 检查操作系统
    if [[ "${DETECTION_RESULTS[os_is_debian]}" != "true" ]]; then
        log_warning "此脚本专为 Debian 系统优化，您的系统是 ${DETECTION_RESULTS[os_name]}"
        ((errors++))
    fi

    # 检查 Docker
    if [[ "${DETECTION_RESULTS[docker_installed]}" != "true" ]]; then
        log_error "Docker 未安装"
        ((errors++))
    fi

    # 检查 Docker Compose
    if [[ "${DETECTION_RESULTS[compose_installed]}" != "true" ]]; then
        log_error "Docker Compose 未安装"
        ((errors++))
    fi

    # 检查端口
    if [[ "${DETECTION_RESULTS[ports_available]}" != "true" ]]; then
        log_warning "部分端口已被占用: ${DETECTION_RESULTS[occupied_ports]}"
        ((errors++))
    fi

    return $errors
}
