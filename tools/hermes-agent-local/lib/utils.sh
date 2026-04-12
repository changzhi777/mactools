#!/bin/bash
#
# 工具函数模块
#
# 作者: 外星动物（常智）
# 组织: IoTchange
# 邮箱: 14455975@qq.com
# 版权: Copyright (C) 2026 IoTchange - All Rights Reserved
#
# 描述: 通用工具函数集合
#

# 获取库文件所在目录
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 加载依赖库（同目录下的其他库）
# shellcheck source=lib/logger.sh
source "${LIB_DIR}/logger.sh"

# ============================================================================
# 版本比较
# ============================================================================

# 提取命令版本号
# 参数: $1=命令名, $2=字段索引(默认2)
# 返回: 版本号字符串
extract_version() {
    local cmd="$1"
    local field="${2:-2}"

    if ! command -v "$cmd" &>/dev/null; then
        return 1
    fi

    $cmd --version 2>&1 | awk -v f="$field" '{print $f}'
}

# 比较两个版本号
# 返回: 0=相等, 1=版本1>版本2, 2=版本1<版本2
version_compare() {
    if [[ "$1" == "$2" ]]; then
        return 0
    fi

    local IFS=.
    local i ver1=($1) ver2=($2)

    # 填充空位
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++)); do
        ver1[i]=0
    done
    for ((i=${#ver2[@]}; i<${#ver1[@]}; i++)); do
        ver2[i]=0
    done

    for ((i=0; i<${#ver1[@]}; i++)); do
        if [[ -z ${ver2[i]:-} ]]; then
            return 1
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]})); then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]})); then
            return 2
        fi
    done

    return 0
}

# ============================================================================
# 文件操作
# ============================================================================

# 安全删除文件
safe_remove() {
    local file="$1"

    if [[ -f "$file" ]]; then
        if rm -f "$file"; then
            log_debug "已删除: $file"
            return 0
        else
            log_error "删除失败: $file"
            return 1
        fi
    fi

    return 0
}

# 备份文件
backup_file() {
    local file="$1"
    local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"

    if [[ -f "$file" ]]; then
        if cp "$file" "$backup"; then
            log_info "已备份: $backup"
            echo "$backup"
            return 0
        else
            log_error "备份失败: $file"
            return 1
        fi
    fi

    return 0
}

# 创建目录（带权限）
create_dir() {
    local dir="$1"
    local perms="${2:-755}"

    if [[ ! -d "$dir" ]]; then
        if mkdir -p "$dir"; then
            chmod "$perms" "$dir"
            log_debug "已创建目录: $dir"
            return 0
        else
            log_error "创建目录失败: $dir"
            return 1
        fi
    fi

    return 0
}

# ============================================================================
# 下载工具
# ============================================================================

# 下载文件（支持 curl 和 wget）
download_file() {
    local url="$1"
    local output="$2"

    if command -v curl &>/dev/null; then
        log_debug "下载文件 (curl): $url"
        if curl -fsSL "$url" -o "$output"; then
            return 0
        fi
    elif command -v wget &>/dev/null; then
        log_debug "下载文件 (wget): $url"
        if wget -q "$url" -O "$output"; then
            return 0
        fi
    else
        log_error "未找到下载工具（curl 或 wget）"
        return 1
    fi

    log_error "下载失败: $url"
    return 1
}

# ============================================================================
# 字符串处理
# ============================================================================

# 去除字符串首尾空格
trim() {
    local var="$*"
    # 移除前导空格
    var="${var#"${var%%[![:space:]]*}"}"
    # 移除尾部空格
    var="${var%"${var##*[![:space:]]}"}"
    printf '%s' "$var"
}

# 检查字符串是否为空
is_empty() {
    local var="$1"
    [[ -z "$(trim "$var")" ]]
}

# ============================================================================
# 进度显示
# ============================================================================

# 显示进度条
show_progress() {
    local current="$1"
    local total="$2"
    local width=50

    local percent=$((current * 100 / total))
    local filled=$((width * current / total))
    local empty=$((width - filled))

    printf "\r["
    printf "%${filled}s" | tr ' ' '='
    printf "%${empty}s" | tr ' ' ' '
    printf "] %d%%" "$percent"

    if [[ $current -eq $total ]]; then
        echo ""
    fi
}

# ============================================================================
# 交互式菜单
# ============================================================================

# 显示选择菜单
show_menu() {
    local title="$1"
    shift
    local options=("$@")

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "$title"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local i=1
    for option in "${options[@]}"; do
        echo "  $i) $option"
        ((i++))
    done

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

# 获取用户选择
get_choice() {
    local max="$1"
    local choice

    while true; do
        echo -en "${COLOR_CYAN}请选择 [1-$max]:${COLOR_RESET} "
        read -r choice

        if [[ "$choice" =~ ^[0-9]+$ ]] && \
           [[ "$choice" -ge 1 ]] && \
           [[ "$choice" -le "$max" ]]; then
            echo "$choice"
            return 0
        fi

        log_warning "无效选择，请输入 1-$max 之间的数字"
    done
}

# ============================================================================
# 系统信息
# ============================================================================

# 获取 CPU 核心数
get_cpu_cores() {
    if command -v nproc &>/dev/null; then
        nproc
    elif command -v sysctl &>/dev/null; then
        sysctl -n hw.ncpu 2>/dev/null || echo "4"
    else
        echo "4"
    fi
}

# 获取系统内存大小（MB）
get_memory_mb() {
    if [[ -f /proc/meminfo ]]; then
        grep MemTotal /proc/meminfo | awk '{print int($2/1024)}'
    elif command -v sysctl &>/dev/null; then
        sysctl -n hw.memsize 2>/dev/null | awk '{print int($1/1024/1024)}'
    else
        echo "2048"
    fi
}

# ============================================================================
# 配置管理
# ============================================================================

# 加载配置文件
load_config() {
    local config_file="$1"

    if [[ -f "$config_file" ]]; then
        # shellcheck source=/dev/null
        source "$config_file"
        log_debug "已加载配置: $config_file"
        return 0
    else
        log_warning "配置文件不存在: $config_file"
        return 1
    fi
}

# 保存配置到文件
save_config() {
    local config_file="$1"
    shift
    local declarations=("$@")

    {
        echo "# 配置文件 - 自动生成"
        echo "# 生成时间: $(date '+%Y-%m-%d %H:%M:%S')"
        echo ""

        for decl in "${declarations[@]}"; do
            echo "$decl"
        done
    } > "$config_file"

    log_debug "已保存配置: $config_file"
}
