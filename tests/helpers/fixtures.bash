#!/usr/bin/env bash
#
# 测试数据 fixtures
# 提供测试所需的模拟数据和测试环境
#

# ============================================
# 环境信息 fixtures
# ============================================

get_macos_version() {
    sw_vers -productVersion
}

get_macos_version_major() {
    sw_vers -productVersion | cut -d. -f1
}

get_system_arch() {
    uname -m
}

# ============================================
# 磁盘空间 fixtures
# ============================================

get_available_disk_space() {
    df -h / | awk 'NR==2 {print $4}'
}

get_available_disk_space_gb() {
    df -h / | awk 'NR==2 {print $4}' | sed 's/G//'
}

# ============================================
# 网络测试 fixtures
# ============================================

get_github_raw_status() {
    curl -s -o /dev/null -w "%{http_code}" --max-time 5 \
        https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw-installer/install.sh
}

check_internet_connection() {
    ping -c 1 -W 2000 8.8.8.8 &>/dev/null
}

# ============================================
# 模拟安装场景 fixtures
# ============================================

create_mock_install_env() {
    local mock_dir=$1
    mkdir -p "$mock_dir"/{bin,lib,etc}

    # 创建模拟的 openclaw 二进制
    cat > "$mock_dir/bin/openclaw" << 'EOF'
#!/bin/bash
echo "Mock openclaw v1.0.0"
EOF
    chmod +x "$mock_dir/bin/openclaw"

    # 创建模拟的配置文件
    cat > "$mock_dir/etc/config.json" << 'EOF'
{
  "version": "1.0.0",
  "model": "gemma-4-e4b-it-4bit"
}
EOF
}

cleanup_mock_install_env() {
    local mock_dir=$1
    rm -rf "$mock_dir"
}

# ============================================
# 测试配置 fixtures
# ============================================

get_test_timeout() {
    case $1 in
        short) echo "5" ;;
        medium) echo "30" ;;
        long) echo "120" ;;
        *) echo "30" ;;
    esac
}

get_test_retry_count() {
    echo "3"
}

# ============================================
# 日志 fixtures
# ============================================

create_mock_log_file() {
    local log_file=$1
    local content=$2

    mkdir -p "$(dirname "$log_file")"
    echo "$content" > "$log_file"
}

append_mock_log() {
    local log_file=$1
    local content=$2

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $content" >> "$log_file"
}

# ============================================
# 进程管理 fixtures
# ============================================

get_process_id() {
    local process_name=$1
    pgrep -x "$process_name"
}

is_process_running() {
    local process_name=$1
    pgrep -x "$process_name" >/dev/null
}

wait_for_process() {
    local process_name=$1
    local max_attempts=${2:-30}
    local attempt=0

    while [ $attempt -lt $max_attempts ]; do
        if is_process_running "$process_name"; then
            return 0
        fi
        sleep 1
        ((attempt++))
    done
    return 1
}

# ============================================
# 文件内容 fixtures
# ============================================

create_mock_install_script() {
    local file_path=$1
    cat > "$file_path" << 'EOF'
#!/bin/bash
set -e

echo "Installing..."
echo "Installation complete"
EOF
    chmod +x "$file_path"
}

create_mock_config_file() {
    local file_path=$1
    local content=$2

    mkdir -p "$(dirname "$file_path")"
    cat > "$file_path" << EOF
$content
EOF
}

# ============================================
# 端口管理 fixtures
# ============================================

get_port_status() {
    local port=$1
    lsof -i ":$port" >/dev/null 2>&1
    echo $?
}

kill_process_on_port() {
    local port=$1
    local pid=$(lsof -ti ":$port")
    if [ -n "$pid" ]; then
        kill -9 $pid 2>/dev/null || true
    fi
}

# ============================================
# 导出函数
# ============================================

export -f get_macos_version
export -f get_macos_version_major
export -f get_system_arch
export -f get_available_disk_space
export -f get_available_disk_space_gb
export -f get_github_raw_status
export -f check_internet_connection
export -f create_mock_install_env
export -f cleanup_mock_install_env
export -f get_test_timeout
export -f get_test_retry_count
export -f create_mock_log_file
export -f append_mock_log
export -f get_process_id
export -f is_process_running
export -f wait_for_process
export -f create_mock_install_script
export -f create_mock_config_file
export -f get_port_status
export -f kill_process_on_port
