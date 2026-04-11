#!/bin/bash
#
# MacClaw Installer - 环境检测模块
# 作者: 外星动物（常智）
# 组织: IoTchange
# 邮箱: 14455975@qq.com
# 版本: V1.0.1
# 版权: Copyright (C) 2026 IoTchange - All Rights Reserved
#
# 说明: 检测 macOS 系统环境、已安装软件和硬件配置
#

# 加载日志模块
source "$(dirname "$0")/logger.sh"

# 检测 macOS 版本
detect_macos_version() {
    local version=$(sw_vers -productVersion)
    local build=$(sw_vers -buildVersion)
    log_info "macOS 版本: $version (构建: $build)"

    # 检查版本是否满足要求
    local major=$(echo "$version" | cut -d. -f1)
    if [ "$major" -lt 12 ]; then
        log_error "macOS 版本过低，需要 macOS 12 或更高版本"
        return 1
    fi

    log_success "✅ macOS 版本满足要求"
    return 0
}

# 检测 CPU 架构
detect_cpu_arch() {
    local arch=$(uname -m)
    log_info "CPU 架构: $arch"

    case "$arch" in
        arm64)
            log_success "✅ Apple Silicon (M1/M2/M3)"
            return 0
            ;;
        x86_64)
            log_success "✅ Intel Mac"
            return 0
            ;;
        *)
            log_warning "⚠️  未知架构: $arch"
            return 1
            ;;
    esac
}

# 检测内存大小
detect_memory() {
    local memory_gb=$(sysctl -n hw.memsize)
    memory_gb=$((memory_gb / 1024 / 1024 / 1024))
    log_info "系统内存: ${memory_gb}GB"

    if [ "$memory_gb" -lt 16 ]; then
        log_warning "⚠️  内存不足 16GB，可能影响性能"
        return 1
    elif [ "$memory_gb" -ge 24 ]; then
        log_success "✅ 内存充足，推荐配置"
        return 0
    else
        log_success "✅ 内存满足基本要求"
        return 0
    fi
}

# 检测可用磁盘空间
detect_disk_space() {
    local available_gb=$(df -h / | tail -1 | awk '{print $4}')
    available_gb=${available_GB%G}  # 移除 G 后缀
    log_info "可用磁盘空间: $available_gb"

    local available_mb=$(df -m / | tail -1 | awk '{print $4}')
    if [ "$available_mb" -lt 20480 ]; then  # 20GB = 20480MB
        log_error "❌ 磁盘空间不足，需要至少 20GB"
        return 1
    fi

    log_success "✅ 磁盘空间充足"
    return 0
}

# 检测 Xcode Command Line Tools
detect_xcode_tools() {
    log_info "🔍 检测 Xcode Command Line Tools..."

    if xcode-select -p &>/dev/null; then
        local version=$(pkgutil --pkg-info=com.apple.pkg.CLTools_Executables 2>/dev/null | grep version | cut -d' ' -f3)
        log_success "✅ Xcode Command Line Tools 已安装 (版本: $version)"
        return 0
    else
        log_warning "⚠️  Xcode Command Line Tools 未安装"
        return 1
    fi
}

# 安装 Xcode Command Line Tools
install_xcode_tools() {
    log_info "📦 正在安装 Xcode Command Line Tools..."
    log_warning "⚠️  系统将弹出安装窗口，请点击\"安装\"按钮"
    log_warning "⚠️  安装过程可能需要几分钟，请耐心等待"

    # 触发安装
    xcode-select --install &>/dev/null

    # 等待安装完成
    log_info "⏳ 等待安装完成..."
    local max_wait=300  # 最多等待5分钟
    local waited=0

    while [ $waited -lt $max_wait ]; do
        if xcode-select -p &>/dev/null; then
            log_success "✅ Xcode Command Line Tools 安装完成"
            return 0
        fi
        sleep 5
        waited=$((waited + 5))
        echo -n "."
    done

    log_error "❌ 安装超时，请手动安装后重试"
    log_info "💡 手动安装命令: xcode-select --install"
    return 1
}

# 验证 Xcode Tools
verify_xcode_tools() {
    local required_commands=("git" "clang" "make" "python3")
    local missing=()

    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done

    if [ ${#missing[@]} -eq 0 ]; then
        log_success "✅ 所有必要工具可用"
        return 0
    else
        log_warning "⚠️  缺少工具: ${missing[*]}"
        return 1
    fi
}

# 检测 Python
detect_python() {
    log_info "🔍 检测 Python..."

    if command -v python3 &>/dev/null; then
        local version=$(python3 --version)
        log_success "✅ $version 已安装"
        return 0
    else
        log_warning "⚠️  Python 未安装"
        return 1
    fi
}

# 检测 Node.js
detect_nodejs() {
    log_info "🔍 检测 Node.js..."

    if command -v node &>/dev/null; then
        local version=$(node --version)
        log_success "✅ Node.js $version 已安装"
        return 0
    else
        log_warning "⚠️  Node.js 未安装（将自动安装）"
        return 1
    fi
}

# 检测 npm
detect_npm() {
    log_info "🔍 检测 npm..."

    if command -v npm &>/dev/null; then
        local version=$(npm --version)
        log_success "✅ npm $version 已安装"
        return 0
    else
        log_warning "⚠️  npm 未安装（将自动安装）"
        return 1
    fi
}

# 检测 OpenClaw
detect_openclaw() {
    log_info "🔍 检测 OpenClaw..."

    if command -v openclaw &>/dev/null; then
        local version=$(openclaw --version 2>/dev/null | head -1)
        log_success "✅ OpenClaw 已安装 ($version)"
        return 0
    else
        log_warning "⚠️  OpenClaw 未安装（将自动安装）"
        return 1
    fi
}

# 检测 oMLX
detect_omlx() {
    log_info "🔍 检测 oMLX..."

    if [ -d "/Applications/oMLX.app" ]; then
        log_success "✅ oMLX 已安装"

        # 检查服务是否运行
        if curl -s http://127.0.0.1:8008/health &>/dev/null; then
            log_success "✅ oMLX 服务运行中"
            return 0
        else
            log_warning "⚠️  oMLX 已安装但服务未运行"
            return 1
        fi
    else
        log_warning "⚠️  oMLX 未安装（将自动安装）"
        return 1
    fi
}

# 检测网络连接
detect_network() {
    log_info "🔍 检测网络连接..."

    if ping -c 1 8.8.8.8 &>/dev/null; then
        log_success "✅ 网络连接正常"
        return 0
    else
        log_error "❌ 网络连接失败"
        return 1
    fi
}

# 检测端口占用
detect_port_usage() {
    local port="$1"
    local service_name="$2"

    log_info "🔍 检测端口 $port ($service_name)..."

    if lsof -i :"$port" &>/dev/null; then
        log_warning "⚠️  端口 $port 已被占用"
        local pid=$(lsof -ti :"$port")
        log_info "占用进程 PID: $pid"
        return 1
    else
        log_success "✅ 端口 $port 可用"
        return 0
    fi
}

# 综合环境检测
detect_environment() {
    log_info "🔍 开始环境检测..."
    echo ""

    local errors=0

    # 基础环境检测
    detect_macos_version || ((errors++))
    detect_cpu_arch || ((errors++))
    detect_memory || ((errors++))
    detect_disk_space || ((errors++))
    detect_network || ((errors++))

    echo ""

    # 开发工具检测
    detect_xcode_tools || {
        log_warning "将尝试安装 Xcode Command Line Tools..."
        install_xcode_tools || ((errors++))
    }

    echo ""

    # 软件检测
    detect_python || ((errors++))
    detect_nodejs
    detect_npm
    detect_openclaw
    detect_omlx

    echo ""

    # 端口检测
    detect_port_usage 18789 "OpenClaw Gateway"
    detect_port_usage 8008 "oMLX"

    echo ""

    if [ $errors -eq 0 ]; then
        log_success "✅ 环境检测完成，所有必要条件满足"
        return 0
    else
        log_warning "⚠️  环境检测完成，发现 $errors 个问题"
        return 1
    fi
}

# 导出函数
export -f detect_macos_version
export -f detect_cpu_arch
export -f detect_memory
export -f detect_disk_space
export -f detect_xcode_tools
export -f install_xcode_tools
export -f verify_xcode_tools
export -f detect_python
export -f detect_nodejs
export -f detect_npm
export -f detect_openclaw
export -f detect_omlx
export -f detect_network
export -f detect_port_usage
export -f detect_environment
