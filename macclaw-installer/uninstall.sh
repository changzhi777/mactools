#!/bin/bash
#
# MacClaw Installer - 卸载脚本
# 作者: 外星动物（常智）
# 组织: IoTchange
# 邮箱: 14455975@qq.com
# 版本: V1.0.1
# 版权: Copyright (C) 2026 IoTchange - All Rights Reserved
#
# 说明: 完全卸载 MacClaw Installer 安装的所有组件
#

set -e

# 获取脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 加载日志模块
source "$SCRIPT_DIR/lib/logger.sh"

# 初始化日志
init_log

# 显示卸载警告
show_warning() {
    clear
    cat << "EOF"
╔════════════════════════════════════════════════════════════╗
║              🗑️  MacClaw 卸载程序 V1.0.1                   ║
╚════════════════════════════════════════════════════════════╝

⚠️  警告：此操作将删除以下组件：

  • OpenClaw CLI
  • oMLX 应用
  • Node.js (通过 nvm)
  • 配置文件和数据
  • AI 模型文件

此操作不可撤销，请确认后继续。

作者: 外星动物（常智）
组织: IoTchange
EOF
}

# 确认卸载
confirm_uninstall() {
    echo ""
    read -p "确认卸载？[y/N]: " confirm

    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        log_info "已取消卸载"
        exit 0
    fi
}

# 停止服务
stop_services() {
    log_info "🛑 停止服务..."

    # 停止 OpenClaw Gateway
    if command -v openclaw &>/dev/null; then
        openclaw gateway stop &>/dev/null || true
        log_success "✅ OpenClaw Gateway 已停止"
    fi

    # 停止 oMLX
    killall oMLX 2>/dev/null || true
    log_success "✅ oMLX 已停止"
}

# 卸载 OpenClaw
uninstall_openclaw() {
    log_info "📦 卸载 OpenClaw..."

    if command -v openclaw &>/dev/null; then
        npm uninstall -g openclaw
        log_success "✅ OpenClaw 已卸载"
    else
        log_info "OpenClaw 未安装"
    fi
}

# 删除 oMLX
uninstall_omlx() {
    log_info "📦 删除 oMLX..."

    if [ -d "/Applications/oMLX.app" ]; then
        rm -rf /Applications/oMLX.app
        log_success "✅ oMLX 已删除"
    else
        log_info "oMLX 未安装"
    fi
}

# 删除 Node.js 和 nvm
uninstall_nodejs() {
    log_info "📦 删除 Node.js 和 nvm..."

    if [ -d "$HOME/.nvm" ]; then
        read -p "是否删除 Node.js 和 nvm？[y/N]: " delete_node

        if [ "$delete_node" == "y" ] || [ "$delete_node" == "Y" ]; then
            rm -rf "$HOME/.nvm"
            log_success "✅ Node.js 和 nvm 已删除"
        else
            log_info "保留 Node.js 和 nvm"
        fi
    else
        log_info "Node.js 和 nvm 未安装"
    fi
}

# 删除配置文件
uninstall_configs() {
    log_info "📦 删除配置文件..."

    read -p "是否删除配置文件？[y/N]: " delete_config

    if [ "$delete_config" == "y" ] || [ "$delete_config" == "Y" ]; then
        # 删除 OpenClaw 配置
        if [ -d "$HOME/.openclaw" ]; then
            rm -rf "$HOME/.openclaw"
            log_success "✅ OpenClaw 配置已删除"
        fi

        # 删除 oMLX 配置
        if [ -d "$HOME/.omlx" ]; then
            rm -rf "$HOME/.omlx"
            log_success "✅ oMLX 配置已删除"
        fi

        # 删除 ModelScope 配置
        if [ -d "$HOME/.modelscope" ]; then
            rm -rf "$HOME/.modelscope"
            log_success "✅ ModelScope 配置已删除"
        fi
    else
        log_info "保留配置文件"
    fi
}

# 删除日志文件
uninstall_logs() {
    log_info "📦 删除日志文件..."

    if [ -f "$HOME/macclaw-install.log" ]; then
        rm -f "$HOME/macclaw-install.log"
        log_success "✅ 安装日志已删除"
    fi
}

# 显示完成报告
show_completion_report() {
    clear
    cat << "EOF"
╔════════════════════════════════════════════════════════════╗
║              ✅ 卸载完成！                                ║
╚════════════════════════════════════════════════════════════╝

感谢您使用 MacClaw Installer！

如果您有任何反馈或建议，欢迎联系我们：

作者: 外星动物（常智）
组织: IoTchange
邮箱: 14455975@qq.com
项目: https://github.com/IoTchange/macclaw-installer

按 Enter 退出...
EOF
    read
}

# 主卸载函数
main() {
    show_warning
    confirm_uninstall

    echo ""
    log_info "🗑️  开始卸载..."
    echo ""

    stop_services
    uninstall_openclaw
    uninstall_omlx
    uninstall_nodejs
    uninstall_configs
    uninstall_logs

    echo ""
    log_success "✅ 卸载完成！"

    show_completion_report
}

# 运行主函数
main "$@"
