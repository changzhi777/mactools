#!/usr/bin/env bats
#
# 环境检测测试
# 验证系统环境是否满足安装要求
#

# 加载公共设置
setup() {
    source "${PROJECT_ROOT}/tests/test_helper/common-setup.bash"
    source "${PROJECT_ROOT}/tests/helpers/fixtures.bash"
}

teardown() {
    cleanup_test_env
}

# ============================================
# macOS 系统检测
# ============================================

@test "检测 macOS 版本" {
    run get_macos_version
    [ "$status" -eq 0 ]
    [ -n "$output" ]

    # 验证版本格式 (例如: 12.0, 13.5, 14.0)
    [[ "$output" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]
}

@test "检测 macOS 主版本号" {
    run get_macos_version_major
    [ "$status" -eq 0 ]
    [ -n "$output" ]

    # 主版本号应该是数字
    [[ "$output" =~ ^[0-9]+$ ]]

    # macOS 12+ (Monterey 或更高)
    [ "$output" -ge 12 ]
}

@test "检测系统架构" {
    run get_system_arch
    [ "$status" -eq 0 ]
    [ -n "$output" ]

    # 应该是 arm64 (Apple Silicon) 或 x86_64 (Intel)
    [[ "$output" =~ ^(arm64|x86_64)$ ]]
}

@test "验证系统架构兼容性" {
    run get_system_arch
    [ "$status" -eq 0 ]

    if [[ "$output" == "arm64" ]]; then
        # Apple Silicon (M1/M2/M3)
        log_test "检测到 Apple Silicon 架构"
    elif [[ "$output" == "x86_64" ]]; then
        # Intel Mac
        log_test "检测到 Intel 架构"
    else
        echo "不支持的架构: $output"
        return 1
    fi
}

# ============================================
# 磁盘空间检测
# ============================================

@test "检测磁盘可用空间" {
    run get_available_disk_space
    [ "$status" -eq 0 ]
    [ -n "$output" ]

    # 输出应该包含数字和单位 (例如: 50G, 100G, 200G)
    [[ "$output" =~ ^[0-9]+[A-Z]+$ ]]
}

@test "验证磁盘空间满足要求" {
    # 至少需要 20GB 可用空间
    local required_space=20

    run get_available_disk_space_gb
    [ "$status" -eq 0 ]

    local available_space=${output//[^0-9.]/}

    if (( $(echo "$available_space < $required_space" | bc -l) )); then
        echo "磁盘空间不足: ${available_space}G 可用，需要 ${required_space}G"
        return 1
    fi

    log_test "磁盘空间充足: ${available_space}G 可用"
}

# ============================================
# 依赖工具检测
# ============================================

@test "检测 curl 工具" {
    command_exists curl
    run curl --version
    [ "$status" -eq 0 ]
}

@test "检测 git 工具" {
    command_exists git
    run git --version
    [ "$status" -eq 0 ]
}

@test "检测 bash 版本" {
    command_exists bash
    run bash --version
    [ "$status" -eq 0 ]
    [[ "$output" =~ "version" ]]
}

@test "检测常用系统工具" {
    # 检查一些常用的系统命令
    command_exists ls
    command_exists cd
    command_exists mkdir
    command_exists rm
    command_exists cp
    command_exists grep
    command_exists awk
    command_exists sed
}

# ============================================
# 网络连接检测
# ============================================

@test "检测网络连接" {
    run check_internet_connection
    # 如果网络不可用，测试会失败但不会中断整个测试套件
    if [ "$status" -ne 0 ]; then
        skip "网络连接不可用"
    fi
}

@test "检测 GitHub 访问性" {
    run get_github_raw_status
    [ "$status" -eq 0 ]

    # 应该返回 200 或 301/302 (重定向)
    [[ "$output" =~ ^(200|301|302)$ ]] || skip "GitHub 访问失败"
}

# ============================================
# 用户权限检测
# ============================================

@test "检测用户主目录可写" {
    [ -w "$HOME" ]
}

@test "检测 /tmp 目录可写" {
    [ -w "/tmp" ]

    # 尝试创建测试文件
    local test_file="/tmp/bats_test_$$.tmp"
    touch "$test_file"
    [ -f "$test_file" ]
    rm "$test_file"
}

@test "检测创建目录权限" {
    local test_dir="${TEST_TEMP_DIR}/permission_test"
    mkdir -p "$test_dir"
    [ -d "$test_dir" ]
    [ -w "$test_dir" ]
}

# ============================================
# 内存检测 (可选)
# ============================================

@test "检测系统内存" {
    run vm_stat | head -1
    [ "$status" -eq 0 ]
}

@test "验证内存满足建议要求" {
    # 建议至少 16GB 内存
    local memory_gb=$(sysctl -n hw.memsize 2>/dev/null)
    memory_gb=$((memory_gb / 1024 / 1024 / 1024))

    log_test "系统内存: ${memory_gb}GB"

    # 这只是一个警告，不是硬性要求
    if [ $memory_gb -lt 16 ]; then
        echo "警告: 内存小于建议的 16GB，可能影响性能"
    fi
}

# ============================================
# 环境变量检测
# ============================================

@test "检测 PATH 环境变量" {
    [ -n "$PATH" ]
    [[ "$PATH" =~ .*:.* ]]
}

@test "检测 HOME 环境变量" {
    [ -n "$HOME" ]
    [ -d "$HOME" ]
}

@test "检测 SHELL 环境变量" {
    [ -n "$SHELL" ]
    [ -f "$SHELL" ]
}

# ============================================
# 项目文件结构检测
# ============================================

@test "检测项目根目录" {
    [ -d "$PROJECT_ROOT" ]
    [ -f "${PROJECT_ROOT}/README.md" ]
}

@test "检测安装器目录" {
    [ -d "$INSTALLER_DIR" ]
    [ -f "${INSTALLER_DIR}/install.sh" ]
}

@test "检测安装器核心库文件" {
    [ -f "${INSTALLER_DIR}/lib/logger.sh" ]
    [ -f "${INSTALLER_DIR}/lib/utils.sh" ]
    [ -f "${INSTALLER_DIR}/lib/detector.sh" ]
    [ -f "${INSTALLER_DIR}/lib/config.sh" ]
    [ -f "${INSTALLER_DIR}/lib/agent.sh" ]
    [ -f "${INSTALLER_DIR}/lib/progress.sh" ]
    [ -f "${INSTALLER_DIR}/lib/validator.sh" ]
    [ -f "${INSTALLER_DIR}/lib/state.sh" ]
}

@test "检测安装器配置文件" {
    [ -f "${INSTALLER_DIR}/config/sources.conf" ]
    [ -f "${INSTALLER_DIR}/config/versions.conf" ]
}

@test "检测安装器组件脚本" {
    [ -f "${INSTALLER_DIR}/scripts/install-nodejs.sh" ]
    [ -f "${INSTALLER_DIR}/scripts/install-openclaw.sh" ]
    [ -f "${INSTALLER_DIR}/scripts/install-omlx.sh" ]
    [ -f "${INSTALLER_DIR}/scripts/install-model.sh" ]
    [ -f "${INSTALLER_DIR}/scripts/install-skills.sh" ]
}

@test "检测卸载脚本" {
    [ -f "${INSTALLER_DIR}/uninstall.sh" ]
    [ -x "${INSTALLER_DIR}/uninstall.sh" ]
}
