#!/usr/bin/env zsh
# ==============================================================================
# BB小子技能 - 苹果系统提醒事项设置 (v2.0)
# 支持真实的 AppleScript 执行和自动化
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
            echo -e "${COLOR_BLUE}🥋 知道不够，必须做到。别忘了：${COLOR_NC}"
            echo "  ${date_time}: ${title}"
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

# 创建重复提醒
execute_recurring_reminder() {
    local title="$1"
    local frequency="$2"
    local time="$3"
    local notes="$4"

    echo -e "${COLOR_CYAN}⏰ 创建重复提醒${COLOR_NC}"
    echo "==================="
    echo ""
    echo -e "${COLOR_BLUE}提醒详情：${COLOR_NC}"
    echo "  标题: ${title}"
    echo "  频率: ${frequency}"
    echo "  时间: ${time}"
    echo "  备注: ${notes}"
    echo ""

    # 根据频率选择创建方法
    case "${frequency}" in
        daily|每日|天)
            local interval=1
            local unit="days"
            ;;
        weekly|每周|周)
            local interval=1
            local unit="weeks"
            ;;
        monthly|每月|月)
            local interval=1
            local unit="months"
            ;;
        *)
            echo -e "${COLOR_YELLOW}⚠️  不支持的频率: ${frequency}${COLOR_NC}"
            echo "支持的频率: daily, weekly, monthly"
            return 1
            ;;
    esac

    # 使用日历事件创建重复提醒（更可靠）
    local calendar_script="
tell application \"Calendar\"
    -- 获取家庭日历
    set homeCal to null
    try
        set homeCal to calendar \"Home\"
    on error
        set homeCal to first calendar
    end try

    -- 创建事件
    set newEvent to make new event at end of events of homeCal with properties {summary:\"${title}\", start date:date \"${time}\", description:\"${notes}\"}

    -- 设置重复规则
    tell newEvent
        make new recurrence rule at end of recurrence rules with properties {frequency:${frequency}, interval:${interval}}
    end tell
end tell
"

    # 询问是否执行
    echo -e "${COLOR_YELLOW}创建方法：${COLOR_NC}"
    echo "  [1] 使用日历事件（推荐）"
    echo "  [2] 使用提醒事项"
    echo "  [3] 仅显示命令"
    echo ""
    echo -n "选择 (1/2/3): "
    read -r method

    case "${method}" in
        1)
            echo -e "${COLOR_CYAN}使用日历创建重复提醒...${COLOR_NC}"
            if osascript -e "${calendar_script}" 2>&1; then
                echo -e "${COLOR_GREEN}✅ 重复提醒创建成功！${COLOR_NC}"
                echo "  提醒已添加到日历，将在指定时间重复通知"
                return 0
            else
                echo -e "${COLOR_RED}❌ 创建失败${COLOR_NC}"
                return 1
            fi
            ;;
        2)
            echo -e "${COLOR_YELLOW}⚠️  提醒事项不支持复杂的重复规则${COLOR_NC}"
            echo "建议使用日历事件或快捷指令"
            return 1
            ;;
        3)
            echo -e "${COLOR_YELLOW}📝 日历 AppleScript：${COLOR_NC}"
            echo ""
            echo 'osascript <<EOF'
            echo "${calendar_script}"
            echo 'EOF'
            return 0
            ;;
        *)
            echo -e "${COLOR_RED}❌ 无效选择${COLOR_NC}"
            return 1
            ;;
    esac
}

# 查看现有提醒
list_existing_reminders() {
    echo -e "${COLOR_CYAN}📋 查看现有提醒${COLOR_NC}"
    echo "==================="
    echo ""

    echo -e "${COLOR_BLUE}正在获取提醒列表...${COLOR_NC}"

    # 获取所有列表
    local lists=$(osascript -e 'tell application "Reminders" to get name of every list' 2>/dev/null)

    if [[ $? -ne 0 ]] || [[ -z "${lists}" ]]; then
        echo -e "${COLOR_YELLOW}⚠️  无法访问提醒事项${COLOR_NC}"
        echo "请检查权限设置"
        return 1
    fi

    echo -e "${COLOR_GREEN}找到以下列表：${COLOR_NC}"
    echo ""

    # 显示每个列表的提醒数量
    for list in ${(ps:,:)lists}; do
        local count=$(osascript -e "tell application \"Reminders\" to count reminders of list \"${list}\"" 2>/dev/null)
        echo -e "  📁 ${list}: ${count} 个提醒"
    done

    echo ""
    echo -e "${COLOR_BLUE}💡 快速操作：${COLOR_NC}"
    echo "  打开提醒应用: open ${REMINDERS_APP}"
    echo "  查看所有提醒: osascript -e 'tell application \"Reminders\" to show every list'"
    echo ""
}

# 提醒管理建议
reminder_management_tips() {
    echo -e "${COLOR_CYAN}💡 提醒管理建议${COLOR_NC}"
    echo "==================="
    echo ""
    echo -e "${COLOR_BLUE}🎯 高效提醒设置原则：${COLOR_NC}"
    echo ""
    echo "1. 时间管理"
    echo "   • 批量设置相似提醒"
    echo "   • 设置合理的提醒间隔"
    echo "   • 避免提醒过载"
    echo ""
    echo "2. 优先级管理"
    echo "   • 重要事项设置多级提醒"
    echo "   • 普通事项单次提醒"
    echo "   • 可选事项设置低优先级"
    echo ""
    echo "3. 分类管理"
    echo "   • 工作/生活提醒分离"
    echo "   • 使用不同列表组织"
    echo "   • 添加智能列表"
    echo ""
    echo "4. 位置提醒"
    echo "   • 到达特定地点触发"
    echo "   • 结合地理围栏"
    echo "   • 上下文感知提醒"
    echo ""
    echo -e "${COLOR_BLUE}🔧 快捷指令自动化：${COLOR_NC}"
    echo "   • 创建每日简报自动化"
    echo "   • 设置基于时间的提醒"
    echo "   • 集成其他应用功能"
    echo ""
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
        "recurring")
            if [[ -z "$2" ]]; then
                echo "用法: macos-reminders.zsh recurring <标题> <频率> <时间> [备注]"
                echo ""
                echo "示例:"
                echo "  macos-reminders.zsh recurring '每日站会' 'daily' '10:00' '上午10点'"
                echo "  macos-reminders.zsh recurring '团队周会' 'weekly' '周一 14:00'"
                echo ""
                echo "频率选项:"
                echo "  • daily/每日 - 每天"
                echo "  • weekly/每周 - 每周"
                echo "  • monthly/每月 - 每月"
            else
                execute_recurring_reminder "$2" "$3" "$4" "$5"
            fi
            ;;
        "list")
            list_existing_reminders
            ;;
        "tips")
            reminder_management_tips
            ;;
        "check")
            check_macos_permissions
            ;;
        "auto")
            # 设置自动执行模式
            if [[ "$2" == "on" ]]; then
                export AUTO_EXECUTE=true
                echo -e "${COLOR_GREEN}✅ 自动执行模式已开启${COLOR_NC}"
            elif [[ "$2" == "off" ]]; then
                export AUTO_EXECUTE=false
                echo -e "${COLOR_YELLOW}⚠️  自动执行模式已关闭${COLOR_NC}"
            else
                echo "用法: macos-reminders.zsh auto [on|off]"
            fi
            ;;
        "help"|"--help"|"-h")
            echo "BB小子苹果提醒设置技能 v2.0"
            echo "支持真实的 AppleScript 执行"
            echo ""
            echo "用法: macos-reminders.zsh [create|recurring|list|tips|check|auto]"
            echo ""
            echo "功能："
            echo "  create    - 创建单次提醒（支持真实执行）"
            echo "  recurring - 创建重复提醒（通过日历）"
            echo "  list      - 查看现有提醒"
            echo "  tips      - 管理建议"
            echo "  check     - 检查权限"
            echo "  auto      - 设置自动执行模式"
            echo ""
            echo "环境变量:"
            echo "  AUTO_EXECUTE=true  - 跳过确认直接执行"
            echo ""
            echo "示例:"
            echo "  AUTO_EXECUTE=true macos-reminders.zsh create '测试' '2024-04-15 10:00'"
            ;;
        *)
            echo "BB小子苹果提醒设置技能"
            echo "用法: macos-reminders.zsh [create|recurring|list|tips|check|auto]"
            echo ""
            echo "功能："
            echo "  create    - 创建单次提醒"
            echo "  recurring - 创建重复提醒"
            echo "  list      - 查看现有提醒"
            echo "  tips      - 管理建议"
            echo "  check     - 检查权限"
            echo "  auto      - 设置自动执行模式"
            ;;
    esac
}

main "$@"
