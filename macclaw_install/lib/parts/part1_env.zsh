#!/usr/bin/env zsh
# ==============================================================================
# MacClaw Install - 第1部分：环境配置
# ==============================================================================
#
# 功能说明：
#   - Homebrew 安装与配置（中科大镜像）
#   - Node.js 安装（nvm + 20.x LTS）
#   - npm 配置（淘宝镜像）
#   - 环境验证
#   - 完善的错误处理和日志记录
#
# 使用方法：
#   source "${LIB_DIR}/parts/part1_env.zsh"
#   install_part1_env
#
# ==============================================================================

# ==============================================================================
# 加载依赖
# ==============================================================================

# 加载错误处理模块（如果可用）
if [[ -f "${LIB_DIR}/core/error-handler.zsh" ]]; then
    source "${LIB_DIR}/core/error-handler.zsh"
fi

# 加载配置文件
load_config() {
    if [[ -f "${SCRIPT_DIR}/config/sources.conf" ]]; then
        source "${SCRIPT_DIR}/config/sources.conf"
    else
        log_warning "配置文件不存在，使用默认配置"
    fi

    if [[ -f "${SCRIPT_DIR}/config/versions.conf" ]]; then
        source "${SCRIPT_DIR}/config/versions.conf"
    fi
}

# ==============================================================================
# Homebrew 安装
# ==============================================================================

# 安装 Homebrew
install_homebrew() {
    log_section "安装 Homebrew"

    # 如果已安装，检查版本
    if ${HOMEBREW_INSTALLED}; then
        log_info "Homebrew 已安装: ${HOMEBREW_VERSION}"

        if ${HOMEBREW_NEED_UPDATE}; then
            log_warning "Homebrew 版本较旧，建议更新"
            if confirm_action "是否更新 Homebrew？"; then
                brew update
                log_success "Homebrew 更新完成"
            fi
        fi

        return 0
    fi

    # 开始安装
    log_info "开始安装 Homebrew..."

    # 设置环境变量（使用中科大镜像）
    export HOMEBREW_BREW_GIT_REMOTE="${HOMEBREW_BREW_GIT_REMOTE:-https://mirrors.ustc.edu.cn/git/brew.git}"
    export HOMEBREW_CORE_GIT_REMOTE="${HOMEBREW_CORE_GIT_REMOTE:-https://mirrors.ustc.edu.cn/git/homebrew-core.git}"
    export HOMEBREW_BOTTLE_DOMAIN="${HOMEBREW_BOTTLE_DOMAIN:-https://mirrors.ustc.edu.cn/homebrew-bottles}"

    # 下载并执行安装脚本
    log_info "从官方源下载 Homebrew 安装脚本..."

    # 使用错误处理
    if /bin/bash -c "$(curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 2>&1 | tee -a "${LOG_FILE}"; then
        log_success "Homebrew 安装成功"
    else
        local exit_code=$?
        if type throw_error >/dev/null 2>&1; then
            throw_error ${ERR_HOMEBREW_INSTALL} "Homebrew 安装失败" "退出码: ${exit_code}"
        else
            log_error "Homebrew 安装失败（退出码: ${exit_code}）"
            increment_error_count
        fi
        return 1
    fi

    # 配置 Homebrew 环境
    setup_homebrew_env

    # 验证安装
    if command -v brew >/dev/null 2>&1; then
        HOMEBREW_INSTALLED=true
        HOMEBREW_VERSION=$(brew --version | head -1 | awk '{print $2}')
        log_success "Homebrew 验证成功: ${HOMEBREW_VERSION}"
        return 0
    else
        log_error "Homebrew 安装验证失败"
        return 1
    fi
}

# 配置 Homebrew 环境
setup_homebrew_env() {
    log_info "配置 Homebrew 环境..."

    # 检测架构
    local homebrew_dir=""
    if [[ $(uname -m) == "arm64" ]]; then
        homebrew_dir="/opt/homebrew"
    else
        homebrew_dir="/usr/local"
    fi

    # 添加到 PATH
    export PATH="${homebrew_dir}/bin:${PATH}"
    export PATH="${homebrew_dir}/sbin:${PATH}"

    # 配置 shell
    if [[ $SHELL == *"zsh"* ]]; then
        # Zsh 配置
        if ! grep -q "eval \"\$(${homebrew_dir}/bin/brew shellenv)\"" ~/.zprofile 2>/dev/null; then
            echo 'eval "$('"${homebrew_dir}"'/bin/brew shellenv)"' >> ~/.zprofile
            log_info "已添加 Homebrew 到 ~/.zprofile"
        fi
    elif [[ $SHELL == *"bash"* ]]; then
        # Bash 配置
        if ! grep -q "eval \"\$(${homebrew_dir}/bin/brew shellenv)\"" ~/.bash_profile 2>/dev/null; then
            echo 'eval "$('"${homebrew_dir}"'/bin/brew shellenv)"' >> ~/.bash_profile
            log_info "已添加 Homebrew 到 ~/.bash_profile"
        fi
    fi

    # 配置国内镜像
    log_info "配置 Homebrew 国内镜像..."

    # 设置 bottle 镜像
    if [[ -n "${HOMEBREW_BOTTLE_DOMAIN}" ]]; then
        export HOMEBREW_BOTTLE_DOMAIN
        mkdir -p "${HOME}/.zprofile"
        echo "export HOMEBREW_BOTTLE_DOMAIN=${HOMEBREW_BOTTLE_DOMAIN}" >> ~/.zprofile
    fi

    log_success "Homebrew 环境配置完成"
}

# ==============================================================================
# Node.js 安装
# ==============================================================================

# 安装 nvm
install_nvm() {
    log_section "安装 nvm"

    # 如果已安装，跳过
    if ${NVM_INSTALLED}; then
        log_info "nvm 已安装"
        return 0
    fi

    log_info "开始安装 nvm..."

    # 设置环境变量
    export NVM_DIR="${NVM_DIR:-${HOME}/.nvm}"

    # 下载并安装 nvm
    local nvm_install_url="https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh"
    log_info "从 ${nvm_install_url} 下载 nvm..."

    if curl -o- "${nvm_install_url}" 2>&1 | tee -a "${LOG_FILE}" | bash; then
        log_success "nvm 安装成功"
    else
        local exit_code=$?
        if type throw_error >/dev/null 2>&1; then
            throw_error ${ERR_NVM_INSTALL} "nvm 安装失败" "URL: ${nvm_install_url}, 退出码: ${exit_code}"
        else
            log_error "nvm 安装失败（退出码: ${exit_code}）"
            increment_error_count
        fi
        return 1
    fi

    # 加载 nvm
    [ -s "${NVM_DIR}/nvm.sh" ] && \. "${NVM_DIR}/nvm.sh"

    # 配置 shell
    setup_nvm_env

    # 验证安装
    if command -v nvm >/dev/null 2>&1; then
        NVM_INSTALLED=true
        log_success "nvm 验证成功"
        return 0
    else
        log_error "nvm 安装验证失败"
        return 1
    fi
}

# 配置 nvm 环境
setup_nvm_env() {
    log_info "配置 nvm 环境..."

    export NVM_DIR="${NVM_DIR:-${HOME}/.nvm}"

    # 配置 shell
    if [[ $SHELL == *"zsh"* ]]; then
        # Zsh 配置
        if ! grep -q 'NVM_DIR' ~/.zshrc 2>/dev/null; then
            cat >> ~/.zshrc << 'EOF'

# NVM configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
EOF
            log_info "已添加 nvm 到 ~/.zshrc"
        fi
    elif [[ $SHELL == *"bash"* ]]; then
        # Bash 配置
        if ! grep -q 'NVM_DIR' ~/.bash_profile 2>/dev/null; then
            cat >> ~/.bash_profile << 'EOF'

# NVM configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
EOF
            log_info "已添加 nvm 到 ~/.bash_profile"
        fi
    fi

    log_success "nvm 环境配置完成"
}

# 安装 Node.js
install_nodejs() {
    log_section "安装 Node.js"

    # 如果已安装，检查版本
    if ${NODEJS_INSTALLED}; then
        log_info "Node.js 已安装: ${NODEJS_VERSION}"

        if ${NODEJS_NEED_UPDATE}; then
            log_warning "Node.js 版本较旧，建议更新到 ${NODEJS_RECOMMENDED_VERSION}"
            if confirm_action "是否更新 Node.js？"; then
                nvm install "${NODEJS_RECOMMENDED_VERSION}"
                nvm use "${NODEJS_RECOMMENDED_VERSION}"
                log_success "Node.js 更新完成"
            fi
        fi

        return 0
    fi

    # 开始安装
    log_info "开始安装 Node.js ${NODEJS_RECOMMENDED_VERSION}..."

    # 加载 nvm
    export NVM_DIR="${NVM_DIR:-${HOME}/.nvm}"
    [ -s "${NVM_DIR}/nvm.sh" ] && \. "${NVM_DIR}/nvm.sh"

    # 设置镜像（如果配置了）
    if [[ -n "${NVM_NODEJS_ORG_MIRROR}" ]]; then
        export NVM_NODEJS_ORG_MIRROR
        log_info "使用 Node.js 镜像: ${NVM_NODEJS_ORG_MIRROR}"
    fi

    # 安装 Node.js LTS 版本
    log_info "安装 Node.js ${NODEJS_RECOMMENDED_VERSION}..."
    log_info "使用镜像: ${NVM_NODEJS_ORG_MIRROR:-官方源}"

    if nvm install "${NODEJS_RECOMMENDED_VERSION}" 2>&1 | tee -a "${LOG_FILE}"; then
        log_success "Node.js 安装成功"
    else
        local exit_code=$?
        if type throw_error >/dev/null 2>&1; then
            throw_error ${ERR_NODEJS_INSTALL} "Node.js 安装失败" "版本: ${NODEJS_RECOMMENDED_VERSION}, 退出码: ${exit_code}"
        else
            log_error "Node.js 安装失败（退出码: ${exit_code}）"
            increment_error_count
        fi
        return 1
    fi

    # 使用该版本
    nvm use "${NODEJS_RECOMMENDED_VERSION}"
    nvm alias default "${NODEJS_RECOMMENDED_VERSION}"

    # 验证安装
    if command -v node >/dev/null 2>&1; then
        NODEJS_INSTALLED=true
        NODEJS_VERSION=$(node --version)
        log_success "Node.js 验证成功: ${NODEJS_VERSION}"
        return 0
    else
        log_error "Node.js 安装验证失败"
        return 1
    fi
}

# 配置 npm
setup_npm() {
    log_section "配置 npm"

    # 设置 npm 淘宝镜像
    log_info "配置 npm 淘宝镜像..."

    local npm_registry="${NPM_REGISTRY:-https://registry.npmmirror.com}"

    if npm config set registry "${npm_registry}"; then
        log_success "npm 镜像配置成功: ${npm_registry}"
    else
        log_warning "npm 镜像配置失败"
    fi

    # 验证配置
    local current_registry=$(npm config get registry)
    log_info "当前 npm registry: ${current_registry}"
}

# ==============================================================================
# 验证安装
# ==============================================================================

# 验证第1部分安装
verify_part1() {
    log_section "验证环境配置"

    local all_ok=true

    # 验证 Homebrew
    echo "验证 Homebrew..."
    if command -v brew >/dev/null 2>&1; then
        local version=$(brew --version | head -1)
        log_list_item "success" "Homebrew: ${version}"
    else
        log_list_item "error" "Homebrew 未安装"
        all_ok=false
    fi

    # 验证 Node.js
    echo "验证 Node.js..."
    if command -v node >/dev/null 2>&1; then
        local version=$(node --version)
        log_list_item "success" "Node.js: ${version}"
    else
        log_list_item "error" "Node.js 未安装"
        all_ok=false
    fi

    # 验证 npm
    echo "验证 npm..."
    if command -v npm >/dev/null 2>&1; then
        local version=$(npm --version)
        log_list_item "success" "npm: ${version}"
    else
        log_list_item "error" "npm 未安装"
        all_ok=false
    fi

    # 验证 nvm
    echo "验证 nvm..."
    if [[ -f "${NVM_DIR}/nvm.sh" ]]; then
        log_list_item "success" "nvm: 已安装"
    else
        log_list_item "warning" "nvm 未安装"
    fi

    echo ""

    if ${all_ok}; then
        log_success "✅ 环境配置验证通过"
        return 0
    else
        log_error "❌ 环境配置验证失败"
        return 1
    fi
}

# ==============================================================================
# 主函数
# ==============================================================================

# 安装第1部分：环境配置
install_part1_env() {
    log_title "第1部分：环境配置"

    # 加载配置
    load_config

    # 安装 Homebrew
    if ! install_homebrew; then
        log_error "Homebrew 安装失败"
        return 1
    fi

    # 安装 nvm
    if ! install_nvm; then
        log_error "nvm 安装失败"
        return 1
    fi

    # 安装 Node.js
    if ! install_nodejs; then
        log_error "Node.js 安装失败"
        return 1
    fi

    # 配置 npm
    setup_npm

    # 验证安装
    if ! verify_part1; then
        log_error "环境配置验证失败"
        return 1
    fi

    log_success "✅ 第1部分完成：环境配置成功"
    return 0
}

# ==============================================================================
# 导出函数
# ==============================================================================

export -f load_config
export -f install_homebrew
export -f setup_homebrew_env
export -f install_nvm
export -f setup_nvm_env
export -f install_nodejs
export -f setup_npm
export -f verify_part1
export -f install_part1_env
