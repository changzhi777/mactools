#!/bin/bash
#
# ==============================================================================
# RustDesk Server Installer - 防火墙配置模块
# ==============================================================================
#
# 功能说明：
#   自动配置防火墙规则，开放 RustDesk 所需端口
#
# 使用方法：
#   source lib/firewall.sh
#   configure_firewall
#
# ==============================================================================

# RustDesk 端口定义
readonly HBBS_PORTS=("21114/tcp" "21115/tcp" "21116/tcp" "21116/udp" "21118/tcp")
readonly HBBR_PORTS=("21117/tcp" "21119/tcp")
readonly ALL_PORTS=("${HBBS_PORTS[@]}" "${HBBR_PORTS[@]}")

#
# 配置 UFW 防火墙
#
configure_ufw() {
    log_step "配置 UFW 防火墙..."

    local rules_added=0

    # 开放 HBBS 端口
    for port in "${HBBS_PORTS[@]}"; do
        local port_num=$(echo "$port" | cut -d'/' -f1)
        local proto=$(echo "$port" | cut -d'/' -f2)

        if ! ufw status | grep -q "$port"; then
            ufw allow "$port" &>/dev/null
            if [[ $? -eq 0 ]]; then
                log_success "已开放端口: $port"
                ((rules_added++))
            else
                log_warning "开放端口失败: $port"
            fi
        else
            log_info "端口已存在: $port"
        fi
    done

    # 开放 HBBR 端口
    for port in "${HBBR_PORTS[@]}"; do
        local port_num=$(echo "$port" | cut -d'/' -f1)
        local proto=$(echo "$port" | cut -d'/' -f2)

        if ! ufw status | grep -q "$port"; then
            ufw allow "$port" &>/dev/null
            if [[ $? -eq 0 ]]; then
                log_success "已开放端口: $port"
                ((rules_added++))
            else
                log_warning "开放端口失败: $port"
            fi
        else
            log_info "端口已存在: $port"
        fi
    done

    if [[ $rules_added -gt 0 ]]; then
        log_success "UFW 防火墙配置完成（添加 $rules_added 条规则）"
        return 0
    else
        log_info "UFW 防火墙规则已存在"
        return 0
    fi
}

#
# 配置 firewalld 防火墙
#
configure_firewalld() {
    log_step "配置 firewalld 防火墙..."

    local rules_added=0

    # 开放 HBBS 端口
    for port in "${HBBS_PORTS[@]}"; do
        local port_num=$(echo "$port" | cut -d'/' -f1)
        local proto=$(echo "$port" | cut -d'/' -f2)

        if ! firewall-cmd --list-ports | grep -q "$port"; then
            firewall-cmd --permanent --add-port="$port" &>/dev/null
            if [[ $? -eq 0 ]]; then
                log_success "已开放端口: $port"
                ((rules_added++))
            else
                log_warning "开放端口失败: $port"
            fi
        else
            log_info "端口已存在: $port"
        fi
    done

    # 开放 HBBR 端口
    for port in "${HBBR_PORTS[@]}"; do
        local port_num=$(echo "$port" | cut -d'/' -f1)
        local proto=$(echo "$port" | cut -d'/' -f2)

        if ! firewall-cmd --list-ports | grep -q "$port"; then
            firewall-cmd --permanent --add-port="$port" &>/dev/null
            if [[ $? -eq 0 ]]; then
                log_success "已开放端口: $port"
                ((rules_added++))
            else
                log_warning "开放端口失败: $port"
            fi
        else
            log_info "端口已存在: $port"
        fi
    done

    # 重新加载防火墙规则
    if [[ $rules_added -gt 0 ]]; then
        firewall-cmd --reload &>/dev/null
        log_success "firewalld 防火墙配置完成（添加 $rules_added 条规则）"
    else
        log_info "firewalld 防火墙规则已存在"
    fi

    return 0
}

#
# 配置 iptables 防火墙
#
configure_iptables() {
    log_step "配置 iptables 防火墙..."

    local rules_added=0

    # 开放 HBBS 端口
    for port in "${HBBS_PORTS[@]}"; do
        local port_num=$(echo "$port" | cut -d'/' -f1)
        local proto=$(echo "$port" | cut -d'/' -f2)

        # 检查规则是否已存在
        if ! iptables -L INPUT -n | grep -q "dpt:$port_num"; then
            iptables -A INPUT -p "$proto" --dport "$port_num" -j ACCEPT &>/dev/null
            if [[ $? -eq 0 ]]; then
                log_success "已开放端口: $port"
                ((rules_added++))
            else
                log_warning "开放端口失败: $port"
            fi
        else
            log_info "端口已存在: $port"
        fi
    done

    # 开放 HBBR 端口
    for port in "${HBBR_PORTS[@]}"; do
        local port_num=$(echo "$port" | cut -d'/' -f1)
        local proto=$(echo "$port" | cut -d'/' -f2)

        if ! iptables -L INPUT -n | grep -q "dpt:$port_num"; then
            iptables -A INPUT -p "$proto" --dport "$port_num" -j ACCEPT &>/dev/null
            if [[ $? -eq 0 ]]; then
                log_success "已开放端口: $port"
                ((rules_added++))
            else
                log_warning "开放端口失败: $port"
            fi
        else
            log_info "端口已存在: $port"
        fi
    done

    # 保存 iptables 规则
    if [[ $rules_added -gt 0 ]]; then
        if command_exists iptables-save; then
            # Debian/Ubuntu
            if [[ -f /etc/debian_version ]]; then
                iptables-save > /etc/iptables/rules.v4 2>/dev/null || \
                iptables-save > /etc/iptables.up.rules 2>/dev/null || \
                log_warning "无法保存 iptables 规则，重启后可能失效"
            # CentOS/RHEL
            elif command_exists service; then
                service iptables save &>/dev/null || \
                log_warning "无法保存 iptables 规则，重启后可能失效"
            fi
        fi
        log_success "iptables 防火墙配置完成（添加 $rules_added 条规则）"
    else
        log_info "iptables 防火墙规则已存在"
    fi

    return 0
}

#
# 删除 UFW 防火墙规则
#
remove_ufw_rules() {
    log_step "删除 UFW 防火墙规则..."

    local rules_removed=0

    for port in "${ALL_PORTS[@]}"; do
        ufw delete allow "$port" &>/dev/null
        if [[ $? -eq 0 ]]; then
            log_success "已删除端口规则: $port"
            ((rules_removed++))
        fi
    done

    log_success "已删除 $rules_removed 条 UFW 规则"
    return 0
}

#
# 删除 firewalld 防火墙规则
#
remove_firewalld_rules() {
    log_step "删除 firewalld 防火墙规则..."

    local rules_removed=0

    for port in "${ALL_PORTS[@]}"; do
        firewall-cmd --permanent --remove-port="$port" &>/dev/null
        if [[ $? -eq 0 ]]; then
            log_success "已删除端口规则: $port"
            ((rules_removed++))
        fi
    done

    # 重新加载防火墙
    firewall-cmd --reload &>/dev/null
    log_success "已删除 $rules_removed 条 firewalld 规则"
    return 0
}

#
# 删除 iptables 防火墙规则
#
remove_iptables_rules() {
    log_step "删除 iptables 防火墙规则..."

    local rules_removed=0

    for port in "${ALL_PORTS[@]}"; do
        local port_num=$(echo "$port" | cut -d'/' -f1)
        local proto=$(echo "$port" | cut -d'/' -f2)

        # 查找并删除规则
        local rule_num=$(iptables -L INPUT --line-numbers -n | grep "dpt:$port_num" | awk '{print $1}' | head -1)
        if [[ -n "$rule_num" ]]; then
            iptables -D INPUT "$rule_num" &>/dev/null
            if [[ $? -eq 0 ]]; then
                log_success "已删除端口规则: $port"
                ((rules_removed++))
            fi
        fi
    done

    # 保存规则
    if [[ $rules_removed -gt 0 ]]; then
        if command_exists iptables-save; then
            if [[ -f /etc/debian_version ]]; then
                iptables-save > /etc/iptables/rules.v4 2>/dev/null || \
                iptables-save > /etc/iptables.up.rules 2>/dev/null
            elif command_exists service; then
                service iptables save &>/dev/null
            fi
        fi
        log_success "已删除 $rules_removed 条 iptables 规则"
    else
        log_info "没有找到需要删除的规则"
    fi

    return 0
}

#
# 验证防火墙规则
#
verify_firewall_rules() {
    log_step "验证防火墙规则..."

    local firewall_type="${DETECTION_RESULTS[firewall_type]}"
    local all_ok=true

    case "$firewall_type" in
        ufw)
            echo ""
            echo "UFW 防火墙规则："
            ufw status | grep -E "21114|21115|21116|21117|21118|21119" || {
                log_warning "未找到 RustDesk 相关规则"
                all_ok=false
            }
            ;;
        firewalld)
            echo ""
            echo "firewalld 防火墙规则："
            firewall-cmd --list-ports | grep -E "21114|21115|21116|21117|21118|21119" || {
                log_warning "未找到 RustDesk 相关规则"
                all_ok=false
            }
            ;;
        iptables)
            echo ""
            echo "iptables 防火墙规则："
            iptables -L INPUT -n | grep -E "21114|21115|21116|21117|21118|21119" || {
                log_warning "未找到 RustDesk 相关规则"
                all_ok=false
            }
            ;;
        none)
            log_warning "未检测到防火墙，跳过验证"
            return 0
            ;;
    esac

    if [[ "$all_ok" == "true" ]]; then
        log_success "防火墙规则验证通过"
        return 0
    else
        log_error "防火墙规则验证失败"
        return 1
    fi
}

#
# 配置防火墙（主函数）
#
configure_firewall() {
    local firewall_type="${DETECTION_RESULTS[firewall_type]}"

    log_blank
    log_title "配置防火墙"

    case "$firewall_type" in
        ufw)
            log_info "检测到 UFW 防火墙"
            configure_ufw
            ;;
        firewalld)
            log_info "检测到 firewalld 防火墙"
            configure_firewalld
            ;;
        iptables)
            log_info "检测到 iptables 防火墙"
            configure_iptables
            ;;
        none)
            log_warning "未检测到防火墙"
            log_warning "建议启用防火墙以保护服务器安全"
            log_info "RustDesk 需要以下端口开放："
            echo "   - 21114/tcp (HBBS Web 控制台)"
            echo "   - 21115/tcp (HBBS NAT 测试)"
            echo "   - 21116/tcp (HBBS ID 注册)"
            echo "   - 21116/udp (HBBS 心跳)"
            echo "   - 21117/tcp (HBBR 中继服务)"
            echo "   - 21118/tcp (HBBS Web 客户端)"
            echo "   - 21119/tcp (HBBR Web 客户端)"
            ;;
        *)
            log_error "未知的防火墙类型: $firewall_type"
            return 1
            ;;
    esac

    # 验证规则
    if [[ "$firewall_type" != "none" ]]; then
        verify_firewall_rules
    fi

    return 0
}

#
# 删除防火墙规则（卸载时使用）
#
remove_firewall_rules() {
    local firewall_type="${DETECTION_RESULTS[firewall_type]}"

    log_blank
    log_title "删除防火墙规则"

    case "$firewall_type" in
        ufw)
            log_info "删除 UFW 防火墙规则"
            remove_ufw_rules
            ;;
        firewalld)
            log_info "删除 firewalld 防火墙规则"
            remove_firewalld_rules
            ;;
        iptables)
            log_info "删除 iptables 防火墙规则"
            remove_iptables_rules
            ;;
        none)
            log_info "未检测到防火墙，跳过删除"
            ;;
        *)
            log_warning "未知的防火墙类型: $firewall_type"
            ;;
    esac

    return 0
}
