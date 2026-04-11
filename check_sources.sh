#!/bin/bash
#
# 国内源配置检查和修复脚本
# 作者: 外星动物（常智）
# 组织: IoTchange
# 邮箱: 14455975@qq.com
# 版本: V1.0.1
# 版权: Copyright (C) 2026 IoTchange - All Rights Reserved
#
# 说明: 检查并修复所有下载源为国内镜像
#

set -e

# 获取脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 加载统一颜色库
if [ -f "$SCRIPT_DIR/macclaw-installer/lib/colors.sh" ]; then
    source "$SCRIPT_DIR/macclaw-installer/lib/colors.sh"
else
    # 后备颜色定义
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    NC='\033[0m'
fi

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          国内源配置检查与修复                              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# ============================================
# 1. npm 源检查
# ============================================

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  1. npm 源检查${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

current_npm=$(npm config get registry)
echo "当前 npm 源: $current_npm"

if [[ "$current_npm" =~ "npmmirror" ]]; then
    echo -e "${GREEN}✓ npm 使用国内淘宝镜像${NC}"
else
    echo -e "${YELLOW}⚠️  npm 未使用国内源，正在配置...${NC}"
    npm config set registry https://registry.npmmirror.com
    echo -e "${GREEN}✓ npm 已切换到淘宝镜像${NC}"
fi

# 验证配置
new_npm=$(npm config get registry)
echo "配置后 npm 源: $new_npm"
echo ""

# ============================================
# 2. pip 源检查
# ============================================

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  2. pip 源检查${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ -f ~/.pip/pip.conf ]; then
    current_pip=$(grep "index-url" ~/.pip/pip.conf | awk '{print $3}')
    echo "当前 pip 源: $current_pip"

    if [[ "$current_pip" =~ "tsinghua" ]]; then
        echo -e "${GREEN}✓ pip 使用清华镜像${NC}"
    else
        echo -e "${YELLOW}⚠️  pip 配置存在但未使用清华源${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  pip 配置文件不存在，正在创建...${NC}"
    mkdir -p ~/.pip

    cat > ~/.pip/pip.conf << 'EOF'
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
trusted-host = pypi.tuna.tsinghua.edu.cn
EOF

    echo -e "${GREEN}✓ pip 已配置清华镜像${NC}"
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

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  3. Git 源检查${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# 检查是否有 nvm
if [ -d ~/.nvm ]; then
    echo "检测到 nvm 安装"

    # 检查 nvm 安装源配置
    if [ -f ~/.nvm/install.sh ]; then
        if grep -q "gitee.com/mirrors/nvm" ~/.nvm/install.sh 2>/dev/null; then
            echo -e "${GREEN}✓ nvm 使用 Gitee 镜像${NC}"
        else
            echo -e "${YELLOW}⚠️  nvm 未配置 Gitee 镜像${NC}"
            echo "💡 建议使用 Gitee 镜像安装 nvm:"
            echo "   export NVM_SOURCE=https://gitee.com/mirrors/nvm.git"
            echo "   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash"
        fi
    fi
else
    echo -e "${BLUE}ℹ️  nvm 未安装${NC}"
fi
echo ""

# ============================================
# 4. Docker 源检查（如果安装）
# ============================================

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  4. Docker 源检查${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if command -v docker &>/dev/null; then
    echo "检测到 Docker 安装"

    # 检查 Docker 镜像
    if [ -f /etc/docker/daemon.json ]; then
        if grep -q "registry-mirrors" /etc/docker/daemon.json 2>/dev/null; then
            echo -e "${GREEN}✓ Docker 配置了镜像加速${NC}"
            echo "当前镜像配置:"
            grep -A 5 "registry-mirrors" /etc/docker/daemon.json 2>/dev/null || true
        else
            echo -e "${YELLOW}⚠️  Docker 未配置镜像加速${NC}"
            echo "💡 建议配置国内镜像源:"
            echo "   阿里云: https://cr.console.aliyun.com"
            echo "   腾讯云: https://cloud.tencent.com/act/mirror"
            echo "   网易云: https://mirror.ccs.tencentyun.com"
        fi
    else
        echo -e "${YELLOW}⚠️  Docker 配置文件不存在${NC}"
    fi
else
    echo -e "${BLUE}ℹ️  Docker 未安装${NC}"
fi
echo ""

# ============================================
# 5. HuggingFace 镜像检查
# ============================================

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  5. HuggingFace 镜像检查${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ -n "$HF_ENDPOINT" ]; then
    echo "当前 HF_ENDPOINT: $HF_ENDPOINT"

    if [[ "$HF_ENDPOINT" =~ "hf-mirror" ]]; then
        echo -e "${GREEN}✓ 使用 HF 国内镜像${NC}"
    else
        echo -e "${YELLOW}⚠️  HF_ENDPOINT 未指向国内镜像${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  HF_ENDPOINT 环境变量未设置${NC}"
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
        echo -e "${GREEN}✓ HF_ENDPOINT 已添加到 $shell_config${NC}"
    fi

    echo -e "${GREEN}✓ HuggingFace 镜像已配置${NC}"
fi
echo ""

# ============================================
# 6. Go 源检查（如果安装）
# ============================================

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  6. Go 源检查${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if command -v go &>/dev/null; then
    echo "检测到 Go 安装"

    # 检查 Go Proxy
    if [ -n "$GOPROXY" ]; then
        echo "当前 GOPROXY: $GOPROXY"

        if [[ "$GOPROXY" =~ "cn" ]] || [[ "$GOPROXY" =~ "goproxy" ]]; then
            echo -e "${GREEN}✓ Go 使用国内代理${NC}"
        else
            echo -e "${YELLOW}⚠️  GOPROXY 未指向国内源${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  GOPROXY 环境变量未设置${NC}"
        echo "💡 建议配置七牛云 Go 国内代理:"
        echo "   export GOPROXY=https://goproxy.cn,direct"
        echo "   export GOSUMDB=sum.golang.google.cn"
    fi
else
    echo -e "${BLUE}ℹ️  Go 未安装${NC}"
fi
echo ""

# ============================================
# 7. Maven 源检查（如果安装）
# ============================================

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  7. Maven 源检查${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if command -v mvn &>/dev/null; then
    echo "检测到 Maven 安装"

    # 检查 settings.xml
    maven_settings="$HOME/.m2/settings.xml"
    if [ -f "$maven_settings" ]; then
        if grep -q "aliyun" "$maven_settings" 2>/dev/null; then
            echo -e "${GREEN}✓ Maven 使用阿里云镜像${NC}"
        else
            echo -e "${YELLOW}⚠️  Maven 未配置国内镜像${NC}"
            echo "💡 建议添加阿里云镜像到 settings.xml"
        fi
    else
        echo -e "${YELLOW}⚠️  Maven 配置文件不存在${NC}"
    fi
else
    echo -e "${BLUE}ℹ️  Maven 未安装${NC}"
fi
echo ""

# ============================================
# 总结
# ============================================

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    配置总结                                  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${GREEN}已配置的国内源:${NC}"
echo -e "  • npm: 淘宝镜像"
echo -e "  • pip: 清华大学镜像"
echo -e "  • HuggingFace: HF-Mirror"
echo ""

echo -e "${YELLOW}需要手动配置的:${NC}"
echo -e "  • Docker: 镜像加速"
echo -e "  • Go: 七牛云代理"
echo -e "  • Maven: 阿里云镜像"
echo ""

echo -e "${CYAN}使用建议:${NC}"
echo "  1. 新开终端使环境变量生效"
echo "  2. 或运行: source ~/.zshrc (或 source ~/.bashrc)"
echo "  3. 重新运行安装脚本确保使用国内源"
echo ""

echo -e "${GREEN}✓ 国内源配置检查完成！${NC}"
