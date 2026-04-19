#!/bin/bash
# OpenClaw + oMLX API 测试脚本
# 版本：V1.0.0
# 作者：外星动物（常智）

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 配置
BASE_URL="http://127.0.0.1:8008"
API_KEY="ak47"
MODEL="gemma-4-e4b-it-4bit"

# 计时器
start_timer() {
    START_TIME=$(date +%s%N)
}

end_timer() {
    END_TIME=$(date +%s%N)
    ELAPSED=$(( (END_TIME - START_TIME) / 1000000 ))
    echo "${ELAPSED}ms"
}

# 打印头部
print_header() {
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║       OpenClaw + oMLX API 测试工具                         ║"
    echo "║                                                            ║"
    echo "║       版本：V1.0.0 | 更新：2026-04-18                     ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "${BLUE}配置信息：${NC}"
    echo "  Base URL: $BASE_URL"
    echo "  Model: $MODEL"
    echo "  API Key: $API_KEY"
    echo ""
}

# 打印测试标题
print_test_title() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# 打印成功
print_success() {
    local time=$2
    if [ -n "$time" ]; then
        echo -e "${GREEN}✅ SUCCESS${NC} [$time]: $1"
    else
        echo -e "${GREEN}✅ SUCCESS${NC}: $1"
    fi
}

# 打印失败
print_error() {
    echo -e "${RED}❌ ERROR${NC}: $1"
}

# 打印信息
print_info() {
    echo -e "${CYAN}ℹ️  INFO${NC}: $1"
}

# 打印响应
print_response() {
    echo ""
    echo -e "${YELLOW}📄 响应：${NC}"
    echo "$1" | jq '.' 2>/dev/null || echo "$1"
}

# 测试1：健康检查
test_health_check() {
    print_test_title "测试1：健康检查端点"

    start_timer
    local response=$(curl -s "$BASE_URL/health")
    local http_code=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/health")
    local time=$(end_timer)

    if [ "$http_code" = "200" ]; then
        print_success "健康检查端点正常（HTTP $http_code）" "$time"
        print_response "$response"
        return 0
    else
        print_error "健康检查端点异常（HTTP $http_code）"
        return 1
    fi
}

# 测试2：模型列表
test_models_list() {
    print_test_title "测试2：模型列表端点"

    start_timer
    local response=$(curl -s "$BASE_URL/v1/models")
    local http_code=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/v1/models")
    local time=$(end_timer)

    if [ "$http_code" = "200" ]; then
        print_success "模型列表获取成功（HTTP $http_code）" "$time"

        local model_count=$(echo "$response" | jq '.data | length' 2>/dev/null || echo "0")
        print_info "可用模型数量：$model_count"

        echo ""
        echo -e "${YELLOW}📋 模型列表：${NC}"
        echo "$response" | jq -r '.data[] | "  - \(.id) (\(.name // "Unknown"))"' 2>/dev/null || echo "  解析失败"

        print_response "$response"
        return 0
    else
        print_error "模型列表获取失败（HTTP $http_code）"
        return 1
    fi
}

# 测试3：简单聊天
test_simple_chat() {
    print_test_title "测试3：简单聊天完成"

    local prompt="你好，请用一句话介绍你自己。"
    print_info "提示词：$prompt"

    start_timer
    local response=$(curl -s -X POST "$BASE_URL/v1/chat/completions" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $API_KEY" \
        -d "{
            \"model\": \"$MODEL\",
            \"messages\": [
                {\"role\": \"user\", \"content\": \"$prompt\"}
            ],
            \"max_tokens\": 100,
            \"temperature\": 0.7
        }")
    local http_code=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$BASE_URL/v1/chat/completions" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $API_KEY" \
        -d "{
            \"model\": \"$MODEL\",
            \"messages\": [
                {\"role\": \"user\", \"content\": \"$prompt\"}
            ],
            \"max_tokens\": 100,
            \"temperature\": 0.7
        }")
    local time=$(end_timer)

    if [ "$http_code" = "200" ]; then
        print_success "聊天完成成功（HTTP $http_code）" "$time"

        local content=$(echo "$response" | jq -r '.choices[0].message.content' 2>/dev/null)
        local usage_prompt=$(echo "$response" | jq -r '.usage.prompt_tokens' 2>/dev/null)
        local usage_completion=$(echo "$response" | jq -r '.usage.completion_tokens' 2>/dev/null)
        local usage_total=$(echo "$response" | jq -r '.usage.total_tokens' 2>/dev/null)

        echo ""
        echo -e "${GREEN}💬 回复：${NC}"
        echo "  $content"
        echo ""
        echo -e "${YELLOW}📊 Token 使用：${NC}"
        echo "  输入：${usage_prompt:-N/A} | 输出：${usage_completion:-N/A} | 总计：${usage_total:-N/A}"

        return 0
    else
        print_error "聊天完成失败（HTTP $http_code）"
        print_response "$response"
        return 1
    fi
}

# 测试4：多轮对话
test_multi_turn_chat() {
    print_test_title "测试4：多轮对话"

    print_info "第一轮：介绍 macOS"
    local response1=$(curl -s -X POST "$BASE_URL/v1/chat/completions" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $API_KEY" \
        -d "{
            \"model\": \"$MODEL\",
            \"messages\": [
                {\"role\": \"user\", \"content\": \"用一句话介绍 macOS\"}
            ],
            \"max_tokens\": 50
        }")

    local reply1=$(echo "$response1" | jq -r '.choices[0].message.content' 2>/dev/null)
    echo -e "${GREEN}第一轮回复：${NC} $reply1"

    print_info "第二轮：基于第一轮回复继续提问"
    start_timer
    local response2=$(curl -s -X POST "$BASE_URL/v1/chat/completions" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $API_KEY" \
        -d "{
            \"model\": \"$MODEL\",
            \"messages\": [
                {\"role\": \"user\", \"content\": \"用一句话介绍 macOS\"},
                {\"role\": \"assistant\", \"content\": \"$reply1\"},
                {\"role\": \"user\", \"content\": \"它的核心优势是什么？\"}
            ],
            \"max_tokens\": 50
        }")
    local time=$(end_timer)

    local http_code=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$BASE_URL/v1/chat/completions" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $API_KEY" \
        -d "{
            \"model\": \"$MODEL\",
            \"messages\": [
                {\"role\": \"user\", \"content\": \"用一句话介绍 macOS\"},
                {\"role\": \"assistant\", \"content\": \"$reply1\"},
                {\"role\": \"user\", \"content\": \"它的核心优势是什么？\"}
            ],
            \"max_tokens\": 50
        }")

    if [ "$http_code" = "200" ]; then
        local reply2=$(echo "$response2" | jq -r '.choices[0].message.content' 2>/dev/null)
        print_success "多轮对话成功" "$time"
        echo -e "${GREEN}第二轮回复：${NC} $reply2"
        return 0
    else
        print_error "多轮对话失败（HTTP $http_code）"
        return 1
    fi
}

# 测试5：流式响应
test_streaming() {
    print_test_title "测试5：流式响应"

    print_info "发送流式请求..."
    echo ""

    start_timer
    local response=$(curl -s -X POST "$BASE_URL/v1/chat/completions" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $API_KEY" \
        -d "{
            \"model\": \"$MODEL\",
            \"messages\": [
                {\"role\": \"user\", \"content\": \"数到5\"}
            ],
            \"max_tokens\": 50,
            \"stream\": true
        }")
    local time=$(end_timer)

    echo -e "${CYAN}流式输出：${NC}"
    echo "$response" | while IFS= read -r line; do
        if [ -n "$line" ]; then
            local content=$(echo "$line" | jq -r '.choices[0].delta.content' 2>/dev/null)
            if [ "$content" != "null" ] && [ -n "$content" ]; then
                echo -n "$content"
            fi
        fi
    done
    echo ""
    echo ""

    print_success "流式响应测试完成" "$time"
}

# 测试6：性能基准测试
test_performance_benchmark() {
    print_test_title "测试6：性能基准测试"

    local iterations=5
    local total_time=0

    print_info "执行 $iterations 次请求..."

    for i in $(seq 1 $iterations); do
        local start=$(date +%s%N)
        curl -s -X POST "$BASE_URL/v1/chat/completions" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $API_KEY" \
            -d "{
                \"model\": \"$MODEL\",
                \"messages\": [
                    {\"role\": \"user\", \"content\": \"hi\"}
                ],
                \"max_tokens\": 10
            }" > /dev/null
        local end=$(date +%s%N)
        local elapsed=$(( (end - start) / 1000000 ))
        total_time=$((total_time + elapsed))

        echo -e "${CYAN}  请求 $i：${elapsed}ms${NC}"
    done

    local avg_time=$((total_time / iterations))

    echo ""
    print_success "平均响应时间：${avg_time}ms"

    if [ $avg_time -lt 1000 ]; then
        echo -e "${GREEN}📊 性能评级：优秀（< 1s）${NC}"
    elif [ $avg_time -lt 3000 ]; then
        echo -e "${YELLOW}📊 性能评级：良好（1-3s）${NC}"
    else
        echo -e "${RED}📊 性能评级：需优化（> 3s）${NC}"
    fi
}

# 测试7：错误处理
test_error_handling() {
    print_test_title "测试7：错误处理"

    print_info "测试无效模型..."
    local response=$(curl -s -X POST "$BASE_URL/v1/chat/completions" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $API_KEY" \
        -d "{
            \"model\": \"invalid-model\",
            \"messages\": [
                {\"role\": \"user\", \"content\": \"hi\"}
            ]
        }")

    if echo "$response" | jq -e '.error' &> /dev/null; then
        print_success "错误处理正常：返回了错误信息"
        echo -e "${YELLOW}错误信息：${NC}"
        echo "$response" | jq -r '.error.message' 2>/dev/null
    else
        print_error "错误处理异常：未返回错误信息"
    fi

    print_info "测试无效 API Key..."
    local response2=$(curl -s -X POST "$BASE_URL/v1/chat/completions" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer invalid-key" \
        -d "{
            \"model\": \"$MODEL\",
            \"messages\": [
                {\"role\": \"user\", \"content\": \"hi\"}
            ]
        }")

    local http_code=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$BASE_URL/v1/chat/completions" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer invalid-key" \
        -d "{
            \"model\": \"$MODEL\",
            \"messages\": [
                {\"role\": \"user\", \"content\": \"hi\"}
            ]
        }")

    if [ "$http_code" = "401" ] || [ "$http_code" = "403" ]; then
        print_success "API Key 验证正常（HTTP $http_code）"
    else
        print_warn "API Key 验证可能有问题（HTTP $http_code）"
    fi
}

# 生成总结报告
print_summary() {
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}                        测试完成                              ${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${GREEN}✅ 所有测试已完成！${NC}"
    echo ""
    echo -e "${BLUE}💡 提示：${NC}"
    echo "  - 如有失败的测试，请检查 omlx 服务状态"
    echo "  - 使用 troubleshoot.sh 诊断问题"
    echo "  - 查看完整文档：docs/api-reference.md"
}

# 主函数
main() {
    print_header

    local tests=(
        "test_health_check"
        "test_models_list"
        "test_simple_chat"
        "test_multi_turn_chat"
        "test_streaming"
        "test_performance_benchmark"
        "test_error_handling"
    )

    for test in "${tests[@]}"; do
        $test
    done

    print_summary
}

# 运行主函数
main "$@"
