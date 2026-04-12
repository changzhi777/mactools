#!/bin/bash
#
# 依赖验证模块
#
# 作者: 外星动物（常智）
# 组织: IoTchange
# 邮箱: 14455975@qq.com
# 版权: Copyright (C) 2026 IoTchange - All Rights Reserved
#
# 描述: 验证系统依赖是否满足 Hermes Agent 安装要求
#

# 获取库文件所在目录
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 加载依赖库（同目录下的其他库）
# shellcheck source=lib/logger.sh
source "${LIB_DIR}/logger.sh"
# shellcheck source=lib/detector.sh
source "${LIB_DIR}/detector.sh"

# ============================================================================
# 验证结果
# ============================================================================

VALIDATION_ERRORS=()
VALIDATION_WARNINGS=()

# ============================================================================
# Python 验证
# ============================================================================

validate_python() {
    log_substep "验证 Python 环境"

    if [[ "$PYTHON_AVAILABLE" != "true" ]]; then
        log_check "fail" "Python 3.11+ 未安装"
        VALIDATION_ERRORS+=("Python 3.11+ 未安装")

        # 提供安装建议
        echo ""
        log_info "安装建议："
        case "$DETECTED_OS" in
            Darwin*)
                echo "  brew install python@3.12"
                ;;
            Linux*)
                echo "  sudo apt install python3.12  # Debian/Ubuntu"
                echo "  sudo yum install python3.12  # CentOS/RHEL"
                ;;
        esac
        return 1
    fi

    log_check "ok" "Python $PYTHON_VERSION"
    return 0
}

# ============================================================================
# uv 包管理器验证
# ============================================================================

validate_uv() {
    log_substep "验证 uv 包管理器"

    if [[ "$UV_AVAILABLE" != "true" ]]; then
        log_check "fail" "uv 未安装"
        VALIDATION_ERRORS+=("uv 包管理器未安装")

        echo ""
        log_info "安装建议："
        echo "  curl -LsSf https://astral.sh/uv/install.sh | sh"
        return 1
    fi

    log_check "ok" "uv 包管理器"
    return 0
}

# ============================================================================
# Git 验证
# ============================================================================

validate_git() {
    log_substep "验证 Git"

    if [[ "$GIT_AVAILABLE" != "true" ]]; then
        log_check "fail" "Git 未安装"
        VALIDATION_ERRORS+=("Git 未安装")

        echo ""
        log_info "安装建议："
        case "$DETECTED_OS" in
            Darwin*)
                echo "  brew install git"
                ;;
            Linux*)
                echo "  sudo apt install git  # Debian/Ubuntu"
                echo "  sudo yum install git  # CentOS/RHEL"
                ;;
        esac
        return 1
    fi

    log_check "ok" "Git"
    return 0
}

# ============================================================================
# 网络连接验证
# ============================================================================

validate_network() {
    log_substep "验证网络连接"

    local hosts=(
        "github.com"
        "pypi.org"
    )

    for host in "${hosts[@]}"; do
        if ping -c 1 -W 2 "$host" &>/dev/null; then
            log_check "ok" "网络连接: $host"
        else
            log_check "fail" "无法连接: $host"
            VALIDATION_WARNINGS+=("无法连接到 $host")
        fi
    done
}

# ============================================================================
# 权限验证
# ============================================================================

validate_permissions() {
    log_substep "验证文件权限"

    # 检查是否有写入权限到安装目录
    local install_dir="${HOME}/.hermes"
    local bin_dir="${HOME}/.local/bin"

    # 检查能否创建目录
    if ! mkdir -p "${install_dir}" 2>/dev/null; then
        log_check "fail" "无法创建安装目录: ${install_dir}"
        VALIDATION_ERRORS+=("权限不足：无法写入 ${install_dir}")
        return 1
    fi

    if ! mkdir -p "${bin_dir}" 2>/dev/null; then
        log_check "fail" "无法创建 bin 目录: ${bin_dir}"
        VALIDATION_ERRORS+=("权限不足：无法写入 ${bin_dir}")
        return 1
    fi

    log_check "ok" "文件权限验证通过"
    return 0
}

# ============================================================================
# 完整验证
# ============================================================================

validate_all() {
    log_step "依赖验证"

    # 先检测环境
    detect_environment

    # 验证各项依赖
    validate_python
    validate_uv
    validate_git
    validate_network
    validate_permissions

    echo ""

    # 显示验证结果
    if [[ ${#VALIDATION_ERRORS[@]} -gt 0 ]]; then
        log_error "验证失败：发现 ${#VALIDATION_ERRORS[@]} 个错误"
        echo ""
        for error in "${VALIDATION_ERRORS[@]}"; do
            echo "  ❌ $error"
        done
        echo ""
        return 1
    fi

    if [[ ${#VALIDATION_WARNINGS[@]} -gt 0 ]]; then
        log_warning "验证通过，但有 ${#VALIDATION_WARNINGS[@]} 个警告"
        echo ""
        for warning in "${VALIDATION_WARNINGS[@]}"; do
            echo "  ⚠️  $warning"
        done
        echo ""
    fi

    log_success "所有依赖验证通过 ✓"
    return 0
}

# ============================================================================
# 自动修复
# ============================================================================

install_uv_if_missing() {
    if [[ "$UV_AVAILABLE" != "true" ]]; then
        log_info "正在安装 uv 包管理器..."
        if curl -LsSf https://astral.sh/uv/install.sh | sh; then
            log_success "uv 安装成功"
            # 重新加载 PATH
            export PATH="${HOME}/.local/bin:${PATH}"
            UV_AVAILABLE=true
            return 0
        else
            log_error "uv 安装失败"
            return 1
        fi
    fi
    return 0
}
