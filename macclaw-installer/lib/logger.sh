#!/bin/bash
#
# MacClaw Installer - 日志模块
# 作者: 外星动物（常智）
# 组织: IoTchange
# 邮箱: 14455975@qq.com
# 版本: V1.0.1
# 版权: Copyright (C) 2026 IoTchange - All Rights Reserved
#
# 说明: 提供彩色日志输出、日志级别控制和文件日志记录功能
#

# 日志级别
LOG_LEVEL_DEBUG=0
LOG_LEVEL_INFO=1
LOG_LEVEL_SUCCESS=2
LOG_LEVEL_WARNING=3
LOG_LEVEL_ERROR=4

# 当前日志级别（默认 INFO）
CURRENT_LOG_LEVEL=$LOG_LEVEL_INFO

# 日志文件
LOG_FILE="$HOME/macclaw-install.log"

# 颜色定义
COLOR_RESET='\033[0m'
COLOR_DEBUG='\033[0;36m'    # 青色
COLOR_INFO='\033[0;34m'     # 蓝色
COLOR_SUCCESS='\033[0;32m'  # 绿色
COLOR_WARNING='\033[0;33m'  # 黄色
COLOR_ERROR='\033[0;31m'    # 红色

# 初始化日志文件
init_log() {
    local log_dir=$(dirname "$LOG_FILE")
    mkdir -p "$log_dir"
    echo "=== MacClaw Installer 日志 ===" > "$LOG_FILE"
    echo "开始时间: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
    echo "================================" >> "$LOG_FILE"
}

# 写入日志文件
write_log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

# 输出调试日志
log_debug() {
    if [ $CURRENT_LOG_LEVEL -le $LOG_LEVEL_DEBUG ]; then
        local message="$1"
        echo -e "${COLOR_DEBUG}[DEBUG]${COLOR_RESET} $message"
        write_log "DEBUG" "$message"
    fi
}

# 输出信息日志
log_info() {
    if [ $CURRENT_LOG_LEVEL -le $LOG_LEVEL_INFO ]; then
        local message="$1"
        echo -e "${COLOR_INFO}[INFO]${COLOR_RESET} $message"
        write_log "INFO" "$message"
    fi
}

# 输出成功日志
log_success() {
    if [ $CURRENT_LOG_LEVEL -le $LOG_LEVEL_SUCCESS ]; then
        local message="$1"
        echo -e "${COLOR_SUCCESS}[SUCCESS]${COLOR_RESET} $message"
        write_log "SUCCESS" "$message"
    fi
}

# 输出警告日志
log_warning() {
    if [ $CURRENT_LOG_LEVEL -le $LOG_LEVEL_WARNING ]; then
        local message="$1"
        echo -e "${COLOR_WARNING}[WARNING]${COLOR_RESET} $message"
        write_log "WARNING" "$message"
    fi
}

# 输出错误日志
log_error() {
    if [ $CURRENT_LOG_LEVEL -le $LOG_LEVEL_ERROR ]; then
        local message="$1"
        echo -e "${COLOR_ERROR}[ERROR]${COLOR_RESET} $message"
        write_log "ERROR" "$message"
    fi
}

# 设置日志级别
set_log_level() {
    local level="$1"
    case "$level" in
        debug)
            CURRENT_LOG_LEVEL=$LOG_LEVEL_DEBUG
            ;;
        info)
            CURRENT_LOG_LEVEL=$LOG_LEVEL_INFO
            ;;
        success)
            CURRENT_LOG_LEVEL=$LOG_LEVEL_SUCCESS
            ;;
        warning)
            CURRENT_LOG_LEVEL=$LOG_LEVEL_WARNING
            ;;
        error)
            CURRENT_LOG_LEVEL=$LOG_LEVEL_ERROR
            ;;
        *)
            log_warning "未知的日志级别: $level"
            ;;
    esac
}

# 显示日志文件位置
show_log_location() {
    log_info "日志文件位置: $LOG_FILE"
}

# 查看日志
view_log() {
    if [ -f "$LOG_FILE" ]; then
        tail -f "$LOG_FILE"
    else
        log_error "日志文件不存在: $LOG_FILE"
    fi
}

# 导出函数
export -f log_debug
export -f log_info
export -f log_success
export -f log_warning
export -f log_error
export -f set_log_level
export -f show_log_location
export -f view_log
