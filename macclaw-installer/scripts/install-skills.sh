#!/bin/bash
#
# MacClaw Installer - Skills 安装脚本
# 作者: 外星动物（常智）
# 版本: V1.0.1
#

# 加载日志模块
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/logger.sh"

# 常用 Skills 列表
COMMON_SKILLS=(
    "file-operations"
    "web-search"
    "code-executor"
    "task-manager"
)

# 安装 Skills
install_skills() {
    log_info "📦 安装常用 Skills..."

    local installed=0
    local failed=0

    for skill in "${COMMON_SKILLS[@]}"; do
        log_info "安装 $skill..."

        openclaw skills install "$skill" --non-interactive 2>/dev/null

        if [ $? -eq 0 ]; then
            log_success "✅ $skill 安装成功"
            ((installed++))
        else
            log_warning "⚠️  $skill 安装失败或不存在"
            ((failed++))
        fi
    done

    echo ""
    log_info "安装完成: $installed 成功, $failed 失败"

    return 0
}

# 列出已安装 Skills
list_skills() {
    log_info "📋 已安装的 Skills:"
    echo ""

    openclaw skills list

    return 0
}

# 主函数
main() {
    install_skills || return 1
    list_skills || return 1

    return 0
}

main "$@"
