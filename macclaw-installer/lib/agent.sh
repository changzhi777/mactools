#!/bin/bash
#
# MacClaw Installer - Agent 管理模块
# 作者: 外星动物（常智）
# 组织: IoTchange
# 邮箱: 14455975@qq.com
# 版本: V1.0.1
# 版权: Copyright (C) 2026 IoTchange - All Rights Reserved
#
# 说明: 管理 OpenClaw Agent 的创建、配置和技能绑定
#

# 加载日志模块
source "$(dirname "$0")/logger.sh"

# 创建 Agent
create_agent() {
    local agent_name="$1"
    local workspace="$2"
    local model="$3"

    log_info "🤖 创建 Agent: $agent_name"

    # 检查 Agent 是否已存在
    if openclaw agents list | grep -q "^$agent_name"; then
        log_warning "⚠️  Agent $agent_name 已存在"
        return 1
    fi

    # 创建 Agent
    openclaw agents add "$agent_name" \
        --workspace "$workspace" \
        --non-interactive

    if [ $? -ne 0 ]; then
        log_error "❌ Agent 创建失败: $agent_name"
        return 1
    fi

    # 配置模型
    openclaw agents config "$agent_name" --model "$model"

    if [ $? -eq 0 ]; then
        log_success "✅ Agent $agent_name 创建完成"
        log_info "   工作空间: $workspace"
        log_info "   模型: $model"
        return 0
    else
        log_error "❌ Agent 配置失败: $agent_name"
        return 1
    fi
}

# 列出所有 Agents
list_agents() {
    log_info "📋 已安装的 Agents:"
    echo ""

    openclaw agents list

    if [ $? -eq 0 ]; then
        return 0
    else
        log_error "❌ 获取 Agent 列表失败"
        return 1
    fi
}

# 删除 Agent
delete_agent() {
    local agent_name="$1"

    log_info "🗑️  删除 Agent: $agent_name"

    # 确认操作
    if ! confirm_action "确认删除 Agent $agent_name？"; then
        log_info "已取消删除"
        return 0
    fi

    openclaw agents delete "$agent_name"

    if [ $? -eq 0 ]; then
        log_success "✅ Agent 删除完成"
        return 0
    else
        log_error "❌ Agent 删除失败"
        return 1
    fi
}

# 为 Agent 配置 Skill
attach_agent_skill() {
    local agent_name="$1"
    local skill_name="$2"

    log_info "⚙️  为 $agent_name 配置 Skill: $skill_name"

    openclaw agents skills attach "$agent_name" "$skill_name"

    if [ $? -eq 0 ]; then
        log_success "✅ Skill 配置完成"
        return 0
    else
        log_error "❌ Skill 配置失败"
        return 1
    fi
}

# 列出 Agent 的 Skills
list_agent_skills() {
    local agent_name="$1"

    log_info "📋 Agent $agent_name 的 Skills:"
    echo ""

    openclaw agents skills list --agent "$agent_name"

    if [ $? -eq 0 ]; then
        return 0
    else
        log_error "❌ 获取 Skills 列表失败"
        return 1
    fi
}

# 创建默认 Agents
create_default_agents() {
    log_info "🤖 开始创建默认 Agents..."
    show_separator

    # 创建 main Agent
    create_agent "main" \
        "$HOME/.openclaw/workspace-main" \
        "omlx/gemma-4-e4b-it-4bit"

    # 创建 assistant Agent
    create_agent "assistant" \
        "$HOME/.openclaw/workspace-assistant" \
        "omlx/gemma-4-e4b-it-4bit"

    show_separator
    log_success "✅ 默认 Agents 创建完成"
}

# 配置默认 Skills
configure_default_skills() {
    log_info "⚙️  配置默认 Agent Skills..."
    show_separator

    # 为 main Agent 配置 Skills
    log_info "为 main Agent 配置 Skills..."
    attach_agent_skill "main" "file-operations"
    attach_agent_skill "main" "web-search"
    attach_agent_skill "main" "code-executor"

    # 为 assistant Agent 配置 Skills
    log_info "为 assistant Agent 配置 Skills..."
    attach_agent_skill "assistant" "file-operations"
    attach_agent_skill "assistant" "task-manager"

    show_separator
    log_success "✅ 默认 Skills 配置完成"
}

# 显示 Agent 状态
show_agent_status() {
    log_info "📊 Agent 状态:"
    echo ""

    list_agents
    echo ""

    # 显示每个 Agent 的 Skills
    local agents=("main" "assistant")
    for agent in "${agents[@]}"; do
        if openclaw agents list | grep -q "^$agent"; then
            list_agent_skills "$agent"
            echo ""
        fi
    done
}

# 导出函数
export -f create_agent
export -f list_agents
export -f delete_agent
export -f attach_agent_skill
export -f list_agent_skills
export -f create_default_agents
export -f configure_default_skills
export -f show_agent_status
