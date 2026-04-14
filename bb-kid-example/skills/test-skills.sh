#!/bin/bash
# BB小子 Agent 技能集成测试脚本
# 版本: 1.0.0
# 测试新闻收集和提醒事项技能的集成

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(dirname "${SCRIPT_DIR}")"

echo "🤖 BB小子 Agent 技能集成测试"
echo "================================"
echo ""

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 测试计数
TESTS_PASSED=0
TESTS_FAILED=0

# 测试函数
run_test() {
    local test_name="$1"
    local test_command="$2"

    echo -e "${BLUE}测试: ${test_name}${NC}"
    echo "命令: ${test_command}"

    if eval "${test_command}"; then
        echo -e "${GREEN}✅ 通过${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}❌ 失败${NC}"
        ((TESTS_FAILED++))
    fi
    echo ""
}

# 1. 测试技能文件存在性
echo "=== 1. 技能文件检查 ==="
run_test "新闻收集技能文件存在" "[ -f ${SCRIPT_DIR}/news-collector.zsh ]"
run_test "提醒事项技能文件存在" "[ -f ${SCRIPT_DIR}/macos-reminders.zsh ]"
run_test "技能配置文件存在" "[ -f ${WORKSPACE_ROOT}/.openclaw/skills.yaml ]"

# 2. 测试技能帮助功能
echo "=== 2. 技能帮助功能 ==="
run_test "新闻收集帮助" "${SCRIPT_DIR}/news-collector.zsh help | grep -q 'BB小子新闻收集技能'"
run_test "提醒事项帮助" "${SCRIPT_DIR}/macos-reminders.zsh help | grep -q 'BB小子苹果提醒设置技能'"

# 3. 测试新闻收集功能
echo "=== 3. 新闻收集功能 ==="
run_test "收集科技新闻" "${SCRIPT_DIR}/news-collector.zsh collect tech 2 | grep -q '📱'"

# 4. 测试提醒事项功能
echo "=== 4. 提醒事项功能 ==="
run_test "查看提醒提示" "${SCRIPT_DIR}/macos-reminders.zsh tips | grep -q '💡'"

# 5. 测试技能配置
echo "=== 5. 技能配置验证 ==="
if [ -f "${WORKSPACE_ROOT}/.openclaw/skills.yaml" ]; then
    run_test "配置文件格式正确" "yq eval '.' ${WORKSPACE_ROOT}/.openclaw/skills.yaml >/dev/null 2>&1 || grep -q 'skills:' ${WORKSPACE_ROOT}/.openclaw/skills.yaml"
    run_test "新闻收集技能已配置" "grep -q 'news-collector:' ${WORKSPACE_ROOT}/.openclaw/skills.yaml"
    run_test "提醒事项技能已配置" "grep -q 'macos-reminders:' ${WORKSPACE_ROOT}/.openclaw/skills.yaml"
fi

# 6. 测试技能权限
echo "=== 6. 技能执行权限 ==="
run_test "新闻收集脚本可执行" "[ -x ${SCRIPT_DIR}/news-collector.zsh ]"
run_test "提醒事项脚本可执行" "[ -x ${SCRIPT_DIR}/macos-reminders.zsh ]"

# 测试结果汇总
echo "================================"
echo "📊 测试结果汇总"
echo "================================"
echo -e "${GREEN}通过: ${TESTS_PASSED}${NC}"
echo -e "${RED}失败: ${TESTS_FAILED}${NC}"
echo "总计: $((TESTS_PASSED + TESTS_FAILED))"
echo ""

if [ ${TESTS_FAILED} -eq 0 ]; then
    echo -e "${GREEN}🎉 所有测试通过！BB小子 Agent 技能集成成功！${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️  部分测试失败，请检查上述错误${NC}"
    exit 1
fi
