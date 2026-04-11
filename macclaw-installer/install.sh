#!/bin/bash
#
# MacClaw Installer - 一键安装脚本
# 作者: 外星动物（常智）
# 组织: IoTchange
# 邮箱: 14455975@qq.com
# 版本: V1.0.1
# 版权: Copyright (C) 2026 IoTchange - All Rights Reserved
#
# 说明: 一键安装 OpenClaw + oMLX + 本地 AI 模型
# 使用: curl -fsSL https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw-installer/install.sh | bash
#

set -e  # 遇到错误立即退出

# 获取脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 加载核心模块
source "$SCRIPT_DIR/lib/logger.sh"
source "$SCRIPT_DIR/lib/utils.sh"
source "$SCRIPT_DIR/lib/detector.sh"
source "$SCRIPT_DIR/lib/config.sh"
source "$SCRIPT_DIR/lib/agent.sh"
source "$SCRIPT_DIR/lib/progress.sh"
source "$SCRIPT_DIR/lib/validator.sh"
source "$SCRIPT_DIR/lib/state.sh"

# 加载配置文件
if [ -f "$SCRIPT_DIR/config/sources.conf" ]; then
    source "$SCRIPT_DIR/config/sources.conf"
fi

if [ -f "$SCRIPT_DIR/config/versions.conf" ]; then
    source "$SCRIPT_DIR/config/versions.conf"
fi

# 初始化日志
init_log

# 主安装函数
main() {
    # 初始化状态管理
    init_state

    # 检查是否从失败中恢复
    if [ -f "$STATE_FILE" ]; then
        log_info "💡 检测到未完成的安装"
        if confirm_action "是否继续之前的安装？"; then
            load_state
        else
            cleanup_state
            init_state
        fi
    fi

    # 显示欢迎界面
    show_welcome

    # 环境检测
    show_overall_progress 1 7 "环境检测"
    detect_environment
    save_state "environment" "completed" 1

    # 配置国内源
    show_overall_progress 2 7 "配置国内源"
    show_sources_config
    configure_all_sources
    save_state "sources" "completed" 2

    # 交互式选择组件
    select_components

    # 确认安装
    echo ""
    log_info "即将安装以下组件："
    for component in "${INSTALL_COMPONENTS[@]}"; do
        echo "  • $component"
    done
    echo ""

    if ! confirm_action "确认开始安装？"; then
        log_info "已取消安装"
        cleanup_state
        exit 0
    fi

    # 开始安装
    log_info "🚀 开始安装..."
    show_separator

    # 安装步骤计数
    local install_step=3

    # 安装 Node.js
    if [[ "${INSTALL_COMPONENTS[@]}" =~ "Node.js" ]]; then
        show_overall_progress $install_step 7 "安装 Node.js"
        show_step_progress $install_step 7 "安装 Node.js" 1

        # 创建备份
        create_backup "nodejs"

        # 执行安装
        if bash "$SCRIPT_DIR/scripts/install-nodejs.sh"; then
            save_state "nodejs" "completed" $install_step
            show_step_progress $install_step 7 "安装 Node.js" 2
            show_complete_status "Node.js" "true"
        else
            save_state "nodejs" "failed" $install_step
            show_step_progress $install_step 7 "安装 Node.js" 3
            show_complete_status "Node.js" "false"
        fi

        ((install_step++))
        show_separator
    fi

    # 安装 OpenClaw
    if [[ "${INSTALL_COMPONENTS[@]}" =~ "OpenClaw" ]]; then
        show_overall_progress $install_step 7 "安装 OpenClaw CLI"
        show_step_progress $install_step 7 "安装 OpenClaw CLI" 1

        create_backup "openclaw"

        if bash "$SCRIPT_DIR/scripts/install-openclaw.sh"; then
            save_state "openclaw" "completed" $install_step
            show_step_progress $install_step 7 "安装 OpenClaw CLI" 2
            show_complete_status "OpenClaw" "true"
        else
            save_state "openclaw" "failed" $install_step
            show_step_progress $install_step 7 "安装 OpenClaw CLI" 3
            show_complete_status "OpenClaw" "false"
        fi

        ((install_step++))
        show_separator
    fi

    # 安装 oMLX
    if [[ "${INSTALL_COMPONENTS[@]}" =~ "oMLX" ]]; then
        show_overall_progress $install_step 7 "安装 oMLX"
        show_step_progress $install_step 7 "安装 oMLX" 1

        create_backup "omlx"

        if bash "$SCRIPT_DIR/scripts/install-omlx.sh"; then
            save_state "omlx" "completed" $install_step
            show_step_progress $install_step 7 "安装 oMLX" 2
            show_complete_status "oMLX" "true"
        else
            save_state "omlx" "failed" $install_step
            show_step_progress $install_step 7 "安装 oMLX" 3
            show_complete_status "oMLX" "false"
        fi

        ((install_step++))
        show_separator
    fi

    # 下载 AI 模型
    if [[ "${INSTALL_COMPONENTS[@]}" =~ "gemma-4" ]]; then
        show_overall_progress $install_step 7 "下载 AI 模型"
        show_step_progress $install_step 7 "下载 AI 模型" 1

        if bash "$SCRIPT_DIR/scripts/install-model.sh"; then
            save_state "model" "completed" $install_step
            show_step_progress $install_step 7 "下载 AI 模型" 2
            show_complete_status "AI 模型" "true"
        else
            save_state "model" "failed" $install_step
            show_step_progress $install_step 7 "下载 AI 模型" 3
            show_complete_status "AI 模型" "false"
        fi

        ((install_step++))
        show_separator
    fi

    # 配置集成
    show_overall_progress $install_step 7 "配置集成"
    log_info "⚙️  配置集成..."
    configure_openclaw
    configure_omlx_apikey

    # 验证配置
    validate_openclaw_config
    validate_omlx_config
    save_state "config" "completed" $install_step
    ((install_step++))
    show_separator

    # 创建 Agent
    if [[ "${INSTALL_COMPONENTS[@]}" =~ "Agent" ]]; then
        show_overall_progress $install_step 7 "创建 Agents"
        show_step_progress $install_step 7 "创建 Agents" 1

        if create_default_agents; then
            save_state "agents" "completed" $install_step
            show_step_progress $install_step 7 "创建 Agents" 2
            show_complete_status "Agents" "true"
        else
            save_state "agents" "failed" $install_step
            show_step_progress $install_step 7 "创建 Agents" 3
            show_complete_status "Agents" "false"
        fi

        ((install_step++))
        show_separator
    fi

    # 安装 Skills
    if [[ "${INSTALL_COMPONENTS[@]}" =~ "Skills" ]]; then
        show_overall_progress $install_step 7 "安装 Skills"
        show_step_progress $install_step 7 "安装 Skills" 1

        if bash "$SCRIPT_DIR/scripts/install-skills.sh" && configure_default_skills; then
            save_state "skills" "completed" $install_step
            show_step_progress $install_step 7 "安装 Skills" 2
            show_complete_status "Skills" "true"
        else
            save_state "skills" "failed" $install_step
            show_step_progress $install_step 7 "安装 Skills" 3
            show_complete_status "Skills" "false"
        fi

        ((install_step++))
        show_separator
    fi

    # 启动服务
    show_overall_progress 7 7 "启动服务"
    log_info "🚀 启动服务..."
    openclaw gateway restart
    sleep 5

    # 验证安装
    log_info "🔍 验证安装..."
    validate_services
    verify_installation

    # 清理临时文件
    cleanup_temp

    # 清理状态文件
    cleanup_state

    # 显示完成报告
    show_completion_report
}

# 验证安装
verify_installation() {
    echo ""

    # 检查 oMLX 服务
    if curl -s http://127.0.0.1:8008/health &>/dev/null; then
        log_success "✅ oMLX 服务运行正常"
    else
        log_warning "⚠️  oMLX 服务未运行"
    fi

    # 检查 OpenClaw Gateway
    if openclaw gateway status &>/dev/null; then
        log_success "✅ OpenClaw Gateway 运行正常"
    else
        log_warning "⚠️  OpenClaw Gateway 未运行"
    fi

    # 测试推理
    log_info "🧪 测试推理功能..."
    if openclaw infer model run \
        --model omlx/gemma-4-e4b-it-4bit \
        --prompt "测试" &>/dev/null; then
        log_success "✅ 推理功能正常"
    else
        log_warning "⚠️  推理功能测试失败"
    fi
}

# 显示完成报告
show_completion_report() {
    clear
    cat << "EOF"
╔════════════════════════════════════════════════════════════╗
║              🎉 安装完成！                                ║
╚════════════════════════════════════════════════════════════╝

✅ 已安装组件:
  ✅ Node.js
  ✅ OpenClaw CLI
  ✅ oMLX 服务
  ✅ gemma-4-e4b-it-4bit 模型
  ✅ 默认 Agents (main, assistant)
  ✅ 常用 Skills

🌐 访问地址:
  Web UI: http://127.0.0.1:18789/
  Dashboard: http://127.0.0.1:18789/

📊 服务状态:
  ✅ oMLX 服务运行中 (端口 8008)
  ✅ OpenClaw Gateway 运行中 (端口 18789)

📝 日志文件:
  安装日志: ~/macclaw-install.log
  OpenClaw: /tmp/openclaw/openclaw-*.log
  oMLX: ~/.omlx/logs/

🔧 常用命令:
  # Agent 管理
  列出 Agents: openclaw agents list
  Agent 配置: openclaw agents config <agent-name>

  # Skills 管理
  列出 Skills: openclaw skills list
  Agent Skills: openclaw agents skills list --agent <agent-name>

  # 测试推理
  测试推理: openclaw infer model run --model omlx/gemma-4-e4b-it-4bit --prompt "你好"

  # 服务管理
  查看状态: openclaw gateway status
  重启服务: openclaw gateway restart
  查看日志: tail -f /tmp/openclaw/openclaw-*.log

📚 更多帮助:
  项目地址: https://github.com/IoTchange/macclaw-installer
  问题反馈: https://github.com/IoTchange/macclaw-installer/issues

作者: 外星动物（常智）
组织: IoTchange
邮箱: 14455975@qq.com

按 Enter 打开 Web UI...
EOF
    read

    # 打开浏览器
    if command -v open &>/dev/null; then
        open http://127.0.0.1:18789/
    fi
}

# 错误处理
trap 'log_error "❌ 安装过程中发生错误，请查看日志: $LOG_FILE"; cleanup_temp; exit 1' ERR

# 运行主函数
main "$@"
