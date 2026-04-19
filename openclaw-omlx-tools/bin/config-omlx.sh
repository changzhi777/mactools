#!/bin/bash
# OpenClaw + oMLX 配置向导脚本
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

# 配置备份目录
BACKUP_DIR="$HOME/.openclaw-omlx-backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# 打印头部
print_header() {
    clear
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║       OpenClaw + oMLX 配置向导                             ║"
    echo "║                                                            ║"
    echo "║       版本：V1.0.0 | 更新：2026-04-18                     ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# 打印步骤
print_step() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# 打印成功
print_success() {
    echo -e "${GREEN}✅${NC} $1"
}

# 打印错误
print_error() {
    echo -e "${RED}❌${NC} $1"
}

# 打印信息
print_info() {
    echo -e "${CYAN}ℹ️${NC} $1"
}

# 打印警告
print_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

# 创建备份目录
create_backup_dir() {
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
        print_success "创建备份目录：$BACKUP_DIR"
    fi
}

# 备份配置文件
backup_config() {
    local file=$1
    local backup_name=$(basename "$file")

    if [ -f "$file" ]; then
        cp "$file" "$BACKUP_DIR/${backup_name}.backup.$TIMESTAMP"
        print_success "备份配置：$file → $BACKUP_DIR/${backup_name}.backup.$TIMESTAMP"
    else
        print_warning "文件不存在，跳过备份：$file"
    fi
}

# 恢复配置
restore_config() {
    local file=$1
    local backup_name=$(basename "$file")

    if [ -f "$BACKUP_DIR/${backup_name}.backup.$TIMESTAMP" ]; then
        cp "$BACKUP_DIR/${backup_name}.backup.$TIMESTAMP" "$file"
        print_success "恢复配置：$file"
    else
        print_error "备份文件不存在：$BACKUP_DIR/${backup_name}.backup.$TIMESTAMP"
        return 1
    fi
}

# 步骤1：检查现有配置
step_check_existing() {
    print_step "步骤 1/6：检查现有配置"

    echo ""
    print_info "检查 omlx 配置..."

    if [ -f "$HOME/.omlx/settings.json" ]; then
        print_success "找到 omlx 配置文件"
        jq '.' "$HOME/.omlx/settings.json" 2>/dev/null || print_error "JSON 格式错误"
    else
        print_warning "未找到 omlx 配置文件"
    fi

    echo ""
    print_info "检查 OpenClaw 配置..."

    if [ -f "$HOME/.openclaw/openclaw.json" ]; then
        print_success "找到 OpenClaw 配置文件"

        if jq -e '.models.providers.omlx' "$HOME/.openclaw/openclaw.json" &> /dev/null; then
            print_success "oMLX 提供商已配置"
            jq '.models.providers.omlx' "$HOME/.openclaw/openclaw.json"
        else
            print_warning "oMLX 提供商未配置"
        fi
    else
        print_warning "未找到 OpenClaw 配置文件"
    fi
}

# 步骤2：备份现有配置
step_backup_config() {
    print_step "步骤 2/6：备份现有配置"

    create_backup_dir

    echo ""
    print_info "备份配置文件..."

    backup_config "$HOME/.omlx/settings.json"
    backup_config "$HOME/.openclaw/openclaw.json"

    echo ""
    print_success "配置备份完成"
}

# 步骤3：配置 oMLX
step_configure_omlx() {
    print_step "步骤 3/6：配置 oMLX"

    echo ""
    print_info "oMLX 配置选项："
    echo "  1) 使用默认配置（推荐）"
    echo "  2) 自定义配置"
    echo ""
    read -p "请选择 [1-2]（默认：1）: " omlx_choice
    omlx_choice=${omlx_choice:-1}

    case $omlx_choice in
        1)
            print_info "使用默认配置..."

            # 创建或更新 omlx 配置
            cat > "$HOME/.omlx/settings.json" << 'EOF'
{
  "version": "1.0",
  "server": {
    "host": "127.0.0.1",
    "port": 8008,
    "log_level": "info",
    "cors_origins": ["*"]
  },
  "model": {
    "model_dirs": ["~/.omlx/models"],
    "model_dir": "~/.omlx/models",
    "max_model_memory": "auto",
    "model_fallback": false
  },
  "memory": {
    "max_process_memory": "auto",
    "prefill_memory_guard": true
  },
  "scheduler": {
    "max_concurrent_requests": 12
  },
  "cache": {
    "enabled": true,
    "ssd_cache_dir": null,
    "ssd_cache_max_size": "auto",
    "hot_cache_max_size": "536870912",
    "initial_cache_blocks": 384
  },
  "auth": {
    "api_key": "ak47",
    "secret_key": "8d73842dbfb606ba423b62fec1343fc927d7e425fc74827a2f43958f4c59337b",
    "skip_api_key_verification": false,
    "sub_keys": []
  },
  "sampling": {
    "max_context_window": 32768,
    "max_tokens": 32768,
    "temperature": 1.0,
    "top_p": 0.95,
    "top_k": 0,
    "repetition_penalty": 1.0
  },
  "logging": {
    "log_dir": null,
    "retention_days": 7
  },
  "ui": {
    "language": "zh"
  }
}
EOF

            print_success "oMLx 配置文件已创建"
            ;;
        2)
            print_info "自定义配置..."

            # 端口
            echo ""
            read -p "输入端口号（默认：8008）: " omlx_port
            omlx_port=${omlx_port:-8008}

            # API Key
            read -p "输入 API Key（默认：ak47）: " omlx_key
            omlx_key=${omlx_key:-ak47}

            # 模型目录
            read -p "输入模型目录（默认：~/.omlx/models）: " omlx_models
            omlx_models=${omlx_models:-~/.omlx/models}

            # 创建配置
            cat > "$HOME/.omlx/settings.json" << EOF
{
  "version": "1.0",
  "server": {
    "host": "127.0.0.1",
    "port": $omlx_port,
    "log_level": "info",
    "cors_origins": ["*"]
  },
  "model": {
    "model_dirs": ["$omlx_models"],
    "model_dir": "$omlx_models"
  },
  "auth": {
    "api_key": "$omlx_key"
  }
}
EOF

            print_success "自定义 oMLX 配置已创建"
            ;;
        *)
            print_error "无效选择，跳过此步骤"
            ;;
    esac
}

# 步骤4：配置 OpenClaw
step_configure_openclaw() {
    print_step "步骤 4/6：配置 OpenClaw"

    echo ""
    print_info "OpenClaw oMLX 提供商配置选项："
    echo "  1) 添加 oMLX 为备用模型（推荐）"
    echo "  2) 设置 oMLX 为主模型"
    echo "  3) 仅添加提供商配置"
    echo "  4) 跳过"
    echo ""
    read -p "请选择 [1-4]（默认：1）: " openclaw_choice
    openclaw_choice=${openclaw_choice:-1}

    # 获取 omlx 配置
    local omlx_port=$(jq -r '.server.port // 8008' "$HOME/.omlx/settings.json" 2>/dev/null || echo "8008")
    local omlx_key=$(jq -r '.auth.api_key // ak47' "$HOME/.omlx/settings.json" 2>/dev/null || echo "ak47")
    local omlx_base_url="http://127.0.0.1:${omlx_port}/v1"

    case $openclaw_choice in
        1|2|3)
            # 添加 omlx 提供商配置
            print_info "添加 oMLX 提供商配置..."

            # 使用 openclaw config 命令
            openclaw config set models.providers.omlx.baseUrl "$omlx_base_url" 2>/dev/null || \
            print_warning "openclaw config 命令失败，需要手动编辑配置文件"

            openclaw config set models.providers.omlx.apiKey "$omlx_key" 2>/dev/null || true

            openclaw config set models.providers.omlx.api "openai-completions" 2>/dev/null || true

            print_success "oMLX 提供商配置已添加"

            # 根据选择设置模型
            if [ "$openclaw_choice" = "1" ]; then
                print_info "设置 oMLX 为备用模型..."
                openclaw config set agents.defaults.model.fallbacks[0] "omlx/gemma-4-e4b-it-4bit" 2>/dev/null || \
                print_warning "需要手动配置 fallbacks"
                print_success "oMLX 已设置为备用模型"
            elif [ "$openclaw_choice" = "2" ]; then
                print_info "设置 oMLX 为主模型..."
                openclaw config set agents.defaults.model.primary "omlx/gemma-4-e4b-it-4bit" 2>/dev/null || \
                print_warning "需要手动配置 primary model"
                print_success "oMLX 已设置为主模型"
            fi
            ;;
        4)
            print_info "跳过 OpenClaw 配置"
            ;;
        *)
            print_error "无效选择，跳过此步骤"
            ;;
    esac
}

# 步骤5：验证配置
step_validate_config() {
    print_step "步骤 5/6：验证配置"

    echo ""
    print_info "验证 oMLX 配置..."

    if jq empty "$HOME/.omlx/settings.json" 2>/dev/null; then
        print_success "oMLX 配置文件格式正确"
    else
        print_error "oMLX 配置文件格式错误"
        return 1
    fi

    echo ""
    print_info "验证 OpenClaw 配置..."

    if jq empty "$HOME/.openclaw/openclaw.json" 2>/dev/null; then
        print_success "OpenClaw 配置文件格式正确"
    else
        print_error "OpenClaw 配置文件格式错误"
        return 1
    fi

    # 检查 omlx 服务
    echo ""
    print_info "检查 oMLX 服务状态..."

    if lsof -i :8008 &> /dev/null; then
        print_success "oMLX 服务正在运行"

        # 测试 API
        if curl -s http://127.0.0.1:8008/health &> /dev/null; then
            print_success "oMLX API 响应正常"
        else
            print_warning "oMLX API 无响应"
        fi
    else
        print_warning "oMLX 服务未运行"
        print_info "启动命令：omlx serve --port 8008"
    fi
}

# 步骤6：完成和后续步骤
step_complete() {
    print_step "步骤 6/6：配置完成"

    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                    配置已完成！                            ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    print_info "后续步骤："

    echo ""
    echo "1️⃣  启动 oMLX 服务："
    echo "   omlx serve --port 8008"
    echo ""
    echo "   或后台运行："
    echo "   nohup omlx serve --port 8008 > ~/omlx.log 2>&1 &"

    echo ""
    echo "2️⃣  验证配置："
    echo "   ./bin/verify-config.sh"

    echo ""
    echo "3️⃣  测试 API："
    echo "   ./bin/test-api.sh"

    echo ""
    echo "4️⃣  测试推理："
    echo "   openclaw infer model run --model omlx/gemma-4-e4b-it-4bit --prompt '你好'"

    echo ""
    echo -e "${CYAN}配置备份位置：${NC}"
    echo "   $BACKUP_DIR/"

    echo ""
    echo -e "${CYAN}如需恢复备份：${NC}"
    echo "   cp $BACKUP_DIR/settings.json.backup.$TIMESTAMP ~/.omlx/settings.json"
    echo "   cp $BACKUP_DIR/openclaw.json.backup.$TIMESTAMP ~/.openclaw/openclaw.json"
}

# 交互式主菜单
show_menu() {
    echo ""
    echo -e "${CYAN}请选择操作：${NC}"
    echo "  1) 完整配置向导（推荐）"
    echo "  2) 仅配置 oMLX"
    echo "  3) 仅配置 OpenClaw"
    echo "  4) 验证现有配置"
    echo "  5) 恢复备份"
    echo "  0) 退出"
    echo ""
    read -p "请选择 [0-5]: " menu_choice

    case $menu_choice in
        1)
            print_header
            step_check_existing
            step_backup_config
            step_configure_omlx
            step_configure_openclaw
            step_validate_config
            step_complete
            ;;
        2)
            print_header
            step_backup_config
            step_configure_omlx
            step_validate_config
            ;;
        3)
            print_header
            step_backup_config
            step_configure_openclaw
            step_validate_config
            ;;
        4)
            print_header
            step_validate_config
            ;;
        5)
            print_info "可用备份："
            ls -lh "$BACKUP_DIR/" 2>/dev/null || print_error "备份目录不存在"
            echo ""
            read -p "输入要恢复的备份文件名: " backup_file
            if [ -f "$BACKUP_DIR/$backup_file" ]; then
                case "$backup_file" in
                    *settings.json*)
                        restore_config "$HOME/.omlx/settings.json"
                        ;;
                    *openclaw.json*)
                        restore_config "$HOME/.openclaw/openclaw.json"
                        ;;
                    *)
                        print_error "无法识别的备份文件"
                        ;;
                esac
            else
                print_error "备份文件不存在"
            fi
            ;;
        0)
            print_info "退出配置向导"
            exit 0
            ;;
        *)
            print_error "无效选择"
            ;;
    esac
}

# 主函数
main() {
    print_header

    # 检查是否在正确的目录
    if [ ! -d "./bin" ]; then
        print_error "请在 openclaw-omlx-tools 目录下运行此脚本"
        exit 1
    fi

    # 检查必要工具
    if ! command -v jq &> /dev/null; then
        print_error "缺少必要工具：jq"
        print_info "安装命令：brew install jq"
        exit 1
    fi

    # 显示菜单
    show_menu

    echo ""
    print_success "配置向导完成！"
}

# 运行主函数
main "$@"
