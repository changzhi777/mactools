#!/usr/bin/env bash
#
# Bats 公共设置文件
# 为所有测试文件提供通用的设置和辅助函数
#

# 加载 Bats 辅助库
load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'
load 'test_helper/bats-file/load'

# 项目根目录
PROJECT_ROOT="$( cd "$( dirname "$BATS_TEST_FILENAME" )/../.." && pwd )"
export PROJECT_ROOT

# 测试临时目录
TEST_TEMP_DIR="$(mktemp -d)"
export TEST_TEMP_DIR

# 安装器路径
INSTALLER_DIR="$PROJECT_ROOT/macclaw-installer"
export INSTALLER_DIR

# 备份目录
BACKUP_DIR="${TEST_TEMP_DIR}/backups"
export BACKUP_DIR

# 日志文件
TEST_LOG="${TEST_TEMP_DIR}/test.log"
export TEST_LOG

# ============================================
# 清理函数
# ============================================

cleanup_test_env() {
    # 清理临时目录
    if [ -d "$TEST_TEMP_DIR" ]; then
        rm -rf "$TEST_TEMP_DIR"
    fi
}

# ============================================
# 环境备份和恢复
# ============================================

backup_environment() {
    mkdir -p "$BACKUP_DIR"

    # 备份 OpenClaw 配置
    if [ -d ~/.openclaw ]; then
        cp -r ~/.openclaw "${BACKUP_DIR}/openclaw"
    fi

    # 备份 oMLX 配置
    if [ -d ~/.omlx ]; then
        cp -r ~/.omlx "${BACKUP_DIR}/omlx"
    fi

    # 备份 nvm
    if [ -d ~/.nvm ]; then
        cp -r ~/.nvm "${BACKUP_DIR}/nvm"
    fi

    # 备份 Node.js 版本
    if command -v node &>/dev/null; then
        node --version > "${BACKUP_DIR}/node.version" 2>&1
    fi
}

restore_environment() {
    # 恢复 OpenClaw 配置
    if [ -d "${BACKUP_DIR}/openclaw" ]; then
        rm -rf ~/.openclaw
        cp -r "${BACKUP_DIR}/openclaw" ~/.openclaw
    fi

    # 恢复 oMLX 配置
    if [ -d "${BACKUP_DIR}/omlx" ]; then
        rm -rf ~/.omlx
        cp -r "${BACKUP_DIR}/omlx" ~/.omlx
    fi

    # 恢复 nvm
    if [ -d "${BACKUP_DIR}/nvm" ]; then
        rm -rf ~/.nvm
        cp -r "${BACKUP_DIR}/nvm" ~/.nvm
    fi
}

# ============================================
# 命令检查函数
# ============================================

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ============================================
# 服务检查函数
# ============================================

service_running() {
    local port=$1
    lsof -i ":$port" >/dev/null 2>&1
}

wait_for_service() {
    local port=$1
    local max_attempts=${2:-30}
    local attempt=0

    while [ $attempt -lt $max_attempts ]; do
        if service_running $port; then
            return 0
        fi
        sleep 1
        ((attempt++))
    done
    return 1
}

# ============================================
# HTTP 请求辅助函数
# ============================================

http_get() {
    local url=$1
    local timeout=${2:-5}
    curl -s --max-time "$timeout" "$url"
}

http_status() {
    local url=$1
    local timeout=${2:-5}
    curl -s -o /dev/null -w "%{http_code}" --max-time "$timeout" "$url"
}

# ============================================
# 文件和目录操作
# ============================================

count_files_in_dir() {
    local dir=$1
    find "$dir" -type f | wc -l
}

dir_size() {
    local dir=$1
    du -sh "$dir" 2>/dev/null | awk '{print $1}'
}

# ============================================
# 日志函数
# ============================================

log_test() {
    local message=$1
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" >> "$TEST_LOG"
}

# ============================================
# 断言辅助函数
# ============================================

assert_command_exists() {
    local cmd=$1
    if ! command_exists "$cmd"; then
        echo "Command not found: $cmd"
        return 1
    fi
}

assert_file_contains() {
    local file=$1
    local pattern=$2
    grep -q "$pattern" "$file"
}

assert_service_running() {
    local port=$1
    if ! service_running $port; then
        echo "Service not running on port: $port"
        return 1
    fi
}

# ============================================
# 测试数据 fixtures
# ============================================

get_test_model_name() {
    echo "gemma-4-e4b-it-4bit"
}

get_test_port() {
    case $1 in
        omlx) echo "8008" ;;
        openclaw) echo "18789" ;;
        *) echo "unknown" ;;
    esac
}

# ============================================
# 清理测试安装
# ============================================

cleanup_test_installation() {
    # 停止服务
    if command_exists openclaw; then
        openclaw gateway stop &>/dev/null || true
    fi

    # 清理临时文件
    rm -rf /tmp/macclaw* 2>/dev/null || true
}

# 导出所有函数
export -f cleanup_test_env
export -f backup_environment
export -f restore_environment
export -f command_exists
export -f service_running
export -f wait_for_service
export -f http_get
export -f http_status
export -f count_files_in_dir
export -f dir_size
export -f log_test
export -f assert_command_exists
export -f assert_file_contains
export -f assert_service_running
export -f get_test_model_name
export -f get_test_port
export -f cleanup_test_installation
