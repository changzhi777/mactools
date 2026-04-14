#!/usr/bin/env zsh
# ==============================================================================
# oMLX 性能测试脚本
# ==============================================================================

echo "🧪 oMLX 性能测试"
echo "=================================="
echo ""

# 测试 1: 简单问答
echo "📝 测试 1: 简单问答"
time openclaw infer model run --model omlx/gemma-4-e4b-it-4bit --prompt "你好" 2>&1 | grep -v "model.run" | grep -v "provider:" | grep -v "outputs:" | tail -1
echo ""

# 测试 2: 代码生成
echo "💻 测试 2: 代码生成"
time openclaw infer model run --model omlx/gemma-4-e4b-it-4bit --prompt "用Python写一个快速排序算法" 2>&1 | grep -v "model.run" | grep -v "provider:" | grep -v "outputs:" | tail -1
echo ""

# 测试 3: 数学问题
echo "🔢 测试 3: 数学问题"
time openclaw infer model run --model omlx/gemma-4-e4b-it-4bit --prompt "计算 123 * 456 + 789" 2>&1 | grep -v "model.run" | grep -v "provider:" | grep -v "outputs:" | tail -1
echo ""

# 显示性能统计
echo "📊 性能统计"
echo "=================================="
if [[ -f ~/.omlx/stats.json ]]; then
    echo "总请求数: $(jq -r '.total_requests' ~/.omlx/stats.json)"
    echo "缓存命中数: $(jq -r '.total_cached_tokens' ~/.omlx/stats.json)"
    echo "平均预填充时间: $(jq -r '.total_prefill_duration / .total_requests' ~/.omlx/stats.json) 秒"
    echo "平均生成时间: $(jq -r '.total_generation_duration / .total_requests' ~/.omlx/stats.json) 秒"
fi
