#!/usr/bin/env zsh
# ==============================================================================
# MacClaw Install - 环境检测模块（交互式简化版）
# ==============================================================================
#
# 作者: 外星动物（常智） / IoTchange / 14455975@qq.com
# 版权: Copyright (C) 2026 IoTchange - All Rights Reserved
#
# 功能说明：
#   检测 macOS 系统环境信息
#   包括：系统版本、硬件信息、已安装软件、磁盘空间、内存状态
#
# 使用方法：
#   source "${LIB_DIR}/core/env-detector-interactive.zsh"
#   detect_all_environments
#
# ==============================================================================

# ==============================================================================
# 全局变量
# ==============================================================================

# 系统信息
typeset -g MACOS_VERSION=""
typeset -g MACOS_BUILD=""
typeset -g CPU_ARCHITECTURE=""
typeset -g CPU_MODEL=""
typeset -g CPU_CORES=0
typeset -g MEMORY_SIZE=0
typeset -g MEMORY_AVAILABLE=0
typeset -g DISK_TOTAL=0
typeset -g DISK_AVAILABLE=0
typeset -g DISK_USED_PERCENT=0

# 已安装软件状态
typeset -g HOMEBREW_INSTALLED=false
typeset -g NODEJS_INSTALLED=false
typeset -g PYTHON3_INSTALLED=false
typeset -g OMLX_INSTALLED=false
typeset -g OPENCLAW_INSTALLED=false

# 对话框模块依赖
if [[ -f "${LIB_DIR}/interactive/dialog-helper.zsh" ]]; then
    source "${LIB_DIR}/interactive/dialog-helper.zsh"
fi

# ==============================================================================
# 系统信息检测
# ==============================================================================

# 检测 macOS 版本
detect_macos_version() {
    MACOS_VERSION=$(sw_vers -productVersion)
    MACOS_BUILD=$(sw_vers -buildVersion)

    export MACOS_VERSION MACOS_BUILD
}

# 检测 CPU 信息
detect_cpu_info() {
    CPU_ARCHITECTURE=$(uname -m)
    CPU_MODEL=$(sysctl -n machdep.cpu.brand_string)
    CPU_CORES=$(sysctl -n hw.ncpu)

    export CPU_ARCHITECTURE CPU_MODEL CPU_CORES
}

# 检测内存信息
detect_memory_info() {
    MEMORY_SIZE=$(sysctl -n hw.memsize)
    MEMORY_AVAILABLE=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
    MEMORY_AVAILABLE=$((MEMORY_AVAILABLE * 4096))  # 转换为字节

    export MEMORY_SIZE MEMORY_AVAILABLE
}

# 检测磁盘信息
detect_disk_info() {
    local disk_info=$(df -h / | tail -1)
    DISK_TOTAL=$(echo "${disk_info}" | awk '{print $2}')
    local available=$(echo "${disk_info}" | awk '{print $4}')
    local used_percent=$(echo "${disk_info}" | awk '{print $5}' | sed 's/%//')

    DISK_AVAILABLE="${available}"
    DISK_USED_PERCENT="${used_percent}"

    export DISK_TOTAL DISK_AVAILABLE DISK_USED_PERCENT
}

# ==============================================================================
# 软件检测
# ==============================================================================

# 检测 Homebrew
detect_homebrew() {
    if command -v brew >/dev/null 2>&1; then
        HOMEBREW_INSTALLED=true
        HOMEBREW_VERSION=$(brew --version | head -1 | awk '{print $2}')
    else
        HOMEBREW_INSTALLED=false
    fi

    export HOMEBREW_INSTALLED HOMEBREW_VERSION
}

# 检测 Node.js
detect_nodejs() {
    if command -v node >/dev/null 2>&1; then
        NODEJS_INSTALLED=true
        NODEJS_VERSION=$(node --version)
    else
        NODEJS_INSTALLED=false
    fi

    export NODEJS_INSTALLED NODEJS_VERSION
}

# 检测 Python3
detect_python3() {
    if command -v python3 >/dev/null 2>&1; then
        PYTHON3_INSTALLED=true
        PYTHON3_VERSION=$(python3 --version)
    else
        PYTHON3_INSTALLED=false
    fi

    export PYTHON3_INSTALLED PYTHON3_VERSION
}

# 检测 omlx
detect_omlx() {
    if pip3 show omlx >/dev/null 2>&1; then
        OMLX_INSTALLED=true
        OMLX_VERSION=$(pip3 show omlx | grep Version | cut -d' ' -f2)
    else
        OMLX_INSTALLED=false
    fi

    export OMLX_INSTALLED OMLX_VERSION
}

# 检测 OpenClaw
detect_openclaw() {
    if command -v openclaw >/dev/null 2>&1; then
        OPENCLAW_INSTALLED=true
        OPENCLAW_VERSION=$(openclaw --version 2>/dev/null | head -1)
    else
        OPENCLAW_INSTALLED=false
    fi

    export OPENCLAW_INSTALLED OPENCLAW_VERSION
}

# ==============================================================================
# 综合检测
# ==============================================================================

# 检测所有环境信息
detect_all_environments() {
    # 系统信息
    detect_macos_version
    detect_cpu_info
    detect_memory_info
    detect_disk_info

    # 软件信息
    detect_homebrew
    detect_nodejs
    detect_python3
    detect_omlx
    detect_openclaw
}

# 格式化内存大小
format_memory_size() {
    local bytes=$1
    local gb=$((bytes / 1024 / 1024 / 1024))
    local mb=$((bytes / 1024 / 1024 % 1024))

    if [[ ${gb} -gt 0 ]]; then
        echo "${gb}GB"
    else
        echo "${mb}MB"
    fi
}

# 格式化 CPU 型号
format_cpu_model() {
    local model="$1"

    # 提取芯片类型
    if [[ "${model}" =~ "Apple M([1-5])( Pro| Max| Ultra)?" ]]; then
        local generation="${match[1]}"
        local variant="${match[2]}"

        case "${generation}" in
            1) echo "Apple M1${variant}" ;;
            2) echo "Apple M2${variant}" ;;
            3) echo "Apple M3${variant}" ;;
            4) echo "Apple M4${variant}" ;;
            5) echo "Apple M5${variant}" ;;
            *) echo "${model}" ;;
        esac
    else
        echo "${model}"
    fi
}

# 检查环境是否符合要求
check_environment_requirements() {
    local issues=()

    # 检查 macOS 版本
    local major_version=$(echo "${MACOS_VERSION}" | cut -d'.' -f1)
    if [[ ${major_version} -lt 12 ]]; then
        issues+=("❌ macOS 版本过低：${MACOS_VERSION}（要求 12.0 或更高）")
    else
        issues+=("✅ macOS 版本：${MACOS_VERSION}")
    fi

    # 检查 CPU 架构
    if [[ "${CPU_ARCHITECTURE}" != "arm64" ]]; then
        issues+=("❌ CPU 架构不支持：${CPU_ARCHITECTURE}（要求 Apple Silicon arm64）")
    else
        issues+=("✅ CPU 架构：$(format_cpu_model "${CPU_MODEL}")")
    fi

    # 检查内存
    local memory_gb=$((MEMORY_SIZE / 1024 / 1024 / 1024))
    if [[ ${memory_gb} -lt 16 ]]; then
        issues+=("⚠️  内存较小：${memory_gb}GB（推荐 16GB 或更多）")
    else
        issues+=("✅ 内存：${memory_gb}GB")
    fi

    # 检查磁盘空间
    local disk_available_gb=$(echo "${DISK_AVAILABLE}" | sed 's/G//' | sed 's/T/*1024/' | bc 2>/dev/null || echo "0")
    if [[ $(echo "${disk_available_gb} < 20" | bc -l 2>/dev/null || echo "0") -eq 1 ]]; then
        issues+=("❌ 磁盘空间不足：${DISK_AVAILABLE}（要求至少 20GB）")
    else
        issues+=("✅ 磁盘可用：${DISK_AVAILABLE}")
    fi

    # 返回问题列表
    echo "${issues[@]}"
}

# ==============================================================================
# 显示函数
# ==============================================================================

# 显示环境检测报告
show_environment_report() {
    # 确保已执行检测
    detect_all_environments

    local report="════════════════════════════════════════════════════════════════════════════════
                          系统环境检测报告
════════════════════════════════════════════════════════════════════════════════

【系统信息】
  macOS 版本：${MACOS_VERSION} (${MACOS_BUILD})
  CPU 架构：$(format_cpu_model "${CPU_MODEL}")
  CPU 核心数：${CPU_CORES}
  内存总量：$(format_memory_size ${MEMORY_SIZE})
  可用内存：$(format_memory_size ${MEMORY_AVAILABLE})
  磁盘可用：${DISK_AVAILABLE}（已使用 ${DISK_USED_PERCENT}%）

【已安装软件】
"

    # 软件状态
    if ${HOMEBREW_INSTALLED}; then
        report="${report}  ✅ Homebrew: ${HOMEBREW_VERSION}\n"
    else
        report="${report}  ⏸️  Homebrew: 未安装\n"
    fi

    if ${NODEJS_INSTALLED}; then
        report="${report}  ✅ Node.js: ${NODEJS_VERSION}\n"
    else
        report="${report}  ⏸️  Node.js: 未安装\n"
    fi

    if ${PYTHON3_INSTALLED}; then
        report="${report}  ✅ Python3: ${PYTHON3_VERSION}\n"
    else
        report="${report}  ⏸️  Python3: 未安装\n"
    fi

    if ${OMLX_INSTALLED}; then
        report="${report}  ✅ omlx: ${OMLX_VERSION}\n"
    else
        report="${report}  ⏸️  omlx: 未安装\n"
    fi

    if ${OPENCLAW_INSTALLED}; then
        report="${report}  ✅ OpenClaw: ${OPENCLAW_VERSION}\n"
    else
        report="${report}  ⏸️  OpenClaw: 未安装\n"
    fi

    report="${report}════════════════════════════════════════════════════════════════════════════════"

    # 显示报告
    echo "${report}"

    # 在对话框中显示
    show_info_dialog "${report}" "环境检测报告"
}

# 显示环境检查结果
show_environment_check() {
    local issues=($(check_environment_requirements))

    local check_report="环境检查结果：\n\n"

    for issue in "${issues[@]}"; do
        check_report="${check_report}${issue}\n"
    done

    # 检查是否有严重问题
    local has_critical=false
    for issue in "${issues[@]}"; do
        if [[ "${issue}" == *"❌"* ]]; then
            has_critical=true
            break
        fi
    done

    if ${has_critical}; then
        check_report="${check_report}\n⚠️  检测到严重问题，建议解决后再继续安装。"
        show_error_dialog "${check_report}" "环境检查失败"
        return 1
    else
        check_report="${check_report}\n✅ 环境检查通过，可以继续安装。"
        show_info_dialog "${check_report}" "环境检查通过"
        return 0
    fi
}

# ==============================================================================
# 导出函数
# ==============================================================================

export -f detect_macos_version
export -f detect_cpu_info
export -f detect_memory_info
export -f detect_disk_info
export -f detect_homebrew
export -f detect_nodejs
export -f detect_python3
export -f detect_omlx
export -f detect_openclaw
export -f detect_all_environments
export -f format_memory_size
export -f format_cpu_model
export -f check_environment_requirements
export -f show_environment_report
export -f show_environment_check
