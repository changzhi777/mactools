#!/bin/sh
#
# 国内源配置检查和修复脚本（POSIX sh 版本）
# 作者: 外星动物（常智）
# 组织: IoTchange
# 邮箱: 14455975@qq.com
# 版本: V1.0.1
# 版权: Copyright (C) 2026 IoTchange - All Rights Reserved
#
# 说明: 检查并修复所有下载源为国内镜像
# Shell 要求: POSIX sh / bash / zsh / dash
#

set -e

# ============================================
# 工具函数
# ============================================

# 获取脚本目录
get_script_dir() {
    if [ -n "${ZSH_VERSION:-}" ]; then
        echo "${funcfiletrace[1]%/*}"
    elif [ -n "${BASH_VERSION:-}" ]; then
        echo "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    else
        echo "$(cd "$(dirname "$0")" && pwd)"
    fi
}

# 检查字符串包含
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
# 初始化
# ============================================

SCRIPT_DIR="$(get_script_dir)"

# 加载统一颜色库
if [ -f "$SCRIPT_DIR/macclaw-installer/lib/colors.sh" ]; then
    . "$SCRIPT_DIR/macclaw-installer/lib/colors.sh"
else
    # 后备颜色定义
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    NC='\033[0m'

    # 定义打印函数
    print_red() { printf "${RED}%s${NC}\n" "$*"; }
    print_green() { printf "${GREEN}%s${NC}\n" "$*"; }
    print_yellow() { printf "${YELLOW}%s${NC}\n" "$*"; }
    print_blue() { printf "${BLUE}%s${NC}\n" "$*"; }
    print_cyan() { printf "${CYAN}%s${NC}\n" "$*"; }
fi

printf "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}\n"
printf "${BLUE}║          国内源配置检查与修复                              ║${NC}\n"
printf "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}\n"
echo ""

# ============================================
# 1. npm 源检查
# ============================================

printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
printf "${CYAN}  1. npm 源检查${NC}\n"
printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

current_npm=$(npm config get registry)
echo "当前 npm 源: $current_npm"

if str_contains "$current_npm" "npmmirror"; then
    printf "${GREEN}✓ npm 使用国内淘宝镜像${NC}\n"
else
    printf "${YELLOW}⚠️  npm 未使用国内源，正在配置...${NC}\n"
    npm config set registry https://registry.npmmirror.com
    printf "${GREEN}✓ npm 已切换到淘宝镜像${NC}\n"
fi

# 验证配置
new_npm=$(npm config get registry)
echo "配置后 npm 源: $new_npm"
echo ""

# ============================================
# 2. pip 源检查
# ============================================

printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
printf "${CYAN}  2. pip 源检查${NC}\n"
printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

if [ -f ~/.pip/pip.conf ]; then
    current_pip=$(grep "index-url" ~/.pip/pip.conf | awk '{print $3}')
    echo "当前 pip 源: $current_pip"

    if str_contains "$current_pip" "tsinghua"; then
        printf "${GREEN}✓ pip 使用清华镜像${NC}\n"
    else
        printf "${YELLOW}⚠️  pip 配置存在但未使用清华源${NC}\n"
    fi
else
    printf "${YELLOW}⚠️  pip 配置文件不存在，正在创建...${NC}\n"
    mkdir -p ~/.pip

    cat > ~/.pip/pip.conf << 'EOF'
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
trusted-host = pypi.tuna.tsinghua.edu.cn
EOF

    printf "${GREEN}✓ pip 已配置清华镜像${NC}\n"
fi

# 验证配置
if [ -f ~/.pip/pip.conf ]; then
    echo "配置文件内容:"
    cat ~/.pip/pip.conf
fi
echo ""

# ============================================
# 3. Git 源检查
# ============================================

printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
printf "${CYAN}  3. Git 源检查${NC}\n"
printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# 检查是否有 nvm
if [ -d ~/.nvm ]; then
    echo "检测到 nvm 安装"

    # 检查 nvm 安装源配置
    if [ -f ~/.nvm/install.sh ]; then
        if grep -q "gitee.com/mirrors/nvm" ~/.nvm/install.sh 2>/dev/null; then
            printf "${GREEN}✓ nvm 使用 Gitee 镜像${NC}\n"
        else
            printf "${YELLOW}⚠️  nvm 未配置 Gitee 镜像${NC}\n"
            echo "💡 建议使用 Gitee 镜像安装 nvm:"
            echo "   export NVM_SOURCE=https://gitee.com/mirrors/nvm.git"
            echo "   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash"
        fi
    fi
else
    printf "${BLUE}ℹ️  nvm 未安装${NC}\n"
fi
echo ""

# ============================================
# 4. Docker 源检查（如果安装）
# ============================================

printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
printf "${CYAN}  4. Docker 源检查${NC}\n"
printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

if command -v docker >/dev/null 2>&1; then
    echo "检测到 Docker 安装"

    # 检查 Docker 镜像
    if [ -f /etc/docker/daemon.json ]; then
        if grep -q "registry-mirrors" /etc/docker/daemon.json 2>/dev/null; then
            printf "${GREEN}✓ Docker 配置了镜像加速${NC}\n"
            echo "当前镜像配置:"
            grep -A 5 "registry-mirrors" /etc/docker/daemon.json 2>/dev/null || true
        else
            printf "${YELLOW}⚠️  Docker 未配置镜像加速${NC}\n"
            echo "💡 建议配置国内镜像源:"
            echo "   阿里云: https://cr.console.aliyun.com"
            echo "   腾讯云: https://cloud.tencent.com/act/mirror"
            echo "   网易云: https://mirror.ccs.tencentyun.com"
        fi
    else
        printf "${YELLOW}⚠️  Docker 配置文件不存在${NC}\n"
    fi
else
    printf "${BLUE}ℹ️  Docker 未安装${NC}\n"
fi
echo ""

# ============================================
# 5. HuggingFace 镜像检查
# ============================================

printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
printf "${CYAN}  5. HuggingFace 镜像检查${NC}\n"
printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

if [ -n "${HF_ENDPOINT:-}" ]; then
    echo "当前 HF_ENDPOINT: $HF_ENDPOINT"

    if str_contains "$HF_ENDPOINT" "hf-mirror"; then
        printf "${GREEN}✓ 使用 HF 国内镜像${NC}\n"
    else
        printf "${YELLOW}⚠️  HF_ENDPOINT 未指向国内镜像${NC}\n"
    fi
else
    printf "${YELLOW}⚠️  HF_ENDPOINT 环境变量未设置${NC}\n"
    echo "💡 正在配置 HF 国内镜像..."

    export HF_ENDPOINT=https://hf-mirror.com

    # 添加到 shell 配置
    shell_config="$HOME/.zshrc"
    if [ ! -f "$shell_config" ]; then
        shell_config="$HOME/.bashrc"
    fi

    if ! grep -q "HF_ENDPOINT" "$shell_config" 2>/dev/null; then
        echo "" >> "$shell_config"
        echo "# HuggingFace 国内镜像" >> "$shell_config"
        echo "export HF_ENDPOINT=https://hf-mirror.com" >> "$shell_config"
        printf "${GREEN}✓ HF_ENDPOINT 已添加到 $shell_config${NC}\n"
    fi

    printf "${GREEN}✓ HuggingFace 镜像已配置${NC}\n"
fi
echo ""

# ============================================
# 6. Go 源检查（如果安装）
# ============================================

printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
printf "${CYAN}  6. Go 源检查${NC}\n"
printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

if command -v go >/dev/null 2>&1; then
    echo "检测到 Go 安装"

    # 检查 Go Proxy
    if [ -n "${GOPROXY:-}" ]; then
        echo "当前 GOPROXY: $GOPROXY"

        if str_contains "$GOPROXY" "cn" || str_contains "$GOPROXY" "goproxy"; then
            printf "${GREEN}✓ Go 使用国内代理${NC}\n"
        else
            printf "${YELLOW}⚠️  GOPROXY 未指向国内源${NC}\n"
        fi
    else
        printf "${YELLOW}⚠️  GOPROXY 环境变量未设置${NC}\n"
        echo "💡 建议配置七牛云 Go 国内代理:"
        echo "   export GOPROXY=https://goproxy.cn,direct"
        echo "   export GOSUMDB=sum.golang.google.cn"
    fi
else
    printf "${BLUE}ℹ️  Go 未安装${NC}\n"
fi
echo ""

# ============================================
# 7. Maven 源检查（如果安装）
# ============================================

printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
printf "${CYAN}  7. Maven 源检查${NC}\n"
printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

if command -v mvn >/dev/null 2>&1; then
    echo "检测到 Maven 安装"

    # 检查 settings.xml
    maven_settings="$HOME/.m2/settings.xml"
    if [ -f "$maven_settings" ]; then
        if grep -q "aliyun" "$maven_settings" 2>/dev/null; then
            printf "${GREEN}✓ Maven 使用阿里云镜像${NC}\n"
        else
            printf "${YELLOW}⚠️  Maven 未配置国内镜像${NC}\n"
            echo "💡 建议添加阿里云镜像到 settings.xml"
        fi
    else
        printf "${YELLOW}⚠️  Maven 配置文件不存在${NC}\n"
    fi
else
    printf "${BLUE}ℹ️  Maven 未安装${NC}\n"
fi
echo ""

# ============================================
# 总结
# ============================================

printf "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}\n"
printf "${BLUE}║                    配置总结                                  ║${NC}\n"
printf "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}\n"
echo ""

printf "${GREEN}已配置的国内源:${NC}\n"
echo "  • npm: 淘宝镜像"
echo "  • pip: 清华大学镜像"
echo "  • HuggingFace: HF-Mirror"
echo ""

printf "${YELLOW}需要手动配置的:${NC}\n"
echo "  • Docker: 镜像加速"
echo "  • Go: 七牛云代理"
echo "  • Maven: 阿里云镜像"
echo ""

printf "${CYAN}使用建议:${NC}\n"
echo "  1. 新开终端使环境变量生效"
echo "  2. 或运行: source ~/.zshrc (或 source ~/.bashrc)"
echo "  3. 重新运行安装脚本确保使用国内源"
echo ""

printf "${GREEN}✓ 国内源配置检查完成！${NC}\n"
