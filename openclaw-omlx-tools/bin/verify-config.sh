#!/bin/bash
# OpenClaw + oMLX 配置验证脚本
# 版本：V1.0.0
# 作者：外星动物（常智）

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 计数器
PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

# 打印头部
print_header() {
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║       OpenClaw + oMLX 配置验证工具                        ║"
    echo "║                                                            ║"
    echo "║       版本：V1.0.0 | 更新：2026-04-18                     ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# 打印通过
print_pass() {
    echo -e "${GREEN}✅ PASS${NC}: $1"
    ((PASS_COUNT++))
}

# 打印失败
print_fail() {
    echo -e "${RED}❌ FAIL${NC}: $1"
    ((FAIL_COUNT++))
}

# 打印警告
print_warn() {
    echo -e "${YELLOW}⚠️  WARN${NC}: $1"
    ((WARN_COUNT++))
}

# 打印信息
print_info() {
    echo -e "${BLUE}ℹ️  INFO${NC}: $1"
}

# 检查命令是否存在
check_command() {
    if command -v "$1" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# 检查端口是否监听
check_port() {
    local port=$1
    if lsof -i ":$port" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# 检查文件是否存在
check_file() {
    local file=$1
    if [ -f "$file" ]; then
        return 0
    else
        return 1
    fi
}

# 验证 JSON 文件
validate_json() {
    local file=$1
    if jq empty "$file" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# 1. 检查必要命令
check_commands() {
    echo ""
    print_info "检查必要命令..."

    local commands=("openclaw" "omlx" "jq" "curl")
    for cmd in "${commands[@]}"; do
        if check_command "$cmd"; then
            print_pass "$cmd 已安装"
        else
            print_fail "$cmd 未安装"
        fi
    done
}

# 2. 检查 omlx 服务
check_omlx_service() {
    echo ""
    print_info "检查 omlx 服务..."

    # 检查端口 8008
    if check_port 8008; then
        print_pass "oMLX 服务正在运行（端口 8008）"

        # 测试健康检查端点
        if curl -s http://127.0.0.1:8008/health &> /dev/null; then
            print_pass "oMLX 健康检查端点响应正常"
        else
            print_fail "oMLX 健康检查端点无响应"
        fi
    else
        print_fail "oMLX 服务未运行（端口 8008 未监听）"
    fi
}

# 3. 检查配置文件
check_config_files() {
    echo ""
    print_info "检查配置文件..."

    # 检查 omlx 配置
    local omlx_config="$HOME/.omlx/settings.json"
    if check_file "$omlx_config"; then
        print_pass "oMLX 配置文件存在: $omlx_config"

        if validate_json "$omlx_config"; then
            print_pass "oMLX 配置文件格式正确"

            # 检查关键配置
            local port=$(jq -r '.server.port' "$omlx_config")
            local api_key=$(jq -r '.auth.api_key' "$omlx_config")

            if [ "$port" = "8008" ]; then
                print_pass "oMLX 端口配置正确: 8008"
            else
                print_warn "oMLX 端口配置异常: $port（预期：8008）"
            fi

            if [ "$api_key" = "ak47" ]; then
                print_pass "oMLX API Key 配置正确: ak47"
            else
                print_warn "oMLX API Key 配置异常: $api_key（预期：ak47）"
            fi
        else
            print_fail "oMLX 配置文件格式错误"
        fi
    else
        print_fail "oMLX 配置文件不存在: $omlx_config"
    fi

    # 检查 openclaw 配置
    local openclaw_config="$HOME/.openclaw/openclaw.json"
    if check_file "$openclaw_config"; then
        print_pass "OpenClaw 配置文件存在: $openclaw_config"

        if validate_json "$openclaw_config"; then
            print_pass "OpenClaw 配置文件格式正确"

            # 检查 omlx 提供商配置
            if jq -e '.models.providers.omlx' "$openclaw_config" &> /dev/null; then
                print_pass "OpenClaw omlx 提供商已配置"

                local base_url=$(jq -r '.models.providers.omlx.baseUrl' "$openclaw_config")
                local api_key=$(jq -r '.models.providers.omlx.apiKey' "$openclaw_config")

                if [ "$base_url" = "http://127.0.0.1:8008/v1" ]; then
                    print_pass "oMLX baseUrl 配置正确"
                else
                    print_warn "oMLX baseUrl 配置: $base_url"
                fi

                if [ "$api_key" = "ak47" ]; then
                    print_pass "oMLX apiKey 配置正确"
                else
                    print_warn "oMLX apiKey 配置: $api_key"
                fi
            else
                print_fail "OpenClaw omlx 提供商未配置"
            fi
        else
            print_fail "OpenClaw 配置文件格式错误"
        fi
    else
        print_fail "OpenClaw 配置文件不存在: $openclaw_config"
    fi
}

# 4. 检查模型
check_models() {
    echo ""
    print_info "检查模型配置..."

    # 检查 omlx 模型列表
    if check_port 8008; then
        local models=$(curl -s http://127.0.0.1:8008/v1/models 2>/dev/null | jq -r '.data[].id' 2>/dev/null)

        if [ -n "$models" ]; then
            print_pass "oMLX 模型列表获取成功"

            # 检查 gemma-4-e4b-it-4bit 模型
            if echo "$models" | grep -q "gemma-4-e4b-it-4bit"; then
                print_pass "gemma-4-e4b-it-4bit 模型已安装"
            else
                print_fail "gemma-4-e4b-it-4bit 模型未找到"
            fi
        else
            print_fail "oMLX 模型列表获取失败"
        fi
    else
        print_warn "oMLX 服务未运行，跳过模型检查"
    fi

    # 检查 openclaw 默认模型配置
    local openclaw_config="$HOME/.openclaw/openclaw.json"
    if check_file "$openclaw_config"; then
        local primary=$(jq -r '.agents.defaults.model.primary' "$openclaw_config")
        local fallbacks=$(jq -r '.agents.defaults.model.fallbacks[]' "$openclaw_config" 2>/dev/null)

        print_info "主模型: $primary"
        print_info "备用模型: ${fallbacks:-无}"

        if echo "$primary" | grep -q "omlx"; then
            print_pass "主模型使用 omlx"
        fi

        if echo "$fallbacks" | grep -q "omlx"; then
            print_pass "备用模型包含 omlx"
        fi
    fi
}

# 5. 测试 API 连通性
test_api_connectivity() {
    echo ""
    print_info "测试 API 连通性..."

    if ! check_port 8008; then
        print_fail "oMLX 服务未运行，跳过 API 测试"
        return
    fi

    # 测试模型列表端点
    local response=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8008/v1/models 2>/dev/null)

    if [ "$response" = "200" ]; then
        print_pass "GET /v1/models 端点正常（HTTP $response）"
    else
        print_fail "GET /v1/models 端点异常（HTTP $response）"
    fi

    # 测试聊天完成端点
    local chat_response=$(curl -s -o /dev/null -w "%{http_code}" -X POST http://127.0.0.1:8008/v1/chat/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ak47" \
        -d '{"model":"gemma-4-e4b-it-4bit","messages":[{"role":"user","content":"hi"}],"max_tokens":10}' 2>/dev/null)

    if [ "$chat_response" = "200" ]; then
        print_pass "POST /v1/chat/completions 端点正常（HTTP $chat_response）"
    else
        print_fail "POST /v1/chat/completions 端点异常（HTTP $chat_response）"
    fi
}

# 6. 生成总结报告
print_summary() {
    echo ""
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}                        验证总结                              ${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${GREEN}✅ 通过：${PASS_COUNT}${NC}"
    echo -e "${RED}❌ 失败：${FAIL_COUNT}${NC}"
    echo -e "${YELLOW}⚠️  警告：${WARN_COUNT}${NC}"
    echo ""

    local total=$((PASS_COUNT + FAIL_COUNT + WARN_COUNT))

    if [ $FAIL_COUNT -eq 0 ]; then
        echo -e "${GREEN}🎉 所有核心检查通过！OpenClaw + oMLX 配置正常。${NC}"
        return 0
    else
        echo -e "${RED}⚠️  发现 ${FAIL_COUNT} 个问题，请使用 troubleshoot.sh 诊断。${NC}"
        return 1
    fi
}

# 主函数
main() {
    print_header
    check_commands
    check_omlx_service
    check_config_files
    check_models
    test_api_connectivity
    print_summary
}

# 运行主函数
main "$@"
