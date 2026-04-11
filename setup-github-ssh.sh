1.#!/bin/bash
#
# GitHub SSH Key 配置脚本
# 作者: 外星动物（常智）
# 组织: IoTchange
# 邮箱: 14455975@qq.com
# 版本: V1.0.1
# 版权: Copyright (C) 2026 IoTchange - All Rights Reserved
#

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          GitHub SSH Key 配置向导                          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# 步骤 1: 检查现有密钥
echo -e "${YELLOW}步骤 1: 检查现有 SSH 密钥...${NC}"
if [ -f ~/.ssh/id_ed25519 ]; then
    echo -e "${GREEN}✅ 发现现有 SSH 密钥${NC}"
    ls -la ~/.ssh/id_ed25519*
else
    echo -e "${YELLOW}⚠️  未找到 SSH 密钥，将生成新密钥${NC}"
fi
echo ""

# 步骤 2: 显示公钥
echo -e "${YELLOW}步骤 2: 你的 SSH 公钥（请复制并添加到 GitHub）${NC}"
echo -e "${BLUE}─────────────────────────────────────────────────────────────${NC}"
cat ~/.ssh/id_ed25519.pub
echo -e "${BLUE}─────────────────────────────────────────────────────────────${NC}"
echo ""

# 步骤 3: 指导添加到 GitHub
echo -e "${YELLOW}步骤 3: 添加公钥到 GitHub${NC}"
echo ""
echo "请按以下步骤操作："
echo ""
echo "1️⃣  访问 GitHub SSH 设置页面："
echo "   https://github.com/settings/keys"
echo ""
echo "2️⃣  点击【New SSH key】或【Add SSH key】"
echo ""
echo "3️⃣  填写标题（建议：MacClaw Installer - $(date +%Y-%m-%d)）"
echo ""
echo "4️⃣  将上面的公钥粘贴到【Key】文本框中"
echo ""
echo "5️⃣  点击【Add SSH key】或【Add key】完成添加"
echo ""
echo -e "${GREEN}✅ 添加完成后，请按 Enter 继续配置...${NC}"
read
echo ""

# 步骤 4: 配置 Git
echo -e "${YELLOW}步骤 4: 配置 Git 用户信息${NC}"
echo ""
git config --global user.name "外星动物（常智）"
git config --global user.email "14455975@qq.com"
echo -e "${GREEN}✅ Git 配置完成${NC}"
echo ""

# 步骤 5: 配置 SSH
echo -e "${YELLOW}步骤 5: 配置 SSH 客户端${NC}"
echo ""
cat > ~/.ssh/config << 'EOF'
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
EOF
chmod 600 ~/.ssh/config
echo -e "${GREEN}✅ SSH 配置完成${NC}"
echo ""

# 步骤 6: 测试连接
echo -e "${YELLOW}步骤 6: 测试 GitHub SSH 连接...${NC}"
echo ""
echo "正在测试连接..."
if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no git@github.com &>/dev/null; then
    echo -e "${GREEN}✅ SSH 连接成功！${NC}"
else
    echo -e "${YELLOW}⚠️  SSH 连接失败，但密钥已配置${NC}"
    echo "可能原因："
    echo "  1. 公钥尚未添加到 GitHub"
    echo "  2. 网络连接问题"
    echo ""
    echo "请确认公钥已添加到 GitHub 后，再次运行以下命令测试："
    echo "  ssh -T git@github.com"
fi
echo ""

# 步骤 7: 配置仓库使用 SSH
echo -e "${YELLOW}步骤 7: 配置项目仓库使用 SSH${NC}"
echo ""
if [ -d "macclaw-installer/.git" ]; then
    cd macclaw-installer
    echo "配置本地仓库..."
    git remote set-url origin git@github.com:changzhi777/mactools.git
    echo -e "${GREEN}✅ 仓库已配置为使用 SSH${NC}"
    cd ..
else
    echo -e "${BLUE}💡 当你创建 GitHub 仓库后，使用以下命令配置：${NC}"
    echo "  git remote set-url origin git@github.com:changzhi777/mactools.git"
fi
echo ""

# 完成
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              🎉 SSH Key 配置完成！                          ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "常用命令："
echo ""
echo "🔍 查看 Git 配置："
echo "  git config --global --list"
echo ""
echo "🧪 测试 SSH 连接："
echo "  ssh -T git@github.com"
echo ""
echo "📤 推送到 GitHub："
echo "  git add ."
echo "  git commit -m 'commit message'"
echo "  git push"
echo ""
echo "🔄 更新本地仓库："
echo "  git pull"
echo ""
echo -e "${BLUE}📚 更多帮助：${NC}"
echo "  GitHub SSH: https://docs.github.com/zh/authentication"
echo "  SSH Keys: https://github.com/settings/keys"
echo ""
