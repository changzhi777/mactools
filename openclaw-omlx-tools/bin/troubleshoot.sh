#!/bin/bash
# OpenClaw + oMLX 问题排查脚本
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

# 问题计数
ISSUE_COUNT=0
FIX_COUNT=0

# 打印头部
print_header() {
    clear
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║       OpenClaw + oMLX 问题排查工具                        ║"
    echo "║                                                            ║"
    echo "║       版本：V1.0.0 | 更新：2026-04-18                     ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# 打印问题
print_issue() {
    echo -e "${RED}🔴 问题${NC}: $1"
    ((ISSUE_COUNT++))
}

# 打印修复
print_fix() {
    echo -e "${GREEN}✅ 修复${NC}: $1"
    ((FIX_COUNT++))
}

# 打印警告
print_warning() {
    echo -e "${YELLOW}⚠️  警告${NC}: $1"
}

# 打印信息
print_info() {
    echo -e "${BLUE}ℹ️  信息${NC}: $1"
}

# 打印成功
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

# 打印部分标题
print_section() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# 诊断1：检查服务状态
check_service_status() {
    print_section "诊断1：服务状态检查"

    # 检查 omlx 服务
    if lsof -i :8008 &> /dev/null; then
        print_success "oMLX 服务正在运行（端口 8008）"

        # 测试健康检查
        if curl -s http://127.0.0.1:8008/health &> /dev/null; then
            print_success "oMLX 健康检查端点响应正常"
        else
            print_issue "oMLX 健康检查端点无响应"
            print_fix "尝试重启 omlx 服务：killall omlx && omlx serve --port 8008"
        fi
    else
        print_issue "oMLX 服务未运行（端口 8008 未监听）"
        print_fix "启动 omlx 服务：omlx serve --port 8008"
    fi

    # 检查 openclaw 服务
    if lsof -i :18789 &> /dev/null; then
        print_success "OpenClaw 网关正在运行（端口 18789）"
    else
        print_warning "OpenClaw 网关未运行（端口 18789）"
        print_info "启动网关：openclaw gateway start"
    fi
}

# 诊断2：检查端口占用
check_port_conflicts() {
    print_section "诊断2：端口冲突检查"

    local ports=(8008 18789)

    for port in "${ports[@]}"; do
        echo ""
        print_info "检查端口 $port..."

        if lsof -i :$port &> /dev/null; then
            local pid=$(lsof -ti :$port)
            local process=$(ps -p $pid -o comm= 2>/dev/null || echo "unknown")

            if [ "$port" = "8008" ]; then
                if [ "$process" = "omlx" ]; then
                    print_success "端口 $port 被正确的进程占用（$process, PID: $pid）"
                else
                    print_issue "端口 $port 被其他进程占用（$process, PID: $pid）"
                    print_fix "终止进程：kill -9 $pid 或 查看详情：ps -p $pid"
                fi
            else
                print_info "端口 $port 已被占用（$process, PID: $pid）"
            fi
        else
            print_info "端口 $port 未被占用"
        fi
    done
}

# 诊断3：检查配置文件
check_config_files() {
    print_section "诊断3：配置文件检查"

    # omlx 配置
    local omlx_config="$HOME/.omlx/settings.json"
    echo ""
    print_info "检查 omlx 配置：$omlx_config"

    if [ -f "$omlx_config" ]; then
        if jq empty "$omlx_config" 2>/dev/null; then
            print_success "oMLX 配置文件格式正确"

            # 检查关键配置
            local port=$(jq -r '.server.port' "$omlx_config")
            local api_key=$(jq -r '.auth.api_key' "$omlx_config")
            local model_dir=$(jq -r '.model.model_dir' "$omlx_config")

            if [ "$port" = "8008" ]; then
                print_success "端口配置正确：$port"
            else
                print_issue "端口配置异常：$port（预期：8008）"
            fi

            if [ "$api_key" = "ak47" ]; then
                print_success "API Key 配置正确：$api_key"
            else
                print_warning "API Key 配置：$api_key"
            fi

            if [ -d "$model_dir" ]; then
                print_success "模型目录存在：$model_dir"
            else
                print_issue "模型目录不存在：$model_dir"
                print_fix "创建目录：mkdir -p $model_dir"
            fi
        else
            print_issue "oMLX 配置文件格式错误"
            print_fix "验证 JSON 格式：jq empty $omlx_config"
        fi
    else
        print_issue "oMLX 配置文件不存在"
        print_fix "运行配置向导：./bin/config-omlx.sh"
    fi

    # openclaw 配置
    local openclaw_config="$HOME/.openclaw/openclaw.json"
    echo ""
    print_info "检查 OpenClaw 配置：$openclaw_config"

    if [ -f "$openclaw_config" ]; then
        if jq empty "$openclaw_config" 2>/dev/null; then
            print_success "OpenClaw 配置文件格式正确"

            # 检查 omlx 提供商
            if jq -e '.models.providers.omlx' "$openclaw_config" &> /dev/null; then
                print_success "oMLX 提供商已配置"

                local base_url=$(jq -r '.models.providers.omlx.baseUrl' "$openclaw_config")
                local api_key=$(jq -r '.models.providers.omlx.apiKey' "$openclaw_config")

                if [ "$base_url" = "http://127.0.0.1:8008/v1" ]; then
                    print_success "oMLX baseUrl 配置正确"
                else
                    print_issue "oMLX baseUrl 配置：$base_url"
                    print_fix "更新配置：openclaw config set models.providers.omlx.baseUrl http://127.0.0.1:8008/v1"
                fi

                if [ "$api_key" = "ak47" ]; then
                    print_success "oMLX apiKey 配置正确"
                else
                    print_warning "oMLX apiKey 配置：$api_key"
                fi
            else
                print_issue "oMLX 提供商未配置"
                print_fix "添加 omlx 提供商配置"
            fi
        else
            print_issue "OpenClaw 配置文件格式错误"
            print_fix "验证 JSON 格式：jq empty $openclaw_config"
        fi
    else
        print_issue "OpenClaw 配置文件不存在"
        print_fix "初始化 OpenClaw：openclaw init"
    fi
}

# 诊断4：检查模型文件
check_model_files() {
    print_section "诊断4：模型文件检查"

    local model_dir="$HOME/.omlx/models"
    local expected_model="gemma-4-e4b-it-4bit"

    echo ""
    print_info "检查模型目录：$model_dir"

    if [ -d "$model_dir" ]; then
        local model_count=$(find "$model_dir" -type d -mindepth 1 | wc -l | tr -d ' ')

        print_info "已安装模型数量：$model_count"

        if [ $model_count -eq 0 ]; then
            print_issue "未找到任何模型"
            print_fix "下载模型：omlx model download $expected_model"
        else
            print_success "找到 $model_count 个模型"

            echo ""
            print_info "已安装的模型："
            find "$model_dir" -type d -mindepth 1 -maxdepth 1 | while read -r model_path; do
                local model_name=$(basename "$model_path")
                local model_size=$(du -sh "$model_path" 2>/dev/null | cut -f1)
                echo "  - $model_name ($model_size)"
            done
        fi

        # 检查特定模型
        if [ -d "$model_dir/$expected_model" ]; then
            print_success "gemma-4-e4b-it-4bit 模型已安装"
        else
            print_issue "gemma-4-e4b-it-4bit 模型未找到"
            print_fix "下载模型：omlx model download $expected_model"
        fi
    else
        print_issue "模型目录不存在"
        print_fix "创建目录并下载模型：mkdir -p $model_dir && omlx model download $expected_model"
    fi
}

# 诊断5：网络连接检查
check_network() {
    print_section "诊断5：网络连接检查"

    echo ""
    print_info "检查本地网络连接..."

    # 测试本地回环
    if ping -c 1 127.0.0.1 &> /dev/null; then
        print_success "本地回环地址正常"
    else
        print_issue "本地回环地址异常"
        print_fix "检查网络配置：系统偏好设置 → 网络"
    fi

    # 测试 omlx 端点
    if curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8008/health 2>/dev/null | grep -q "200"; then
        print_success "oMLX API 端点可访问"
    else
        print_issue "oMLX API 端点不可访问"
        print_fix "检查 omlx 服务状态：lsof -i :8008"
    fi

    # 测试 DNS 解析（如果需要云端 API）
    echo ""
    print_info "检查 DNS 解析..."
    if nslookup api.openai.com &> /dev/null; then
        print_success "DNS 解析正常"
    else
        print_warning "DNS 解析可能有问题"
        print_fix "检查 DNS 设置：系统偏好设置 → 网络 → DNS"
    fi
}

# 诊断6：权限检查
check_permissions() {
    print_section "诊断6：权限检查"

    echo ""
    print_info "检查文件权限..."

    # 检查配置文件权限
    local files=(
        "$HOME/.omlx/settings.json"
        "$HOME/.openclaw/openclaw.json"
    )

    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            local perms=$(ls -l "$file" | awk '{print $1}')
            print_info "$file: $perms"

            if [ -r "$file" ] && [ -w "$file" ]; then
                print_success "文件可读写"
            else
                print_issue "文件权限不足"
                print_fix "修改权限：chmod 644 $file"
            fi
        fi
    done

    # 检查脚本执行权限
    echo ""
    print_info "检查脚本执行权限..."
    if [ -x "./bin/troubleshoot.sh" ]; then
        print_success "脚本具有执行权限"
    else
        print_issue "脚本缺少执行权限"
        print_fix "添加执行权限：chmod +x bin/*.sh"
    fi
}

# 诊断7：日志分析
analyze_logs() {
    print_section "诊断7：日志分析"

    # omlx 日志
    local omlx_log="$HOME/omlx.log"
    echo ""
    print_info "检查 omlx 日志：$omlx_log"

    if [ -f "$omlx_log" ]; then
        local log_size=$(du -h "$omlx_log" | cut -f1)
        print_info "日志文件大小：$log_size"

        print_info "最近的错误信息："
        local errors=$(grep -i "error\|exception\|failed" "$omlx_log" 2>/dev/null | tail -5)
        if [ -n "$errors" ]; then
            echo "$errors" | while IFS= read -r line; do
                echo -e "${RED}  $line${NC}"
            done
        else
            print_success "未发现错误信息"
        fi
    else
        print_info "oMLx 日志文件不存在（正常，如果使用 GUI 版本）"
    fi

    # openclaw 日志
    echo ""
    print_info "检查 OpenClaw 日志目录：/tmp/openclaw/"
    if [ -d "/tmp/openclaw" ]; then
        local latest_log=$(ls -t /tmp/openclaw/*.log 2>/dev/null | head -1)
        if [ -n "$latest_log" ]; then
            print_info "最新日志：$latest_log"
            print_info "最近的错误信息："
            tail -10 "$latest_log" | grep -i "error\|exception\|failed" || print_success "未发现错误信息"
        fi
    else
        print_info "OpenClaw 日志目录不存在"
    fi
}

# 诊断8：系统资源检查
check_system_resources() {
    print_section "诊断8：系统资源检查"

    echo ""
    print_info "检查系统资源..."

    # 内存使用
    local mem_total=$(sysctl hw.memsize | awk '{print $2/1024/1024/1024 " GB"}')
    local mem_used=$(vm_stat | perl -ne '/page size of (\d+)/ and $ps=$1; /Pages free\s+(\d+)/ and printf "%.2f GB\n", $1*$ps/1024/1024/1024' 2>/dev/null || echo "N/A")

    print_info "总内存：$mem_total"
    print_info "可用内存：$mem_used"

    # 磁盘空间
    local disk_usage=$(df -h / | tail -1 | awk '{print $5 " 已使用"}')
    print_info "磁盘使用：$disk_usage"

    # CPU 负载
    local load=$(uptime | awk -F'load average:' '{print $2}')
    print_info "CPU 负载：$load"

    # omlx 进程资源
    echo ""
    print_info "oMLX 进程资源："
    if pgrep -x omlx > /dev/null; then
        local omlx_pid=$(pgrep -x omlx | head -1)
        local omlx_mem=$(ps -p $omlx_pid -o rss= 2>/dev/null | awk '{print $1/1024/1024 " GB"}')
        local omlx_cpu=$(ps -p $omlx_pid -o %cpu= 2>/dev/null)
        print_success "PID: $omlx_pid | 内存: $omlx_mem | CPU: $omlx_cpu%"
    else
        print_warning "oMLX 进程未运行"
    fi
}

# 生成诊断报告
generate_report() {
    print_section "诊断报告"

    echo ""
    echo -e "${CYAN}发现的问题：${RED} $ISSUE_COUNT${NC}"
    echo -e "${CYAN}可用的修复：${GREEN} $FIX_COUNT${NC}"
    echo ""

    if [ $ISSUE_COUNT -eq 0 ]; then
        echo -e "${GREEN}🎉 未发现问题！系统运行正常。${NC}"
    else
        echo -e "${YELLOW}建议操作：${NC}"
        echo "  1. 按照上述修复提示逐一解决问题"
        echo "  2. 运行验证脚本：./bin/verify-config.sh"
        echo "  3. 如问题持续，查看完整文档：docs/troubleshooting.md"
    fi

    echo ""
    echo -e "${CYAN}生成详细报告...${NC}"

    local report_file="$HOME/openclaw-omlx-diagnostic-$(date +%Y%m%d_%H%M%S).txt"
    {
        echo "OpenClaw + oMLX 诊断报告"
        echo "生成时间：$(date)"
        echo ""
        echo "系统信息："
        sw_vers
        echo ""
        echo "配置文件："
        cat "$HOME/.omlx/settings.json" 2>/dev/null || echo "未找到"
        echo ""
        cat "$HOME/.openclaw/openclaw.json" 2>/dev/null || echo "未找到"
    } > "$report_file"

    print_success "详细报告已保存：$report_file"
}

# 主函数
main() {
    print_header

    check_service_status
    check_port_conflicts
    check_config_files
    check_model_files
    check_network
    check_permissions
    analyze_logs
    check_system_resources
    generate_report

    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}                        诊断完成                              ${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# 运行主函数
main "$@"
