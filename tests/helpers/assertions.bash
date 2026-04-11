#!/usr/bin/env bash
#
# 自定义断言函数
# 提供项目特定的断言逻辑
#

# ============================================
# 安装相关断言
# ============================================

assert_openclaw_installed() {
    if ! command -v openclaw &>/dev/null; then
        echo "OpenClaw not installed"
        return 1
    fi

    if [ ! -d ~/.openclaw ]; then
        echo "OpenClaw config directory not found"
        return 1
    fi

    return 0
}

assert_omlx_installed() {
    if [ ! -d ~/.omlx ]; then
        echo "oMLX not installed"
        return 1
    fi

    return 0
}

assert_nodejs_installed() {
    if ! command -v node &>/dev/null; then
        echo "Node.js not installed"
        return 1
    fi

    return 0
}

assert_nvm_installed() {
    if [ ! -f "$NVM_DIR/nvm.sh" ] && [ ! -f ~/.nvm/nvm.sh ]; then
        echo "nvm not installed"
        return 1
    fi

    return 0
}

# ============================================
# 服务相关断言
# ============================================

assert_omlx_service_running() {
    local port=${1:-8008}

    if ! lsof -i ":$port" >/dev/null 2>&1; then
        echo "oMLX service not running on port $port"
        return 1
    fi

    return 0
}

assert_openclaw_service_running() {
    local port=${1:-18789}

    if ! lsof -i ":$port" >/dev/null 2>&1; then
        echo "OpenClaw service not running on port $port"
        return 1
    fi

    return 0
}

# ============================================
# 文件系统断言
# ============================================

assert_dir_exists() {
    local dir=$1

    if [ ! -d "$dir" ]; then
        echo "Directory not found: $dir"
        return 1
    fi

    return 0
}

assert_file_exists() {
    local file=$1

    if [ ! -f "$file" ]; then
        echo "File not found: $file"
        return 1
    fi

    return 0
}

assert_file_executable() {
    local file=$1

    if [ ! -x "$file" ]; then
        echo "File not executable: $file"
        return 1
    fi

    return 0
}

assert_file_contains() {
    local file=$1
    local pattern=$2

    if ! grep -q "$pattern" "$file"; then
        echo "File '$file' does not contain pattern: $pattern"
        return 1
    fi

    return 0
}

# ============================================
# 版本断言
# ============================================

assert_version_at_least() {
    local current=$1
    local required=$2

    # 简单的版本比较
    if [ "$(printf '%s\n' "$required" "$current" | sort -V | head -n1)" != "$required" ]; then
        echo "Version $current is less than required $required"
        return 1
    fi

    return 0
}

# ============================================
# 配置断言
# ============================================

assert_config_key_exists() {
    local config_file=$1
    local key=$2

    if ! grep -q "^$key=" "$config_file"; then
        echo "Config key '$key' not found in $config_file"
        return 1
    fi

    return 0
}

assert_config_value_equals() {
    local config_file=$1
    local key=$2
    local expected=$3

    local actual=$(grep "^$key=" "$config_file" | cut -d= -f2)
    if [ "$actual" != "$expected" ]; then
        echo "Config value mismatch for '$key': expected '$expected', got '$actual'"
        return 1
    fi

    return 0
}

# ============================================
# 日志断言
# ============================================

assert_log_contains() {
    local log_file=$1
    local pattern=$2

    if ! grep -q "$pattern" "$log_file"; then
        echo "Log file '$log_file' does not contain pattern: $pattern"
        return 1
    fi

    return 0
}

assert_log_not_contains_errors() {
    local log_file=$1

    if grep -qi "error\|fail\|exception" "$log_file"; then
        echo "Log file contains errors"
        return 1
    fi

    return 0
}

# ============================================
# 网络断言
# ============================================

assert_url_accessible() {
    local url=$1
    local timeout=${2:-5}

    local status=$(curl -s -o /dev/null -w "%{http_code}" --max-time "$timeout" "$url")

    if [ "$status" != "200" ]; then
        echo "URL not accessible: $url (status: $status)"
        return 1
    fi

    return 0
}

assert_service_responds() {
    local url=$1
    local timeout=${2:-5}

    local response=$(curl -s --max-time "$timeout" "$url")

    if [ -z "$response" ]; then
        echo "Service not responding: $url"
        return 1
    fi

    return 0
}

# ============================================
# 性能断言
# ============================================

assert_command_timeout() {
    local command=$1
    local timeout=$2

    timeout "$timeout" $command >/dev/null 2>&1
    local status=$?

    if [ $status -eq 124 ]; then
        echo "Command timed out after ${timeout}s"
        return 1
    fi

    return 0
}

assert_disk_space_available() {
    local required_gb=$1

    local available=$(df -h / | awk 'NR==2 {print $4}' | sed 's/G//' | sed 's/[A-Za-z]*//g')

    if (( $(echo "$available < $required_gb" | bc -l) )); then
        echo "Insufficient disk space: ${available}G available, ${required_gb}G required"
        return 1
    fi

    return 0
}

# ============================================
# 导出函数
# ============================================

export -f assert_openclaw_installed
export -f assert_omlx_installed
export -f assert_nodejs_installed
export -f assert_nvm_installed
export -f assert_omlx_service_running
export -f assert_openclaw_service_running
export -f assert_dir_exists
export -f assert_file_exists
export -f assert_file_executable
export -f assert_file_contains
export -f assert_version_at_least
export -f assert_config_key_exists
export -f assert_config_value_equals
export -f assert_log_contains
export -f assert_log_not_contains_errors
export -f assert_url_accessible
export -f assert_service_responds
export -f assert_command_timeout
export -f assert_disk_space_available
