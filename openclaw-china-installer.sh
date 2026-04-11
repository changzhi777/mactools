#!/bin/bash
#
# ==============================================================================
# OpenClaw 国内源安装脚本
# ==============================================================================
#
# 项目名称：OpenClaw China Installer
# 文件名称：openclaw-china-installer.sh
#
# 作者信息：
#   作者：外星动物（常智）
#   组织：IoTchange
#   邮箱：14455975@qq.com
#   GitHub：https://github.com/changzhi777
#
# 版本信息：
#   当前版本：V1.0.0
#   发布日期：2026-04-12
#   修订历史：
#     V1.0.0 (2026-04-12): 初始版本
#
# 版权声明：
#   Copyright (C) 2026 IoTchange - All Rights Reserved
#
# 许可证：
#   MIT License
#
#   特此授予任何获得本软件和相关文档文件（"软件"的人不受限制地处理
#   本软件的权利，包括但不限于使用、复制、修改、合并、发布、分发、
#   再许可和/或出售软件副本的权利，并允许获得本软件的人这样做，但须
#   符合以下条件：
#
#   1. 上述版权声明和本许可声明应包含在软件的所有副本或重要部分中。
#
#   2. 本软件按"原样"提供，不提供任何形式的明示或暗示保证，包括但不
#      限于对适销性、特定用途适用性和非侵权性的保证。在任何情况下，作者
#      或版权持有人均不对任何索赔、损害或其他责任负责，无论是合同、
#      侵权或其他形式的诉讼，由软件或软件的使用或其他交易引起、引起
#      或与之相关。
#
# 功能说明：
#   一键安装 OpenClaw 及其依赖环境，使用国内镜像源加速下载
#   支持 macOS 12+ 系统
#   交互式菜单选择安装模式
#
# 使用方法：
#   chmod +x openclaw-china-installer.sh
#   sudo ./openclaw-china-installer.sh
#
# 或直接执行：
#   bash openclaw-china-installer.sh
#
# 依赖要求：
#   - macOS 12 或更高版本
#   - Xcode Command Line Tools
#   - curl（下载文件）
#   - git（克隆仓库）
#   - python3（系统自带）
#
# 支持的组件：
#   - Node.js (通过 nvm 安装)
#   - OpenClaw CLI (通过 npm 安装)
#   - oMLX (通过 pip3 安装)
#   - AI 模型 (gemma-4-e4b-it-4bit)
#
# 镜像源配置：
#   - Node.js: https://npmmirror.com (淘宝镜像)
#   - npm: https://registry.npmmirror.com
#   - pip: https://pypi.tuna.tsinghua.edu.cn (清华镜像)
#
# 文档地址：
#   - 项目主页：https://github.com/changzhi777/mactools
#   - 使用文档：https://github.com/changzhi777/mactools/blob/main/OPENCLAW_INSTALL_GUIDE.md
#   - 问题反馈：https://github.com/changzhi777/mactools/issues
#
# 免责声明：
#   本脚本仅供学习和个人使用。使用本脚本安装的软件和组件请遵守其
#   各自的许可证条款。作者不对本脚本的使用结果承担任何责任。
#
# ==============================================================================

set -e

# ==============================================================================
# 配置参数
# ==============================================================================

# 版本信息
VERSION="V1.0.0"
RELEASE_DATE="2026-04-12"

# 国内镜像源配置
NVM_MIRROR="https://npmmirror.com/mirrors/node"
NPM_REGISTRY="https://registry.npmmirror.com"
PIP_INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple"

# 安装路径
NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
OPENCLAW_INSTALL_DIR="${OPENCLAW_INSTALL_DIR:-$HOME/.openclaw}"

# 日志文件
LOG_FILE="${LOG_FILE:-$HOME/openclaw-install.log}"

# ==============================================================================
# 颜色定义
# ==============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# ==============================================================================
# 日志函数
# ==============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

# ==============================================================================
# 版权信息显示
# ==============================================================================

show_copyright_notice() {
    cat << EOF
╔════════════════════════════════════════════════════════════╗
║                                                              ║
║       OpenClaw 国内源安装器 ${VERSION}                       ║
║                                                              ║
║       作者: 外星动物（常智）                                 ║
║       组织: IoTchange                                        ║
║       邮箱: 14455975@qq.com                                  ║
║                                                              ║
║       Copyright (C) 2026 IoTchange                            ║
║       MIT License                                            ║
║                                                              ║
╚════════════════════════════════════════════════════════════╝

EOF
}

# ==============================================================================
# 主菜单显示
# ==============================================================================

show_menu() {
    clear
    show_copyright_notice
    cat << EOF
请选择安装模式：

  1) 🚀 快速安装（推荐）
     自动安装所有依赖和 OpenClaw

  2) ⚙️  自定义安装
     选择性安装组件

  3) 📋 查看系统信息
     检查当前环境

  4) ℹ️  关于
     查看版本和版权信息

  0) 🚪 退出

EOF
    echo -n "请输入选项 [0-4]: "
}

# ==============================================================================
# 组件选择菜单
# ==============================================================================

show_component_menu() {
    clear
    cat << EOF
╔════════════════════════════════════════════════════════════╗
║       选择要安装的组件                                      ║
╚════════════════════════════════════════════════════════════╝

  [1] Node.js (JavaScript 运行环境)
  [2] OpenClaw CLI (AI 开发工具)
  [3] oMLX (本地推理引擎)
  [4] AI 模型 (gemma-4-e4b-it-4bit)

  [A] 全选
  [N] 取消所有选择
  [B] 返回主菜单

EOF
    echo -n "请选择 (输入数字或字母): "
}

# ==============================================================================
# 菜单处理逻辑
# ==============================================================================

handle_menu_choice() {
    local choice=$1

    case "$choice" in
        1)
            quick_install
            ;;
        2)
            custom_install
            ;;
        3)
            show_system_info
            press_enter_continue
            ;;
        4)
            show_about
            ;;
        0)
            log_info "退出安装"
            exit 0
            ;;
        *)
            log_error "无效选项: $choice"
            press_enter_continue
            ;;
    esac
}

# ==============================================================================
# 快速安装模式
# ==============================================================================

quick_install() {
    clear
    cat << EOF
╔════════════════════════════════════════════════════════════╗
║       🚀 快速安装模式                                        ║
╚════════════════════════════════════════════════════════════╝

将自动安装以下组件：

  ✅ Node.js (LTS 版本)
  ✅ OpenClaw CLI
  ✅ oMLX 本地推理引擎
  ✅ gemma-4-e4b-it-4bit AI 模型

所有组件将从国内镜像源下载，速度更快！

EOF

    if confirm_action "确认开始快速安装？"; then
        log_info "🚀 开始快速安装..."
        echo ""

        # 执行安装步骤
        check_environment
        install_nodejs
        install_openclaw
        install_omlx
        download_model
        verify_installation
        show_completion

        log_success "🎉 快速安装完成！"
    else
        log_info "已取消安装"
    fi

    press_enter_continue
}

# ==============================================================================
# 自定义安装模式
# ==============================================================================

custom_install() {
    local selected_components=()

    while true; do
        show_component_menu
        read component_choice

        case "$component_choice" in
            A|a)
                selected_components=("nodejs" "openclaw" "omlx" "model")
                log_success "已选择所有组件"
                break
                ;;
            N|n)
                selected_components=()
                log_warning "已取消所有选择"
                break
                ;;
            B|b)
                return
                ;;
            1)
                if [[ ! " ${selected_components[@]} " =~ " nodejs " ]]; then
                    selected_components+=("nodejs")
                    log_success "已选择: Node.js"
                else
                    log_warning "已取消: Node.js"
                    selected_components=("${selected_components[@]/nodejs/}")
                fi
                ;;
            2)
                if [[ ! " ${selected_components[@]} " =~ " openclaw " ]]; then
                    selected_components+=("openclaw")
                    log_success "已选择: OpenClaw CLI"
                else
                    log_warning "已取消: OpenClaw CLI"
                    selected_components=("${selected_components[@]/openclaw/}")
                fi
                ;;
            3)
                if [[ ! " ${selected_components[@]} " =~ " omlx " ]]; then
                    selected_components+=("omlx")
                    log_success "已选择: oMLX"
                else
                    log_warning "已取消: oMLX"
                    selected_components=("${selected_components[@]/omlx/}")
                fi
                ;;
            4)
                if [[ ! " ${selected_components[@]} " =~ " model " ]]; then
                    selected_components+=("model")
                    log_success "已选择: AI 模型"
                else
                    log_warning "已取消: AI 模型"
                    selected_components=("${selected_components[@]/model/}")
                fi
                ;;
            *)
                log_error "无效选项"
                ;;
        esac

        sleep 1
    done

    # 显示选择结果
    if [ ${#selected_components[@]} -eq 0 ]; then
        log_warning "未选择任何组件"
        press_enter_continue
        return
    fi

    echo ""
    log_info "将安装以下组件："
    for component in "${selected_components[@]}"; do
        case "$component" in
            nodejs) echo "  • Node.js" ;;
            openclaw) echo "  • OpenClaw CLI" ;;
            omlx) echo "  • oMLX" ;;
            model) echo "  • AI 模型" ;;
        esac
    done
    echo ""

    if confirm_action "确认开始安装？"; then
        log_info "🚀 开始自定义安装..."
        echo ""

        # 根据选择安装
        for component in "${selected_components[@]}"; do
            case "$component" in
                nodejs) install_nodejs ;;
                openclaw) install_openclaw ;;
                omlx) install_omlx ;;
                model) download_model ;;
            esac
        done

        verify_installation
        show_completion
        log_success "🎉 自定义安装完成！"
    else
        log_info "已取消安装"
    fi

    press_enter_continue
}

# ==============================================================================
# 系统信息显示
# ==============================================================================

show_system_info() {
    clear
    cat << EOF
╔════════════════════════════════════════════════════════════╗
║       📋 系统信息                                          ║
╚════════════════════════════════════════════════════════════╝

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

操作系统：
  • macOS 版本: $(sw_vers -productVersion)
  • 系统架构: $(uname -m)
  • 内核版本: $(uname -r)

硬件配置：
  • CPU 架构: $(uname -m)
  • 内存大小: $(sysctl -n hw.memsize | awk '{print $1/1024/1024/1024 "GB"}')
  • 可用磁盘: $(df -h / | tail -1 | awk '{print $4}')

已安装组件：
EOF

    # 检查各组件
    if command -v node &>/dev/null; then
        echo "  ✅ Node.js: $(node --version)"
    else
        echo "  ❌ Node.js: 未安装"
    fi

    if command -v openclaw &>/dev/null; then
        echo "  ✅ OpenClaw: $(openclaw --version 2>/dev/null | head -1)"
    else
        echo "  ❌ OpenClaw: 未安装"
    fi

    if [ -d "/Applications/oMLX.app" ]; then
        echo "  ✅ oMLX: 已安装"
    else
        echo "  ❌ oMLX: 未安装"
    fi

    cat << EOF

网络配置：
  • npm 源: ${NPM_REGISTRY}
  • pip 源: ${PIP_INDEX_URL}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
}

# ==============================================================================
# 关于信息显示
# ==============================================================================

show_about() {
    clear
    cat << EOF
╔════════════════════════════════════════════════════════════╗
║       ℹ️  关于                                              ║
╚════════════════════════════════════════════════════════════╝

项目名称：OpenClaw China Installer
当前版本：${VERSION}
发布日期：${RELEASE_DATE}

作者：外星动物（常智）
组织：IoTchange
邮箱：14455975@qq.com
GitHub：https://github.com/changzhi777

版权：Copyright (C) 2026 IoTchange
许可证：MIT License

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

项目主页：https://github.com/changzhi777/mactools
文档地址：https://github.com/changzhi777/mactools/blob/main/OPENCLAW_INSTALL_GUIDE.md
问题反馈：https://github.com/changzhi777/mactools/issues

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
    press_enter_continue
}

# ==============================================================================
# 环境检查
# ==============================================================================

check_environment() {
    log_info "🔍 检查安装环境..."

    # 检查 macOS 版本
    local macos_version=$(sw_vers -productVersion)
    local major=$(echo "$macos_version" | cut -d. -f1)

    if [ "$major" -lt 12 ]; then
        log_error "macOS 版本过低，需要 macOS 12 或更高版本"
        log_error "当前版本: $macos_version"
        exit 1
    fi

    log_success "✅ macOS 版本: $macos_version"

    # 检查 Xcode Command Line Tools
    if ! xcode-select -p &>/dev/null; then
        log_error "❌ Xcode Command Line Tools 未安装"
        echo ""
        echo "💡 请先安装 Xcode Command Line Tools："
        echo ""
        echo "  xcode-select --install"
        echo ""
        echo "⏳ 安装完成后，请重新运行此脚本"
        echo ""
        exit 1
    fi

    log_success "✅ Xcode Command Line Tools 已安装"

    # 检查必需命令
    local required_commands=("curl" "git" "python3")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            log_error "❌ 缺少必需命令: $cmd"
            exit 1
        fi
    done

    log_success "✅ 所有必要工具可用"
    echo ""
}

# ==============================================================================
# 安装 Node.js
# ==============================================================================

install_nodejs() {
    log_info "📦 安装 Node.js..."

    # 检查是否已安装
    if command -v node &>/dev/null; then
        local version=$(node --version)
        log_success "✅ Node.js 已安装: $version"
        return 0
    fi

    # 安装 nvm
    if [ ! -d "$NVM_DIR" ]; then
        log_info "下载并安装 nvm..."

        # 使用国内镜像下载 nvm
        export NVM_INSTALL_SOURCE="${NVM_MIRROR}/nvm.sh"
        curl -o- "$NVM_INSTALL_SOURCE" | bash

        # 加载 nvm
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    fi

    # 安装最新的 LTS 版本
    log_info "安装 Node.js LTS 版本..."
    bash -c "source $NVM_DIR/nvm.sh && nvm install --lts" || {
        log_error "Node.js 安装失败"
        return 1
    }

    # 配置 npm 淘宝镜像
    bash -c "source $NVM_DIR/nvm.sh && npm config set registry $NPM_REGISTRY"

    # 验证安装
    if command -v node &>/dev/null; then
        local version=$(node --version)
        log_success "✅ Node.js 安装成功: $version"
        log_success "✅ npm 淘宝镜像已配置"
    else
        log_error "Node.js 安装失败"
        return 1
    fi

    echo ""
}

# ==============================================================================
# 安装 OpenClaw
# ==============================================================================

install_openclaw() {
    log_info "📦 安装 OpenClaw CLI..."

    # 检查是否已安装
    if command -v openclaw &>/dev/null; then
        local version=$(openclaw --version 2>/dev/null | head -1)
        log_success "✅ OpenClaw 已安装: $version"
        return 0
    fi

    # 使用 npm 淘宝镜像安装
    bash -c "source $NVM_DIR/nvm.sh && npm install -g @iotchange/openclaw --registry=$NPM_REGISTRY" || {
        log_error "OpenClaw 安装失败"
        return 1
    }

    # 验证安装
    if command -v openclaw &>/dev/null; then
        log_success "✅ OpenClaw 安装成功"
    else
        log_error "OpenClaw 安装失败"
        return 1
    fi

    echo ""
}

# ==============================================================================
# 安装 oMLX
# ==============================================================================

install_omlx() {
    log_info "📦 安装 oMLX..."

    # 使用 pip 清华镜像安装
    pip3 install --upgrade omlx -i "$PIP_INDEX_URL" || {
        log_error "oMLX 安装失败"
        return 1
    }

    log_success "✅ oMLX 安装成功"
    echo ""
}

# ==============================================================================
# 下载 AI 模型
# ==============================================================================

download_model() {
    log_info "📥 下载 AI 模型..."

    # 使用 OpenClaw 下载模型
    if command -v openclaw &>/dev/null; then
        openclaw model pull omlx/gemma-4-e4b-it-4bit || {
            log_warning "⚠️  模型下载失败，可以稍后手动下载"
            return 0
        }
        log_success "✅ AI 模型下载完成"
    else
        log_warning "⚠️  OpenClaw 未安装，跳过模型下载"
    fi

    echo ""
}

# ==============================================================================
# 验证安装
# ==============================================================================

verify_installation() {
    log_info "🔍 验证安装..."

    local all_ok=true

    # 检查 Node.js
    if command -v node &>/dev/null; then
        log_success "✅ Node.js: $(node --version)"
    else
        log_error "❌ Node.js 未安装"
        all_ok=false
    fi

    # 检查 OpenClaw
    if command -v openclaw &>/dev/null; then
        log_success "✅ OpenClaw: $(openclaw --version | head -1)"
    else
        log_error "❌ OpenClaw 未安装"
        all_ok=false
    fi

    # 检查 oMLX
    if pip3 show omlx &>/dev/null; then
        local version=$(pip3 show omlx | grep Version | cut -d' ' -f2)
        log_success "✅ oMLX: $version"
    else
        log_error "❌ oMLX 未安装"
        all_ok=false
    fi

    echo ""

    if [ "$all_ok" = true ]; then
        log_success "🎉 安装验证通过！"
        return 0
    else
        log_warning "⚠️  部分组件安装失败，请查看日志"
        return 1
    fi
}

# ==============================================================================
# 显示完成信息
# ==============================================================================

show_completion() {
    clear
    cat << EOF
╔════════════════════════════════════════════════════════════╗
║              🎉 安装完成！                                ║
╚════════════════════════════════════════════════════════════╝

✅ 已安装组件:
  ✅ Node.js $(node --version 2>/dev/null || echo "")
  ✅ OpenClaw CLI
  ✅ oMLX 本地推理引擎
  ✅ gemma-4-e4b-it-4bit AI 模型

📚 使用指南:

  # 查看 OpenClaw 版本
  openclaw --version

  # 测试推理
  openclaw infer model run --model omlx/gemma-4-e4b-it-4bit --prompt "你好"

  # 查看帮助
  openclaw --help

📞 获取帮助:
  项目地址: https://github.com/changzhi777/mactools
  问题反馈: https://github.com/changzhi777/mactools/issues

作者: 外星动物（常智）
组织: IoTchange
邮箱: 14455975@qq.com

EOF

    # 尝试打开项目页面
    if command -v open &>/dev/null; then
        sleep 2
        open https://github.com/changzhi777/mactools
    fi
}

# ==============================================================================
# 辅助函数
# ==============================================================================

confirm_action() {
    local message="$1"
    echo -n "$message [y/N]: "
    read response

    case "$response" in
        [Yy]|[Yy][Ee][Ss])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

press_enter_continue() {
    echo ""
    echo -n "按 Enter 返回主菜单..."
    read
}

# ==============================================================================
# 错误处理
# ==============================================================================

cleanup() {
    log_info "清理临时文件..."
    rm -rf /tmp/openclaw-* 2>/dev/null || true
}

trap cleanup EXIT

trap 'log_error "安装过程中发生错误，请查看日志: $LOG_FILE"; cleanup; exit 1' ERR

# ==============================================================================
# 主函数
# ==============================================================================

main() {
    # 初始化日志
    echo "=== OpenClaw 国内源安装日志 ===" > "$LOG_FILE"
    echo "开始时间: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
    echo "================================" >> "$LOG_FILE"

    # 交互式菜单循环
    while true; do
        show_menu
        read choice
        handle_menu_choice "$choice"
    done
}

# ==============================================================================
# 运行主函数
# ==============================================================================

main "$@"
