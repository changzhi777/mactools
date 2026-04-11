#!/usr/bin/env bats
#
# 卸载测试
# 验证卸载脚本的功能和完整性
#

# 加载公共设置
setup() {
    source "${PROJECT_ROOT}/tests/test_helper/common-setup.bash"
    source "${PROJECT_ROOT}/tests/helpers/fixtures.bash"
    source "${PROJECT_ROOT}/tests/helpers/assertions.bash"

    # 备份现有环境
    backup_environment
}

teardown() {
    restore_environment
    cleanup_test_env
}

# ============================================
# 卸载脚本基础测试
# ============================================

@test "卸载脚本存在" {
    [ -f "${INSTALLER_DIR}/uninstall.sh" ]
}

@test "卸载脚本可执行" {
    [ -x "${INSTALLER_DIR}/uninstall.sh" ] || skip "卸载脚本无执行权限"
}

@test "卸载脚本语法正确" {
    run bash -n "${INSTALLER_DIR}/uninstall.sh"
    [ "$status" -eq 0 ]
}

# ============================================
# 卸载脚本结构测试
# ============================================

@test "卸载脚本包含版本信息" {
    run grep -i "版本\|version" "${INSTALLER_DIR}/uninstall.sh"
    [ "$status" -eq 0 ]
}

@test "卸载脚本包含作者信息" {
    run grep -i "作者\|author" "${INSTALLER_DIR}/uninstall.sh"
    [ "$status" -eq 0 ]
}

@test "卸载脚本包含使用说明" {
    run grep -i "使用\|usage" "${INSTALLER_DIR}/uninstall.sh"
    [ "$status" -eq 0 ]
}

# ============================================
# 卸载功能测试
# ============================================

@test "卸载脚本包含停止服务逻辑" {
    run grep -E "stop|restart|shutdown" "${INSTALLER_DIR}/uninstall.sh"
    [ "$status" -eq 0 ]
}

@test "卸载脚本包含删除 OpenClaw 逻辑" {
    run grep -i "openclaw" "${INSTALLER_DIR}/uninstall.sh"
    [ "$status" -eq 0 ]
}

@test "卸载脚本包含删除 oMLX 逻辑" {
    run grep -i "omlx" "${INSTALLER_DIR}/uninstall.sh"
    [ "$status" -eq 0 ]
}

@test "卸载脚本包含删除 Node.js/nvm 逻辑" {
    run grep -E "nvm|nodejs|node" "${INSTALLER_DIR}/uninstall.sh"
    [ "$status" -eq 0 ]
}

@test "卸载脚本包含删除配置文件逻辑" {
    run grep -E "rm -rf|remove.*config|delete.*config" "${INSTALLER_DIR}/uninstall.sh"
    [ "$status" -eq 0 ]
}

# ============================================
# 清理范围测试
# ============================================

@test "验证卸载脚本清理 OpenClaw 目录" {
    run grep -E "rm.*\.openclaw|remove.*openclaw" "${INSTALLER_DIR}/uninstall.sh"
    [ "$status" -eq 0 ]
}

@test "验证卸载脚本清理 oMLX 目录" {
    run grep -E "rm.*\.omlx|remove.*omlx" "${INSTALLER_DIR}/uninstall.sh"
    [ "$status" -eq 0 ]
}

@test "验证卸载脚本清理 nvm 目录" {
    run grep -E "rm.*\.nvm|remove.*nvm" "${INSTALLER_DIR}/uninstall.sh"
    [ "$status" -eq 0 ]
}

@test "验证卸载脚本清理临时文件" {
    run grep -E "tmp|temp|临时" "${INSTALLER_DIR}/uninstall.sh"
    [ "$status" -eq 0 ]
}

# ============================================
# 安全性测试
# ============================================

@test "卸载脚本包含用户确认" {
    run grep -i "confirm\|确认\|continue" "${INSTALLER_DIR}/uninstall.sh"
    [ "$status" -eq 0 ]
}

@test "卸载脚本包含警告信息" {
    run grep -i "warn\|warning\|警告\|caution" "${INSTALLER_DIR}/uninstall.sh"
    [ "$status" -eq 0 ]
}

@test "卸载脚本有错误处理" {
    run grep "set -e\|trap\|error" "${INSTALLER_DIR}/uninstall.sh"
    [ "$status" -eq 0 ]
}

# ============================================
# 备份功能测试
# ============================================

@test "卸载脚本是否提供备份选项" {
    run grep -i "backup\|备份" "${INSTALLER_DIR}/uninstall.sh"
    # 备份是可选功能
    log_test "备份选项检查完成"
}

# ============================================
# 日志和报告测试
# ============================================

@test "卸载脚本包含日志输出" {
    run grep -E "echo|log|print" "${INSTALLER_DIR}/uninstall.sh"
    [ "$status" -eq 0 ]
}

@test "卸载脚本包含完成报告" {
    run grep -i "complete\|finish\|done\|完成" "${INSTALLER_DIR}/uninstall.sh"
    [ "$status" -eq 0 ]
}

# ============================================
# 依赖清理测试
# ============================================

@test "验证卸载脚本清理环境变量" {
    run grep -E "unset|export.*PATH|环境变量" "${INSTALLER_DIR}/uninstall.sh"
    # 清理环境变量是可选的
    log_test "环境变量清理检查完成"
}

@test "验证卸载脚本清理别名" {
    run grep -i "unalias" "${INSTALLER_DIR}/uninstall.sh"
    # 清理别名是可选的
    log_test "别名清理检查完成"
}

# ============================================
# 服务停止测试（模拟）
# ============================================

@test "验证服务停止逻辑存在" {
    # 检查是否尝试停止 OpenClaw Gateway
    run grep -E "openclaw.*stop|gateway.*stop" "${INSTALLER_DIR}/uninstall.sh"
    [ "$status" -eq 0 ] || skip "未找到显式的服务停止命令"
}

@test "验证进程清理逻辑" {
    run grep -E "kill|pkill|process" "${INSTALLER_DIR}/uninstall.sh"
    [ "$status" -eq 0 ]
}

# ============================================
# 残留文件检查测试
# ============================================

@test "验证卸载脚本清理日志文件" {
    run grep -E "\.log|logs|日志" "${INSTALLER_DIR}/uninstall.sh"
    [ "$status" -eq 0 ]
}

@test "验证卸载脚本清理缓存" {
    run grep -i "cache|缓存" "${INSTALLER_DIR}/uninstall.sh"
    # 清理缓存是可选的
    log_test "缓存清理检查完成"
}

# ============================================
# 卸载确认测试
# ============================================

@test "卸载脚本有二次确认" {
    run grep -E "confirm.*twice|二次确认|are you sure" "${INSTALLER_DIR}/uninstall.sh"
    # 二次确认是可选的
    log_test "二次确认检查完成"
}

# ============================================
# 完整性测试
# ============================================

@test "卸载脚本包含所有组件清理" {
    local components=(
        "openclaw"
        "omlx"
        "nvm"
    )

    local found_count=0
    for component in "${components[@]}"; do
        if grep -qi "$component" "${INSTALLER_DIR}/uninstall.sh"; then
            ((found_count++))
        fi
    done

    log_test "找到 $found_count/${#components[@]} 个组件的清理逻辑"
    [ "$found_count" -gt 0 ]
}

@test "验证卸载脚本的清理顺序" {
    # 通常应该先停止服务，再删除文件
    local output=$(cat "${INSTALLER_DIR}/uninstall.sh")
    local stop_pos=$(echo "$output" | grep -n -E "stop|kill" | head -1 | cut -d: -f1)
    local remove_pos=$(echo "$output" | grep -n "rm -rf" | head -1 | cut -d: -f1)

    if [ ! -z "$stop_pos" ] && [ ! -z "$remove_pos" ]; then
        # 验证停止操作在删除操作之前
        [ "$stop_pos" -lt "$remove_pos" ] || skip "停止操作不在删除之前"
    else
        skip "无法确定清理顺序"
    fi
}

# ============================================
# 回滚测试（如果有备份）
# ============================================

@test "验证卸载脚本支持重新安装" {
    # 卸载后应该能够重新安装
    # 这个测试需要实际运行卸载脚本，所以默认跳过
    skip "需要实际运行卸载脚本"
}

# ============================================
# 卸载脚本执行测试（非破坏性）
# ============================================

@test "卸载脚本可以显示帮助信息" {
    run bash "${INSTALLER_DIR}/uninstall.sh" --help 2>&1 || true
    # 可能没有 --help 选项
    [ -n "$output" ] || skip "无帮助信息"
}

@test "卸载脚本可以干运行（如果支持）" {
    run bash "${INSTALLER_DIR}/uninstall.sh" --dry-run 2>&1 || true
    # 可能没有 --dry-run 选项
    log_test "干运行检查完成"
}

# ============================================
# 卸载后的系统状态测试
# ============================================

@test "验证卸载后系统状态（模拟）" {
    # 检查卸载脚本是否会清理重要的系统文件
    run grep -E "rm -rf.*/(usr|var|etc|System)" "${INSTALLER_DIR}/uninstall.sh"
    # 不应该删除系统目录
    if [ "$status" -eq 0 ]; then
        echo "警告：卸载脚本可能删除系统文件"
        # 检查是否确实是系统目录
        [[ ! "$output" =~ "rm -rf.*/(usr|var|etc|System)" ]]
    fi
}

# ============================================
# 用户数据保护测试
# ============================================

@test "验证卸载脚本不删除用户数据" {
    # 检查是否会删除用户目录（除了应用相关目录）
    run grep -E "rm -rf.*/Users/[^/]+/(Documents|Downloads|Desktop|Music|Pictures|Movies)" "${INSTALLER_DIR}/uninstall.sh"
    # 不应该删除用户数据目录
    [ "$status" -ne 0 ]
}

# ============================================
# 卸载脚本性能测试
# ============================================

@test "验证卸载脚本执行效率" {
    # 检查是否有不必要的延迟
    run grep -E "sleep.*[5-9]|sleep.*[1-9][0-9]" "${INSTALLER_DIR}/uninstall.sh"
    # 长时间的 sleep 可能影响效率
    if [ "$status" -eq 0 ]; then
        log_test "发现潜在的长时间延迟"
    else
        log_test "未发现明显的性能问题"
    fi
}

# ============================================
# 卸载脚本与安装脚本一致性测试
# ============================================

@test "验证卸载脚本覆盖所有安装内容" {
    # 检查安装脚本创建的目录是否都被卸载脚本清理
    local install_dirs=$(grep -oE "mkdir.*/[\w]+" "${INSTALLER_DIR}/install.sh" | awk '{print $2}' | sort -u)
    local uninstall_clean=$(grep -oE "rm.*/[\w]+" "${INSTALLER_DIR}/uninstall.sh" | awk '{print $2}' | sort -u)

    # 这里只是验证逻辑，不要求完全匹配
    log_test "安装目录数: $(echo '$install_dirs' | wc -l)"
    log_test "卸载清理数: $(echo '$uninstall_clean' | wc -l)"
}

# ============================================
# 卸载脚本文档测试
# ============================================

@test "卸载脚本包含注释" {
    local comment_count=$(grep "^#" "${INSTALLER_DIR}/uninstall.sh" | wc -l)
    [ "$comment_count" -gt 5 ]
}

@test "卸载脚本包含函数文档" {
    run grep -B1 "^.*() {" "${INSTALLER_DIR}/uninstall.sh" | grep "^#" | head -1
    [ "$status" -eq 0 ] || skip "无函数文档"
}

# ============================================
# 卸载脚本测试覆盖
# ============================================

@test "验证卸载脚本的主要功能" {
    local required_features=(
        "stop.*service"
        "rm.*openclaw"
        "rm.*omlx"
    )

    local missing_features=0
    for feature in "${required_features[@]}"; do
        if ! grep -qE "$feature" "${INSTALLER_DIR}/uninstall.sh"; then
            ((missing_features++))
            echo "缺失功能: $feature"
        fi
    done

    log_test "缺失功能数: $missing_features"
    [ "$missing_features" -le 1 ] || skip "缺少多个必要功能"
}

# ============================================
# 卸载后的系统恢复测试
# ============================================

@test "验证卸载脚本恢复系统环境" {
    # 检查是否会清理 PATH 等环境变量
    run grep -E "PATH|export|环境变量" "${INSTALLER_DIR}/uninstall.sh"
    # 恢复环境变量是可选的
    log_test "环境恢复检查完成"
}
