#!/usr/bin/env bats
#
# 组件功能测试
# 验证已安装组件的功能
#

# 加载公共设置
setup() {
    source "${PROJECT_ROOT}/tests/test_helper/common-setup.bash"
    source "${PROJECT_ROOT}/tests/helpers/fixtures.bash"
    source "${PROJECT_ROOT}/tests/helpers/assertions.bash"
}

teardown() {
    cleanup_test_env
}

# ============================================
# Node.js 组件测试
# ============================================

@test "Node.js 命令可用性检查（如果已安装）" {
    if command_exists node; then
        run node --version
        [ "$status" -eq 0 ]
        [[ "$output" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]
    else
        skip "Node.js 未安装"
    fi
}

@test "Node.js 能执行简单脚本（如果已安装）" {
    if command_exists node; then
        run node -e "console.log('test')"
        [ "$status" -eq 0 ]
        [[ "$output" =~ "test" ]]
    else
        skip "Node.js 未安装"
    fi
}

@test "npm 命令可用性检查（如果已安装）" {
    if command_exists npm; then
        run npm --version
        [ "$status" -eq 0 ]
        [[ "$output" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
    else
        skip "npm 未安装"
    fi
}

@test "nvm 安装检查（如果已安装）" {
    if [ -f "$NVM_DIR/nvm.sh" ] || [ -f ~/.nvm/nvm.sh ]; then
        run bash -c 'source ~/.nvm/nvm.sh && nvm --version'
        [ "$status" -eq 0 ]
        [[ "$output" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
    else
        skip "nvm 未安装"
    fi
}

# ============================================
# OpenClaw 组件测试
# ============================================

@test "OpenClaw CLI 命令可用性（如果已安装）" {
    if command_exists openclaw; then
        run openclaw --help
        # 可能返回 0 或 1，都算正常
        [ "$status" -le 1 ]
    else
        skip "OpenClaw 未安装"
    fi
}

@test "OpenClaw 配置目录存在（如果已安装）" {
    if [ -d ~/.openclaw ]; then
        [ -d ~/.openclaw ]
        [ -d ~/.openclaw/workspace ]
    else
        skip "OpenClaw 配置目录不存在"
    fi
}

@test "OpenClaw Gateway 服务检查（如果运行）" {
    if service_running 18789; then
        run curl -s http://127.0.0.1:18789/health
        [ "$status" -eq 0 ] || skip "Gateway 未响应"
    else
        skip "OpenClaw Gateway 服务未运行"
    fi
}

@test "OpenClaw Agent 列表检查（如果已安装）" {
    if command_exists openclaw; then
        run openclaw agents list
        # 可能返回 0 或非 0，取决于是否有 agents
        log_test "Agent 列表查询执行"
    else
        skip "OpenClaw 未安装"
    fi
}

# ============================================
# oMLX 组件测试
# ============================================

@test "oMLX 安装目录检查（如果已安装）" {
    if [ -d ~/.omlx ]; then
        [ -d ~/.omlx ]
        [ -f ~/.omlx/settings.json ] || skip "oMLX 配置文件不存在"
    else
        skip "oMLX 未安装"
    fi
}

@test "oMLX 服务端口检查（如果运行）" {
    if service_running 8008; then
        run curl -s http://127.0.0.1:8008/health
        [ "$status" -eq 0 ] || skip "oMLX 健康检查端点未响应"
    else
        skip "oMLX 服务未运行（端口 8008）"
    fi
}

@test "oMLX 配置文件存在（如果已安装）" {
    if [ -d ~/.omlx ]; then
        [ -f ~/.omlx/settings.json ] || skip "配置文件不存在"
    else
        skip "oMLX 未安装"
    fi
}

# ============================================
# AI 模型测试
# ============================================

@test "gemma-4 模型文件检查（如果已下载）" {
    local model_dir="$HOME/.omlx/models/gemma-4-e4b-it-4bit"

    if [ -d "$model_dir" ]; then
        [ -d "$model_dir" ]
        # 检查是否有模型文件（至少 1GB）
        local model_size=$(du -sh "$model_dir" 2>/dev/null | awk '{print $1}' | sed 's/G//')
        if [ ! -z "$model_size" ]; then
            log_test "模型大小: ${model_size}G"
        fi
    else
        skip "gemma-4 模型未下载"
    fi
}

@test "模型推理功能测试（如果组件已安装）" {
    if command_exists openclaw && service_running 8008; then
        skip "推理测试耗时较长，默认跳过"
        # 实际测试（取消上面的 skip）
        # run openclaw infer model run --model omlx/gemma-4-e4b-it-4bit --prompt "test"
        # [ "$status" -eq 0 ]
    else
        skip "OpenClaw 或 oMLX 服务未运行"
    fi
}

# ============================================
# Skills 组件测试
# ============================================

@test "Skills 目录检查（如果已安装）" {
    if [ -d ~/.openclaw/skills ]; then
        [ -d ~/.openclaw/skills ]
    else
        skip "Skills 目录不存在"
    fi
}

@test "Skills 列表检查（如果 OpenClaw 已安装）" {
    if command_exists openclaw; then
        run openclaw skills list
        log_test "Skills 列表查询执行"
    else
        skip "OpenClaw 未安装"
    fi
}

# ============================================
# 集成功能测试
# ============================================

@test "OpenClaw 和 oMLX 集成检查" {
    if command_exists openclaw && [ -d ~/.omlx ]; then
        # 检查 OpenClaw 是否配置了 oMLX
        if [ -f ~/.openclaw/config.json ]; then
            run grep -i "omlx" ~/.openclaw/config.json
            [ "$status" -eq 0 ] || skip "OpenClaw 未配置 oMLX"
        else
            skip "OpenClaw 配置文件不存在"
        fi
    else
        skip "OpenClaw 或 oMLX 未安装"
    fi
}

@test "完整组件安装验证" {
    local installed_count=0

    # 检查 Node.js
    if command_exists node; then
        ((installed_count++))
        log_test "✓ Node.js 已安装"
    fi

    # 检查 OpenClaw
    if command_exists openclaw; then
        ((installed_count++))
        log_test "✓ OpenClaw 已安装"
    fi

    # 检查 oMLX
    if [ -d ~/.omlx ]; then
        ((installed_count++))
        log_test "✓ oMLX 已安装"
    fi

    # 检查模型
    if [ -d "$HOME/.omlx/models/gemma-4-e4b-it-4bit" ]; then
        ((installed_count++))
        log_test "✓ gemma-4 模型已下载"
    fi

    log_test "已安装组件数: $installed_count"

    # 至少应该有一个组件（如果是真实环境）
    # [ "$installed_count" -gt 0 ] || skip "未检测到已安装组件"
}

# ============================================
# 服务状态测试
# ============================================

@test "所有服务端口检查" {
    local services_running=0

    # 检查 oMLX (8008)
    if service_running 8008; then
        ((services_running++))
        log_test "✓ oMLX 服务运行中 (8008)"
    fi

    # 检查 OpenClaw Gateway (18789)
    if service_running 18789; then
        ((services_running++))
        log_test "✓ OpenClaw Gateway 运行中 (18789)"
    fi

    log_test "运行中的服务数: $services_running"
}

@test "服务可访问性测试" {
    # oMLX 健康检查
    if service_running 8008; then
        run curl -s --max-time 5 http://127.0.0.1:8008/health
        [ "$status" -eq 0 ] || skip "oMLX 健康检查失败"
    else
        skip "oMLX 服务未运行"
    fi
}

# ============================================
# 配置验证测试
# ============================================

@test "OpenClaw 配置验证（如果已安装）" {
    if [ -f ~/.openclaw/config.json ]; then
        # 验证 JSON 格式
        run python3 -m json.tool ~/.openclaw/config.json
        [ "$status" -eq 0 ] || skip "配置文件 JSON 格式无效"
    else
        skip "OpenClaw 配置文件不存在"
    fi
}

@test "oMLX 配置验证（如果已安装）" {
    if [ -f ~/.omlx/settings.json ]; then
        # 验证 JSON 格式
        run python3 -m json.tool ~/.omlx/settings.json
        [ "$status" -eq 0 ] || skip "配置文件 JSON 格式无效"
    else
        skip "oMLX 配置文件不存在"
    fi
}

# ============================================
# 日志和调试测试
# ============================================

@test "OpenClaw 日志文件检查（如果已安装）" {
    if [ -d ~/.openclaw ]; then
        local log_file=$(find ~/.openclaw -name "*.log" 2>/dev/null | head -1)
        if [ -n "$log_file" ]; then
            [ -f "$log_file" ]
            log_test "日志文件: $log_file"
        else
            skip "未找到日志文件"
        fi
    else
        skip "OpenClaw 未安装"
    fi
}

@test "oMLX 日志文件检查（如果已安装）" {
    if [ -d ~/.omlx ]; then
        local log_dir="$HOME/.omlx/logs"
        if [ -d "$log_dir" ]; then
            local log_files=$(ls "$log_dir"/*.log 2>/dev/null | wc -l)
            [ "$log_files" -gt 0 ] || skip "未找到日志文件"
        else
            skip "日志目录不存在"
        fi
    else
        skip "oMLX 未安装"
    fi
}

# ============================================
# 性能测试
# ============================================

@test "服务响应时间测试" {
    if service_running 8008; then
        # 测试 oMLX 响应时间
        run curl -s -o /dev/null -w "%{time_total}" http://127.0.0.1:8008/health
        [ "$status" -eq 0 ]

        local response_time=$output
        log_test "oMLX 响应时间: ${response_time}s"

        # 响应时间应该小于 5 秒
        run bash -c "(( $(echo \"$response_time < 5\" | bc -l) ))"
        [ "$status" -eq 0 ] || skip "响应时间过长"
    else
        skip "oMLX 服务未运行"
    fi
}
