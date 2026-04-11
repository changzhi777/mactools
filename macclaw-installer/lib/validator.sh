#!/bin/bash
#
# MacClaw Installer - 配置验证模块
# 作者: 外星动物（常智）
# 版本: V1.0.1
#

# 加载日志模块
source "$(dirname "$0")/logger.sh"

# 验证 JSON 文件
validate_json() {
    local file_path="$1"

    if [ ! -f "$file_path" ]; then
        log_error "❌ 文件不存在: $file_path"
        return 1
    fi

    # 使用 python3 验证 JSON
    if python3 -m json.tool "$file_path" > /dev/null 2>&1; then
        return 0
    else
        log_error "❌ JSON 格式错误: $file_path"
        return 1
    fi
}

# 验证 OpenClaw 配置
validate_openclaw_config() {
    local config_file="$HOME/.openclaw/openclaw.json"

    if [ ! -f "$config_file" ]; then
        log_warning "⚠️  OpenClaw 配置文件不存在"
        return 1
    fi

    log_info "🔍 验证 OpenClaw 配置..."

    # 验证 JSON 格式
    if ! validate_json "$config_file"; then
        return 1
    fi

    # 验证必要字段
    local required_fields=(
        "gateway.port"
        "agents.defaults.model.primary"
        "models.providers.omlx.baseUrl"
        "models.providers.omlx.apiKey"
    )

    for field in "${required_fields[@]}"; do
        if ! python3 -c "
import json
with open('$config_file', 'r') as f:
    data = json.load(f)
    try:
        value = data${field// /.}
        if not value:
            exit(1)
    except:
        exit(1)
" 2>/dev/null; then
            log_error "❌ 缺少必要字段: $field"
            return 1
        fi
    done

    log_success "✅ OpenClaw 配置验证通过"
    return 0
}

# 验证 oMLX 配置
validate_omlx_config() {
    local config_file="$HOME/.omlx/settings.json"

    if [ ! -f "$config_file" ]; then
        log_warning "⚠️  oMLX 配置文件不存在"
        return 1
    fi

    log_info "🔍 验证 oMLX 配置..."

    # 验证 JSON 格式
    if ! validate_json "$config_file"; then
        return 1
    fi

    # 验证 API Key
    local api_key=$(python3 -c "
import json
with open('$config_file', 'r') as f:
    data = json.load(f)
    print(data.get('auth', {}).get('api_key', ''))
" 2>/dev/null)

    if [ "$api_key" != "ak47" ]; then
        log_warning "⚠️  oMLX API Key 不匹配: $api_key"
        log_info "   应为: ak47"
        return 1
    fi

    # 验证端口
    local port=$(python3 -c "
import json
with open('$config_file', 'r') as f:
    data = json.load(f)
    print(data.get('server', {}).get('port', ''))
" 2>/dev/null)

    if [ "$port" != "8008" ]; then
        log_warning "⚠️  oMLX 端口不是默认值: $port"
    fi

    log_success "✅ oMLX 配置验证通过"
    return 0
}

# 验证环境配置
validate_environment() {
    log_info "🔍 验证环境配置..."

    local errors=0

    # 验证 Node.js
    if ! command -v node &>/dev/null; then
        log_error "❌ Node.js 未安装"
        ((errors++))
    fi

    # 验证 npm
    if ! command -v npm &>/dev/null; then
        log_error "❌ npm 未安装"
        ((errors++))
    fi

    # 验证 Python
    if ! command -v python3 &>/dev/null; then
        log_error "❌ Python3 未安装"
        ((errors++))
    fi

    # 验证 pip
    if ! command -v pip3 &>/dev/null; then
        log_error "❌ pip3 未安装"
        ((errors++))
    fi

    if [ $errors -eq 0 ]; then
        log_success "✅ 环境配置验证通过"
        return 0
    else
        log_error "❌ 环境配置验证失败，发现 $errors 个错误"
        return 1
    fi
}

# 验证服务状态
validate_services() {
    log_info "🔍 验证服务状态..."

    local errors=0

    # 验证 oMLX 服务
    if ! curl -s http://127.0.0.1:8008/health &>/dev/null; then
        log_warning "⚠️  oMLX 服务未运行"
        ((errors++))
    else
        log_success "✅ oMLX 服务运行正常"
    fi

    # 验证 OpenClaw Gateway
    if ! openclaw gateway status &>/dev/null; then
        log_warning "⚠️  OpenClaw Gateway 未运行"
        ((errors++))
    else
        log_success "✅ OpenClaw Gateway 运行正常"
    fi

    if [ $errors -eq 0 ]; then
        log_success "✅ 服务状态验证通过"
        return 0
    else
        log_warning "⚠️  服务状态验证完成，发现 $errors 个问题"
        return 1
    fi
}

# 验证模型文件
validate_model() {
    log_info "🔍 验证模型文件..."

    local model_path="$HOME/.modelscope/hub/mlx-community/gemma-4-e4b-it-4bit"

    if [ ! -d "$model_path" ]; then
        log_warning "⚠️  模型文件不存在: $model_path"
        return 1
    fi

    # 检查模型文件完整性
    local required_files=(
        "config.json"
        "model"
        "tokenizer.json"
    )

    for file in "${required_files[@]}"; do
        if [ ! -e "$model_path/$file" ]; then
            log_warning "⚠️  缺少模型文件: $file"
        fi
    done

    local size=$(du -sh "$model_path" 2>/dev/null | cut -f1)
    log_success "✅ 模型验证通过 (大小: $size)"
    return 0
}

# 综合验证
validate_all() {
    log_info "🔍 开始综合验证..."
    show_separator

    local errors=0

    validate_environment || ((errors++))
    show_separator

    validate_openclaw_config || ((errors++))
    show_separator

    validate_omlx_config || ((errors++))
    show_separator

    validate_model || ((errors++))
    show_separator

    validate_services || ((errors++))
    show_separator

    if [ $errors -eq 0 ]; then
        log_success "✅ 所有验证通过"
        return 0
    else
        log_warning "⚠️  验证完成，发现 $errors 个问题"
        return 1
    fi
}

# 导出函数
export -f validate_json
export -f validate_openclaw_config
export -f validate_omlx_config
export -f validate_environment
export -f validate_services
export -f validate_model
export -f validate_all
