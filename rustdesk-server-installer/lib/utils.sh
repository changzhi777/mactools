#!/bin/bash
#
# ==============================================================================
# RustDesk Server Installer - 工具函数模块
# ==============================================================================
#
# 功能说明：
#   提供通用的工具函数，包括交互提示、数据验证等
#
# 使用方法：
#   source lib/utils.sh
#   if prompt_yes_no "是否继续？"; then
#       echo "用户选择是"
#   fi
#
# ==============================================================================

#
# 交互式 yes/no 提示
# 参数：$1=提示消息, $2=默认值（y/n，默认 y）
# 返回：0=是, 1=否
#
prompt_yes_no() {
    local message="$1"
    local default="${2:-y}"
    local prompt=""
    local response

    # 构建提示符
    if [[ "$default" == "y" ]]; then
        prompt="$message [Y/n]: "
    else
        prompt="$message [y/N]: "
    fi

    # 读取用户输入
    read -p "$prompt" response
    response=${response:-$default}

    # 转换为小写并判断
    response=$(echo "$response" | tr '[:upper:]' '[:lower:]')
    if [[ "$response" =~ ^y(es)?$ ]]; then
        return 0
    else
        return 1
    fi
}

#
# IP 地址验证
# 参数：$1=IP 地址
# 返回：0=有效, 1=无效
#
validate_ip() {
    local ip="$1"
    local stat=1

    if [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
           && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi

    return $stat
}

#
# 端口验证
# 参数：$1=端口号
# 返回：0=有效, 1=无效
#
validate_port() {
    local port="$1"

    if [[ "$port" =~ ^[0-9]+$ ]] && [[ "$port" -ge 1 ]] && [[ "$port" -le 65535 ]]; then
        return 0
    else
        return 1
    fi
}

#
# 获取服务器主 IP 地址
# 返回：输出主 IP 地址
#
get_server_ip() {
    # 尝试多种方法获取 IP
    local ip=""

    # 方法 1: hostname -I
    if command -v hostname &>/dev/null; then
        ip=$(hostname -I 2>/dev/null | awk '{print $1}')
    fi

    # 方法 2: ip addr
    if [[ -z "$ip" ]] && command -v ip &>/dev/null; then
        ip=$(ip route get 1 2>/dev/null | awk '{print $7}' | head -1)
    fi

    # 方法 3: ifconfig
    if [[ -z "$ip" ]] && command -v ifconfig &>/dev/null; then
        ip=$(ifconfig 2>/dev/null | grep 'inet ' | grep -v '127.0.0.1' | head -1 | awk '{print $2}')
    fi

    echo "$ip"
}

#
# 生成随机字符串
# 参数：$1=长度（默认 16）
# 返回：输出随机字符串
#
generate_random_string() {
    local length="${1:-16}"

    if command -v openssl &>/dev/null; then
        openssl rand -hex "$((length / 2))" 2>/dev/null | head -c "$length"
    else
        tr -dc 'a-zA-Z0-9' < /dev/urandom 2>/dev/null | head -c "$length"
    fi
}

#
# 检查命令是否存在
# 参数：$1=命令名称
# 返回：0=存在, 1=不存在
#
command_exists() {
    command -v "$1" &>/dev/null
}

#
# 检查端口是否被占用
# 参数：$1=端口号, $2=协议（tcp/udp，默认 tcp）
# 返回：0=被占用, 1=未占用
#
is_port_in_use() {
    local port="$1"
    local proto="${2:-tcp}"
    local result=1

    if command -v ss &>/dev/null; then
        if ss "-${proto:0:1}"ln | grep -q ":$port "; then
            result=0
        fi
    elif command -v netstat &>/dev/null; then
        if netstat -"${proto:0:1}"ln 2>/dev/null | grep -q ":$port "; then
            result=0
        fi
    fi

    return $result
}

#
# 检查是否为 root 用户
# 返回：0=是 root, 1=不是 root
#
is_root() {
    [[ $EUID -eq 0 ]]
}

#
# 检测操作系统类型
# 返回：输出操作系统名称（debian/ubuntu/centos等）
#
detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "$ID"
    elif [[ -f /etc/redhat-release ]]; then
        echo "centos"
    elif [[ -f /etc/debian_version ]]; then
        echo "debian"
    else
        echo "unknown"
    fi
}

#
# 检测操作系统版本
# 返回：输出版本号
#
detect_os_version() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "$VERSION_ID"
    elif [[ -f /etc/debian_version ]]; then
        cat /etc/debian_version
    else
        echo "unknown"
    fi
}

#
# 等待按键继续
#
pause() {
    echo ""
    read -p "按 Enter 键继续..."
}

#
# 进度条显示（简化版）
# 参数：$1=当前进度, $2=总数, $3=步骤描述
#
show_progress() {
    local current=$1
    local total=$2
    local message="${3:-处理中}"
    local percent=$((current * 100 / total))

    echo -ne "\r[${current}/${total}] ${percent}% - ${message}"

    if [[ $current -eq $total ]]; then
        echo ""  # 完成时换行
    fi
}

#
# 检查网络连接
# 参数：$1=主机（默认 8.8.8.8）, $2=端口（默认 53）
# 返回：0=可连接, 1=无法连接
#
check_network() {
    local host="${1:-8.8.8.8}"
    local port="${2:-53}"
    local timeout=3

    if command -v nc &>/dev/null; then
        nc -z -w "$timeout" "$host" "$port" &>/dev/null
        return $?
    elif command -v bash &>/dev/null; then
        timeout "$timeout" bash -c "cat < /dev/null > /dev/tcp/$host/$port" &>/dev/null
        return $?
    else
        return 1
    fi
}

#
# 获取目录大小（可读格式）
# 参数：$1=目录路径
# 返回：输出可读格式的大小
#
get_dir_size() {
    local dir="$1"

    if [[ -d "$dir" ]]; then
        du -sh "$dir" 2>/dev/null | cut -f1
    else
        echo "N/A"
    fi
}

#
# 备份文件
# 参数：$1=文件路径
# 返回：0=成功, 1=失败
#
backup_file() {
    local file="$1"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup="${file}.backup_${timestamp}"

    if [[ -f "$file" ]]; then
        cp "$file" "$backup"
        echo "$backup"
        return 0
    else
        return 1
    fi
}

#
# 确认操作（危险操作二次确认）
# 参数：$1=操作描述
# 返回：0=确认, 1=取消
#
confirm_dangerous_operation() {
    local operation="$1"

    echo ""
    echo "⚠️  警告：您即将执行以下操作："
    echo "   $operation"
    echo ""
    read -p "请输入 'yes' 确认继续，或按任意键取消: " response

    if [[ "$response" == "yes" ]]; then
        return 0
    else
        return 1
    fi
}

#
# 清理临时文件
# 参数：$1=临时目录或文件列表
#
cleanup_temp_files() {
    local temp_files="$1"

    for file in $temp_files; do
        if [[ -e "$file" ]]; then
            rm -rf "$file"
        fi
    done
}
