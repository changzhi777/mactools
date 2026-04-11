#!/bin/bash
#
# 纯 Shell 脚本测试框架
# 作者: 外星动物（常智）
# 组织: IoTchange
# 邮箱: 14455975@qq.com
# 版本: V1.0.1
# 版权: Copyright (C) 2026 IoTchange - All Rights Reserved
#
# 说明: 无依赖的纯 Shell 测试框架
#

set -e

# ============================================
# 颜色定义（加载统一颜色库）
# ============================================

# 获取项目根目录
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 加载统一颜色库
if [ -f "$PROJECT_ROOT/macclaw-installer/lib/colors.sh" ]; then
    source "$PROJECT_ROOT/macclaw-installer/lib/colors.sh"
else
    # 后备颜色定义
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    NC='\033[0m'
fi

# ============================================
# 测试统计
# ============================================

TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0
TESTS_RUN=0

# ============================================
# 测试结果存储
# ============================================

FAILED_TESTS=()
declare -a FAILED_TESTS

# ============================================
# 项目路径
# ============================================

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALLER_DIR="$PROJECT_ROOT/macclaw-installer"

# ============================================
# 核心测试函数
# ============================================

# 辅助函数
command_exists() {
    command -v "$1" &>/dev/null
}

# 测试断言函数
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-断言失败}"

    if [ "$expected" = "$actual" ]; then
        return 0
    else
        echo "  ❌ $message"
        echo "     期望: $expected"
        echo "     实际: $actual"
        return 1
    fi
}

assert_not_empty() {
    local value="$1"
    local message="${2:-值不应为空}"

    if [ -n "$value" ]; then
        return 0
    else
        echo "  ❌ $message"
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    local message="${2:-文件不存在: $file}"

    if [ -f "$file" ]; then
        return 0
    else
        echo "  ❌ $message"
        return 1
    fi
}

assert_dir_exists() {
    local dir="$1"
    local message="${2:-目录不存在: $dir}"

    if [ -d "$dir" ]; then
        return 0
    else
        echo "  ❌ $message"
        return 1
    fi
}

assert_command_exists() {
    local cmd="$1"
    local message="${2:-命令不存在: $cmd}"

    if command -v "$cmd" &>/dev/null; then
        return 0
    else
        echo "  ❌ $message"
        return 1
    fi
}

assert_success() {
    local status="$1"
    local message="${2:-命令执行失败}"

    if [ "$status" -eq 0 ]; then
        return 0
    else
        echo "  ❌ $message (退出码: $status)"
        return 1
    fi
}

# 跳过测试
skip_test() {
    local reason="$1"
    echo "  ⏭️  跳过: $reason"
    ((TESTS_SKIPPED++))
    return 0
}

# ============================================
# 测试运行器
# ============================================

# 运行单个测试
run_test() {
    local test_name="$1"
    local test_function="$2"

    ((TESTS_TOTAL++))
    ((TESTS_RUN++))

    echo -n "  测试 $TESTS_RUN: $test_name ... "

    # 执行测试函数
    if $test_function; then
        echo -e "${GREEN}✓ 通过${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ 失败${NC}"
        ((TESTS_FAILED++))
        FAILED_TESTS+=("$test_name")
        return 1
    fi
}

# 运行测试套件
run_test_suite() {
    local suite_name="$1"
    local suite_function="$2"

    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $suite_name${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    $suite_function
}

# ============================================
# 辅助函数
# ============================================

# 打印分隔线
print_separator() {
    echo ""
    echo -e "${CYAN}────────────────────────────────────────────────────────${NC}"
}

# 打印标题
print_header() {
    local title="$1"
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    printf "${BLUE}║${NC} %-60s ${BLUE}║${NC}\n" "$title"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
}

# 打印测试报告
print_test_report() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                    测试报告                                ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  总测试数: ${CYAN}$TESTS_TOTAL${NC}"
    echo -e "  运行测试: ${CYAN}$TESTS_RUN${NC}"
    echo -e "  通过测试: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "  失败测试: ${RED}$TESTS_FAILED${NC}"
    echo -e "  跳过测试: ${YELLOW}$TESTS_SKIPPED${NC}"

    if [ $TESTS_FAILED -gt 0 ]; then
        echo ""
        echo -e "${RED}失败的测试:${NC}"
        for test in "${FAILED_TESTS[@]}"; do
            echo -e "  ${RED}✗${NC} $test"
        done
    fi

    echo ""

    # 计算通过率
    if [ $TESTS_RUN -gt 0 ]; then
        local pass_rate=$((TESTS_PASSED * 100 / TESTS_RUN))
        echo -e "  通过率: ${CYAN}${pass_rate}%${NC}"
    fi

    echo ""

    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}✓ 所有测试通过！${NC}"
        return 0
    else
        echo -e "${RED}✗ 部分测试失败${NC}"
        return 1
    fi
}

# ============================================
# 清理函数
# ============================================

cleanup() {
    # 清理临时文件
    rm -rf /tmp/pure_shell_test_* 2>/dev/null || true
}

# ============================================
# 信号处理
# ============================================

trap cleanup EXIT
