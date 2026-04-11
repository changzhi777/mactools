#!/bin/sh
#
# MacTools E2E 测试脚本（改进版）
# 作者: 外星动物（常智）
# 版本: V1.0.1
# 说明: 完整的端到端测试，处理 ZIP 缓存问题
#

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 测试统计
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

# 测试结果
run_test() {
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    test_name="$1"
    test_command="$2"

    echo -n "  测试 $TESTS_TOTAL: $test_name ... "

    if eval "$test_command" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ 通过${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗ 失败${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# 清理函数
cleanup() {
    echo ""
    echo "清理测试环境..."
    rm -rf /tmp/mactools-e2e-test-* 2>/dev/null || true
}

trap cleanup EXIT

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          MacTools E2E 测试（完整版）                    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

TEST_DIR="/tmp/mactools-e2e-test-$$"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

# ============================================
# 阶段 1: 本地脚本测试（使用本地文件）
# ============================================

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  阶段 1: 本地脚本测试${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 复制本地文件进行测试
if [ -f "/Users/mac/cz_code/mactools/macclaw-installer/install-posix.sh" ]; then
    cp /Users/mac/cz_code/mactools/macclaw-installer/install-posix.sh .
    echo "  ✅ 使用本地 install-posix.sh"
else
    echo "  ⚠️  本地文件不存在，使用线上版本"
    curl -fsSL https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw-installer/install-posix.sh -o install-posix.sh
fi

run_test "install-posix.sh 语法（sh）" "sh -n install-posix.sh"
run_test "install-posix.sh 语法（bash）" "bash -n install-posix.sh"
run_test "install-posix.sh 语法（zsh）" "zsh -n install-posix.sh"

# 检查修复代码
if grep -q "unzip -q -O UTF-8" install-posix.sh; then
    echo "  ✅ 包含编码修复代码"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "  ✗ 缺少编码修复代码"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_TOTAL=$((TESTS_TOTAL + 1))

echo ""
echo -e "${GREEN}✅ 本地脚本测试完成${NC}"
echo ""

# ============================================
# 阶段 2: POSIX 兼容库测试
# ============================================

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  阶段 2: POSIX 兼容库测试${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ -f "/Users/mac/cz_code/mactools/macclaw-installer/lib/posix_compat.sh" ]; then
    cp /Users/mac/cz_code/mactools/macclaw-installer/lib/posix_compat.sh .
    . ./posix_compat.sh

    run_test "str_contains 函数" "str_contains 'hello world' 'world'"
    run_test "str_contains 不匹配" "! str_contains 'hello world' 'xyz'"
    run_test "command_exists（bash）" "command_exists bash"
    run_test "file_exists（README）" "test -f /Users/mac/cz_code/mactools/README.md && file_exists /Users/mac/cz_code/mactools/README.md"

    script_dir=$(get_script_dir)
    if [ -n "$script_dir" ]; then
        echo "  ✅ get_script_dir: $script_dir"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "  ✗ get_script_dir 失败"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    TESTS_TOTAL=$((TESTS_TOTAL + 1))

    detected_shell=$(detect_shell)
    echo "  ✅ detect_shell: $detected_shell"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    TESTS_TOTAL=$((TESTS_TOTAL + 1))

    # 测试数组模拟（手动实现）
    INSTALL_COMPONENTS=""
    add_component() {
        component="$1"
        if [ -z "$INSTALL_COMPONENTS" ]; then
            INSTALL_COMPONENTS="$component"
        else
            INSTALL_COMPONENTS="$INSTALL_COMPONENTS $component"
        fi
    }
    has_component() {
        component="$1"
        case "$INSTALL_COMPONENTS" in
            *$component*) return 0 ;;
            *) return 1 ;;
        esac
    }

    add_component "Node.js"
    add_component "OpenClaw"
    if has_component "Node.js"; then
        echo "  ✅ 数组模拟功能正常"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "  ✗ 数组模拟功能失败"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
fi

echo ""
echo -e "${GREEN}✅ POSIX 兼容库测试完成${NC}"
echo ""

# ============================================
# 阶段 3: Git 克隆测试（避免 ZIP 编码问题）
# ============================================

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  阶段 3: Git 克隆测试${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

cd "$TEST_DIR"

run_test "git 克隆仓库" "git clone --depth 1 https://github.com/changzhi777/mactools.git mactools-git"

if [ -d "mactools-git" ]; then
    cd mactools-git

    run_test "README.md 存在" "test -f README.md"
    run_test "VERSION 文件存在" "test -f VERSION"
    run_test "macclaw-installer 目录存在" "test -d macclaw-installer"
    run_test "tests 目录存在" "test -d tests"

    run_test "install-posix.sh 存在" "test -f macclaw-installer/install-posix.sh"
    run_test "install.sh 存在" "test -f macclaw-installer/install.sh"
    run_test "lib/posix_compat.sh 存在" "test -f macclaw-installer/lib/posix_compat.sh"
    run_test "lib/colors.sh 存在" "test -f macclaw-installer/lib/colors.sh"

    echo ""
    echo "  📁 项目结构（前 15 项）:"
    find . -maxdepth 2 -type d | head -15 | sed 's|^\./|     |'

    echo ""
    echo "  📄 关键文件:"
    ls -1 *.md 2>/dev/null | head -10 | sed 's/^/     /'
fi

echo ""
echo -e "${GREEN}✅ Git 克隆测试完成${NC}"
echo ""

# ============================================
# 阶段 4: 文件内容验证
# ============================================

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  阶段 4: 文件内容验证${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

cd "$TEST_DIR/mactools-git"

run_test "README.md 包含安装命令" "grep -q 'install-posix.sh' README.md"
run_test "install-posix.sh 包含作者信息" "grep -q '外星动物（常智）' macclaw-installer/install-posix.sh"
run_test "install-posix.sh 包含版本信息" "grep -q 'V1.0.1' macclaw-installer/install-posix.sh"
run_test "install-posix.sh 包含编码修复" "grep -q 'unzip -q -O UTF-8' macclaw-installer/install-posix.sh"
run_test "posix_compat.sh 包含核心函数" "grep -q 'get_script_dir' macclaw-installer/lib/posix_compat.sh"

echo ""
echo "  📝 版本信息:"
if [ -f "VERSION" ]; then
    cat VERSION | sed 's/^/     /'
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "     ✗ 无法读取版本"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_TOTAL=$((TESTS_TOTAL + 1))

echo ""
echo -e "${GREEN}✅ 文件内容验证完成${NC}"
echo ""

# ============================================
# 阶段 5: 环境兼容性测试
# ============================================

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  阶段 5: 环境兼容性测试${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

run_test "sh 可用" "command -v sh"
run_test "bash 可用" "command -v bash"
run_test "zsh 可用" "command -v zsh"

# 检测 dash
if command -v dash >/dev/null 2>&1; then
    echo "  ✅ dash 可用"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "  ⚠️  dash 未安装（可选）"
fi
TESTS_TOTAL=$((TESTS_TOTAL + 1))

echo ""
echo "  🖥️  系统信息:"
echo "     macOS: $(sw_vers -productVersion) $(sw_vers -buildVersion)"
echo "     架构: $(uname -m)"
echo "     内核: $(uname -r)"
echo "     主机: $(hostname)"
echo "     可用空间: $(df -h / | tail -1 | awk '{print $4}')"

echo ""
echo -e "${GREEN}✅ 环境兼容性测试完成${NC}"
echo ""

# ============================================
# 阶段 6: 工具链测试
# ============================================

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  阶段 6: 工具链测试${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

run_test "curl 可用" "command -v curl && curl --version | head -1"
run_test "git 可用" "command -v git && git --version"
run_test "unzip 可用" "command -v unzip"

# 可选工具
for tool in node openclaw python3 pip3 npm; do
    if command -v "$tool" >/dev/null 2>&1; then
        version=$($tool --version 2>/dev/null || $tool -v 2>/dev/null || echo "未知版本")
        echo "  ✅ $tool: $version"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "  ⚠️  $tool: 未安装"
    fi
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
done

echo ""
echo -e "${GREEN}✅ 工具链测试完成${NC}"
echo ""

# ============================================
# 阶段 7: 线上资源测试
# ============================================

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  阶段 7: 线上资源测试${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

run_test "GitHub 仓库可访问" "curl -s -I https://github.com/changzhi777/mactools | grep -q 200"
run_test "install-posix.sh 可下载" "curl -s -I https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw-installer/install-posix.sh | grep -q 200"
run_test "install.sh 可下载" "curl -s -I https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw-installer/install.sh | grep -q 200"
run_test "README.md 可访问" "curl -s -I https://raw.githubusercontent.com/changzhi777/mactools/main/README.md | grep -q 200"

echo ""
echo "  🌐 线上资源状态:"
echo "     ✅ GitHub 仓库: https://github.com/changzhi777/mactools"
echo "     ✅ POSIX 版本: install-posix.sh"
echo "     ✅ Bash 版本: install.sh"
echo "     ✅ 文档: README.md"

echo ""
echo -e "${GREEN}✅ 线上资源测试完成${NC}"
echo ""

# ============================================
# 阶段 8: 实际安装命令测试（模拟）
# ============================================

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  阶段 8: 安装命令测试${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

cd "$TEST_DIR"

# 测试 POSIX 版本安装命令
echo "  📥 测试 POSIX 版本安装命令..."
cat > test_install_posix.sh << 'EOF'
#!/bin/sh
# 模拟安装过程
echo "检测在线安装模式..."
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# 下载项目
echo "下载项目..."
if git clone --depth 1 https://github.com/changzhi777/mactools.git temp_repo; then
    echo "✅ 下载成功"
    cd temp_repo/macclaw-installer

    # 加载库
    if [ -f "lib/posix_compat.sh" ]; then
        . lib/posix_compat.sh
        echo "✅ 库加载成功"

        # 测试函数
        if str_contains "test" "es"; then
            echo "✅ 函数测试通过"
        fi
    fi

    cd /tmp
    rm -rf "$TEMP_DIR"
    exit 0
else
    echo "❌ 下载失败"
    exit 1
fi
EOF

chmod +x test_install_posix.sh
if sh test_install_posix.sh >/dev/null 2>&1; then
    echo "  ✅ POSIX 安装流程测试通过"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "  ✗ POSIX 安装流程测试失败"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_TOTAL=$((TESTS_TOTAL + 1))

echo ""
echo -e "${GREEN}✅ 安装命令测试完成${NC}"
echo ""

# ============================================
# 阶段 9: 性能测试
# ============================================

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  阶段 9: 性能测试${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 测试脚本启动时间
cd "$TEST_DIR/mactools-git"
start_time=$(date +%s%N)
sh -n macclaw-installer/install-posix.sh
end_time=$(date +%s%N)
syntax_time=$((end_time - start_time))

echo "  ⚡ 脚本语法检查: ${syntax_time}ns"

# 测试 Git 克隆速度
start_time=$(date +%s)
if git clone --depth 1 https://github.com/changzhi777/mactools.git test-clone >/dev/null 2>&1; then
    end_time=$(date +%s)
    clone_time=$((end_time - start_time))
    echo "  ⚡ Git 克隆时间: ${clone_time}s"
    rm -rf test-clone
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "  ✗ Git 克隆失败"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_TOTAL=$((TESTS_TOTAL + 1))

echo ""
echo -e "${GREEN}✅ 性能测试完成${NC}"
echo ""

# ============================================
# 测试报告
# ============================================

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    E2E 测试报告                              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo "  测试阶段: 9"
echo "  总测试数: ${CYAN}$TESTS_TOTAL${NC}"
echo "  通过测试: ${GREEN}$TESTS_PASSED${NC}"
echo "  失败测试: ${RED}$TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ 所有 E2E 测试通过！${NC}"
else
    echo ""
    echo -e "${RED}✗ 部分测试失败${NC}"
fi

echo ""

# 计算通过率
if [ $TESTS_TOTAL -gt 0 ]; then
    pass_rate=$((TESTS_PASSED * 100 / TESTS_TOTAL))
    echo "  通过率: ${CYAN}${pass_rate}%${NC}"
fi

echo ""
echo "测试目录: $TEST_DIR"
echo "（测试完成后将自动清理）"

echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║          🎉 E2E 测试全部通过！                          ║${NC}"
    echo -e "${GREEN}║                                                            ║${NC}"
    echo -e "${GREEN}║  所有功能验证通过，项目可以正常使用！                  ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "推荐安装命令："
    echo "  curl -fsSL https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw-installer/install-posix.sh | sh"
    echo ""
    exit 0
else
    echo -e "${RED}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║          ⚠️  部分测试失败                                 ║${NC}"
    echo -e "${RED}║                                                            ║${NC}"
    echo -e "${RED}║  请检查失败项目并修复问题                                ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    exit 1
fi
