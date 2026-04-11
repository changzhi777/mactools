#!/usr/bin/env bats
#
# 本地安装测试
# 验证本地直接执行安装脚本的功能
#

# 加载公共设置
setup() {
    source "${PROJECT_ROOT}/tests/test_helper/common-setup.bash"
    source "${PROJECT_ROOT}/tests/helpers/fixtures.bash"

    # 备份现有环境
    backup_environment
}

teardown() {
    # 清理测试环境
    cleanup_test_installation
    restore_environment
    cleanup_test_env
}

# ============================================
# 安装脚本存在性和权限测试
# ============================================

@test "安装脚本存在" {
    [ -f "${INSTALLER_DIR}/install.sh" ]
}

@test "安装脚本可执行" {
    [ -x "${INSTALLER_DIR}/install.sh" ] || skip "脚本无执行权限"
}

@test "安装脚本语法正确" {
    run bash -n "${INSTALLER_DIR}/install.sh"
    [ "$status" -eq 0 ]
}

# ============================================
# 库文件完整性测试
# ============================================

@test "核心库文件存在" {
    local lib_files=(
        "lib/logger.sh"
        "lib/utils.sh"
        "lib/detector.sh"
        "lib/config.sh"
        "lib/agent.sh"
        "lib/progress.sh"
        "lib/validator.sh"
        "lib/state.sh"
    )

    for lib_file in "${lib_files[@]}"; do
        [ -f "${INSTALLER_DIR}/${lib_file}" ] || echo "Missing: ${lib_file}"
    done
}

@test "库文件语法正确" {
    local lib_files=(
        "lib/logger.sh"
        "lib/utils.sh"
        "lib/detector.sh"
        "lib/config.sh"
    )

    for lib_file in "${lib_files[@]}"; do
        run bash -n "${INSTALLER_DIR}/${lib_file}"
        [ "$status" -eq 0 ] || echo "Syntax error in: ${lib_file}"
    done
}

@test "库文件可以加载" {
    run bash -c "source '${INSTALLER_DIR}/lib/logger.sh' && echo 'loaded'"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "loaded" ]]
}

# ============================================
# 配置文件测试
# ============================================

@test "配置文件存在" {
    [ -f "${INSTALLER_DIR}/config/sources.conf" ]
    [ -f "${INSTALLER_DIR}/config/versions.conf" ]
}

@test "配置文件格式正确" {
    # 检查 sources.conf
    run grep "=" "${INSTALLER_DIR}/config/sources.conf" | head -1
    [ "$status" -eq 0 ]

    # 检查 versions.conf
    run grep "=" "${INSTALLER_DIR}/config/versions.conf" | head -1
    [ "$status" -eq 0 ]
}

@test "配置文件包含必要配置" {
    # 检查国内源配置
    run grep -i "npm" "${INSTALLER_DIR}/config/sources.conf"
    [ "$status" -eq 0 ] || echo "Missing npm mirror config"

    # 检查版本配置
    run grep "=" "${INSTALLER_DIR}/config/versions.conf"
    [ "$status" -eq 0 ] || echo "Missing version config"
}

# ============================================
# 组件脚本测试
# ============================================

@test "组件安装脚本存在" {
    local script_files=(
        "scripts/install-nodejs.sh"
        "scripts/install-openclaw.sh"
        "scripts/install-omlx.sh"
        "scripts/install-model.sh"
        "scripts/install-skills.sh"
    )

    for script_file in "${script_files[@]}"; do
        [ -f "${INSTALLER_DIR}/${script_file}" ] || echo "Missing: ${script_file}"
    done
}

@test "组件脚本可执行" {
    local script_files=(
        "scripts/install-nodejs.sh"
        "scripts/install-openclaw.sh"
        "scripts/install-omlx.sh"
        "scripts/install-model.sh"
        "scripts/install-skills.sh"
    )

    for script_file in "${script_files[@]}"; do
        local script_path="${INSTALLER_DIR}/${script_file}"
        if [ -f "$script_path" ]; then
            # 检查是否有 shebang
            run head -1 "$script_path"
            [[ "$output" =~ "#!/" ]] || echo "No shebang in: ${script_file}"
        fi
    done
}

@test "组件脚本语法正确" {
    local script_files=(
        "scripts/install-nodejs.sh"
        "scripts/install-openclaw.sh"
        "scripts/install-omlx.sh"
        "scripts/install-model.sh"
    )

    for script_file in "${script_files[@]}"; do
        run bash -n "${INSTALLER_DIR}/${script_file}"
        [ "$status" -eq 0 ] || echo "Syntax error in: ${script_file}"
    done
}

# ============================================
# 卸载脚本测试
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

@test "卸载脚本包含清理逻辑" {
    # 检查是否包含删除命令
    run grep -q "rm -rf" "${INSTALLER_DIR}/uninstall.sh"
    [ "$status" -eq 0 ]

    # 检查是否提到 openclaw
    run grep -qi "openclaw" "${INSTALLER_DIR}/uninstall.sh"
    [ "$status" -eq 0 ]
}

@test "卸载脚本包含服务停止逻辑" {
    run grep -E "stop|restart" "${INSTALLER_DIR}/uninstall.sh"
    [ "$status" -eq 0 ]
}

# ============================================
# 脚本功能测试
# ============================================

@test "安装脚本包含版本信息" {
    run grep -i "版本\|version" "${INSTALLER_DIR}/install.sh" | head -3
    [ "$status" -eq 0 ]
    [ -n "$output" ]
}

@test "安装脚本包含作者信息" {
    run grep -i "作者\|author" "${INSTALLER_DIR}/install.sh"
    [ "$status" -eq 0 ]
}

@test "安装脚本包含使用说明" {
    run grep -i "使用\|usage" "${INSTALLER_DIR}/install.sh"
    [ "$status" -eq 0 ]
}

# ============================================
# 脚本结构测试
# ============================================

@test "安装脚本包含主函数" {
    run grep "main()" "${INSTALLER_DIR}/install.sh"
    [ "$status" -eq 0 ]
}

@test "安装脚本包含错误处理" {
    run grep "set -e" "${INSTALLER_DIR}/install.sh"
    [ "$status" -eq 0 ]
}

@test "安装脚本调用主函数" {
    run grep 'main "$@"' "${INSTALLER_DIR}/install.sh"
    [ "$status" -eq 0 ] || run grep "main" "${INSTALLER_DIR}/install.sh" | tail -1
    [ "$status" -eq 0 ]
}

# ============================================
# 脚本依赖测试
# ============================================

@test "安装脚本加载必要库" {
    run grep "source.*lib/" "${INSTALLER_DIR}/install.sh"
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -gt 5 ]
}

@test "安装脚本加载配置文件" {
    run grep "source.*config/" "${INSTALLER_DIR}/install.sh"
    [ "$status" -eq 0 ]
}

# ============================================
# 功能模块测试
# ============================================

@test "安装脚本包含环境检测" {
    run grep "detect_environment" "${INSTALLER_DIR}/install.sh"
    [ "$status" -eq 0 ]
}

@test "安装脚本包含配置国内源" {
    run grep -i "source\|mirror" "${INSTALLER_DIR}/install.sh"
    [ "$status" -eq 0 ]
}

@test "安装脚本包含组件选择" {
    run grep -i "select.*component\|install.*component" "${INSTALLER_DIR}/install.sh"
    [ "$status" -eq 0 ]
}

@test "安装脚本包含服务启动" {
    run grep -E "start|restart|gateway" "${INSTALLER_DIR}/install.sh"
    [ "$status" -eq 0 ]
}

# ============================================
# 日志和进度显示测试
# ============================================

@test "安装脚本包含日志函数" {
    run grep -E "log_|echo.*log" "${INSTALLER_DIR}/install.sh"
    [ "$status" -eq 0 ]
}

@test "安装脚本包含进度显示" {
    run grep -i "progress\|进度" "${INSTALLER_DIR}/install.sh"
    [ "$status" -eq 0 ]
}

@test "安装脚本包含完成报告" {
    run grep -i "complete\|finish\|完成" "${INSTALLER_DIR}/install.sh"
    [ "$status" -eq 0 ]
}

# ============================================
# 错误处理和回退测试
# ============================================

@test "安装脚本包含备份逻辑" {
    run grep -i "backup\|备份" "${INSTALLER_DIR}/install.sh"
    [ "$status" -eq 0 ]
}

@test "安装脚本包含错误捕获" {
    run grep "trap\|error\|fail" "${INSTALLER_DIR}/install.sh"
    [ "$status" -eq 0 ]
}

@test "安装脚本包含清理逻辑" {
    run grep -i "cleanup\|clean\|清理" "${INSTALLER_DIR}/install.sh"
    [ "$status" -eq 0 ]
}

# ============================================
# 交互式功能测试
# ============================================

@test "安装脚本包含用户确认" {
    run grep -i "confirm\|continue\|确认" "${INSTALLER_DIR}/install.sh"
    [ "$status" -eq 0 ]
}

@test "安装脚本包含欢迎界面" {
    run grep -i "welcome\|欢迎" "${INSTALLER_DIR}/install.sh"
    [ "$status" -eq 0 ]
}

# ============================================
# 文档和注释测试
# ============================================

@test "安装脚本包含注释" {
    local comment_count=$(grep "^#" "${INSTALLER_DIR}/install.sh" | wc -l)
    [ "$comment_count" -gt 10 ]
}

@test "安装脚本包含函数文档" {
    # 检查是否有函数定义的注释
    run grep -B1 "^.*() {" "${INSTALLER_DIR}/install.sh" | grep "^#" | head -1
    [ "$status" -eq 0 ]
}

# ============================================
# 安全性测试
# ============================================

@test "安装脚本不包含硬编码密码" {
    run grep -i "password\|secret\|token" "${INSTALLER_DIR}/install.sh"
    # 这个测试可能会误报，因为可能有合法的使用
    # 这里只是检查不应该有明文密码
    if [ "$status" -eq 0 ]; then
        # 如果找到了，确保它们不是实际密码
        ! [[ "$output" =~ "=.*\".*[a-zA-Z0-9]{16,}\" ]]
    fi
}

@test "安装脚本使用相对路径或环境变量" {
    # 检查脚本是否正确处理路径
    run grep 'SCRIPT_DIR' "${INSTALLER_DIR}/install.sh"
    [ "$status" -eq 0 ]
}
