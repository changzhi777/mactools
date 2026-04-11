#!/bin/bash
#
# MacClaw Installer - 颜色定义库
# 作者: 外星动物（常智）
# 组织: IoTchange
# 邮箱: 14455975@qq.com
# 版本: V1.0.1
# 版权: Copyright (C) 2026 IoTchange - All Rights Reserved
#
# 说明: 统一的颜色定义，供所有脚本使用
#

# ============================================
# ANSI 颜色代码
# ============================================

export RED='\033[0;31m'          # 错误
export GREEN='\033[0;32m'        # 成功
export YELLOW='\033[1;33m'       # 警告
export BLUE='\033[0;34m'         # 信息
export CYAN='\033[0;36m'         # 标题
export MAGENTA='\033[0;35m'      # 强调
export NC='\033[0m'              # 无颜色（重置）

# ============================================
# 颜色使用函数
# ============================================

# 打印红色文本
print_red() {
    echo -e "${RED}$*${NC}"
}

# 打印绿色文本
print_green() {
    echo -e "${GREEN}$*${NC}"
}

# 打印黄色文本
print_yellow() {
    echo -e "${YELLOW}$*${NC}"
}

# 打印蓝色文本
print_blue() {
    echo -e "${BLUE}$*${NC}"
}

# 打印青色文本
print_cyan() {
    echo -e "${CYAN}$*${NC}"
}

# 打印品红色文本
print_magenta() {
    echo -e "${MAGENTA}$*${NC}"
}

# ============================================
# UI 元素函数
# ============================================

# 打印分隔线
print_separator() {
    echo -e "${CYAN}────────────────────────────────────────────────────────${NC}"
}

# 打印标题框
print_header() {
    local title="$1"
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    printf "${BLUE}║${NC} %-60s ${BLUE}║${NC}\n" "$title"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
}

# 打印成功标记
print_success() {
    echo -e "${GREEN}✓ $*${NC}"
}

# 打印错误标记
print_error() {
    echo -e "${RED}✗ $*${NC}"
}

# 打印警告标记
print_warning() {
    echo -e "${YELLOW}⚠️  $*${NC}"
}

# 打印信息标记
print_info() {
    echo -e "${BLUE}ℹ️  $*${NC}"
}
