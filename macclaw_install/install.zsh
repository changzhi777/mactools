#!/usr/bin/env zsh
# ==============================================================================
# MacClaw Install - 简化版安装脚本
# ==============================================================================
#
# 功能说明：
#   - 半交互式安装（oMLX 需要手动安装）
#   - 自动检测并安装缺失组件
#   - 修复了原脚本的PATH和交互问题
#   - 清晰的进度输出
#
# 使用方法：
#   ./install.zsh
#
# ==============================================================================

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 日志文件
LOG_FILE="${HOME}/macclaw_simple_install.log"

# 脚本目录
SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd)"

# ==============================================================================
# 日志函数
# ==============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*" | tee -a "${LOG_FILE}"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*" | tee -a "${LOG_FILE}"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*" | tee -a "${LOG_FILE}"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" | tee -a "${LOG_FILE}"
}

log_section() {
    echo "" | tee -a "${LOG_FILE}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" | tee -a "${LOG_FILE}"
    echo -e "${CYAN}  $*${NC}" | tee -a "${LOG_FILE}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" | tee -a "${LOG_FILE}"
    echo "" | tee -a "${LOG_FILE}"
}

# ==============================================================================
# 系统检测
# ==============================================================================

detect_system() {
    log_section "系统检测"

    # macOS 版本
    local macos_version=$(sw_vers -productVersion)
    log_info "macOS 版本: ${macos_version}"

    # CPU 架构
    local arch=$(uname -m)
    log_info "CPU 架构: ${arch}"

    # CPU 型号
    local cpu=$(sysctl -n machdep.cpu.brand_string)
    log_info "CPU 型号: ${cpu}"

    # 内存大小
    local memory_gb=$(( $(sysctl -n hw.memsize) / 1024 / 1024 / 1024 ))
    log_info "内存大小: ${memory_gb}GB"

    # 磁盘空间
    local disk_free=$(/bin/df -h / | /usr/bin/tail -1 | /usr/bin/awk '{print $4}')
    log_info "磁盘可用空间: ${disk_free}"

    echo ""
}

# ==============================================================================
# 组件检测
# ==============================================================================

check_homebrew() {
    if command -v brew >/dev/null 2>&1; then
        local version=$(brew --version | head -1)
        log_success "Homebrew 已安装: ${version}"
        return 0
    else
        log_info "Homebrew 未安装"
        return 1
    fi
}

check_nodejs() {
    if command -v node >/dev/null 2>&1; then
        local version=$(node --version)
        log_success "Node.js 已安装: ${version}"
        return 0
    else
        log_info "Node.js 未安装"
        return 1
    fi
}

check_npm() {
    if command -v npm >/dev/null 2>&1; then
        local version=$(npm --version)
        log_success "npm 已安装: ${version}"
        return 0
    else
        log_info "npm 未安装"
        return 1
    fi
}

check_openclaw() {
    if command -v openclaw >/dev/null 2>&1; then
        local version=$(openclaw --version 2>&1 | head -1)
        log_success "OpenClaw 已安装: ${version}"
        return 0
    else
        log_info "OpenClaw 未安装"
        return 1
    fi
}

check_omlx() {
    if [[ -d "/Applications/oMLX.app" ]]; then
        log_success "oMLX 应用已安装"
        return 0
    else
        log_info "oMLX 应用未安装"
        return 1
    fi
}

detect_components() {
    log_section "组件检测"

    check_homebrew || true
    check_nodejs || true
    check_npm || true
    check_openclaw || true
    check_omlx || true

    echo ""
}

# ==============================================================================
# 安装 Homebrew
# ==============================================================================

install_homebrew() {
    log_section "安装 Homebrew"

    if check_homebrew; then
        log_info "Homebrew 已安装，跳过"
        return 0
    fi

    log_warning "Homebrew 安装需要管理员权限和交互式终端"
    log_warning "当前环境不支持，跳过 Homebrew 安装"
    echo ""
    echo "💡 如果您需要安装 Homebrew，请在终端中手动运行："
    echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    echo ""
    log_info "继续安装其他组件..."
    return 0
}

# ==============================================================================
# 安装 Node.js
# ==============================================================================

install_nodejs() {
    log_section "安装 Node.js"

    if check_nodejs; then
        log_info "Node.js 已安装，跳过"
        return 0
    fi

    log_info "Node.js 未安装，但脚本暂不支持自动安装"
    log_warning "请手动安装 Node.js: https://nodejs.org/"
    return 0
}

# ==============================================================================
# 安装 OpenClaw
# ==============================================================================

install_openclaw() {
    log_section "安装 OpenClaw"

    # 检查 OpenClaw 是否已安装
    if check_openclaw; then
        log_success "OpenClaw 已安装"
        return 0
    fi

    log_info "OpenClaw 未安装"

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  OpenClaw 安装向导${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${WHITE}OpenClaw 是一个本地 AI Agent 框架，支持多种推理引擎。${NC}"
    echo ""
    echo -e "${YELLOW}是否需要安装 OpenClaw？${NC}"
    echo "  1) 是 - 在新终端窗口中安装 OpenClaw"
    echo "  2) 否 - 跳过 OpenClaw 安装"
    echo "  3) 重新检测 - 检查是否已安装"
    echo ""
    echo -n "请选择 [1-3]: "

    read choice
    echo ""

    case "${choice}" in
        1|"yes"|"y"|"Y"|"是")
            log_info "准备在新终端窗口中安装 OpenClaw..."

            echo ""
            echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${CYAN}  安装说明${NC}"
            echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo ""
            echo -e "${WHITE}📱 安装步骤：${NC}"
            echo "  1. 即将打开一个新的终端窗口"
            echo "  2. 新窗口会自动运行 OpenClaw 安装脚本"
            echo "  3. 请在新窗口中按照提示完成安装"
            echo "  4. 安装完成后，返回此终端并按 Enter 继续"
            echo ""
            echo -e "${YELLOW}⏳  脚本将在此暂停，等待您完成安装...${NC}"
            echo ""

            # 等待用户确认
            echo -n "准备好了吗？按 Enter 开始打开新终端窗口..."
            read

            log_info "正在打开新的终端窗口..."

            # 使用 osascript 打开新的终端窗口并执行安装命令
            if [[ -f "/Applications/Utilities/Terminal.app" ]]; then
                # 使用 macOS Terminal
                osascript <<EOF
tell application "Terminal"
    activate
    do script "cd /tmp && echo '正在安装 OpenClaw...' && echo '' && echo '安装命令: curl -fsSL https://openclaw.ai/install.sh | bash' && echo '' && echo '安装过程可能需要几分钟，请耐心等待...' && echo '' && curl -fsSL https://openclaw.ai/install.sh | bash && echo '' && echo '✅ OpenClaw 安装完成！' && echo '' && echo '请返回原终端窗口并按 Enter 继续' && echo ''"
end tell
EOF
            elif [[ -f "/Applications/iTerm.app" ]]; then
                # 使用 iTerm2
                osascript <<EOF
tell application "iTerm"
    activate
    set newWindow to (create window with default profile)
    tell current session of newWindow
        write text "cd /tmp && echo '正在安装 OpenClaw...' && echo '' && echo '安装命令: curl -fsSL https://openclaw.ai/install.sh | bash' && echo '' && echo '安装过程可能需要几分钟，请耐心等待...' && echo '' && curl -fsSL https://openclaw.ai/install.sh | bash && echo '' && echo '✅ OpenClaw 安装完成！' && echo '' && echo '请返回原终端窗口并按 Enter 继续' && echo ''"
    end tell
end tell
EOF
            else
                log_error "未找到终端应用程序"
                log_info "请手动在终端中运行以下命令："
                echo ""
                echo "   curl -fsSL https://openclaw.ai/install.sh | bash"
                echo ""
                return 1
            fi

            log_success "新终端窗口已打开"
            echo ""
            echo -e "${YELLOW}⏳  等待您在新窗口中完成 OpenClaw 安装...${NC}"
            echo ""

            # 等待用户确认
            echo -n "安装完成后，请按 Enter 键继续..."
            read

            echo ""
            log_info "检测 OpenClaw 安装状态..."

            # 刷新 PATH
            export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${PATH}"

            # 重新检测 OpenClaw
            if command -v openclaw >/dev/null 2>&1; then
                local version=$(openclaw --version 2>&1 | head -1)
                log_success "✅ OpenClaw 安装成功！"
                log_info "版本: ${version}"
                return 0
            else
                log_warning "⚠️  未检测到 OpenClaw 命令"
                log_warning "请确认安装步骤是否正确"

                # 提供调试信息
                echo ""
                echo -e "${YELLOW}💡 调试提示：${NC}"
                echo "  1. 检查新窗口中的安装是否有错误"
                echo "  2. 尝试在当前终端中运行: openclaw --version"
                echo "  3. 如果命令存在，可能是 PATH 问题"
                echo ""

                # 询问是否重试
                echo -n "是否重新检测？[y/N]: "
                read retry_choice
                if [[ "${retry_choice}" =~ ^[yY] ]]; then
                    install_openclaw
                    return $?
                fi

                return 0
            fi
            ;;

        2|"no"|"n"|"N"|"否")
            log_info "跳过 OpenClaw 安装"
            log_info "您可以稍后手动安装，或访问 https://openclaw.ai/"
            echo ""
            echo "手动安装命令："
            echo "   curl -fsSL https://openclaw.ai/install.sh | bash"
            echo ""
            return 0
            ;;

        3|"重新检测"|"r"|"R")
            log_info "重新检测 OpenClaw 安装状态..."

            # 刷新 PATH
            export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${PATH}"

            if command -v openclaw >/dev/null 2>&1; then
                local version=$(openclaw --version 2>&1 | head -1)
                log_success "✅ OpenClaw 已安装！"
                log_info "版本: ${version}"
                return 0
            else
                log_warning "⚠️  未检测到 OpenClaw"
                log_info "重新开始安装流程..."
                install_openclaw
                return $?
            fi
            ;;

        *)
            log_warning "无效选择，跳过 OpenClaw 安装"
            return 0
            ;;
    esac
}

# ==============================================================================
# 安装 omlx
# ==============================================================================

install_omlx() {
    log_section "安装 oMLX"

    # 检查 oMLX 应用是否已安装
    if [[ -d "/Applications/oMLX.app" ]]; then
        log_success "oMLX 应用已安装"
        return 0
    fi

    log_info "oMLX 是一个 macOS 应用程序，需要手动安装"

    # 检测 macOS 版本
    local macos_version=$(sw_vers -productVersion)
    local major_version=$(echo "${macos_version}" | cut -d. -f1)

    # 确定 DMG URL
    local dmg_url=""
    local dmg_filename=""

    if [[ ${major_version} -ge 26 ]]; then
        dmg_url="https://github.com/jundot/omlx/releases/download/v0.3.5.dev1/oMLX-0.3.5.dev1-macos26-tahoe.dmg"
        dmg_filename="oMLX-0.3.5.dev1-macos26-tahoe.dmg"
    elif [[ ${major_version} -ge 15 ]]; then
        dmg_url="https://github.com/jundot/omlx/releases/download/v0.3.5.dev1/oMLX-0.3.5.dev1-macos15-sequoia.dmg"
        dmg_filename="oMLX-0.3.5.dev1-macos15-sequoia.dmg"
    else
        log_warning "不支持的 macOS 版本: ${macos_version}"
        log_info "请访问 https://github.com/jundot/omlx/releases 下载适合的版本"
        return 0
    fi

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  oMLX 手动安装向导${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${WHITE}检测到的 macOS 版本：${NC} ${macos_version}"
    echo -e "${WHITE}将下载的版本：${NC} ${dmg_filename}"
    echo ""

    # 询问用户是否自动下载并打开
    echo -e "${YELLOW}是否自动下载并打开 oMLX 安装包？${NC}"
    echo "  1) 是 - 自动下载并打开 DMG 文件"
    echo "  2) 否 - 跳过 oMLX 安装"
    echo "  3) 重新检测 - 检查是否已安装"
    echo ""
    echo -n "请选择 [1-3]: "

    read choice
    echo ""

    case "${choice}" in
        1|"yes"|"y"|"Y"|"是")
            log_info "正在下载 oMLX..."

            # 下载 DMG
            if curl -L -o /tmp/oMLX.dmg "${dmg_url}" 2>&1 | tee -a "${LOG_FILE}"; then
                log_success "下载完成: /tmp/oMLX.dmg"

                # 显示文件信息
                local file_size=$(ls -lh /tmp/oMLX.dmg | awk '{print $5}')
                log_info "文件大小: ${file_size}"

                # 打开 DMG
                log_info "正在打开安装包..."
                open /tmp/oMLX.dmg

                echo ""
                echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                echo -e "${CYAN}  安装说明${NC}"
                echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                echo ""
                echo -e "${WHITE}📱 安装步骤：${NC}"
                echo "  1. 在打开的 Finder 窗口中，找到 oMLX.app"
                echo "  2. 将 oMLX.app 拖拽到 Applications 文件夹"
                echo "  3. 等待复制完成"
                echo "  4. 返回此终端，按 Enter 继续"
                echo ""
                echo -e "${YELLOW}⏳  脚本已暂停，等待您完成安装...${NC}"
                echo ""

                # 等待用户确认
                echo -n "安装完成后，请按 Enter 键继续..."
                read

                echo ""
                log_info "检测 oMLX 安装状态..."

                # 检测安装
                if [[ -d "/Applications/oMLX.app" ]]; then
                    log_success "✅ oMLX 安装成功！"

                    # 清理 DMG 文件
                    log_info "清理下载的 DMG 文件..."
                    rm -f /tmp/oMLX.dmg
                    log_success "清理完成"

                    return 0
                else
                    log_warning "⚠️  未检测到 oMLX 应用"
                    log_warning "请确认安装步骤是否正确"
                    log_info "您可以稍后手动安装，OpenClaw 仍可正常使用"

                    # 询问是否重试
                    echo ""
                    echo -n "是否重新检测？[y/N]: "
                    read retry_choice
                    if [[ "${retry_choice}" =~ ^[yY] ]]; then
                        install_omlx
                        return $?
                    fi

                    return 0
                fi
            else
                log_error "下载失败"
                log_info "请手动下载: ${dmg_url}"
                return 1
            fi
            ;;

        2|"no"|"n"|"N"|"否")
            log_info "跳过 oMLX 安装"
            log_info "您可以稍后手动安装，OpenClaw 仍可正常使用"
            log_info "下载链接: ${dmg_url}"
            return 0
            ;;

        3|"重新检测"|"r"|"R")
            log_info "重新检测 oMLX 安装状态..."
            if [[ -d "/Applications/oMLX.app" ]]; then
                log_success "✅ oMLX 已安装！"
                return 0
            else
                log_warning "⚠️  未检测到 oMLX 应用"
                log_info "重新开始安装流程..."
                install_omlx
                return $?
            fi
            ;;

        *)
            log_warning "无效选择，跳过 oMLX 安装"
            return 0
            ;;
    esac
}

# ==============================================================================
# 测试 AI 模型
# ==============================================================================

test_model() {
    log_section "测试 AI 模型"

    if ! check_openclaw; then
        log_warning "OpenClaw 未安装，跳过模型测试"
        return 0
    fi

    log_info "测试 OpenClaw 推理功能..."
    log_info "使用模型: omlx/gemma-4-e4b-it-4bit"

    # 测试推理（使用 || true 确保即使失败也继续执行）
    local test_output=$(openclaw infer model run --model omlx/gemma-4-e4b-it-4bit --prompt "你好" 2>&1)
    local test_exit_code=$?

    # 记录测试输出
    echo "${test_output}" | tee -a "${LOG_FILE}" >/dev/null

    if [[ ${test_exit_code} -eq 0 ]]; then
        log_success "模型测试成功！"
    else
        log_warning "模型测试失败，但这不影响后续使用"
        log_info "您可以稍后手动测试: openclaw infer model run --model omlx/gemma-4-e4b-it-4bit --prompt '你好'"
    fi

    # 无论测试结果如何，都继续执行
    return 0
}

# ==============================================================================
# 配置 oMLX 本地算力
# ==============================================================================

configure_omlx_local() {
    log_section "配置 oMLX 本地算力"

    if ! check_openclaw; then
        log_warning "OpenClaw 未安装，无法配置 oMLX"
        return 1
    fi

    if ! [[ -d "/Applications/oMLX.app" ]]; then
        log_warning "oMLX 应用未安装，无法配置本地算力"
        log_info "请先安装 oMLX 应用"
        return 1
    fi

    log_info "配置 OpenClaw 使用本地 oMLX 推理引擎..."

    # 检查 oMLX 配置文件
    local omlx_config="${HOME}/.omlx/settings.json"
    local openclaw_config="${HOME}/.openclaw/openclaw.json"

    if [[ ! -f "${omlx_config}" ]]; then
        log_warning "oMLX 配置文件不存在: ${omlx_config}"
        log_info "请先启动 oMLX 应用并完成初始配置"
        return 1
    fi

    # 检查 OpenClaw 是否已配置 oMLX
    if openclaw config get agents.defaults.model.primary 2>/dev/null | grep -q "omlx"; then
        log_success "oMLX 本地算力已配置"
        # 继续执行，不返回
    else
        echo ""
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${CYAN}  oMLX 本地算力配置${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo -e "${WHITE}检测到：${NC}"
        echo "  • oMLX 应用: /Applications/oMLX.app"
        echo "  • OpenClaw: $(openclaw --version 2>&1 | head -1)"
        echo ""
        echo -e "${YELLOW}是否配置 OpenClaw 使用本地 oMLX 推理？${NC}"
        echo "  1) 是 - 配置 oMLX 作为默认推理引擎"
        echo "  2) 否 - 跳过配置"
        echo ""

        # 检测是否为非交互模式（管道安装）
        if [[ ! -t 0 ]]; then
            echo -e "${CYAN}[自动选择] 是 - 配置 oMLX 作为默认推理引擎${NC}"
            choice="1"
        else
            echo -n "请选择 [1-2]: "
            read choice
        fi
        echo ""

        case "${choice}" in
            1|"yes"|"y"|"Y"|"是")
                log_info "正在配置 oMLX 本地算力..."

                # 配置 oMLX 为默认模型
                if openclaw config set agents.defaults.model.primary "omlx/gemma-4-e4b-it-4bit" 2>&1 | tee -a "${LOG_FILE}"; then
                    log_success "oMLX 配置成功"
                    log_info "默认模型已设置为: omlx/gemma-4-e4b-it-4bit"
                else
                    log_warning "配置失败，请手动配置"
                    log_info "手动配置命令："
                    echo "  openclaw config set agents.defaults.model.primary omlx/gemma-4-e4b-it-4bit"
                    # 不返回1，改为返回0继续执行
                fi

                # 验证配置
                log_info "验证配置..."
                local configured_model=$(openclaw config get agents.defaults.model.primary 2>/dev/null)
                if [[ "${configured_model}" == *"omlx"* ]]; then
                    log_success "✅ oMLX 本地算力配置成功！"
                    log_info "OpenClaw 现在使用本地 oMLX 进行推理"
                else
                    log_warning "配置验证失败，但继续执行后续步骤"
                fi
                ;;

            2|"no"|"n"|"N"|"否")
                log_info "跳过 oMLX 本地算力配置"
                ;;

            *)
                log_warning "无效选择，跳过配置"
                ;;
        esac
    fi

    # 无论配置结果如何，都返回0继续执行
    return 0
}

# ==============================================================================
# 优化 oMLX 性能
# ==============================================================================

optimize_omlx_performance() {
    log_section "优化 oMLX 性能"

    if ! [[ -d "/Applications/oMLX.app" ]]; then
        log_warning "oMLX 应用未安装，无法优化性能"
        return 1
    fi

    local omlx_config="${HOME}/.omlx/settings.json"
    local omlx_stats="${HOME}/.omlx/stats.json"

    if [[ ! -f "${omlx_config}" ]]; then
        log_warning "oMLX 配置文件不存在"
        return 1
    fi

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  oMLX 性能优化${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # 显示当前性能统计
    if [[ -f "${omlx_stats}" ]]; then
        echo -e "${WHITE}📊 当前使用统计：${NC}"
        local total_requests=$(jq -r '.total_requests' "${omlx_stats}" 2>/dev/null || echo "0")
        local cached_tokens=$(jq -r '.total_cached_tokens' "${omlx_stats}" 2>/dev/null || echo "0")
        local cache_hit_rate=$(echo "scale=1; ${cached_tokens} * 100 / ($(jq -r '.total_prompt_tokens' "${omlx_stats}" 2>/dev/null || echo "1") + ${cached_tokens})" | bc 2>/dev/null || echo "0")

        echo "  • 总请求数: ${total_requests}"
        echo "  • 缓存命中数: ${cached_tokens}"
        echo "  • 缓存命中率: ${cache_hit_rate}%"
        echo ""
    fi

    # 显示当前配置
    echo -e "${WHITE}⚙️  当前配置：${NC}"
    local current_concurrent=$(jq -r '.scheduler.max_concurrent_requests' "${omlx_config}" 2>/dev/null || echo "未知")
    local current_cache=$(jq -r '.cache.initial_cache_blocks' "${omlx_config}" 2>/dev/null || echo "未知")
    local current_temp=$(jq -r '.sampling.temperature' "${omlx_config}" 2>/dev/null || echo "未知")

    echo "  • 并发请求: ${current_concurrent}"
    echo "  • 初始缓存块: ${current_cache}"
    echo "  • 采样温度: ${current_temp}"
    echo ""

    echo -e "${YELLOW}是否优化 oMLX 性能配置？${NC}"
    echo "  1) 是 - 开始性能优化"
    echo "  2) 否 - 跳过优化"
    echo "  3) 查看详细配置 - 查看当前详细配置"
    echo ""

    # 检测是否为非交互模式（管道安装）
    if [[ ! -t 0 ]]; then
        echo -e "${CYAN}[自动选择] 是 - 开始性能优化${NC}"
        choice="1"
    else
        echo -n "请选择 [1-3]: "
        read choice
    fi
    echo ""

    case "${choice}" in
        1|"yes"|"y"|"Y"|"是")
            log_info "开始优化 oMLX 性能..."

            # 备份当前配置
            local backup_config="${HOME}/.omlx/settings.json.backup"
            cp "${omlx_config}" "${backup_config}"
            log_info "已备份当前配置到: ${backup_config}"

            # 根据系统内存自动优化
            local memory_gb=$(( $(sysctl -n hw.memsize) / 1024 / 1024 / 1024 ))
            local new_concurrent=""
            local new_cache_blocks=""
            local new_hot_cache=""

            if [[ ${memory_gb} -ge 32 ]]; then
                # 高配置系统
                new_concurrent="16"
                new_cache_blocks="512"
                new_hot_cache="1073741824"  # 1GB
                log_info "检测到高配置系统 (${memory_gb}GB)，使用高性能配置"
            elif [[ ${memory_gb} -ge 16 ]]; then
                # 中配置系统
                new_concurrent="12"
                new_cache_blocks="384"
                new_hot_cache="536870912"  # 512MB
                log_info "检测到中配置系统 (${memory_gb}GB)，使用平衡配置"
            else
                # 低配置系统
                new_concurrent="8"
                new_cache_blocks="256"
                new_hot_cache="268435456"  # 256MB
                log_info "检测到低配置系统 (${memory_gb}GB)，使用保守配置"
            fi

            # 应用优化配置
            log_info "应用性能优化..."

            if command -v jq >/dev/null 2>&1; then
                # 使用 jq 修改配置
                jq ".scheduler.max_concurrent_requests = ${new_concurrent}" "${omlx_config}" > /tmp/omlx_settings.json
                jq ".cache.initial_cache_blocks = ${new_cache_blocks}" /tmp/omlx_settings.json > /tmp/omlx_settings.tmp
                jq ".cache.hot_cache_max_size = \"${new_hot_cache}\"" /tmp/omlx_settings.tmp > "${omlx_config}"
                rm -f /tmp/omlx_settings.tmp

                log_success "配置文件已更新"
            else
                log_warning "jq 未安装，使用备用方法..."
                # 备用方法：使用 sed
                sed -i '' "s/\"max_concurrent_requests\": [0-9]*/\"max_concurrent_requests\": ${new_concurrent}/" "${omlx_config}"
                sed -i '' "s/\"initial_cache_blocks\": [0-9]*/\"initial_cache_blocks\": ${new_cache_blocks}/" "${omlx_config}"
                log_success "配置文件已更新（备用方法）"
            fi

            # 需要重启 oMLX 服务以应用新配置
            echo ""
            echo -e "${YELLOW}⚠️  oMLX 服务需要重启以应用新配置${NC}"
            echo ""
            echo "重启方法："
            echo "  1. 在 oMLX 应用中点击 '重启服务' 按钮"
            echo "  2. 或重启 oMLX 应用"
            echo ""

            # 检测是否为非交互模式
            if [[ ! -t 0 ]]; then
                echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                echo -e "${CYAN}  📋 重要提醒（非交互模式）${NC}"
                echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                echo ""
                echo -e "${WHITE}⚠️  oMLX 性能优化已完成，但需要重启服务才能生效！${NC}"
                echo ""
                echo -e "${YELLOW}🔄 请按以下步骤重启 oMLX 服务：${NC}"
                echo ""
                echo "  方式1（推荐）："
                echo "    1. 打开 oMLX 应用"
                echo "    2. 点击 '重启服务' 按钮"
                echo ""
                echo "  方式2："
                echo "    1. 完全退出 oMLX 应用"
                echo "    2. 重新启动 oMLX 应用"
                echo ""
                echo -e "${GREEN}✅ 重启后，新的性能配置将自动生效${NC}"
                echo -e "${GREEN}✅ 并发请求将提升至: 12${NC}"
                echo -e "${GREEN}✅ 缓存块将提升至: 384${NC}"
                echo ""
                echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                echo ""
                echo -e "${WHITE}💡 安装脚本将继续执行后续步骤...${NC}"
                echo ""
                # 短暂延迟，让用户看到提醒
                sleep 3
            else
                echo -n "重启完成后，按 Enter 继续..."
                read
            fi

            # 验证配置
            log_info "验证新配置..."
            local verify_concurrent=$(jq -r '.scheduler.max_concurrent_requests' "${omlx_config}" 2>/dev/null || echo "未知")

            echo ""
            echo -e "${WHITE}🎯 优化后配置：${NC}"
            echo "  • 并发请求: ${current_concurrent} → ${verify_concurrent}"
            echo "  • 缓存块: ${current_cache} → ${new_cache_blocks}"
            echo ""

            log_success "✅ oMLX 性能优化完成！"
            ;;

        2|"no"|"n"|"N"|"否")
            log_info "跳过性能优化"
            return 0
            ;;

        3|"view"|"v"|"V"|"查看")
            log_info "当前详细配置："
            echo ""
            cat "${omlx_config}" | jq '.' 2>/dev/null || cat "${omlx_config}"
            echo ""

            # 询问是否继续优化
            echo -n "是否继续优化？[y/N]: "
            read continue_choice
            if [[ "${continue_choice}" =~ ^[yY] ]]; then
                optimize_omlx_performance
                return $?
            fi
            ;;

        *)
            log_warning "无效选择，跳过优化"
            return 0
            ;;
    esac
}

# ==============================================================================
# 安装插件
# ==============================================================================

install_plugins() {
    log_section "安装推荐插件"

    if ! check_openclaw; then
        log_warning "OpenClaw 未安装，无法安装插件"
        return 1
    fi

    # 加载插件配置
    if [[ -f "${SCRIPT_DIR}/config/plugins.conf" ]]; then
        source "${SCRIPT_DIR}/config/plugins.conf"
    else
        log_info "插件配置文件不存在，跳过插件安装"
        return 0
    fi

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  OpenClaw 插件安装${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${WHITE}推荐插件列表：${NC}"
    echo ""

    # 显示推荐插件
    local index=1
    for plugin in "${RECOMMENDED_PLUGINS[@]}"; do
        local description="${PLUGIN_DESCRIPTIONS[$plugin]:-无描述}"
        local category="${PLUGIN_CATEGORIES[$plugin]:-other}"
        echo -e "  ${GREEN}[${index}]${NC} ${plugin}"
        echo "      ${description}"
        echo "      类别: ${category}"
        echo ""
        ((index++))
    done

    echo -e "${YELLOW}是否安装推荐插件？${NC}"
    echo "  1) 全部安装 - 安装所有推荐插件"
    echo "  2) 选择安装 - 选择要安装的插件"
    echo "  3) 跳过 - 不安装插件"
    echo ""

    # 检测是否为非交互模式（管道安装）
    if [[ ! -t 0 ]]; then
        echo -e "${CYAN}[自动选择] 全部安装 - 安装所有推荐插件${NC}"
        choice="1"
    else
        echo -n "请选择 [1-3]: "
        read choice
    fi
    echo ""

    case "${choice}" in
        1|"all"|"a"|"A"|"全部")
            log_info "开始安装所有推荐插件..."

            local success_count=0
            local fail_count=0

            for plugin in "${RECOMMENDED_PLUGINS[@]}"; do
                log_info "正在安装: ${plugin}"

                if openclaw plugins install "${plugin}" 2>&1 | tee -a "${LOG_FILE}"; then
                    log_success "✅ ${plugin} 安装成功"
                    ((success_count++))
                else
                    log_warning "⚠️  ${plugin} 安装失败"
                    ((fail_count++))
                fi
            done

            echo ""
            log_success "插件安装完成"
            log_info "成功: ${success_count}, 失败: ${fail_count}"
            ;;

        2|"select"|"s"|"S"|"选择")
            log_info "选择要安装的插件"
            echo ""
            echo "请输入要安装的插件编号（多个用空格分隔）:"
            read -a selected_indices

            for index in "${selected_indices[@]}"; do
                if [[ ${index} -ge 1 && ${index} -le ${#RECOMMENDED_PLUGINS[@]} ]]; then
                    local plugin="${RECOMMENDED_PLUGINS[$((index-1))]}"
                    log_info "正在安装: ${plugin}"

                    if openclaw plugins install "${plugin}" 2>&1 | tee -a "${LOG_FILE}"; then
                        log_success "✅ ${plugin} 安装成功"
                    else
                        log_warning "⚠️  ${plugin} 安装失败"
                    fi
                fi
            done
            ;;

        3|"skip"|"s"|"S"|"跳过")
            log_info "跳过插件安装"
            ;;

        *)
            log_warning "无效选择，跳过插件安装"
            ;;
    esac

    return 0
}

# ==============================================================================
# 创建 Agent
# ==============================================================================

create_agents() {
    log_section "创建 AI Agent"

    if ! check_openclaw; then
        log_warning "OpenClaw 未安装，无法创建 Agent"
        return 1
    fi

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  创建 AI Agent${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # 检查 oMLX 是否可用
    local omlx_available=false
    if [[ -d "/Applications/oMLX.app" ]]; then
        omlx_available=true
        echo -e "${GREEN}✅ 检测到 oMLX 本地算力${NC}"
    else
        echo -e "${YELLOW}⚠️  未检测到 oMLX，Agent 将使用其他推理引擎${NC}"
    fi

    echo ""
    echo -e "${WHITE}推荐 Agent 模板：${NC}"
    echo ""
    echo "  1) 🤖 BB小子 - 基于 oMLX 本地 AI 的智能助手（推荐）"
    echo "  2) 👨‍💻 开发者助手 - 专业的软件开发助手"
    echo "  3) ✍️ 写作助手 - 专业的写作和编辑助手"
    echo "  4) 📊 数据分析助手 - 专业的数据分析和洞察助手"
    echo "  5) 🔧 自定义 - 创建自定义 Agent"
    echo "  6) ⏭️  跳过 - 不创建 Agent"
    echo ""

    # 检测是否为非交互模式（管道安装）
    if [[ ! -t 0 ]]; then
        echo -e "${CYAN}[自动选择] BB小子 - 基于 oMLX 本地 AI 的智能助手${NC}"
        choice="1"
    else
        echo -n "请选择 [1-6]: "
        read choice
    fi
    echo ""

    case "${choice}" in
        1|"bb-kid"|"b"|"B"|"bb"|"BB小子")
            create_bb_kid_agent
            ;;

        2|"developer"|"d"|"D")
            create_agent "developer" "开发者助手" "👨‍💻" "coding"
            ;;

        3|"writer"|"w"|"W")
            create_agent "writer" "写作助手" "✍️" "writing"
            ;;

        3|"analyst"|"a"|"A")
            create_agent "analyst" "数据分析助手" "📊" "data"
            ;;

        5|"custom"|"c"|"C"|"自定义")
            echo ""
            echo -n "请输入 Agent 名称: "
            read agent_name
            echo -n "请输入 Agent 描述: "
            read agent_description
            echo -n "请选择 Emoji 图标: "
            read agent_emoji
            echo -n "请输入主题 (coding/writing/data/other): "
            read agent_theme

            create_agent "${agent_name}" "${agent_description}" "${agent_emoji}" "${agent_theme}"
            ;;

        6|"skip"|"s"|"S"|"跳过")
            log_info "跳过 Agent 创建"
            ;;

        *)
            log_warning "无效选择，跳过 Agent 创建"
            ;;
    esac
}

# BB小子 Agent 创建函数
create_bb_kid_agent() {
    log_section "创建 BB小子 Agent"

    local agent_id="bb-kid"
    local agent_name="BB小子"
    local agent_emoji="🤖"
    local agent_theme="tech"

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  BB小子 - oMLX 本地 AI 助手${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${WHITE}🤖 BB小子 特性：${NC}"
    echo "  • 基于 oMLX 本地 AI 引擎"
    echo "  • 使用 gemma-4-e4b-it-4bit 模型"
    echo "  • 擅长编程、写作和分析"
    echo "  • 完全本地运行，保护隐私"
    echo ""

    # 检查 oMLX 是否可用
    if ! [[ -d "/Applications/oMLX.app" ]]; then
        log_warning "oMLX 应用未安装"
        log_info "BB小子 Agent 将使用其他推理引擎"
    else
        log_success "oMLX 本地算力已就绪"
    fi

    # 检查 Agent 是否已存在
    if openclaw agents list 2>/dev/null | grep -q "${agent_id}"; then
        log_warning "Agent 'bb-kid' 已存在"

        echo ""
        echo -n "是否重新配置 BB小子 Agent？[y/N]: "
        read recreate_choice
        if [[ ! "${recreate_choice}" =~ ^[yY] ]]; then
            log_info "保持现有配置"
            return 0
        fi

        log_info "重新配置 BB小子 Agent..."
    else
        log_info "创建新的 BB小子 Agent..."
    fi

    # 创建 BB小子 工作空间
    local workspace="${HOME}/.openclaw/workspaces/${agent_id}"

    if [[ ! -d "${workspace}" ]]; then
        mkdir -p "${workspace}"
        log_info "创建工作空间: ${workspace}"
    fi

    # 创建 BB小子 配置文件
    local bb_config="${workspace}/bb-kid-config.json"
    cat > "${bb_config}" << EOF
{
  "name": "BB小子",
  "description": "基于 oMLX 本地 AI 的智能助手",
  "version": "1.0.0",
  "created": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "model": "omlx/gemma-4-e4b-it-4bit",
  "capabilities": [
    "编程开发",
    "代码审查",
    "技术写作",
    "问题分析",
    "创意生成"
  ],
  "preferences": {
    "language": "zh-CN",
    "creativity": "balanced",
    "response_length": "medium"
  }
}
EOF

    # 添加或更新 Agent
    if openclaw agents list 2>/dev/null | grep -q "${agent_id}"; then
        # Agent 已存在，只更新配置
        log_info "更新 BB小子 Agent 配置..."
    else
        # 创建新 Agent
        if openclaw agents add "${agent_id}" --workspace "${workspace}" 2>&1 | tee -a "${LOG_FILE}"; then
            log_success "BB小子 Agent 创建成功"
        else
            log_error "BB小子 Agent 创建失败"
            return 1
        fi
    fi

    # 设置 BB小子身份
    openclaw agents set-identity "${agent_id}" \
        --name "${agent_name}" \
        --emoji "${agent_emoji}" \
        --theme "${agent_theme}" 2>/dev/null || true

    # 配置 BB小子 使用 oMLX 模型
    log_info "配置 BB小子 使用 oMLX 本地模型..."

    # 为 BB小子 设置专用模型配置
    if openclaw config set "agents.${agent_id}.model" "omlx/gemma-4-e4b-it-4bit" 2>&1 | tee -a "${LOG_FILE}"; then
        log_success "BB小子 模型配置成功"
    else
        log_warning "模型配置失败，使用默认配置"
    fi

    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  🤖 BB小子 Agent 创建完成！${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${WHITE}📋 BB小子 信息：${NC}"
    echo "  • 名称: BB小子"
    echo "  • ID: bb-kid"
    echo "  • Emoji: 🤖"
    echo "  • 模型: omlx/gemma-4-e4b-it-4bit"
    echo "  • 工作空间: ${workspace}"
    echo ""
    echo -e "${WHITE}🚀 使用方法：${NC}"
    echo ""
    echo "  # 切换到 BB小子 Agent"
    echo "  openclaw agents use bb-kid"
    echo ""
    echo "  # 与 BB小子对话"
    echo "  openclaw agent"
    echo ""
    echo "  # 查看 BB小子配置"
    echo "  openclaw agents list"
    echo ""

    # 测试 BB小子
    echo -e "${YELLOW}是否测试 BB小子 Agent？${NC} "
    echo "  1) 是 - 发送测试消息"
    echo "  2) 否 - 跳过测试"
    echo ""

    # 检测是否为非交互模式（管道安装）
    if [[ ! -t 0 ]]; then
        echo -e "${CYAN}[自动选择] 否 - 跳过测试（非交互模式）${NC}"
        test_choice="2"
    else
        echo -n "请选择 [1-2]: "
        read test_choice
    fi
    echo ""

    if [[ "${test_choice}" == "1" ]]; then
        log_info "测试 BB小子 Agent..."

        # 切换到 BB小子 Agent
        if openclaw agents use "${agent_id}" 2>/dev/null; then
            log_success "已切换到 BB小子 Agent"

            # 发送测试消息
            echo ""
            echo -e "${CYAN}正在发送测试消息...${NC}"
            if openclaw agent --prompt "你好，我是BB小子的创造者，请做一个自我介绍" 2>&1 | tee -a "${LOG_FILE}"; then
                log_success "✅ BB小子 Agent 测试成功！"
            else
                log_warning "Agent 测试失败"
            fi
        else
            log_warning "切换 Agent 失败"
        fi
    fi

    return 0
}

# Agent 创建辅助函数
create_agent() {
    local agent_id="$1"
    local agent_name="$2"
    local agent_emoji="$3"
    local agent_theme="$4"

    log_info "创建 Agent: ${agent_name}"

    # 检查 Agent 是否已存在
    if openclaw agents list 2>/dev/null | grep -q "${agent_id}"; then
        log_warning "Agent '${agent_id}' 已存在"
        return 0
    fi

    # 创建 Agent 工作空间
    local workspace="${HOME}/.openclaw/workspaces/${agent_id}"

    if [[ ! -d "${workspace}" ]]; then
        mkdir -p "${workspace}"
        log_info "创建工作空间: ${workspace}"
    fi

    # 添加 Agent
    if openclaw agents add "${agent_id}" --workspace "${workspace}" 2>&1 | tee -a "${LOG_FILE}"; then
        log_success "Agent 创建成功: ${agent_id}"

        # 设置 Agent 身份
        openclaw agents set-identity "${agent_id}" \
            --name "${agent_name}" \
            --emoji "${agent_emoji}" \
            --theme "${agent_theme}" 2>/dev/null || true

        log_info "Agent 配置完成"
        log_info "  名称: ${agent_name}"
        log_info "  ID: ${agent_id}"
        log_info "  工作空间: ${workspace}"
    else
        log_warning "Agent 创建失败"
        return 1
    fi
}

# ==============================================================================
# 主函数
# ==============================================================================

main() {
    # 初始化日志
    {
        echo "=============================================================================="
        echo "  MacClaw Install - 简化版安装日志"
        echo "=============================================================================="
        echo "  开始时间: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "  用户: ${USER}"
        echo "  主机: $(hostname)"
        echo "=============================================================================="
        echo ""
    } > "${LOG_FILE}"

    # 显示标题
    clear
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║       🦞 MacClaw Install - 简化版安装工具                 ║"
    echo "║                                                            ║"
    echo "║       一键安装 OpenClaw + omlx 本地 AI 环境                ║"
    echo "║                                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""

    # 系统检测
    detect_system || true

    # 组件检测
    detect_components || true

    # 安装组件
    install_homebrew || true
    install_nodejs || true
    install_openclaw || true
    install_omlx || true
    test_model || true

    # 高级功能（确保即使失败也继续执行）
    configure_omlx_local || true
    optimize_omlx_performance || true
    install_plugins || true
    create_agents || true

    # 最终检测
    log_section "安装完成"
    detect_components

    # 显示总结
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  🎉 安装完成！${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "📝 日志文件: ${LOG_FILE}"
    echo ""

    # 检测是否为非交互模式，显示额外提醒
    if [[ ! -t 0 ]]; then
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${CYAN}  📋 后续操作提醒${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo -e "${WHITE}✅ 安装已完成，但请完成以下步骤以获得最佳体验：${NC}"
        echo ""

        # 检查是否进行了oMLX性能优化
        if [[ -f "${HOME}/.omlx/settings.json.backup" ]]; then
            echo -e "${YELLOW}🔄 1. 重启 oMLX 服务（重要！）${NC}"
            echo ""
            echo "   性能优化已完成，需要重启才能生效："
            echo "   • 打开 oMLX 应用"
            echo "   • 点击 '重启服务' 按钮"
            echo "   • 或完全重启 oMLX 应用"
            echo ""
            echo -e "${GREEN}   重启后性能提升：${NC}"
            echo "   • 并发请求: 8 → 12"
            echo "   • 缓存块: 256 → 384"
            echo ""
        fi

        echo -e "${YELLOW}🤖 2. 开始使用 BB小子 Agent${NC}"
        echo ""
        echo "   切换到 BB小子："
        echo "   ${CYAN}openclaw agents use bb-kid${NC}"
        echo ""
        echo "   开始对话："
        echo "   ${CYAN}openclaw chat '你好，BB小子'${NC}"
        echo ""

        echo -e "${YELLOW}🥋 3. BB小子 健康提醒功能${NC}"
        echo ""
        echo "   收集科技新闻（含健康提醒）："
        echo "   ${CYAN}~/.openclaw/workspaces/bb-kid/skills/news-collector-bruce.zsh collect tech 3${NC}"
        echo ""
        echo "   创建提醒事项："
        echo "   ${CYAN}~/.openclaw/workspaces/bb-kid/skills/macos-reminders-bruce.zsh create '功夫训练' '18:00' '今日练习'${NC}"
        echo ""
        echo "   智能健康提醒："
        echo "   ${CYAN}bash ~/.openclaw/workspaces/bb-kid/skills/bruce-lee-reminders.sh smart${NC}"
        echo ""

        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
    fi

    echo "🚀 快速开始："
    echo ""
    echo "  # 测试本地推理"
    echo "  openclaw infer model run --model omlx/gemma-4-e4b-it-4bit --prompt '你好'"
    echo ""
    echo "  # 运行 Agent 交互"
    echo "  openclaw agent"
    echo ""
    echo "  # 查看所有 Agent"
    echo "  openclaw agents list"
    echo ""
    echo "  # 查看已安装插件"
    echo "  openclaw plugins list"
    echo ""
    echo "  # 查看帮助"
    echo "  openclaw --help"
    echo ""
    echo "📚 更多功能："
    echo ""
    echo "  # 配置 OpenClaw"
    echo "  openclaw configure"
    echo ""
    echo "  # 创建新 Agent"
    echo "  openclaw agents add myagent --workspace ~/.openclaw/workspace-myagent"
    echo ""
    echo "  # 安装插件"
    echo "  openclaw plugins install <plugin-name>"
    echo ""
    echo "  # 查看模型状态"
    echo "  openclaw models status"
    echo ""

    # 非交互模式的最终提醒
    if [[ ! -t 0 ]]; then
        echo ""
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${WHITE}🥋 '知道不够，必须做到。'${NC}"
        echo -e "${WHITE}🥋 'Be water, my friend.'${NC}"
        echo ""
        echo -e "${GREEN}✅ 一键安装完成！BB小子 Agent已就绪！${NC}"
        echo -e "${GREEN}✅ 请按照上述步骤完成后续配置${NC}"
        echo ""
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
    fi
}

# 运行主函数
main
