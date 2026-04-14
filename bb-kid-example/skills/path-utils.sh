#!/bin/bash
# BB小子路径处理工具模块
# 提供跨平台兼容的路径处理功能

# ==============================================================================
# 路径解析和验证
# ==============================================================================

# 获取绝对路径（兼容 ~ 符号）
get_absolute_path() {
    local path="$1"

    # 展开 ~ 符号
    if [[ "${path}" =~ ^~ ]]; then
        path="${path/#\~/${HOME}}"
    fi

    # 转换为绝对路径
    if [[ -d "${path}" ]]; then
        (cd "${path}" && pwd)
    elif [[ -f "${path}" ]]; then
        local dir=$(dirname "${path}")
        local base=$(basename "${path}")
        echo "$(cd "${dir}" && pwd)/${base}"
    else
        # 文件不存在，但返回绝对路径格式
        local dir=$(dirname "${path}")
        local base=$(basename "${path}")
        if [[ -d "${dir}" ]]; then
            echo "$(cd "${dir}" && pwd)/${base}"
        else
            echo "${path}" # 返回原路径（可能无效）
        fi
    fi
}

# 验证路径有效性
validate_path() {
    local path="$1"
    local path_type="${2:-auto}" # auto, file, dir, any

    local absolute_path=$(get_absolute_path "${path}")

    case "${path_type}" in
        file)
            [[ -f "${absolute_path}" ]] && echo "${absolute_path}" && return 0
            ;;
        dir)
            [[ -d "${absolute_path}" ]] && echo "${absolute_path}" && return 0
            ;;
        any)
            [[ -e "${absolute_path}" ]] && echo "${absolute_path}" && return 0
            ;;
        auto)
            if [[ -e "${absolute_path}" ]]; then
                echo "${absolute_path}"
                return 0
            fi
            ;;
    esac

    return 1
}

# 创建目录（如果不存在）
ensure_directory() {
    local dir="$1"
    local absolute_dir=$(get_absolute_path "${dir}")

    if [[ ! -d "${absolute_dir}" ]]; then
        mkdir -p "${absolute_dir}" 2>/dev/null || {
            echo "错误：无法创建目录 ${absolute_dir}" >&2
            return 1
        }
    fi

    echo "${absolute_dir}"
    return 0
}

# 获取脚本目录（兼容符号链接）
get_script_dir() {
    local source="${BASH_SOURCE[0]}"
    while [[ -h "${source}" ]]; do
        local dir="$(cd -P "$(dirname "${source}")" && pwd)"
        source="$(readlink "${source}")"
        [[ "${source}" != /* ]] && source="${dir}/${source}"
    done
    (cd -P "$(dirname "${source}")" && pwd)
}

# 规范化路径（处理 .. 和 .）
normalize_path() {
    local path="$1"
    local absolute_path=$(get_absolute_path "${path}")

    # 使用 Python 或其他工具规范化路径
    if command -v python3 >/dev/null 2>&1; then
        python3 -c "import os, sys; print(os.path.normpath('${absolute_path}'))"
    elif command -v perl >/dev/null 2>&1; then
        perl -MCwd -e 'print Cwd::realpath($ARGV[0])' "${absolute_path}"
    else
        echo "${absolute_path}"
    fi
}

# 检查路径写权限
check_write_permission() {
    local path="$1"
    local absolute_path=$(get_absolute_path "${path}")

    if [[ -f "${absolute_path}" ]]; then
        [[ -w "${absolute_path}" ]] && return 0 || return 1
    elif [[ -d "${absolute_path}" ]]; then
        [[ -w "${absolute_path}" ]] && return 0 || return 1
    else
        # 检查父目录写权限
        local parent_dir=$(dirname "${absolute_path}")
        [[ -w "${parent_dir}" ]] && return 0 || return 1
    fi
}

# ==============================================================================
# BB小子特定路径
# ==============================================================================

# 获取 BB小子工作区根目录
get_bb_kid_workspace_root() {
    echo "${HOME}/.openclaw/workspaces/bb-kid"
}

# 获取技能目录
get_skills_dir() {
    echo "$(get_bb_kid_workspace_root)/skills"
}

# 获取缓存目录
get_cache_dir() {
    local cache_type="${1:-news}"
    echo "$(get_bb_kid_workspace_root)/cache/${cache_type}"
}

# 获取配置目录
get_config_dir() {
    echo "$(get_bb_kid_workspace_root)/.openclaw"
}

# ==============================================================================
# 路径调试
# ==============================================================================

# 显示路径信息
show_path_info() {
    local path="$1"
    local absolute_path=$(get_absolute_path "${path}")

    echo "路径信息："
    echo "  原始路径: ${path}"
    echo "  绝对路径: ${absolute_path}"
    echo "  规范路径: $(normalize_path "${absolute_path}")"

    if [[ -e "${absolute_path}" ]]; then
        echo "  存在性: 是"
        if [[ -f "${absolute_path}" ]]; then
            echo "  类型: 文件"
            echo "  大小: $(stat -f%z "${absolute_path}" 2>/dev/null || stat -c%s "${absolute_path}" 2>/dev/null) 字节"
        elif [[ -d "${absolute_path}" ]]; then
            echo "  类型: 目录"
        fi
        echo "  可读: $([[ -r "${absolute_path}" ]] && echo "是" || echo "否")"
        echo "  可写: $([[ -w "${absolute_path}" ]] && echo "是" || echo "否")"
        echo "  可执行: $([[ -x "${absolute_path}" ]] && echo "是" || echo "否")"
    else
        echo "  存在性: 否"
    fi
}

# ==============================================================================
# 批量路径验证
# ==============================================================================

# 验证 BB小子所需的所有路径
validate_bb_kid_paths() {
    echo "🔍 验证 BB小子 路径配置"
    echo "========================"
    echo ""

    local all_valid=true
    local paths=(
        "WORKSPACE_ROOT:$(get_bb_kid_workspace_root):dir"
        "SKILLS_DIR:$(get_skills_dir):dir"
        "CONFIG_DIR:$(get_config_dir):dir"
        "NEWS_CACHE:$(get_cache_dir news):dir"
    )

    for path_info in "${paths[@]}"; do
        local name="${path_info%%:*}"
        local rest="${path_info#*:}"
        local path="${rest%%:*}"
        local type="${rest##*:}"

        echo -n "  ${name}: "

        if validate_path "${path}" "${type}" >/dev/null 2>&1; then
            echo -e "\033[0;32m✓ 有效\033[0m ($(validate_path "${path}" "${type}"))"
        else
            echo -e "\033[0;31m✗ 无效\033[0m (${path})"
            all_valid=false
        fi
    done

    echo ""
    if ${all_valid}; then
        echo -e "\033[0;32m✅ 所有路径验证通过\033[0m"
        return 0
    else
        echo -e "\033[0;33m⚠️  部分路径需要修复\033[0m"
        return 1
    fi
}

# 修复 BB小子 路径
fix_bb_kid_paths() {
    echo "🔧 修复 BB小子 路径"
    echo "=================="
    echo ""

    # 确保所有必需目录存在
    ensure_directory "$(get_bb_kid_workspace_root)"
    ensure_directory "$(get_skills_dir)"
    ensure_directory "$(get_config_dir)"
    ensure_directory "$(get_cache_dir news)"

    echo -e "\033[0;32m✅ 路径修复完成\033[0m"
    echo ""
}

# ==============================================================================
# 导出函数
# ==============================================================================

export -f get_absolute_path
export -f validate_path
export -f ensure_directory
export -f get_script_dir
export -f normalize_path
export -f check_write_permission
export -f get_bb_kid_workspace_root
export -f get_skills_dir
export -f get_cache_dir
export -f get_config_dir
export -f show_path_info
export -f validate_bb_kid_paths
export -f fix_bb_kid_paths
