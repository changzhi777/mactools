#!/bin/bash
#
# MacClaw Installer - 工具函数模块
# 作者: 外星动物（常智）
# 组织: IoTchange
# 邮箱: 14455975@qq.com
# 版本: V1.0.1
# 版权: Copyright (C) 2026 IoTchange - All Rights Reserved
#
# 说明: 提供通用的工具函数
#

# 加载日志模块（支持在线安装模式）
if [ -n "$MACCLAW_LIB_DIR" ]; then
    source "$MACCLAW_LIB_DIR/logger.sh"
else
    source "$(dirname "$0")/logger.sh"
fi

# 显示欢迎界面
show_welcome() {
    clear
    cat << "EOF"
╔════════════════════════════════════════════════════════════╗
║              🦞 MacClaw 一键安装器 V1.0.1                   ║
║       OpenClaw + oMLX 本地 AI 模型完整安装                  ║
╚════════════════════════════════════════════════════════════╝

作者: 外星动物（常智）
组织: IoTchange
邮箱: 14455975@qq.com
版权: Copyright (C) 2026 IoTchange

本项目将自动安装以下组件：
  • Node.js (通过 nvm)
  • OpenClaw CLI
  • oMLX 本地推理服务
  • gemma-4-e4b-it-4bit AI 模型
  • Agent & Skills (可选)

按 Enter 继续，或 Ctrl+C 退出...
EOF
    # 检测是否在管道模式下，如果是则跳过等待
    if [ -t 0 ]; then
        # 终端模式，正常等待用户输入
        read
    else
        # 管道模式（curl | sh），跳过等待自动继续
        log_info "检测到在线安装模式，自动继续..."
        sleep 1
    fi
}

# 显示配置国内源
show_sources_config() {
    cat << "EOF"
⚙️  配置国内源（优化下载速度）

将配置以下国内镜像源：
  ✅ npm: 淘宝镜像
  ✅ pip: 清华大学镜像
  ✅ ModelScope: Hugging Face 镜像
  ✅ GitHub: Gitee 镜像

这将显著提升下载速度...
EOF
}

# 交互式选择组件
select_components() {
    local components=(
        "Node.js (通过 nvm) [推荐]"
        "OpenClaw CLI"
        "oMLX 服务"
        "gemma-4-e4b-it-4bit 模型 (约4GB)"
        "创建默认 Agent"
        "安装常用 Skills"
    )

    local selected=()

    echo ""
    echo "📦 选择要安装的组件："
    echo ""

    for i in "${!components[@]}"; do
        local num=$((i + 1))
        local status="[ ]"
        if [ "${selected[$i]}" == "true" ]; then
            status="[✓]"
        fi
        echo "  [$num] $status ${components[$i]}"
    done

    echo ""
    echo "操作说明:"
    echo "  - 输入序号切换选择状态"
    echo "  - 输入 'all' 选择全部"
    echo "  - 输入 'none' 取消全部"
    echo "  - 按 Enter 确认选择"
    echo ""
    echo -n "请选择: "

    local choice
    if [ -t 0 ]; then
        # 终端模式，正常读取用户输入
        read choice
    else
        # 管道模式，默认选择全部
        log_info "检测到在线安装模式，默认选择全部组件..."
        choice="all"
        sleep 1
    fi

    case "$choice" in
        all)
            for i in "${!components[@]}"; do
                selected[$i]=true
            done
            ;;
        none)
            for i in "${!components[@]}"; do
                selected[$i]=false
            done
            ;;
        "")
            # 默认选择全部
            for i in "${!components[@]}"; do
                selected[$i]=true
            done
            ;;
        *)
            if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#components[@]}" ]; then
                local idx=$((choice - 1))
                if [ "${selected[$idx]}" == "true" ]; then
                    selected[$idx]=false
                else
                    selected[$idx]=true
                fi
            fi
            ;;
    esac

    # 导出选择结果
    export INSTALL_COMPONENTS=()
    for i in "${!selected[@]}"; do
        if [ "${selected[$i]}" == "true" ]; then
            INSTALL_COMPONENTS+=("${components[$i]}")
        fi
    done

    log_info "已选择组件: ${INSTALL_COMPONENTS[*]}"
}

# 显示进度条
show_progress() {
    local current=$1
    local total=$2
    local message=${3:-"处理中"}
    local percent=$((current * 100 / total))

    local filled=$((percent / 2))
    local empty=$((50 - filled))

    printf "\r["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "] %d%% (%s)" "$percent" "$message"
}

# 下载文件
download_file() {
    local url="$1"
    local output="$2"
    local description=${3:-"文件"}

    log_info "📥 下载 $description..."

    if command -v curl &>/dev/null; then
        curl -fsSL "$url" -o "$output" || {
            log_error "❌ 下载失败: $url"
            return 1
        }
    elif command -v wget &>/dev/null; then
        wget -q "$url" -O "$output" || {
            log_error "❌ 下载失败: $url"
            return 1
        }
    else
        log_error "❌ 缺少下载工具 (curl 或 wget)"
        return 1
    fi

    log_success "✅ 下载完成: $output"
    return 0
}

# 检查命令是否存在
command_exists() {
    command -v "$1" &>/dev/null
}

# 确认操作
confirm_action() {
    local message="$1"
    local default=${2:-"n"}

    echo -n "$message [y/N]: "
    local response

    if [ -t 0 ]; then
        # 终端模式，正常读取用户输入
        read response
    else
        # 管道模式，使用默认值
        log_info "检测到在线安装模式，使用默认值: $default"
        response="$default"
        sleep 1
    fi

    if [ -z "$response" ]; then
        response="$default"
    fi

    case "$response" in
        [Yy]|[Yy][Ee][Ss])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# 检查是否为 root
check_root() {
    if [ "$EUID" -eq 0 ]; then
        log_warning "⚠️  不建议以 root 权限运行此脚本"
        return 0
    else
        return 1
    fi
}

# 获取临时目录
get_temp_dir() {
    echo "/tmp/macclaw-installer-$$"
}

# 清理临时文件
cleanup_temp() {
    local temp_dir=$(get_temp_dir)
    if [ -d "$temp_dir" ]; then
        log_info "🧹 清理临时文件..."
        rm -rf "$temp_dir"
        log_success "✅ 清理完成"
    fi
}

# 显示错误并退出
error_exit() {
    local message="$1"
    local code=${2:-1}

    log_error "$message"
    exit "$code"
}

# 检查上一个命令是否成功
check_success() {
    if [ $? -eq 0 ]; then
        log_success "✅ 操作成功"
        return 0
    else
        log_error "❌ 操作失败"
        return 1
    fi
}

# 等待按键
wait_for_key() {
    echo ""
    echo -n "按 Enter 继续..."
    if [ -t 0 ]; then
        # 终端模式，正常等待用户输入
        read
    else
        # 管道模式，自动继续
        log_info "检测到在线安装模式，自动继续..."
        sleep 1
    fi
}

# 显示分隔线
show_separator() {
    echo ""
    echo "=========================================="
    echo ""
}

# 检测操作系统版本
get_os_version() {
    sw_vers -productVersion
}

# 检测 CPU 架构
get_cpu_arch() {
    uname -m
}

# 检查是否为 Apple Silicon
is_apple_silicon() {
    [ "$(uname -m)" == "arm64" ]
}

# 检查是否为 Intel
is_intel() {
    [ "$(uname -m)" == "x86_64" ]
}

# 获取 Home 目录
get_home_dir() {
    echo "$HOME"
}

# 创建目录（如果不存在）
ensure_dir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
    fi
}

# 备份文件
backup_file() {
    local file="$1"
    if [ -f "$file" ]; then
        local backup="${file}.backup.$(date +%Y%m%d%H%M%S)"
        cp "$file" "$backup"
        log_info "📦 已备份: $backup"
    fi
}

# 导出函数
export -f show_welcome
export -f show_sources_config
export -f select_components
export -f show_progress
export -f download_file
export -f command_exists
export -f confirm_action
export -f check_root
export -f get_temp_dir
export -f cleanup_temp
export -f error_exit
export -f check_success
export -f wait_for_key
export -f show_separator
export -f get_os_version
export -f get_cpu_arch
export -f is_apple_silicon
export -f is_intel
export -f get_home_dir
export -f ensure_dir
export -f backup_file
