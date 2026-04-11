#!/bin/bash
#
# 版本管理脚本 - MacTools
# 作者: 外星动物（常智）
# 组织: IoTchange
# 邮箱: 14455975@qq.com
# 版本: V1.0.1
# 版权: Copyright (C) 2026 IoTchange - All Rights Reserved
#
# 说明: 自动更新项目版本号（每次推送更新第三位数字+1）
#

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 项目根目录
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"

# 版本文件
VERSION_FILE="$PROJECT_ROOT/VERSION"
README_VERSION="$PROJECT_ROOT/README.md"

# ============================================
# 显示使用帮助
# ============================================

show_help() {
    cat << EOF
用法: $0 [选项]

选项:
  -h, --help          显示此帮助信息
  -v, --version       显示当前版本号
  -i, --increment     增加版本号（第三位数字+1）
  -s, --set VERSION   设置特定版本号
  -c, --check         检查所有文件的版本一致性
  --bump MINOR        增加次版本号（第二位数字+1）
  --bump MAJOR        增加主版本号（第一位数字+1）

示例:
  $0 --version        # 显示当前版本
  $0 --increment      # V1.0.1 -> V1.0.2
  $0 --set V1.2.3     # 设置版本为 V1.2.3
  $0 --bump MINOR     # V1.0.1 -> V1.1.0

版本规则:
  V主版本.次版本.修订版本
  - 主版本：重大架构变更
  - 次版本：功能添加或修改
  - 修订版本：Bug修复和小改进（每次推送自动+1）

EOF
}

# ============================================
# 获取当前版本号
# ============================================

get_current_version() {
    if [ -f "$VERSION_FILE" ]; then
        cat "$VERSION_FILE"
    else
        echo "V1.0.0"
    fi
}

# ============================================
# 验证版本号格式
# ============================================

validate_version() {
    local version=$1
    if [[ ! "$version" =~ ^V[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "❌ 错误: 版本号格式不正确"
        echo "   正确格式: V1.0.0"
        exit 1
    fi
}

# ============================================
# 增加版本号
# ============================================

increment_version() {
    local current_version=$(get_current_version)
    local version_type=$1

    # 移除 'V' 前缀
    local version_number=${current_version#V}

    # 分割版本号
    IFS='.' read -r major minor patch <<< "$version_number"

    case $version_type in
        "PATCH")
            ((patch++))
            ;;
        "MINOR")
            ((minor++))
            patch=0
            ;;
        "MAJOR")
            ((major++))
            minor=0
            patch=0
            ;;
        *)
            echo "❌ 错误: 未知的版本类型"
            exit 1
            ;;
    esac

    local new_version="V${major}.${minor}.${patch}"
    echo "$new_version"
}

# ============================================
# 更新版本文件
# ============================================

update_version_file() {
    local new_version=$1

    echo "$new_version" > "$VERSION_FILE"
    echo -e "${GREEN}✓ 版本文件已更新: $new_version${NC}"
}

# ============================================
# 更新 README.md
# ============================================

update_readme_version() {
    local new_version=$1

    if [ -f "$README_VERSION" ]; then
        # 更新 README 中的版本号
        sed -i '' "s/\*\*版本:\*\* V[0-9]+\.[0-9]+\.[0-9]+/**版本:** $new_version/g" "$README_VERSION"
        sed -i '' "s/\*\*Version:\*\* V[0-9]+\.[0-9]+\.[0-9]+/**Version:** $new_version/g" "$README_VERSION"
        echo -e "${GREEN}✓ README.md 已更新: $new_version${NC}"
    fi
}

# ============================================
# 更新所有脚本的版本号
# ============================================

update_script_versions() {
    local new_version=$1

    echo -e "${BLUE}更新脚本文件版本号...${NC}"

    # 更新主要脚本
    local scripts=(
        "macclaw-installer/install.sh"
        "macclaw-installer/uninstall.sh"
        "setup-github-ssh.sh"
        "tests/run_e2e_tests.sh"
    )

    for script in "${scripts[@]}"; do
        if [ -f "$script" ]; then
            sed -i '' "s/# 版本: V[0-9]+\.[0-9]+\.[0-9]+/# 版本: $new_version/g" "$script"
            echo -e "${GREEN}  ✓ $script${NC}"
        fi
    done

    # 更新库文件
    for lib_file in macclaw-installer/lib/*.sh; do
        if [ -f "$lib_file" ]; then
            sed -i '' "s/# 版本: V[0-9]+\.[0-9]+\.[0-9]+/# 版本: $new_version/g" "$lib_file"
        fi
    done

    # 更新组件脚本
    for script_file in macclaw-installer/scripts/*.sh; do
        if [ -f "$script_file" ]; then
            sed -i '' "s/# 版本: V[0-9]+\.[0-9]+\.[0-9]+/# 版本: $new_version/g" "$script_file"
        fi
    done
}

# ============================================
# 检查版本一致性
# ============================================

check_version_consistency() {
    local current_version=$(get_current_version)
    echo -e "${BLUE}检查版本一致性...${NC}"
    echo "当前版本: $current_version"
    echo ""

    local inconsistent_files=()

    # 检查所有脚本文件
    while IFS= read -r -d '' file; do
        if grep -q "# 版本:" "$file"; then
            local file_version=$(grep "# 版本:" "$file" | head -1 | sed 's/.*版本: //')
            if [ "$file_version" != "$current_version" ]; then
                inconsistent_files+=("$file: $file_version")
            fi
        fi
    done < <(find . -name "*.sh" -type f -print0)

    if [ ${#inconsistent_files[@]} -eq 0 ]; then
        echo -e "${GREEN}✓ 所有文件版本一致${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠ 发现版本不一致的文件:${NC}"
        for file in "${inconsistent_files[@]}"; do
            echo "  - $file"
        done
        return 1
    fi
}

# ============================================
# 显示版本变更
# ============================================

show_version_change() {
    local old_version=$1
    local new_version=$2

    echo ""
    echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║          版本变更                        ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "旧版本: ${YELLOW}$old_version${NC}"
    echo -e "新版本: ${GREEN}$new_version${NC}"
    echo ""
}

# ============================================
# 创建 Git 提交
# ============================================

create_commit() {
    local new_version=$1

    echo ""
    read -p "是否创建 Git 提交？(y/n) " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git add .
        git commit -m "chore: 版本更新至 $new_version

- 更新所有脚本文件版本号
- 更新 README.md 版本信息
- 版本规则: V主版本.次版本.修订版本
- 修订版本: Bug修复和小改进

作者: 外星动物（常智）
组织: IoTchange
邮箱: 14455975@qq.com"

        echo -e "${GREEN}✓ Git 提交已创建${NC}"

        read -p "是否推送到 GitHub？(y/n) " -n 1 -r
        echo

        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git push
            echo -e "${GREEN}✓ 已推送到 GitHub${NC}"
        fi
    fi
}

# ============================================
# 主函数
# ============================================

main() {
    local current_version=$(get_current_version)
    local new_version=""
    local version_type="PATCH"

    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--version)
                echo "$current_version"
                exit 0
                ;;
            -i|--increment)
                new_version=$(increment_version "PATCH")
                shift
                ;;
            -s|--set)
                new_version="$2"
                validate_version "$new_version"
                shift 2
                ;;
            -c|--check)
                check_version_consistency
                exit $?
                ;;
            --bump)
                version_type="$2"
                new_version=$(increment_version "$version_type")
                shift 2
                ;;
            *)
                echo "未知选项: $1"
                show_help
                exit 1
                ;;
        esac
    done

    # 如果没有指定新版本，默认增加修订版本
    if [ -z "$new_version" ]; then
        new_version=$(increment_version "PATCH")
    fi

    # 显示版本变更
    show_version_change "$current_version" "$new_version"

    # 更新所有文件
    update_version_file "$new_version"
    update_readme_version "$new_version"
    update_script_versions "$new_version"

    echo ""
    echo -e "${GREEN}✓ 版本更新完成: $new_version${NC}"
    echo ""

    # 询问是否创建提交
    create_commit "$new_version"
}

# 运行主函数
main "$@"
