#!/bin/bash
#
# 环境检测模块
#
# 作者: 外星动物（常智）
# 组织: IoTchange
# 邮箱: 14455975@qq.com
# 版权: Copyright (C) 2026 IoTchange - All Rights Reserved
#
# 描述: 检测操作系统、Python版本、依赖工具等环境信息
#

# 获取库文件所在目录
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 加载依赖库（同目录下的其他库）
# shellcheck source=lib/logger.sh
source "${LIB_DIR}/logger.sh"

# ============================================================================
# 全局变量
# ============================================================================

DETECTED_OS=""
DETECTED_ARCH=""
PYTHON_VERSION=""
PYTHON_AVAILABLE=false
UV_AVAILABLE=false
GIT_AVAILABLE=false
NODE_VERSION=""

# ============================================================================
# 操作系统检测
# ============================================================================

detect_os() {
    log_debug "检测操作系统..."

    DETECTED_OS="$(uname -s)"
    DETECTED_ARCH="$(uname -m)"

    case "$DETECTED_OS" in
        Linux*)
            if [[ -f /etc/os-release ]]; then
                . /etc/os-release
                log_debug "检测到 Linux: $NAME $VERSION"
            fi
            ;;
        Darwin*)
            local macos_version="$(sw_vers -productVersion)"
            log_debug "检测到 macOS: $macos_version"
            ;;
        MINGW*|MSYS*|CYGWIN*)
            log_debug "检测到 Windows (Git Bash/MSYS)"
            ;;
        *)
            log_error "不支持的操作系统: $DETECTED_OS"
            return 1
            ;;
    esac

    log_info "操作系统: $DETECTED_OS $DETECTED_ARCH"
    return 0
}

# ============================================================================
# Python 版本检测
# ============================================================================

detect_python() {
    log_debug "检测 Python 版本..."

    if ! command -v python3 &>/dev/null; then
        log_warning "未找到 Python 3"
        PYTHON_AVAILABLE=false
        return 1
    fi

    PYTHON_VERSION="$(extract_version "python3")"
    local major_minor="$(echo "$PYTHON_VERSION" | awk -F. '{print $1"."$2}')"

    log_debug "Python 版本: $PYTHON_VERSION"

    # 检查版本是否 >= 3.11
    if [[ "$(echo "$major_minor" | awk -F. '{print $1}')" -lt 3 ]] || \
       [[ "$(echo "$major_minor" | awk -F. '{print $1"."$2}')" < "3.11" ]]; then
        log_warning "Python 版本过低: $PYTHON_VERSION (需要 >= 3.11)"
        PYTHON_AVAILABLE=false
        return 1
    fi

    log_success "Python 版本: $PYTHON_VERSION ✓"
    PYTHON_AVAILABLE=true
    return 0
}

# ============================================================================
# uv 包管理器检测
# ============================================================================

detect_uv() {
    log_debug "检测 uv 包管理器..."

    if ! command -v uv &>/dev/null; then
        log_warning "未找到 uv 包管理器"
        UV_AVAILABLE=false
        return 1
    fi

    local uv_version="$(extract_version "uv" "2")"
    log_success "uv 版本: $uv_version ✓"
    UV_AVAILABLE=true
    return 0
}

# ============================================================================
# Git 检测
# ============================================================================

detect_git() {
    log_debug "检测 Git..."

    if ! command -v git &>/dev/null; then
        log_warning "未找到 Git"
        GIT_AVAILABLE=false
        return 1
    fi

    local git_version="$(extract_version "git" "3")"
    log_success "Git 版本: $git_version ✓"
    GIT_AVAILABLE=true
    return 0
}

# ============================================================================
# Node.js 检测（可选）
# ============================================================================

detect_nodejs() {
    log_debug "检测 Node.js（可选依赖）..."

    if ! command -v node &>/dev/null; then
        log_debug "未找到 Node.js（可选）"
        NODE_VERSION=""
        return 0
    fi

    NODE_VERSION="$(extract_version "node")"
    log_info "Node.js 版本: $NODE_VERSION (可选)"
    return 0
}

# ============================================================================
# 完整环境检测
# ============================================================================

detect_environment() {
    log_step "环境检测"

    detect_os
    detect_python
    detect_uv
    detect_git
    detect_nodejs

    echo ""
    log_info "环境检测完成"

    # 返回检测结果
    if [[ "$PYTHON_AVAILABLE" == "true" ]] && \
       [[ "$GIT_AVAILABLE" == "true" ]]; then
        return 0
    else
        log_warning "环境不完整，需要安装缺失的依赖"
        return 1
    fi
}

# ============================================================================
# 环境信息输出
# ============================================================================

print_environment_info() {
    log_step "环境信息"

    echo "操作系统: ${DETECTED_OS} ${DETECTED_ARCH}"
    echo "Python: ${PYTHON_VERSION:-未安装}"
    echo "uv: $([ "$UV_AVAILABLE" == "true" ] && echo "已安装" || echo "未安装")"
    echo "Git: $([ "$GIT_AVAILABLE" == "true" ] && echo "已安装" || echo "未安装")"
    echo "Node.js: ${NODE_VERSION:-未安装}"
    echo ""
}
