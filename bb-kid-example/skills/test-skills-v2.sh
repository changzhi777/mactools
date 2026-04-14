#!/bin/bash
# BB小子 Agent 技能集成测试脚本 v2.0
# 测试新闻收集和提醒事项技能的完整集成

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(dirname "${SCRIPT_DIR}")"

echo "🤖 BB小子 Agent 技能集成测试 v2.0"
echo "===================================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 测试计数
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# 测试函数
run_test() {
    local test_name="$1"
    local test_command="$2"

    ((TESTS_TOTAL++))
    echo -e "${BLUE}测试 ${TESTS_TOTAL}: ${test_name}${NC}"
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
echo -e "${CYAN}=== 1. 技能文件检查 ===${NC}"
run_test "新闻收集技能文件存在" "[ -f ${SCRIPT_DIR}/news-collector.zsh ]"
run_test "提醒事项技能文件存在" "[ -f ${SCRIPT_DIR}/macos-reminders.zsh ]"
run_test "技能配置文件存在" "[ -f ${WORKSPACE_ROOT}/.openclaw/skills.yaml ]"
run_test "新闻获取模块存在" "[ -f ${SCRIPT_DIR}/news-fetcher.sh ]"
run_test "API配置文件存在" "[ -f ${SCRIPT_DIR}/news-api.conf ]"

# 2. 测试技能帮助功能
echo -e "${CYAN}=== 2. 技能帮助功能 ===${NC}"
run_test "新闻收集帮助" "${SCRIPT_DIR}/news-collector.zsh help | grep -q 'v2.0'"
run_test "提醒事项帮助" "${SCRIPT_DIR}/macos-reminders.zsh help | grep -q 'v2.0'"

# 3. 测试新闻收集功能
echo -e "${CYAN}=== 3. 新闻收集功能 ===${NC}"
run_test "收集科技新闻（真实API）" "${SCRIPT_DIR}/news-collector.zsh collect tech 1 | grep -q 'Hacker News'"
run_test "新闻收集降级功能" "${SCRIPT_DIR}/news-collector.zsh collect ai 1 | grep -q 'AI'"

# 4. 测试提醒事项功能
echo -e "${CYAN}=== 4. 提醒事项功能 ===${NC}"
run_test "权限检查功能" "${SCRIPT_DIR}/macos-reminders.zsh check | grep -q '所有权限检查通过'"
run_test "查看提醒列表" "${SCRIPT_DIR}/macos-reminders.zsh list | grep -q '提醒列表'"
run_test "管理建议功能" "${SCRIPT_DIR}/macos-reminders.zsh tips | grep -q '提醒管理建议'"

# 5. 测试真实提醒创建
echo -e "${CYAN}=== 5. 真实提醒创建测试 ===${NC}"
run_test "创建测试提醒" "AUTO_EXECUTE=true ${SCRIPT_DIR}/macos-reminders.zsh create 'BB小子自动化测试' '2026-12-31 23:59' '自动化测试' | grep -q '创建成功'"

# 6. 测试技能配置
echo -e "${CYAN}=== 6. 技能配置验证 ===${NC}"
if [ -f "${WORKSPACE_ROOT}/.openclaw/skills.yaml" ]; then
    run_test "配置文件格式正确" "grep -q 'skills:' ${WORKSPACE_ROOT}/.openclaw/skills.yaml"
    run_test "新闻收集技能已配置" "grep -q 'news-collector:' ${WORKSPACE_ROOT}/.openclaw/skills.yaml"
    run_test "提醒事项技能已配置" "grep -q 'macos-reminders:' ${WORKSPACE_ROOT}/.openclaw/skills.yaml"
    run_test "工作流配置存在" "grep -q 'workflows:' ${WORKSPACE_ROOT}/.openclaw/skills.yaml"
fi

# 7. 测试技能权限
echo -e "${CYAN}=== 7. 技能执行权限 ===${NC}"
run_test "新闻收集脚本可执行" "[ -x ${SCRIPT_DIR}/news-collector.zsh ]"
run_test "提醒事项脚本可执行" "[ -x ${SCRIPT_DIR}/macos-reminders.zsh ]"
run_test "新闻获取模块可执行" "[ -x ${SCRIPT_DIR}/news-fetcher.sh ]"

# 8. 测试依赖工具
echo -e "${CYAN}=== 8. 依赖工具检查 ===${NC}"
run_test "curl可用" "command -v curl >/dev/null 2>&1"
run_test "jq可用" "command -v jq >/dev/null 2>&1"
run_test "osascript可用" "command -v osascript >/dev/null 2>&1"

# 9. 测试AppleScript功能
echo -e "${CYAN}=== 9. AppleScript功能测试 ===${NC}"
run_test "提醒应用可访问" "osascript -e 'tell application \"Reminders\" to get name of every list' >/dev/null 2>&1"
run_test "日历应用可访问" "osascript -e 'tell application \"Calendar\" to get name of every calendar' >/dev/null 2>&1"

# 10. 测试缓存功能
echo -e "${CYAN}=== 10. 缓存功能测试 ===${NC}"
CACHE_DIR="${HOME}/.openclaw/workspaces/bb-kid/cache/news"
run_test "缓存目录存在" "[ -d ${CACHE_DIR} ]"

# 测试结果汇总
echo "===================================="
echo -e "${CYAN}📊 测试结果汇总${NC}"
echo "===================================="
echo -e "${GREEN}通过: ${TESTS_PASSED}${NC}"
echo -e "${RED}失败: ${TESTS_FAILED}${NC}"
echo "总计: ${TESTS_TOTAL}"
echo ""

# 计算通过率
PASS_RATE=$((TESTS_PASSED * 100 / TESTS_TOTAL))
echo -e "通过率: ${PASS_RATE}%"
echo ""

if [ ${TESTS_FAILED} -eq 0 ]; then
    echo -e "${GREEN}🎉 所有测试通过！BB小子 Agent 技能集成完全成功！${NC}"
    echo ""
    echo -e "${CYAN}🚀 可以开始使用以下功能：${NC}"
    echo "  • 新闻收集: ~/.openclaw/workspaces/bb-kid/skills/news-collector.zsh collect tech"
    echo "  • 创建提醒: ~/.openclaw/workspaces/bb-kid/skills/macos-reminders.zsh create '标题' '时间'"
    echo "  • 查看演示: cat ${SCRIPT_DIR}/REMINDERS_DEMO.md"
    exit 0
else
    echo -e "${YELLOW}⚠️  部分测试失败，请检查上述错误${NC}"
    echo ""
    echo -e "${YELLOW}💡 常见问题解决：${NC}"
    echo "  1. 权限问题: ~/.openclaw/workspaces/bb-kid/skills/macos-reminders.zsh check"
    echo "  2. 依赖缺失: brew install jq"
    echo "  3. 网络问题: 检查互联网连接"
    exit 1
fi
