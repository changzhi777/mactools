#!/bin/bash
# BB小子 - 李小龙风格健康提醒系统
# 像水一样，保持流动和活力

# ==============================================================================
# 时间感知系统
# ==============================================================================

# 获取当前时间信息
get_current_time_info() {
    local current_hour=$(date +%H)
    local current_minute=$(date +%M)
    local current_dayOfWeek=$(date +%u) # 1=周一, 7=周日
    local current_date=$(date +%Y-%m-%d)

    echo "${current_hour}|${current_minute}|${current_dayOfWeek}|${current_date}"
}

# 判断是否为工作日
is_workday() {
    local dayOfWeek=$(date +%u)
    # 1-5 是周一到周五
    [[ ${dayOfWeek} -ge 1 && ${dayOfWeek} -le 5 ]]
}

# 判断是否为工作时间
is_work_hours() {
    local hour=$(date +%H)
    # 9:00-18:00 为工作时间
    [[ ${hour} -ge 9 && ${hour} -lt 18 ]]
}

# 判断是否为运动时间
is_exercise_time() {
    local hour=$(date +%H)
    # 推荐：早晨6-8点，晚上18-20点
    [[ (${hour} -ge 6 && ${hour} -lt 8) || (${hour} -ge 18 && ${hour} -lt 20) ]]
}

# 判断是否为休息时间
is_break_time() {
    local hour=$(date +%H)
    local minute=$(date +%M)

    # 工作时间内每2小时提醒休息
    if is_work_hours; then
        local totalMinutes=$((hour * 60 + minute))
        local workStart=$((9 * 60)) # 9:00
        local elapsed=$((totalMinutes - workStart))

        # 每2小时提醒一次休息：11:00, 13:00, 15:00, 17:00
        [[ $((elapsed % 120)) -lt 15 ]] # 15分钟窗口期
    fi
}

# ==============================================================================
# 李小龙风格健康提醒
# ==============================================================================

# 喝水提醒
drink_water_reminder() {
    local hour=$(date +%H)
    local messages=()

    if [[ ${hour} -ge 9 && ${hour} -lt 12 ]]; then
        messages+=(
            "上午时光，身体需要水分。像水一样，保持流动。"
            "水是生命之源。别等渴了才喝。"
            "身体像水一样，需要不断流动才能保持活力。"
        )
    elif [[ ${hour} -ge 12 && ${hour} -lt 15 ]]; then
        messages+=(
            "午后人容易疲劳，喝水能提神醒脑。"
            "下午时光，补充水分保持专注。"
            "功夫不是吹出来的，健康也是。喝水！"
        )
    elif [[ ${hour} -ge 15 && ${hour} -lt 18 ]]; then
        messages+=(
            "傍晚时分，别让身体缺水。"
            "一天快结束了，保持水分到最后。"
        )
    else
        messages+=(
            "像水一样，时刻保持流动。"
            "身体需要水分，就像功夫需要练习。"
        )
    fi

    # 随机选择一条消息
    local count=${#messages[@]}
    local index=$((RANDOM % count))
    echo "${messages[$index]}"
}

# 运动提醒
exercise_reminder() {
    local hour=$(date +%H)
    local messages=()

    if [[ ${hour} -ge 6 && ${hour} -lt 9 ]]; then
        messages+=(
            "早晨时光，身体已经准备好活动了。动起来！"
            "早上练功，一天精神。别偷懒！"
            "年轻不是借口。功夫不是吹出来的，练出来的！"
        )
    elif [[ ${hour} -ge 12 && ${hour} -lt 14 ]]; then
        messages+=(
            "午休时间，适合伸展身体。别坐太久！"
            "饭后百步走，活到九十九。起来动动！"
            "身体需要运动，就像功夫需要练习。"
        )
    elif [[ ${hour} -ge 18 && ${hour} -lt 21 ]]; then
        messages+=(
            "工作了一天，该让身体活动活动了。"
            "晚上练功，恢复精力。今天练得怎么样？"
            "功夫不是一天练成的，但每天都必须练。"
        )
    else
        messages+=(
            "身体像水一样，需要流动才能保持活力。"
            "运动不是为了表演，是为了健康。"
            "年轻也注意保持运动。身体是你最重要的资产。"
        )
    fi

    local count=${#messages[@]}
    local index=$((RANDOM % count))
    echo "${messages[$index]}"
}

# 工作日提醒
workday_motivation() {
    local hour=$(date +%H)
    local messages=()

    if [[ ${hour} -ge 9 && ${hour} -lt 12 ]]; then
        messages+=(
            "新的一天，新的挑战。准备好了吗？"
            "专注当下，像水一样适应变化。"
            "限制只是为了突破。今天要突破什么？"
        )
    elif [[ ${hour} -ge 14 && ${hour} -lt 17 ]]; then
        messages+=(
            "下午时光，保持专注。别让疲劳战胜你。"
            "工作效率来自简洁。去除不必要的。"
            "持续改进，精益求精。这就是功夫精神。"
        )
    else
        messages+=(
            "一天结束，反思今天。明天继续进步。"
            "功夫不是一天练成的，但每天都必须练。"
        )
    fi

    local count=${#messages[@]}
    local index=$((RANDOM % count))
    echo "${messages[$index]}"
}

# 休息提醒
break_reminder() {
    local messages=(
        "坐太久了，起来活动活动。身体需要流动。"
        "眼睛累了，看看远方。像水一样，灵活调整。"
        "休息是为了更好地前进。别硬撑！"
        "功夫讲究张弛有度。你呢？"
    )

    local count=${#messages[@]}
    local index=$((RANDOM % count))
    echo "${messages[$index]}"
}

# ==============================================================================
# 智能提醒系统
# ==============================================================================

# 智能健康提醒
smart_health_reminder() {
    local time_info=$(get_current_time_info)
    IFS='|' read -r hour minute dayOfWeek date <<< "${time_info}"

    echo "🥋 李小龙健康提醒"
    echo "================"
    echo ""
    echo "时间: $(date '+%H:%M')"
    echo "日期: ${date}"
    echo ""

    # 根据时间提供不同提醒
    if is_exercise_time; then
        echo -e "🏃 运动时间："
        echo "  $(exercise_reminder)"
        echo ""
    fi

    # 每2小时提醒喝水（简单模拟）
    if [[ $((minute % 30)) -lt 5 ]]; then
        echo -e "💧 喝水提醒："
        echo "  $(drink_water_reminder)"
        echo ""
    fi

    # 工作日特定提醒
    if is_workday && is_work_hours; then
        if is_break_time; then
            echo -e "🧘 休息提醒："
            echo "  $(break_reminder)"
            echo ""
        fi

        echo -e "💪 功夫精神："
        echo "  $(workday_motivation)"
        echo ""
    fi

    echo "🥋 像水一样，保持流动。"
}

# 快速提醒
quick_reminder() {
    local reminder_type="$1"

    case "${reminder_type}" in
        water)
            echo "💧 $(drink_water_reminder)"
            ;;
        exercise)
            echo "🏃 $(exercise_reminder)"
            ;;
        break)
            echo "🧘 $(break_reminder)"
            ;;
        motivation)
            echo "💪 $(workday_motivation)"
            ;;
        *)
            smart_health_reminder
            ;;
    esac
}

# ==============================================================================
# 主函数
# ==============================================================================

main() {
    local action="$1"

    case "${action}" in
        smart|check)
            smart_health_reminder
            ;;
        water)
            quick_reminder water
            ;;
        exercise)
            quick_reminder exercise
            ;;
        break)
            quick_reminder break
            ;;
        motivation)
            quick_reminder motivation
            ;;
        help|--help|-h)
            echo "李小龙风格健康提醒系统"
            echo ""
            echo "用法: $0 [smart|water|exercise|break|motivation]"
            echo ""
            echo "命令:"
            echo "  smart       - 智能健康提醒（根据时间和日期）"
            echo "  water       - 喝水提醒"
            echo "  exercise    - 运动提醒"
            echo "  break       - 休息提醒"
            echo "  motivation  - 功夫精神激励"
            echo ""
            echo "示例:"
            echo "  $0 smart       # 智能提醒"
            echo "  $0 water       # 喝水提醒"
            echo "  $0 exercise    # 运动提醒"
            ;;
        *)
            smart_health_reminder
            ;;
    esac
}

# 如果直接运行脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
