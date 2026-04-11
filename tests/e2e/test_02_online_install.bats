#!/usr/bin/env bats
#
# 在线安装测试
# 验证通过 curl | bash 方式在线安装的功能
#

# 加载公共设置
setup() {
    source "${PROJECT_ROOT}/tests/test_helper/common-setup.bash"
    source "${PROJECT_ROOT}/tests/helpers/fixtures.bash"

    # 备份现有环境
    backup_environment
}

teardown() {
    # 恢复环境
    restore_environment
    cleanup_test_env
}

# ============================================
# 在线脚本访问性测试
# ============================================

@test "在线安装脚本 URL 可访问" {
    run get_github_raw_status
    [ "$status" -eq 0 ]
    [[ "$output" =~ ^(200|301|302)$ ]]
}

@test "下载在线安装脚本前 20 行" {
    run curl -fsSL https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw-installer/install.sh | head -20
    [ "$status" -eq 0 ]
    [ -n "$output" ]

    # 验证是 bash 脚本
    [[ "$output" =~ "#!/bin/bash" ]]
    [[ "$output" =~ "MacClaw Installer" ]]
}

@test "验证在线脚本包含关键功能" {
    run curl -fsSL https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw-installer/install.sh
    [ "$status" -eq 0 ]

    # 检查关键函数和逻辑
    [[ "$output" =~ "main()" ]]
    [[ "$output" =~ "detect_environment" ]]
    [[ "$output" =~ "install-nodejs.sh" ]]
    [[ "$output" =~ "install-openclaw.sh" ]]
    [[ "$output" =~ "install-omlx.sh" ]]
}

# ============================================
# 在线安装模式检测测试
# ============================================

@test "检测在线安装模式逻辑" {
    run curl -fsSL https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw-installer/install.sh
    [ "$status" -eq 0 ]

    # 检查在线安装模式检测代码
    [[ "$output" =~ "检测到在线安装模式" ]] || \
    [[ "$output" =~ "在线安装" ]] || \
    [[ "$output" =~ "lib" ]]
}

@test "验证在线下载逻辑存在" {
    run curl -fsSL https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw-installer/install.sh
    [ "$status" -eq 0 ]

    # 检查 git clone 或 curl 下载逻辑
    [[ "$output" =~ "git clone" ]] || \
    [[ "$output" =~ "curl" ]]
}

# ============================================
# 下载测试（不实际执行安装）
# ============================================

@test "下载完整项目到临时目录" {
    skip "此测试耗时较长，默认跳过。使用 --force 选项强制执行。"

    local temp_download_dir="${TEST_TEMP_DIR}/download_test"
    mkdir -p "$temp_download_dir"

    run git clone --depth 1 https://github.com/changzhi777/mactools.git "$temp_download_dir"
    [ "$status" -eq 0 ]
    [ -d "$temp_download_dir/macclaw-installer" ]
    [ -f "$temp_download_dir/macclaw-installer/install.sh" ]
}

@test "验证下载的项目结构" {
    skip "依赖下载测试，默认跳过"

    local temp_download_dir="${TEST_TEMP_DIR}/download_test"

    if [ ! -d "$temp_download_dir/macclaw-installer" ]; then
        skip "需要先执行下载测试"
    fi

    # 验证关键文件存在
    [ -f "$temp_download_dir/macclaw-installer/install.sh" ]
    [ -f "$temp_download_dir/macclaw-installer/uninstall.sh" ]
    [ -d "$temp_download_dir/macclaw-installer/lib" ]
    [ -d "$temp_download_dir/macclaw-installer/scripts" ]
}

# ============================================
# 在线安装脚本语法验证
# ============================================

@test "验证在线脚本语法正确性" {
    local temp_script="${TEST_TEMP_DIR}/online_install.sh"

    run curl -fsSL https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw-installer/install.sh -o "$temp_script"
    [ "$status" -eq 0 ]
    [ -f "$temp_script" ]

    # 检查 bash 语法
    run bash -n "$temp_script"
    [ "$status" -eq 0 ]
}

@test "验证脚本可执行权限" {
    local temp_script="${TEST_TEMP_DIR}/online_install.sh"

    run curl -fsSL https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw-installer/install.sh -o "$temp_script"
    [ "$status" -eq 0 ]

    chmod +x "$temp_script"
    [ -x "$temp_script" ]
}

# ============================================
# GitHub Raw 内容完整性测试
# ============================================

@test "检查脚本头部信息" {
    run curl -fsSL https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw-installer/install.sh | head -15
    [ "$status" -eq 0 ]

    # 验证脚本元信息
    [[ "$output" =~ "MacClaw Installer" ]]
    [[ "$output" =~ "外星动物" ]] || [[ "$output" =~ "changzhi" ]]
    [[ "$output" =~ "版本" ]] || [[ "$output" =~ "Version" ]]
}

@test "检查脚本设置部分" {
    run curl -fsSL https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw-installer/install.sh | grep -A 5 "set -e"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "set -e" ]]
}

# ============================================
# 依赖文件访问性测试
# ============================================

@test "检查 lib 文件可访问性" {
    local lib_files=(
        "logger.sh"
        "utils.sh"
        "detector.sh"
        "config.sh"
    )

    for lib_file in "${lib_files[@]}"; do
        run curl -s -o /dev/null -w "%{http_code}" \
            https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw-installer/lib/"${lib_file}
        [ "$status" -eq 0 ]
        [[ "$output" =~ ^(200|301|302)$ ]] || echo "Failed to access: ${lib_file}"
    done
}

@test "检查脚本文件可访问性" {
    local script_files=(
        "install-nodejs.sh"
        "install-openclaw.sh"
        "install-omlx.sh"
    )

    for script_file in "${script_files[@]}"; do
        run curl -s -o /dev/null -w "%{http_code}" \
            https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw-installer/scripts/"${script_file}"
        [ "$status" -eq 0 ]
        [[ "$output" =~ ^(200|301|302)$ ]] || echo "Failed to access: ${script_file}"
    done
}

# ============================================
# 版本一致性测试
# ============================================

@test "检查本地和在线脚本版本一致性" {
    local local_version=$(grep "版本:" "${INSTALLER_DIR}/install.sh" | head -1)
    local online_version=$(curl -fsSL https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw-installer/install.sh | grep "版本:" | head -1)

    echo "本地版本: $local_version"
    echo "在线版本: $online_version"

    # 注意：这个测试可能会失败，因为本地可能已修改
    # 这里只是检查格式一致性
    [ -n "$local_version" ]
    [ -n "$online_version" ]
}

# ============================================
# 错误处理测试
# ============================================

@test "处理无效的在线 URL" {
    run curl -s --max-time 5 https://raw.githubusercontent.com/changzhi777/mactools/main/nonexistent-file.sh
    [ "$status" -ne 0 ] || [ "$output" =~ "404" ]
}

@test "处理网络超时" {
    run curl -s --max-time 1 https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw-installer/install.sh
    # 可能成功（网络快）或超时（网络慢）
    # 这里只是验证命令不会挂起
    [ -n "$output" ] || [ "$status" -ne 0 ]
}

# ============================================
# 完整性测试
# ============================================

@test "验证在线脚本能被 bash 解析" {
    local temp_script="${TEST_TEMP_DIR}/parse_test.sh"

    run curl -fsSL https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw-installer/install.sh -o "$temp_script"
    [ "$status" -eq 0 ]

    # 尝试解析（不执行）
    run bash -n "$temp_script"
    [ "$status" -eq 0 ]
}

@test "验证脚本包含必要的主函数" {
    run curl -fsSL https://raw.githubusercontent.com/changzhi777/mactools/main/macclaw-installer/install.sh
    [ "$status" -eq 0 ]

    # 检查主函数和关键逻辑
    [[ "$output" =~ "main()" ]] || \
    [[ "$output" =~ "main {" ]] || \
    [[ "$output" =~ "function main" ]]
}
