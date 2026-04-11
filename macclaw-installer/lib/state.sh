#!/bin/bash
#
# MacClaw Installer - 状态管理模块
# 作者: 外星动物（常智）
# 版本: V1.0.1
#

# 加载日志模块
source "$(dirname "$0")/logger.sh"

# 状态文件路径
STATE_FILE="$HOME/.macclaw-installer/state.json"
BACKUP_DIR="$HOME/.macclaw-installer/backups"

# 初始化状态文件
init_state() {
    log_info "📝 初始化安装状态..."

    local state_dir=$(dirname "$STATE_FILE")
    mkdir -p "$state_dir"
    mkdir -p "$BACKUP_DIR"

    cat > "$STATE_FILE" << EOF
{
  "version": "V1.0.1",
  "start_time": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "current_step": 0,
  "total_steps": 7,
  "completed_steps": [],
  "failed_steps": [],
  "components": {
    "xcode_tools": false,
    "nodejs": false,
    "openclaw": false,
    "omlx": false,
    "model": false,
    "agents": false,
    "skills": false
  },
  "last_update": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

    log_success "✅ 状态文件已创建"
}

# 保存安装状态
save_state() {
    local step_name="$1"
    local status="$2"  # completed, failed
    local step_number="$3"

    if [ ! -f "$STATE_FILE" ]; then
        init_state
    fi

    # 更新状态
    python3 << EOF
import json

with open('$STATE_FILE', 'r') as f:
    state = json.load(f)

state['current_step'] = $step_number
state['last_update'] = '$(date -u +%Y-%m-%dT%H:%M:%SZ)'

if '$status' == 'completed':
    if '$step_name' not in state['completed_steps']:
        state['completed_steps'].append('$step_name')
    state['components']['$step_name'] = True
elif '$status' == 'failed':
    if '$step_name' not in state['failed_steps']:
        state['failed_steps'].append('$step_name')

with open('$STATE_FILE', 'w') as f:
    json.dump(state, f, indent=2)
EOF

    log_debug "状态已保存: $step_name ($status)"
}

# 加载安装状态
load_state() {
    if [ ! -f "$STATE_FILE" ]; then
        log_warning "⚠️  状态文件不存在，返回初始状态"
        return 1
    fi

    log_info "📂 加载安装状态..."
    cat "$STATE_FILE"
    return 0
}

# 获取已完成步骤
get_completed_steps() {
    if [ ! -f "$STATE_FILE" ]; then
        echo ""
        return
    fi

    python3 -c "
import json
with open('$STATE_FILE', 'r') as f:
    state = json.load(f)
    print(' '.join(state['completed_steps']))
"
}

# 检查步骤是否完成
is_step_completed() {
    local step_name="$1"

    if [ ! -f "$STATE_FILE" ]; then
        return 1
    fi

    local completed=$(python3 -c "
import json
with open('$STATE_FILE', 'r') as f:
    state = json.load(f)
    print('1' if '$step_name' in state['completed_steps'] else '0')
")

    return "$completed"
}

# 清理状态文件
cleanup_state() {
    log_info "🧹 清理状态文件..."

    if [ -f "$STATE_FILE" ]; then
        # 备份状态文件
        local backup_file="$BACKUP_DIR/state-$(date +%Y%m%d%H%M%S).json"
        cp "$STATE_FILE" "$backup_file"
        log_info "📦 状态已备份: $backup_file"

        # 删除状态文件
        rm -f "$STATE_FILE"
        log_success "✅ 状态文件已清理"
    fi
}

# 从失败步骤恢复
resume_from_failure() {
    if [ ! -f "$STATE_FILE" ]; then
        log_info "无失败记录，从头开始"
        return 1
    fi

    log_info "🔄 检测到失败记录，准备恢复..."

    local failed_steps=$(python3 -c "
import json
with open('$STATE_FILE', 'r') as f:
    state = json.load(f)
    print(' '.join(state['failed_steps']))
")

    if [ -z "$failed_steps" ]; then
        log_info "无失败步骤"
        return 1
    fi

    log_warning "⚠️  以下步骤失败："
    for step in $failed_steps; do
        echo "  • $step"
    done

    echo ""
    if confirm_action "是否重新执行失败的步骤？"; then
        return 0
    else
        log_info "跳过失败步骤"
        return 1
    fi
}

# 创建安装备份
create_backup() {
    local component="$1"
    local backup_path="$BACKUP_DIR/$component-$(date +%Y%m%d%H%M%S)"

    log_info "📦 创建备份: $component"

    case "$component" in
        openclaw)
            if [ -d "$HOME/.openclaw" ]; then
                cp -r "$HOME/.openclaw" "$backup_path"
                log_success "✅ OpenClaw 配置已备份"
            fi
            ;;
        omlx)
            if [ -f "$HOME/.omlx/settings.json" ]; then
                cp "$HOME/.omlx/settings.json" "$backup_path"
                log_success "✅ oMLX 配置已备份"
            fi
            ;;
        *)
            log_warning "⚠️  未知的备份组件: $component"
            ;;
    esac
}

# 恢复备份
restore_backup() {
    local component="$1"
    local backup_path=$(ls -t "$BACKUP_DIR/$component"-* 2>/dev/null | head -1)

    if [ -z "$backup_path" ]; then
        log_warning "⚠️  未找到备份: $component"
        return 1
    fi

    log_info "📦 恢复备份: $component"

    case "$component" in
        openclaw)
            if [ -d "$backup_path" ]; then
                rm -rf "$HOME/.openclaw"
                cp -r "$backup_path" "$HOME/.openclaw"
                log_success "✅ OpenClaw 配置已恢复"
            fi
            ;;
        omlx)
            if [ -f "$backup_path" ]; then
                cp "$backup_path" "$HOME/.omlx/settings.json"
                log_success "✅ oMLX 配置已恢复"
            fi
            ;;
        *)
            log_warning "⚠️  未知的备份组件: $component"
            ;;
    esac

    return 0
}

# 导出函数
export -f init_state
export -f save_state
export -f load_state
export -f get_completed_steps
export -f is_step_completed
export -f cleanup_state
export -f resume_from_failure
export -f create_backup
export -f restore_backup
