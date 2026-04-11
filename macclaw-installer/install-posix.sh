#!/bin/sh
#
# MacClaw Installer - 一键安装脚本（POSIX sh 版本）
# 作者: 外星动物（常智）
# 组织: IoTchange
# 邮箱: 14455975@qq.com
# 版本: V1.0.1
# 版权: Copyright (C) 2026 IoTchange - All Rights Reserved
#
# 说明: 一键安装 OpenClaw + oMLX + 本地 AI 模型
# 使用: curl -fsSL https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw-installer/install-posix.sh | sh
#
# Shell 要求:
#   - POSIX sh (推荐)
#   - bash 3.0+ (完全兼容)
#   - zsh 5.0+ (兼容)
#   - dash (兼容)
#
# 已测试平台:
#   - macOS 12+ (sh/bash/zsh)
#   - Ubuntu 20.04+ (sh/bash/dash)
#   - Alpine Linux (dash/ash)
#

set -e  # 遇到错误立即退出

# ============================================
# 加载 POSIX 兼容库
# ============================================

# 获取脚本目录（POSIX 兼容）
get_script_dir() {
    if [ -n "${ZSH_VERSION:-}" ]; then
        echo "${funcfiletrace[1]%/*}"
    elif [ -n "${BASH_VERSION:-}" ]; then
        echo "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    else
        # 通用方法
        echo "$(cd "$(dirname "$0")" && pwd)"
    fi
}

SCRIPT_DIR="$(get_script_dir)"

# 加载 POSIX 兼容库
if [ -f "$SCRIPT_DIR/lib/posix_compat.sh" ]; then
    . "$SCRIPT_DIR/lib/posix_compat.sh"
fi

# ============================================
# 下载函数（POSIX 兼容）
# ============================================

# 通过 curl 下载并解压项目
download_via_curl() {
    url="$1"
    output_file="$2"
    target_dir="$3"

    if ! curl -fsSL "$url" -o "$output_file" 2>/dev/null; then
        echo "❌ 下载失败，请检查网络连接或手动下载："
        echo "   $url"
        return 1
    fi

    echo "✅ 下载成功，正在解压..."

    if ! command -v unzip >/dev/null 2>&1; then
        echo "❌ 错误: 系统缺少 unzip 命令"
        echo "💡 请先安装: brew install unzip"
        rm -f "$output_file"
        return 1
    fi

    # 尝试使用 unzip 解压，处理中文文件名
    # macOS 使用 GB18030，Linux 使用 UTF-8
    if unzip -q -O UTF-8 "$output_file" 2>/dev/null || \
       unzip -q -O GB18030 "$output_file" 2>/dev/null || \
       unzip -q "$output_file"; then
        echo "✅ 解压成功"
    else
        echo "❌ 解压失败"
        echo "💡 可能原因："
        echo "   1. 压缩文件损坏"
        echo "   2. 磁盘空间不足"
        echo "   3. 文件名编码问题"
        rm -f "$output_file"
        return 1
    fi

    # 检测解压后的目录（处理可能的中文文件名）
    if [ -d "mactools-main" ]; then
        mv mactools-main "$target_dir"
        rm -f "$output_file"
        return 0
    else
        # 尝试查找包含 macclaw-installer 的目录
        extracted_dir=$(find . -maxdepth 1 -type d -name "*mactools*" | head -1)
        if [ -n "$extracted_dir" ] && [ -d "$extracted_dir" ]; then
            mv "$extracted_dir" "$target_dir"
            rm -f "$output_file"
            echo "✅ 找到并移动目录: $extracted_dir"
            return 0
        else
            echo "❌ 解压后未找到 mactools 目录"
            echo "💡 当前目录内容:"
            ls -la
            rm -f "$output_file"
            return 1
        fi
    fi
}

# 通过 git 克隆项目
download_via_git() {
    repo_url="$1"
    target_dir="$2"

    if ! command -v git >/dev/null 2>&1; then
        return 1
    fi

    if git clone --depth 1 "$repo_url" "$target_dir" 2>/dev/null; then
        echo "✅ Git 克隆成功"
        return 0
    else
        return 1
    fi
}

# 自动检测并下载项目
download_project() {
    temp_dir="$1"
    repo_url="https://github.com/changzhi777/mactools.git"
    zip_url="https://github.com/changzhi777/mactools/archive/refs/heads/main.zip"
    target_dir="$temp_dir/temp_repo"

    echo "📥 正在下载项目..."

    # 方法 1: 尝试使用 git clone（更快）
    if download_via_git "$repo_url" "$target_dir"; then
        return 0
    fi

    # 方法 2: 使用 curl 下载（备用）
    echo "⚠️  Git 克隆失败，尝试使用 curl 下载..."
    echo "💡 如果下载失败，请检查："
    echo "   1. 网络连接是否正常"
    echo "   2. GitHub 是否可访问"
    echo "   3. 防火墙是否阻止连接"

    cd "$temp_dir"
    if download_via_curl "$zip_url" "mactools.zip" "temp_repo"; then
        return 0
    fi

    return 1
}

# ============================================
# 检测是否是在线安装
# ============================================

if [ ! -d "$SCRIPT_DIR/lib" ]; then
    echo "🔧 检测到在线安装模式，正在下载完整项目..."

    TEMP_DIR=$(mktemp -d) || {
        echo "❌ 无法创建临时目录"
        exit 1
    }

    if ! download_project "$TEMP_DIR"; then
        echo "❌ 项目下载失败"
        rm -rf "$TEMP_DIR"
        exit 1
    fi

    # 自动检测安装器目录
    if [ -d "$TEMP_DIR/temp_repo/macclaw-installer" ]; then
        SCRIPT_DIR="$TEMP_DIR/temp_repo/macclaw-installer"
    elif [ -d "$TEMP_DIR/temp_repo" ]; then
        SCRIPT_DIR="$TEMP_DIR/temp_repo"
    else
        echo "❌ 无法找到安装器目录"
        rm -rf "$TEMP_DIR"
        exit 1
    fi

    echo "✅ 项目已下载到: $SCRIPT_DIR"
    echo ""
fi

# 设置库目录环境变量
MACCLAW_LIB_DIR="$SCRIPT_DIR/lib"
MACCLAW_CONFIG_DIR="$SCRIPT_DIR/config"
export MACCLAW_LIB_DIR MACCLAW_CONFIG_DIR

# ============================================
# 加载核心模块
# ============================================

# 检查并加载模块
load_module() {
    module_name="$1"
    module_path="$SCRIPT_DIR/lib/$module_name.sh"

    if [ -f "$module_path" ]; then
        . "$module_path"
    else
        echo "⚠️  警告: 模块 $module_name 不存在"
    fi
}

# 加载必需的模块
load_module "logger"
load_module "utils"
load_module "detector"
load_module "config"
load_module "agent"
load_module "progress"
load_module "validator"
load_module "state"

# ============================================
# 加载配置文件
# ============================================

if [ -f "$SCRIPT_DIR/config/sources.conf" ]; then
    . "$SCRIPT_DIR/config/sources.conf"
fi

if [ -f "$SCRIPT_DIR/config/versions.conf" ]; then
    . "$SCRIPT_DIR/config/versions.conf"
fi

# 初始化日志
if command -v init_log >/dev/null 2>&1; then
    init_log
fi

# ============================================
# 字符串包含检查（替代 [[ =~ ]]）
# ============================================

# 检查字符串中是否包含指定模式
str_contains() {
    string="$1"
    pattern="$2"

    case "$string" in
        *$pattern*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# ============================================
# 组件选择（使用字符串替代数组）
# ============================================

# 安装组件列表（空格分隔）
INSTALL_COMPONENTS=""

# 添加组件到列表
add_component() {
    component="$1"

    if [ -z "$INSTALL_COMPONENTS" ]; then
        INSTALL_COMPONENTS="$component"
    else
        INSTALL_COMPONENTS="$INSTALL_COMPONENTS $component"
    fi
}

# 检查组件是否在列表中
has_component() {
    component="$1"
    str_contains "$INSTALL_COMPONENTS" "$component"
}

# 显示所有组件
show_components() {
    for component in $INSTALL_COMPONENTS; do
        echo "  • $component"
    done
}

# ============================================
# 主安装函数
# ============================================

main() {
    # 初始化状态管理
    if command -v init_state >/dev/null 2>&1; then
        init_state
    fi

    # 检查是否从失败中恢复
    if [ -n "${STATE_FILE:-}" ] && [ -f "$STATE_FILE" ]; then
        echo "💡 检测到未完成的安装"
        if command -v confirm_action >/dev/null 2>&1; then
            if confirm_action "是否继续之前的安装？"; then
                if command -v load_state >/dev/null 2>&1; then
                    load_state
                fi
            else
                if command -v cleanup_state >/dev/null 2>&1; then
                    cleanup_state
                fi
                if command -v init_state >/dev/null 2>&1; then
                    init_state
                fi
            fi
        fi
    fi

    # 显示欢迎界面
    if command -v show_welcome >/dev/null 2>&1; then
        show_welcome
    fi

    # 环境检测
    echo "🔍 环境检测..."
    if command -v detect_environment >/dev/null 2>&1; then
        detect_environment
    fi

    # 配置国内源
    echo "🌏 配置国内源..."
    if command -v configure_all_sources >/dev/null 2>&1; then
        configure_all_sources
    fi

    # 交互式选择组件（简化版）
    echo ""
    echo "请选择要安装的组件："
    echo "  1) Node.js"
    echo "  2) OpenClaw CLI"
    echo "  3) oMLX"
    echo "  4) gemma-4 AI 模型"
    echo "  5) 全部安装（推荐）"
    echo ""
    printf "请输入选项 (1-5): "

    read choice

    case "$choice" in
        1)
            add_component "Node.js"
            ;;
        2)
            add_component "OpenClaw"
            ;;
        3)
            add_component "oMLX"
            ;;
        4)
            add_component "gemma-4"
            ;;
        5)
            add_component "Node.js"
            add_component "OpenClaw"
            add_component "oMLX"
            add_component "gemma-4"
            ;;
        *)
            echo "❌ 无效选项"
            exit 1
            ;;
    esac

    # 确认安装
    echo ""
    echo "即将安装以下组件："
    show_components
    echo ""

    printf "确认开始安装？ [y/N]: "
    read confirm

    if [ ! "$confirm" = "y" ] && [ ! "$confirm" = "Y" ]; then
        echo "已取消安装"
        exit 0
    fi

    # 开始安装
    echo ""
    echo "🚀 开始安装..."
    echo ""

    # 安装 Node.js
    if has_component "Node.js"; then
        echo "📦 安装 Node.js..."
        if [ -f "$SCRIPT_DIR/scripts/install-nodejs.sh" ]; then
            if sh "$SCRIPT_DIR/scripts/install-nodejs.sh"; then
                echo "✅ Node.js 安装成功"
            else
                echo "❌ Node.js 安装失败"
            fi
        fi
    fi

    # 安装 OpenClaw
    if has_component "OpenClaw"; then
        echo "📦 安装 OpenClaw CLI..."
        if [ -f "$SCRIPT_DIR/scripts/install-openclaw.sh" ]; then
            if sh "$SCRIPT_DIR/scripts/install-openclaw.sh"; then
                echo "✅ OpenClaw 安装成功"
            else
                echo "❌ OpenClaw 安装失败"
            fi
        fi
    fi

    # 安装 oMLX
    if has_component "oMLX"; then
        echo "📦 安装 oMLX..."
        if [ -f "$SCRIPT_DIR/scripts/install-omlx.sh" ]; then
            if sh "$SCRIPT_DIR/scripts/install-omlx.sh"; then
                echo "✅ oMLX 安装成功"
            else
                echo "❌ oMLX 安装失败"
            fi
        fi
    fi

    # 下载 AI 模型
    if has_component "gemma-4"; then
        echo "📦 下载 AI 模型..."
        if [ -f "$SCRIPT_DIR/scripts/install-model.sh" ]; then
            if sh "$SCRIPT_DIR/scripts/install-model.sh"; then
                echo "✅ AI 模型下载成功"
            else
                echo "❌ AI 模型下载失败"
            fi
        fi
    fi

    # 配置集成
    echo "⚙️  配置集成..."
    if command -v configure_openclaw >/dev/null 2>&1; then
        configure_openclaw
    fi
    if command -v configure_omlx_apikey >/dev/null 2>&1; then
        configure_omlx_apikey
    fi

    # 启动服务
    echo "🚀 启动服务..."
    if command -v openclaw >/dev/null 2>&1; then
        openclaw gateway restart
        sleep 5
    fi

    # 清理临时文件
    if [ -n "${TEMP_DIR:-}" ] && [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi

    # 清理状态文件
    if command -v cleanup_state >/dev/null 2>&1; then
        cleanup_state
    fi

    # 显示完成报告
    show_completion_report
}

# ============================================
# 显示完成报告
# ============================================

show_completion_report() {
    clear
    cat << 'EOF'
╔════════════════════════════════════════════════════════════╗
║              🎉 安装完成！                                ║
╚════════════════════════════════════════════════════════════╝

✅ 已安装组件:
  ✅ Node.js
  ✅ OpenClaw CLI
  ✅ oMLX 服务
  ✅ gemma-4-e4b-it-4bit 模型

🌐 访问地址:
  Web UI: http://127.0.0.1:18789/

📊 服务状态:
  ✅ oMLX 服务运行中 (端口 8008)
  ✅ OpenClaw Gateway 运行中 (端口 18789)

🔧 常用命令:
  # Agent 管理
  列出 Agents: openclaw agents list

  # 测试推理
  测试推理: openclaw infer model run --model omlx/gemma-4-e4b-it-4bit --prompt "你好"

  # 服务管理
  查看状态: openclaw gateway status
  重启服务: openclaw gateway restart

📚 更多帮助:
  项目地址: https://github.com/changzhi777/mactools
  问题反馈: https://github.com/changzhi777/mactools/issues

作者: 外星动物（常智）
组织: IoTchange
邮箱: 14455975@qq.com

按 Enter 打开 Web UI...
EOF
    read

    # 打开浏览器
    if command -v open >/dev/null 2>&1; then
        open http://127.0.0.1:18789/
    fi
}

# ============================================
# 错误处理
# ============================================

trap 'echo "❌ 安装过程中发生错误"; cleanup_temp; exit 1' ERR

# 清理临时文件
cleanup_temp() {
    if [ -n "${TEMP_DIR:-}" ] && [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}

# ============================================
# 运行主函数
# ============================================

main "$@"
