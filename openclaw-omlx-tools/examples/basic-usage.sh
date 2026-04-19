#!/bin/bash
# OpenClaw + oMLX 基础用法示例
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

# 打印标题
print_title() {
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║       OpenClaw + oMLX 基础用法示例                        ║"
    echo "║                                                            ║"
    echo "║       版本：V1.0.0 | 更新：2026-04-18                     ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# 打印示例标题
print_example() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  示例 $1：$2${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# 打印成功
print_success() {
    echo -e "${GREEN}✅${NC} $1"
}

# 打印信息
print_info() {
    echo -e "${CYAN}ℹ️${NC} $1"
}

# 示例1：验证配置
example1_verify_config() {
    print_example "1" "验证配置"

    echo ""
    print_info "检查 omlx 服务..."
    if lsof -i :8008 &> /dev/null; then
        print_success "oMLX 服务正在运行"

        print_info "测试健康检查..."
        response=$(curl -s $BASE_URL/health)
        print_success "健康检查通过"
    else
        echo -e "${RED}❌ oMLX 服务未运行${NC}"
        print_info "启动命令：omlx serve --port 8008"
        return 1
    fi

    echo ""
    print_info "检查配置文件..."
    if [ -f "$HOME/.omlx/settings.json" ]; then
        print_success "oMLX 配置文件存在"
    else
        echo -e "${RED}❌ oMLX 配置文件不存在${NC}"
    fi

    if [ -f "$HOME/.openclaw/openclaw.json" ]; then
        print_success "OpenClaw 配置文件存在"
    else
        echo -e "${RED}❌ OpenClaw 配置文件不存在${NC}"
    fi
}

# 示例2：测试 API
example2_test_api() {
    print_example "2" "测试 API"

    echo ""
    print_info "获取模型列表..."
    response=$(curl -s $BASE_URL/v1/models)
    model_count=$(echo "$response" | jq -r '.data | length')

    print_success "找到 $model_count 个模型"
    echo "$response" | jq -r '.data[] | "  - \(.id)"'

    echo ""
    print_info "测试简单对话..."
    response=$(curl -s -X POST $BASE_URL/v1/chat/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $API_KEY" \
        -d "{
            \"model\": \"$MODEL\",
            \"messages\": [{\"role\": \"user\", \"content\": \"你好\"}],
            \"max_tokens\": 20
        }")

    content=$(echo "$response" | jq -r '.choices[0].message.content')
    print_success "回复：$content"
}

# 示例3：简单对话
example3_simple_chat() {
    print_example "3" "简单对话"

    local prompt="用一句话介绍 macOS"
    print_info "提示词：$prompt"

    echo ""
    response=$(curl -s -X POST $BASE_URL/v1/chat/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $API_KEY" \
        -d "{
            \"model\": \"$MODEL\",
            \"messages\": [{\"role\": \"user\", \"content\": \"$prompt\"}],
            \"max_tokens\": 50,
            \"temperature\": 0.7
        }")

    content=$(echo "$response" | jq -r '.choices[0].message.content')
    usage_prompt=$(echo "$response" | jq -r '.usage.prompt_tokens')
    usage_completion=$(echo "$response" | jq -r '.usage.completion_tokens')

    echo ""
    echo -e "${GREEN}💬 回复：${NC}"
    echo "  $content"
    echo ""
    echo -e "${CYAN}📊 Token 使用：${NC}"
    echo "  输入：$usage_prompt | 输出：$usage_completion"

    print_success "对话完成"
}

# 示例4：多轮对话
example4_multi_turn() {
    print_example "4" "多轮对话"

    print_info "第一轮：介绍 Python"
    response1=$(curl -s -X POST $BASE_URL/v1/chat/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $API_KEY" \
        -d '{
            "model": "'$MODEL'",
            "messages": [{"role": "user", "content": "用一句话介绍 Python"}],
            "max_tokens": 50
        }')

    reply1=$(echo "$response1" | jq -r '.choices[0].message.content')
    echo -e "${GREEN}第一轮回复：${NC} $reply1"

    print_info "第二轮：基于第一轮回复继续提问"
    response2=$(curl -s -X POST $BASE_URL/v1/chat/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $API_KEY" \
        -d "{
            \"model\": \"$MODEL\",
            \"messages\": [
                {\"role\": \"user\", \"content\": \"用一句话介绍 Python\"},
                {\"role\": \"assistant\", \"content\": \"$reply1\"},
                {\"role\": \"user\", \"content\": \"它的主要应用场景有哪些？\"}
            ],
            \"max_tokens\": 50
        }")

    reply2=$(echo "$response2" | jq -r '.choices[0].message.content')
    echo -e "${GREEN}第二轮回复：${NC} $reply2"

    print_success "多轮对话完成"
}

# 示例5：批量处理
example5_batch() {
    print_example "5" "批量处理"

    print_info "批量生成3条内容..."

    local prompts=(
        "用一句话介绍 Go"
        "用一句话介绍 Rust"
        "用一句话介绍 JavaScript"
    )

    for i in "${!prompts[@]}"; do
        prompt="${prompts[$i]}"
        echo ""
        print_info "请求 $((i+1))/3：$prompt"

        response=$(curl -s -X POST $BASE_URL/v1/chat/completions \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $API_KEY" \
            -d "{
                \"model\": \"$MODEL\",
                \"messages\": [{\"role\": \"user\", \"content\": \"$prompt\"}],
                \"max_tokens\": 30
            }")

        content=$(echo "$response" | jq -r '.choices[0].message.content')
        echo -e "${GREEN}回复：${NC} $content"
    done

    echo ""
    print_success "批量处理完成"
}

# 示例6：流式响应
example6_streaming() {
    print_example "6" "流式响应"

    local prompt="数到5"
    print_info "提示词：$prompt"
    print_info "流式输出："

    echo ""
    echo -e "${CYAN}"

    curl -s -X POST $BASE_URL/v1/chat/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $API_KEY" \
        -d "{
            \"model\": \"$MODEL\",
            \"messages\": [{\"role\": \"user\", \"content\": \"$prompt\"}],
            \"stream\": true
        }" | while IFS= read -r line; do
        if [ -n "$line" ]; then
            content=$(echo "$line" | jq -r '.choices[0].delta.content' 2>/dev/null)
            if [ "$content" != "null" ] && [ -n "$content" ]; then
                echo -n "$content"
            fi
        fi
    done

    echo ""
    echo ""
    print_success "流式响应完成"
}

# 示例7：使用 OpenClaw CLI
example7_openclaw_cli() {
    print_example "7" "使用 OpenClaw CLI"

    echo ""
    print_info "测试 OpenClaw 推理..."

    if command -v openclaw &> /dev/null; then
        print_success "OpenClaw CLI 已安装"

        echo ""
        print_info "执行推理..."
        openclaw infer model run \
            --model omlx/gemma-4-e4b-it-4bit \
            --prompt "你好，请用一句话介绍你自己" \
            --max-tokens 50

        print_success "推理完成"
    else
        echo -e "${YELLOW}⚠️  OpenClaw CLI 未安装${NC}"
        print_info "安装命令：npm install -g @openclaw/cli"
    fi
}

# 主函数
main() {
    print_title

    local examples=(
        "example1_verify_config"
        "example2_test_api"
        "example3_simple_chat"
        "example4_multi_turn"
        "example5_batch"
        "example6_streaming"
        "example7_openclaw_cli"
    )

    echo ""
    echo -e "${CYAN}选择要运行的示例：${NC}"
    echo "  1) 验证配置"
    echo "  2) 测试 API"
    echo "  3) 简单对话"
    echo "  4) 多轮对话"
    echo "  5) 批量处理"
    echo "  6) 流式响应"
    echo "  7) 使用 OpenClaw CLI"
    echo "  8) 运行所有示例"
    echo "  0) 退出"
    echo ""
    read -p "请选择 [0-8]: " choice

    case $choice in
        1) example1_verify_config ;;
        2) example2_test_api ;;
        3) example3_simple_chat ;;
        4) example4_multi_turn ;;
        5) example5_batch ;;
        6) example6_streaming ;;
        7) example7_openclaw_cli ;;
        8)
            for example in "${examples[@]}"; do
                $example
            done
            ;;
        0)
            print_info "退出"
            exit 0
            ;;
        *)
            echo -e "${RED}无效选择${NC}"
            exit 1
            ;;
    esac

    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}                        示例完成                              ${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${BLUE}💡 提示：${NC}"
    echo "  - 修改脚本中的配置变量以适应你的环境"
    echo "  - 查看完整文档：../docs/"
    echo "  - 运行测试脚本：../bin/test-api.sh"
}

# 运行主函数
main "$@"
