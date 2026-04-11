#!/bin/sh
#
# POSIX Shell 兼容性库
# 作者: 外星动物（常智）
# 组织: IoTchange
# 邮箱: 14455975@qq.com
# 版本: V1.0.1
# 版权: Copyright (C) 2026 IoTchange - All Rights Reserved
#
# 说明: 提供 POSIX sh 兼容的函数，替代 bash 特性
# 支持: sh, bash, zsh, dash, ksh
#

# ============================================
# 脚本路径获取（替代 ${BASH_SOURCE[0]}）
# ============================================

# 获取脚本目录（POSIX 兼容）
get_script_dir() {
    # 尝试多种方法获取脚本路径
    if [ -n "${ZSH_VERSION:-}" ]; then
        # zsh
        echo "${funcfiletrace[1]%/*}"
    elif [ -n "${BASH_VERSION:-}" ]; then
        # bash
        echo "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    else
        # 通用方法（适用于大多数 sh）
        # 尝试从 $0 获取
        local script_dir="$0"
        if [ -L "$script_dir" ]; then
            # 处理符号链接
            script_dir="$(readlink "$script_dir")"
        fi
        echo "$(cd "$(dirname "$script_dir")" && pwd)"
    fi
}

# 获取脚本绝对路径
get_script_path() {
    if [ -n "${BASH_VERSION:-}" ]; then
        echo "${BASH_SOURCE[0]}"
    else
        echo "$0"
    fi
}

# ============================================
# 字符串操作（替代 bash 特性）
# ============================================

# 检查字符串包含（替代 [[ $str =~ pattern ]]）
str_contains() {
    # 使用 case 语句实现正则匹配
    local string="$1"
    local pattern="$2"

    case "$string" in
        *$pattern*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# 检查字符串相等（替代 [[ $str == $pattern ]]）
str_equals() {
    [ "$1" = "$2" ]
}

# 检查字符串不等
str_not_equals() {
    [ "$1" != "$2" ]
}

# 检查字符串为空
str_is_empty() {
    [ -z "$1" ]
}

# 检查字符串非空
str_is_not_empty() {
    [ -n "$1" ]
}

# ============================================
# 数组模拟（替代 bash 数组）
# ============================================

# 使用空格分隔的字符串模拟数组
# 注意: POSIX sh 不支持真正的数组，这里使用字符串模拟

# 创建"数组"
array_create() {
    echo "$@"
}

# 获取"数组"长度
array_length() {
    local arr="$1"
    set -- $arr
    echo $#
}

# 检查"数组"包含某元素
array_contains() {
    local arr="$1"
    local element="$2"
    set -- $arr

    for item in "$@"; do
        if [ "$item" = "$element" ]; then
            return 0
        fi
    done

    return 1
}

# 遍历"数组"
array_foreach() {
    local arr="$1"
    local callback="$2"

    set -- $arr
    for item in "$@"; do
        $callback "$item"
    done
}

# ============================================
# 算术运算（POSIX 兼容）
# ============================================

# 算术运算（POSIX 支持 $(( ))）
calc() {
    echo "$(($@))"
}

# 比较数字
num_eq() {
    [ "$1" -eq "$2" ]
}

num_ne() {
    [ "$1" -ne "$2" ]
}

num_gt() {
    [ "$1" -gt "$2" ]
}

num_ge() {
    [ "$1" -ge "$2" ]
}

num_lt() {
    [ "$1" -lt "$2" ]
}

num_le() {
    [ "$1" -le "$2" ]
}

# ============================================
# 逻辑操作
# ============================================

# 逻辑与
and() {
    [ "$1" -a "$2" ]
}

# 逻辑或
or() {
    [ "$1" -o "$2" ]
}

# 逻辑非
not() {
    [ ! "$1" ]
}

# ============================================
# 文件测试（POSIX 兼容）
# ============================================

# 检查文件存在且可读
file_is_readable() {
    [ -r "$1" ]
}

# 检查文件存在且可写
file_is_writable() {
    [ -w "$1" ]
}

# 检查文件存在且可执行
file_is_executable() {
    [ -x "$1" ]
}

# 检查是普通文件
file_is_regular() {
    [ -f "$1" ]
}

# 检查是目录
file_is_directory() {
    [ -d "$1" ]
}

# 检查文件存在
file_exists() {
    [ -e "$1" ]
}

# ============================================
# 命令存在性检查
# ============================================

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ============================================
# 字符串处理
# ============================================

# 去除字符串前导空格
str_ltrim() {
    local str="$1"
    echo "$str" | sed 's/^[[:space:]]*//'
}

# 去除字符串尾随空格
str_rtrim() {
    local str="$1"
    echo "$str" | sed 's/[[:space:]]*$//'
}

# 去除字符串两端空格
str_trim() {
    local str="$1"
    echo "$str" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

# 字符串转小写
str_tolower() {
    local str="$1"
    echo "$str" | tr '[:upper:]' '[:lower:]'
}

# 字符串转大写
str_toupper() {
    local str="$1"
    echo "$str" | tr '[:lower:]' '[:upper:]'
}

# ============================================
# 路径处理
# ============================================

# 获取文件名（不含路径）
get_basename() {
    local path="$1"
    echo "${path##*/}"
}

# 获取目录名（不含文件名）
get_dirname() {
    local path="$1"
    echo "${path%/*}"
}

# 获取文件扩展名
get_extension() {
    local path="$1"
    local basename="${path##*/}"
    echo "${basename##*.}"
}

# 去除文件扩展名
remove_extension() {
    local path="$1"
    echo "${path%.*}"
}

# ============================================
# 颜色输出（简化版）
# ============================================

# 检查终端是否支持颜色
supports_color() {
    # 检查 NO_COLOR 环境变量
    if [ -n "${NO_COLOR:-}" ]; then
        return 1
    fi

    # 检查终端类型
    case "${TERM:-}" in
        xterm*|vt100*|screen*|ansi*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# 安全的颜色输出（自动检测支持）
echo_red() {
    if supports_color; then
        printf '\033[0;31m%s\033[0m\n' "$*"
    else
        echo "$*"
    fi
}

echo_green() {
    if supports_color; then
        printf '\033[0;32m%s\033[0m\n' "$*"
    else
        echo "$*"
    fi
}

echo_yellow() {
    if supports_color; then
        printf '\033[1;33m%s\033[0m\n' "$*"
    else
        echo "$*"
    fi
}

echo_blue() {
    if supports_color; then
        printf '\033[0;34m%s\033[0m\n' "$*"
    else
        echo "$*"
    fi
}

# ============================================
# 交互确认
# ============================================

# 询问用户确认（默认: 否）
confirm() {
    local prompt="$1"
    local response

    printf '%s [y/N]: ' "$prompt"
    read response

    case "$response" in
        [Yy]|[Yy][Ee][Ss])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# ============================================
# 日志函数
# ============================================

# 日志级别
LOG_DEBUG=0
LOG_INFO=1
LOG_WARN=2
LOG_ERROR=3

# 当前日志级别（默认 INFO）
LOG_LEVEL=${LOG_LEVEL:-$LOG_INFO}

# 记录日志
log_msg() {
    local level="$1"
    shift
    local msg="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    printf '[%s] [%s] %s\n' "$timestamp" "$level" "$msg"
}

# Debug 日志
log_debug() {
    if [ $LOG_LEVEL -le $LOG_DEBUG ]; then
        log_msg "DEBUG" "$@"
    fi
}

# Info 日志
log_info() {
    if [ $LOG_LEVEL -le $LOG_INFO ]; then
        log_msg "INFO" "$@"
    fi
}

# Warning 日志
log_warn() {
    if [ $LOG_LEVEL -le $LOG_WARN ]; then
        log_msg "WARN" "$@"
    fi
}

# Error 日志
log_error() {
    if [ $LOG_LEVEL -le $LOG_ERROR ]; then
        log_msg "ERROR" "$@"
    fi
}

# ============================================
# 兼容性信息
# ============================================

# 显示 shell 信息
show_shell_info() {
    echo "Shell Information:"
    echo "  Shell: $(basename $SHELL)"
    echo "  Path: $SHELL"

    if [ -n "${BASH_VERSION:-}" ]; then
        echo "  Bash Version: $BASH_VERSION"
    fi

    if [ -n "${ZSH_VERSION:-}" ]; then
        echo "  Zsh Version: $ZSH_VERSION"
    fi
}

# 检测当前 shell
detect_shell() {
    if [ -n "${BASH_VERSION:-}" ]; then
        echo "bash"
    elif [ -n "${ZSH_VERSION:-}" ]; then
        echo "zsh"
    elif [ -n "${KSH_VERSION:-}" ]; then
        echo "ksh"
    else
        echo "sh"
    fi
}
