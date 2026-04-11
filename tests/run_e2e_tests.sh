#!/bin/bash
#
# e2e 测试运行器
# 作者: 外星动物（常智）
# 组织: IoTchange
# 邮箱: 14455975@qq.com
# 版本: V1.0.1
# 版权: Copyright (C) 2026 IoTchange - All Rights Reserved
#
# 说明: 用于运行 MacClaw Installer 的端到端测试
#

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 项目根目录
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# 添加 Bats 到 PATH（如果安装在用户目录）
if [ -d "$HOME/.local/bin" ] && [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# ============================================
# 打印带颜色的消息
# ============================================

print_header() {
    echo ""
    echo -e "${BLUE}==========================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}==========================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# ============================================
# 检查依赖
# ============================================

check_dependencies() {
    print_header "检查依赖"

    local missing_deps=0

    # 检查 Bats
    if ! command -v bats &>/dev/null; then
        print_error "Bats 未安装"
        print_info "请运行以下命令安装 Bats:"
        echo "  mkdir -p ~/.local/bin"
        echo "  cd /tmp && git clone --depth 1 https://github.com/bats-core/bats.git"
        echo "  cd bats && PREFIX=~/.local ./install.sh ~/.local"
        ((missing_deps++))
    else
        local bats_version=$(bats --version)
        print_success "Bats 已安装: $bats_version"
    fi

    # 检查辅助工具
    if command -v curl &>/dev/null; then
        print_success "curl 已安装"
    else
        print_warning "curl 未安装，部分测试可能失败"
    fi

    if command -v git &>/dev/null; then
        print_success "git 已安装"
    else
        print_warning "git 未安装，部分测试可能失败"
    fi

    if [ $missing_deps -gt 0 ]; then
        print_error "缺少 $missing_deps 个必要依赖"
        exit 1
    fi
}

# ============================================
# 运行测试
# ============================================

run_tests() {
    print_header "MacClaw Installer e2e 测试"

    # 检查测试目录
    if [ ! -d "tests/e2e" ]; then
        print_error "测试目录不存在: tests/e2e"
        exit 1
    fi

    # 计算测试文件数
    local test_count=$(ls tests/e2e/*.bats 2>/dev/null | wc -l)
    print_info "找到 $test_count 个测试文件"
    echo ""

    # 运行测试
    local start_time=$(date +%s)

    if bats tests/e2e/ \
        --tap \
        --timing \
        --verbose-report; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))

        echo ""
        print_header "测试结果"
        print_success "所有测试通过！"
        print_info "总耗时: ${duration} 秒"
        return 0
    else
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))

        echo ""
        print_header "测试结果"
        print_error "部分测试失败"
        print_info "总耗时: ${duration} 秒"
        print_info "请查看上面的测试报告了解详情"
        return 1
    fi
}

# ============================================
# 运行特定测试
# ============================================

run_specific_test() {
    local test_file=$1

    if [ ! -f "$test_file" ]; then
        print_error "测试文件不存在: $test_file"
        exit 1
    fi

    print_header "运行测试: $test_file"

    bats "$test_file" \
        --tap \
        --timing \
        --verbose-report
}

# ============================================
# 列出可用测试
# ============================================

list_tests() {
    print_header "可用的测试文件"

    local test_num=1
    for test_file in tests/e2e/*.bats; do
        if [ -f "$test_file" ]; then
            local test_name=$(basename "$test_file")
            echo "  $test_num. $test_name"
            ((test_num++))
        fi
    done
}

# ============================================
# 显示帮助信息
# ============================================

show_help() {
    cat << EOF
用法: $0 [选项] [测试文件]

选项:
  -h, --help          显示此帮助信息
  -l, --list          列出所有可用的测试文件
  -v, --verbose       详细输出模式
  -f, --file FILE     运行特定的测试文件

示例:
  $0                  # 运行所有测试
  $0 -l              # 列出所有测试
  $0 -f test_01_environment.bats  # 运行特定测试

环境变量:
  BATS_VERBOSE_RUN   设置为 '1' 启用详细输出
  TEST_TIMEOUT       测试超时时间（秒）

EOF
}

# ============================================
# 主函数
# ============================================

main() {
    local test_file=""

    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -l|--list)
                list_tests
                exit 0
                ;;
            -f|--file)
                test_file="$2"
                shift 2
                ;;
            -v|--verbose)
                export BATS_VERBOSE_RUN=1
                shift
                ;;
            *)
                print_error "未知选项: $1"
                show_help
                exit 1
                ;;
        esac
    done

    # 检查依赖
    check_dependencies

    # 运行测试
    if [ -n "$test_file" ]; then
        run_specific_test "$test_file"
    else
        run_tests
    fi
}

# 运行主函数
main "$@"
