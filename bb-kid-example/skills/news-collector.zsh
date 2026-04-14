#!/usr/bin/env zsh
# ==============================================================================
# BB小子技能 - 热点新闻收集整理 (v2.0)
# 支持真实新闻源：RSS、API 和内置降级
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd)"

# 快速依赖检查
if [[ -f "${SCRIPT_DIR}/dependency-check.sh" ]]; then
    if ! bash "${SCRIPT_DIR}/dependency-check.sh" quick >/dev/null 2>&1; then
        echo "⚠️  检测到依赖缺失，运行以下命令检查："
        echo "  bash ${SCRIPT_DIR}/dependency-check.sh check"
        echo "  bash ${SCRIPT_DIR}/dependency-check.sh fix"
    fi
fi

# 加载路径工具
if [[ -f "${SCRIPT_DIR}/path-utils.sh" ]]; then
    source "${SCRIPT_DIR}/path-utils.sh"
else
    # 降级到简单路径处理
    get_absolute_path() {
        local path="$1"
        [[ "${path}" =~ ^~ ]] && path="${path/#\~/${HOME}}"
        echo "${path}"
    }
fi

# 新闻源配置
typeset -A NEWS_SOURCES=(
    ["tech"]="科技新闻"
    ["ai"]="人工智能"
    ["coding"]="编程开发"
    ["apple"]="苹果相关"
)

# 颜色定义
typeset -g COLOR_CYAN='\033[0;36m'
typeset -g COLOR_GREEN='\033[0;32m'
typeset -g COLOR_YELLOW='\033[1;33m'
typeset -g COLOR_RED='\033[0;31m'
typeset -g COLOR_NC='\033[0m'

# 内置新闻源（降级使用）
builtin_news() {
    local category="$1"

    case "${category}" in
        "tech")
            echo "📱 今日科技要闻："
            echo "  1. Apple 发布新的 M5 芯片性能提升显著"
            echo "  2. Google Gemini 2.0 模型能力超越 GPT-4"
            echo "  3. 特斯拉 Optimus 机器人开始批量交付"
            echo ""
            ;;
        "ai")
            echo "🤖 AI核心动态："
            echo "  1. OpenAI 发布 GPT-5 预览版"
            echo "  2. Anthropic Claude 4.6 性能大幅提升"
            echo "  3. 开源模型 Llama 3 引起广泛关注"
            echo ""
            ;;
        "coding")
            echo "💻 编程实战要点："
            echo "  1. Rust 2.0 版本发布，性能提升50%"
            echo "  2. Python 4.0 添加新的类型系统"
            echo "  3. JavaScript 框架生态持续演进"
            echo ""
            ;;
        "apple")
            echo "🍎 苹果关键更新："
            echo "  1. macOS 26.4.1 修复多个安全漏洞"
            echo "  2. iOS 19.4 新增辅助功能"
            echo "  3. 新款 iPad Pro 性能测试结果"
            echo ""
            ;;
    esac

    echo "🥋 值得关注的就这些。其他都是噪音。"
}

# 收集新闻函数
collect_news() {
    local category="$1"
    local limit="${2:-5}"

    echo "📰 收集${NEWS_SOURCES[$category]}新闻..."
    echo ""

    # 尝试使用真实新闻源
    if [[ -f "${SCRIPT_DIR}/news-fetcher.sh" ]]; then
        source "${SCRIPT_DIR}/news-fetcher.sh"

        echo -e "${COLOR_CYAN}🌐 正在连接实时新闻源...${NC}"
        echo ""

        # 检查依赖工具
        local dependencies_met=true
        if ! command -v curl >/dev/null 2>&1; then
            echo -e "${COLOR_YELLOW}⚠️  curl 未安装，使用内置新闻源${NC}"
            dependencies_met=false
        fi

        if ! command -v jq >/dev/null 2>&1; then
            echo -e "${COLOR_YELLOW}⚠️  jq 未安装，JSON解析功能受限${NC}"
        fi

        if [[ "${dependencies_met}" == "true" ]]; then
            if smart_fetch_news "${category}" "${limit}"; then
                return 0
            else
                echo -e "${COLOR_YELLOW}⚠️  实时新闻源获取失败，使用内置新闻源${NC}"
                echo ""
            fi
        fi
    else
        echo -e "${COLOR_YELLOW}⚠️  新闻获取模块未找到，使用内置新闻源${NC}"
        echo ""
    fi

    # 降级到内置新闻源
    echo -e "${COLOR_GREEN}📋 使用内置新闻源${COLOR_NC}"
    echo ""
    builtin_news "${category}"
}

# 整理新闻摘要
summarize_news() {
    local category="$1"

    echo "📋 ${NEWS_SOURCES[$category]}新闻摘要"
    echo "================================"
    echo ""
    echo "更新时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    echo "重点新闻："
    echo "  • 查看详细信息和源链接"
    echo "  • 设置关键词提醒"
    echo "  • 相关技术讨论"
    echo ""
}

# 李小龙风格健康提醒（新闻收集后）
show_bruce_reminder_after_news() {
    local hour=$(date +%H)
    local minute=$(date +%M)
    local dayOfWeek=$(date +%u)

    echo ""
    echo -e "${COLOR_CYAN}🥋 李小龙提醒：${COLOR_NC}"

    # 根据时间和星期几提供不同提醒
    if [[ ${dayOfWeek} -ge 1 && ${dayOfWeek} -le 5 ]]; then
        # 工作日提醒
        case ${hour} in
            9|10|11)
                echo "  上午时光，保持专注。像水一样适应变化。"
                ;;
            12|13)
                echo "  午后时光，喝口水，活动一下身体。功夫不是吹出来的。"
                ;;
            14|15|16|17)
                echo "  下午时光，别让疲劳积累。起来走走，保持流动。"
                ;;
            18|19)
                echo "  一天结束，反思今天。明天继续进步。"
                ;;
            *)
                echo "  身体像水一样，需要流动才能保持活力。"
                ;;
        esac
    else
        # 周末提醒
        echo "  周末时光，休息是为了更好地前进。但也别忘了运动。"
    fi

    # 偶尔提醒喝水
    if [[ $((minute % 30)) -lt 10 ]]; then
        echo "  💧 别忘了喝水。像水一样，保持流动。"
    fi

    # 年轻也注意保持运动
    if [[ ${hour} -ge 14 && ${hour} -lt 17 ]]; then
        echo "  💪 年轻也注意保持运动。功夫不是吹出来的，是练出来的。"
    fi

    echo ""
}

# 主函数
main() {
    local action="$1"
    local category="${2:-tech}"

    case "${action}" in
        "collect")
            collect_news "${category}" "${3:-5}"
            ;;
        "summarize")
            summarize_news "${category}"
            ;;
        "help"|"--help"|"-h")
            echo "BB小子新闻收集技能 v2.0"
            echo "支持实时新闻源和内置降级"
            echo ""
            echo "用法: news-collector.zsh [collect|summarize] [category] [limit]"
            echo "类别: tech, ai, coding, apple"
            echo "限制: 每次收集的新闻数量（默认5）"
            echo ""
            echo "示例:"
            echo "  news-collector.zsh collect tech 10   # 收集10条科技新闻"
            echo "  news-collector.zsh summarize ai       # AI新闻摘要"
            ;;
        *)
            echo "BB小子新闻收集技能"
            echo "用法: news-collector.zsh [collect|summarize] [category]"
            echo "类别: tech, ai, coding, apple"
            ;;
    esac
}

main "$@"
