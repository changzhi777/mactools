#!/usr/bin/env zsh
# ==============================================================================
# BB小子技能 - 苹果系统提醒事项设置 (李小龙风格版)
# 支持真实的 AppleScript 执行和自动化
# 包含时间感知和健康提醒
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
    WORKSPACE_ROOT=$(get_bb_kid_workspace_root)
    SKILLS_DIR=$(get_skills_dir)
    CONFIG_DIR=$(get_config_dir)
else
    # 降级到硬编码路径
    WORKSPACE_ROOT="${HOME}/.openclaw/workspaces/bb-kid"
    SKILLS_DIR="${WORKSPACE_ROOT}/skills"
    CONFIG_DIR="${WORKSPACE_ROOT}/.openclaw"
fi

# 颜色定义
typeset -g COLOR_RED='\033[0;31m'
typeset -g COLOR_GREEN='\033[0;32m'
typeset -g COLOR_YELLOW='\033[1;33m'
typeset -g COLOR_BLUE='\033[0;34m'
typeset -g COLOR_CYAN='\033[0;36m'
typeset -g COLOR_NC='\033[0m'

# 配置
typeset -g REMINDERS_APP="/System/Applications/Reminders.app"
typeset -g CALENDAR_APP="/System/Applications/Calendar.app"
typeset -g SHORTCUTS_APP="/System/Applications/Shortcuts.app"
typeset -g DEFAULT_LIST="BB小子"
typeset -g AUTO_EXECUTE=${AUTO_EXECUTE:-false}

# ==============================================================================
# 时间感知系统
# ==============================================================================

# 获取当前时间信息
get_current_time_info() {
    local current_hour=$(date +%H)
    local current_minute=$(date +%M)
    local current_dayOfWeek=$(date +%u)
    local current_date=$(date +%Y-%m-%d)

    echo "${current_hour}|${current_minute}|${current_dayOfWeek}|${current_date}"
}

# 判断是否为工作日
is_workday() {
    local dayOfWeek=$(date +%u)
    [[ ${dayOfWeek} -ge 1 && ${dayOfWeek} -le 5 ]]
}

# 判断是否为工作时间
is_work_hours() {
    local hour=$(date +%H)
    [[ ${hour} -ge 9 && ${hour} -lt 18 ]]
}

# ==============================================================================
# 李小龙风格健康提醒
# ==============================================================================

# 根据时间提供健康提醒
get_bruce_health_reminder() {
    local time_info=$(get_current_time_info)
    IFS='|' read -r hour minute dayOfWeek date <<< "${time_info}"

    local reminders=()

    # 基于时间的健康提醒
    if is_workday; then
        case ${hour} in
            9|10)
                if [[ $((minute % 30)) -lt 10 ]]; then
                    reminders+=("💧 别忘了喝水。像水一样，保持流动。")
                fi
                reminders+=("💪 保持专注。像水一样适应变化。")
                ;;
            11|12)
                reminders+=("🧘 午休时间到了。起来活动活动身体。")
                reminders+=("💧 补充水分。功夫不是吹出来的。")
                ;;
            13|14|15|16)
                if [[ $((minute % 30)) -lt 10 ]]; then
                    reminders+=("💧 记得喝水。")
                fi
                reminders+=("💪 年轻也注意保持运动。功夫不是吹出来的，是练出来的。")
                reminders+=("🧘 坐太久了，起来走走。保持流动。")
                ;;
            17|18)
                reminders+=("🔄 一天结束了，反思今天。明天继续进步。")
                ;;
            *)
                reminders+=("🥋 身体像水一样，需要流动才能保持活力。")
                ;;
        esac
    else
        # 周末提醒
        case ${hour} in
            6|7|8)
                reminders+=("🏃 早晨时光，适合运动。功夫不是一天练成的。")
                ;;
            9|10|11)
                reminders+=("🌱 周末时光，休息是为了更好地前进。")
                ;;
            14|15|16)
                reminders+=("💪 别忘了运动。功夫不是吹出来的。")
                ;;
            *)
                reminders+=("🥋 像水一样，保持流动和活力。")
                ;;
        esac
    fi

    # 输出提醒
    if [[ ${#reminders[@]} -gt 0 ]]; then
        local count=${#reminders[@]}
        local index=$((RANDOM % count))
        echo "${reminders[$index]}"
    fi
}

# ==============================================================================
# 权限检查模块
# ==============================================================================

# 检查 macOS 权限
check_macos_permissions() {
    echo -e "${COLOR_CYAN}🔒 检查 macOS 权限${COLOR_NC}"
    echo "==================="
    echo ""

    local all_good=true

    # 检查提醒应用
    echo -e "${COLOR_BLUE}检查提醒应用...${COLOR_NC}"
    if [[ -d "${REMINDERS_APP}" ]]; then
        echo -e "${COLOR_GREEN}✅ 提醒应用已安装${COLOR_NC}"

        # 测试 AppleScript 访问
        if osascript -e 'tell application "Reminders" to get name of every list' >/dev/null 2>&1; then
            echo -e "${COLOR_GREEN}✅ AppleScript 访问权限正常${COLOR_NC}"
        else
            echo -e "${COLOR_YELLOW}⚠️  AppleScript 访问受限${COLOR_NC}"
            echo -e "${COLOR_YELLOW}   请在 系统设置 → 隐私与安全性 → 自动化 中授权终端${COLOR_NC}"
            all_good=false
        fi
    else
        echo -e "${COLOR_RED}❌ 提醒应用未找到${COLOR_NC}"
        all_good=false
    fi

    echo ""

    # 检查日历应用
    echo -e "${COLOR_BLUE}检查日历应用...${COLOR_NC}"
    if [[ -d "${CALENDAR_APP}" ]]; then
        echo -e "${COLOR_GREEN}✅ 日历应用已安装${COLOR_NC}"

        if osascript -e 'tell application "Calendar" to get name of every calendar' >/dev/null 2>&1; then
            echo -e "${COLOR_GREEN}✅ 日历访问权限正常${COLOR_NC}"
        else
            echo -e "${COLOR_YELLOW}⚠️  日历访问受限${COLOR_NC}"
            all_good=false
        fi
    else
        echo -e "${COLOR_YELLOW}⚠️  日历应用未找到${COLOR_NC}"
    fi

    echo ""

    # 检查通知权限
    echo -e "${COLOR_BLUE}检查通知权限...${COLOR_NC}"
    if osascript -e 'tell application "System Events" to get name of every process whose background only is false' >/dev/null 2>&1; then
        echo -e "${COLOR_GREEN}✅ 系统事件访问正常${COLOR_NC}"
    else
        echo -e "${COLOR_YELLOW}⚠️  系统事件访问受限${COLOR_NC}"
        all_good=false
    fi

    echo ""
    if ${all_good}; then
        echo -e "${COLOR_GREEN}🎉 所有权限检查通过！${COLOR_NC}"
        return 0
    else
        echo -e "${COLOR_YELLOW}⚠️  部分权限需要手动授权${COLOR_NC}"
        return 1
    fi
}

# ==============================================================================
# 提醒事项创建模块
# ==============================================================================

# 执行 AppleScript 创建提醒
execute_applescript_reminder() {
    local title="$1"
    local date_time="$2"
    local notes="$3"
    local list_name="${4:-${DEFAULT_LIST}}"

    echo -e "${COLOR_CYAN}🍏 创建 macOS 提醒事项${COLOR_NC}"
    echo "==================="
    echo ""
    echo -e "${COLOR_BLUE}提醒详情：${COLOR_NC}"
    echo "  标题: ${title}"
    echo "  时间: ${date_time}"
    echo "  备注: ${notes}"
    echo "  列表: ${list_name}"
    echo ""

    # 构建 AppleScript
    local applescript="
tell application \"Reminders\"
    -- 确保列表存在
    set targetList to null
    try
        set targetList to list \"${list_name}\"
    on error
        set targetList to make new list with properties {name:\"${list_name}\"}
    end try

    -- 创建提醒
    set newReminder to make new reminder with properties {name:\"${title}\", body:\"${notes}\"} at end of reminders of targetList

    -- 设置到期时间
    try
        set due date of newReminder to date \"${date_time}\"
    on error errMsg
        log \"时间解析错误: \" & errMsg
    end try

    -- 设置优先级
    set priority of newReminder to 0
end tell
"

    # 询问是否执行
    if [[ "${AUTO_EXECUTE}" == "true" ]]; then
        local execute=true
    else
        echo -e "${COLOR_YELLOW}是否执行创建提醒？${COLOR_NC}"
        echo "  [Y] 是 - 直接创建"
        echo "  [N] 否 - 仅显示命令"
        echo "  [A] 总是 - 以后自动执行"
        echo ""
        echo -n "选择 (Y/N/A): "
        read -r choice

        case "${choice}" in
            y|Y|yes|YES) execute=true ;;
            a|A|always|ALWAYS)
                execute=true
                export AUTO_EXECUTE=true
                echo -e "${COLOR_GREEN}✓ 已设置为自动执行模式${COLOR_NC}"
                ;;
            *) execute=false ;;
        esac
    fi

    if ${execute}; then
        echo -e "${COLOR_CYAN}正在创建提醒...${COLOR_NC}"

        # 执行 AppleScript
        local result=$(osascript -e "${applescript}" 2>&1)

        if [[ $? -eq 0 ]]; then
            echo -e "${COLOR_GREEN}✅ 提醒已创建。${COLOR_NC}"
            echo ""
            echo -e "${COLOR_CYAN}🥋 知道不够，必须做到。别忘了：${COLOR_NC}"
            echo "  ${date_time}: ${title}"

            # 提供健康提醒
            echo ""
            echo -e "${COLOR_CYAN}💡 李小龙提醒：${COLOR_NC}"
            get_bruce_health_reminder
            echo ""

            return 0
        else
            echo -e "${COLOR_RED}❌ 提醒创建失败${COLOR_NC}"
            echo -e "${COLOR_RED}错误: ${result}${COLOR_NC}"
            return 1
        fi
    else
        echo -e "${COLOR_YELLOW}📝 AppleScript 命令：${COLOR_NC}"
        echo ""
        echo 'osascript <<EOF'
        echo "${applescript}"
        echo 'EOF'
        echo ""
        return 0
    fi
}

# ==============================================================================
# 主函数
# ==============================================================================

main() {
    local action="$1"

    case "${action}" in
        "create")
            if [[ -z "$2" ]]; then
                echo "用法: macos-reminders.zsh create <标题> <时间> [备注] [列表]"
                echo ""
                echo "示例:"
                echo "  macos-reminders.zsh create '团队会议' '2024-04-15 14:00' '准备PPT'"
                echo "  macos-reminders.zsh create '买牛奶' '明天 10:00' '' '购物'"
                echo ""
                echo "时间格式:"
                echo "  • YYYY-MM-DD HH:MM"
                echo "  • '明天 HH:MM'"
                echo "  • '下周一 HH:MM'"
            else
                execute_applescript_reminder "$2" "$3" "$4" "$5"
            fi
            ;;
        "check")
            check_macos_permissions
            ;;
        "help"|"--help"|"-h")
            echo "BB小子苹果提醒设置技能 v2.0 (李小龙风格)"
            echo "支持真实的 AppleScript 执行"
            echo ""
            echo "用法: macos-reminders.zsh [create|check]"
            echo ""
            echo "功能:"
            echo "  create    - 创建单次提醒（含健康提醒）"
            echo "  check     - 检查权限"
            echo ""
            echo "🥋 李小龙风格特色："
            echo "  • 时间感知的健康提醒"
            echo "  • 工作日运动和喝水提醒"
            echo "  • 简洁直接的对话风格"
            echo "  • 功夫哲学融入日常"
            ;;
        *)
            echo "BB小子苹果提醒设置技能"
            echo "用法: macos-reminders.zsh [create|check]"
            echo ""
            echo "功能："
            echo "  create    - 创建单次提醒"
            echo "  check     - 检查权限"
            ;;
    esac
}

main "$@"
