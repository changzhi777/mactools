#!/bin/bash
# BB小子新闻获取模块
# 支持 RSS、API 和备用源获取

# 加载配置和工具
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 加载路径工具
if [[ -f "${SCRIPT_DIR}/path-utils.sh" ]]; then
    source "${SCRIPT_DIR}/path-utils.sh"
    CACHE_DIR=$(get_cache_dir "news")
else
    # 降级路径处理
    CACHE_DIR="${HOME}/.openclaw/workspaces/bb-kid/cache/news"
fi

# 设置默认值
REQUEST_TIMEOUT=${REQUEST_TIMEOUT:-10}
MAX_RETRIES=${MAX_RETRIES:-3}
USER_AGENT=${USER_AGENT:-"BB-Kid-News-Collector/2.0"}
CACHE_ENABLED=${CACHE_ENABLED:-true}
CACHE_DURATION=${CACHE_DURATION:-3600}
MAX_NEWS_ITEMS=${MAX_NEWS_ITEMS:-10}
SUMMARY_LENGTH=${SUMMARY_LENGTH:-100}

# 创建缓存目录
mkdir -p "${CACHE_DIR}"

# 颜色定义
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 从RSS源获取新闻
fetch_rss_news() {
    local category="$1"
    local limit="${2:-5}"
    local news_data=()

    echo -e "${CYAN}📡 正在从 RSS 源获取 ${category} 新闻...${NC}"

    # 查找该类别的所有源
    local sources=()
    for source in "${NEWS_SOURCES[@]}"; do
        local cat="${source%%:*}"
        if [[ "${cat}" == "${category}" ]]; then
            sources+=("${source}")
        fi
    done

    # 如果没有找到，尝试备用源
    if [[ ${#sources[@]} -eq 0 ]]; then
        for source in "${BACKUP_SOURCES[@]}"; do
            local cat="${source%%:*}"
            if [[ "${cat}" == "${category}" ]]; then
                sources+=("${source}")
            fi
        done
    fi

    # 从源中获取新闻
    local count=0
    for source in "${sources[@]}"; do
        if [[ ${count} -ge ${limit} ]]; then
            break
        fi

        local rest="${source#*:}"
        local name="${rest%%:*}"
        local url="${rest##*:}"

        echo -e "  📡 获取源: ${name}"

        # 检查缓存
        local url_hash=$(echo "${url}" | md5sum | cut -d' ' -f1)
        local cache_file="${CACHE_DIR}/${url_hash}.xml"
        local use_cache=false

        if [[ "${CACHE_ENABLED}" == "true" ]] && [[ -f "${cache_file}" ]]; then
            local current_time=$(date +%s)
            local cache_mtime=$(stat -f %m "${cache_file}" 2>/dev/null || stat -c %Y "${cache_file}" 2>/dev/null)
            local cache_age=$((current_time - cache_mtime))

            if [[ ${cache_age} -lt ${CACHE_DURATION} ]]; then
                use_cache=true
                echo -e "    ${GREEN}✓ 使用缓存${NC}"
            fi
        fi

        local rss_content=""
        if [[ "${use_cache}" == "true" ]]; then
            rss_content=$(cat "${cache_file}")
        else
            # 获取RSS内容
            rss_content=$(curl -s -L --max-time ${REQUEST_TIMEOUT} \
                -A "${USER_AGENT}" \
                "${url}" 2>/dev/null)

            if [[ $? -eq 0 ]] && [[ -n "${rss_content}" ]]; then
                # 保存到缓存
                echo "${rss_content}" > "${cache_file}"
            else
                echo -e "    ${YELLOW}⚠️  获取失败，尝试下一个源${NC}"
                continue
            fi
        fi

        # 解析RSS（使用简单的XML解析）
        local items=()
        local in_item=false
        local current_item=""
        local title=""
        local link=""
        local description=""

        while IFS= read -r line; do
            if [[ "${line}" =~ \<item\> ]]; then
                in_item=true
                current_item=""
            elif [[ "${line}" =~ \<\/item\> ]]; then
                in_item=false
                if [[ -n "${title}" ]] && [[ ${count} -lt ${limit} ]]; then
                    # 清理HTML标签
                    description=$(echo "${description}" | sed -e 's/<[^>]*>//g' -e 's/&lt;/</g' -e 's/&gt;/>/g' -e 's/&amp;/\&/g')
                    description="${description:0:${SUMMARY_LENGTH}}"

                    news_data+=("${title}")
                    news_data+=("${link}")
                    news_data+=("${description}")
                    news_data+=("${name}")
                    ((count++))
                fi
                title=""
                link=""
                description=""
            elif [[ "${in_item}" == "true" ]]; then
                if [[ "${line}" =~ \<title\>(.+)\</title\> ]]; then
                    title="${BASH_REMATCH[1]}"
                elif [[ "${line}" =~ \<link\>(.+)\</link\> ]]; then
                    link="${BASH_REMATCH[1]}"
                elif [[ "${line}" =~ \<description\>(.+)\</description\> ]]; then
                    description="${BASH_REMATCH[1]}"
                fi
            fi
        done <<< "${rss_content}"
    done

    # 输出新闻数据
    if [[ ${#news_data[@]} -gt 0 ]]; then
        echo -e "${GREEN}✓ 成功获取 ${count} 条新闻${NC}"
        echo ""
        echo -e "${CYAN}📱 ${category} 新闻：${NC}"
        echo ""

        local i=0
        while [[ ${i} -lt ${#news_data[@]} ]]; do
            local title="${news_data[$i]}"
            ((i++))
            local link="${news_data[$i]}"
            ((i++))
            local description="${news_data[$i]}"
            ((i++))
            local source="${news_data[$i]}"
            ((i++))

            echo -e "${GREEN}  $((i/4)). ${title}${NC}"
            echo -e "     ${description}..."
            echo -e "     📰 来源: ${source}"
            echo -e "     🔗 链接: ${link}"
            echo ""
        done
    else
        echo -e "${YELLOW}⚠️  未能获取新闻，使用内置新闻源${NC}"
        return 1
    fi

    return 0
}

# 获取技术新闻（使用Hacker News API）
fetch_hackernews() {
    local limit="${1:-5}"

    echo -e "${CYAN}📡 正在从 Hacker News API 获取科技新闻...${NC}"

    local api_url="https://hacker-news.firebaseio.com/v0/topstories.json"
    local story_ids=$(curl -s --max-time ${REQUEST_TIMEOUT} "${api_url}")

    if [[ $? -ne 0 ]] || [[ -z "${story_ids}" ]]; then
        echo -e "${YELLOW}⚠️  Hacker News API 获取失败${NC}"
        return 1
    fi

    # 获取前N条新闻
    local count=0
    echo -e "${CYAN}📱 Hacker News 热门：${NC}"
    echo ""

    for id in $(echo "${story_ids}" | jq -r '.[]' | head -n "${limit}"); do
        if [[ ${count} -ge ${limit} ]]; then
            break
        fi

        local story_url="https://hacker-news.firebaseio.com/v0/item/${id}.json"
        local story=$(curl -s --max-time ${REQUEST_TIMEOUT} "${story_url}")

        if [[ $? -eq 0 ]] && [[ -n "${story}" ]]; then
            local title=$(echo "${story}" | jq -r '.title // empty' 2>/dev/null)
            local story_url_link=$(echo "${story}" | jq -r '.url // empty' 2>/dev/null)
            local score=$(echo "${story}" | jq -r '.score // 0' 2>/dev/null)

            # 如果没有URL，使用Hacker News讨论页
            if [[ -z "${story_url_link}" ]] || [[ "${story_url_link}" == "null" ]]; then
                story_url_link="https://news.ycombinator.com/item?id=${id}"
            fi

            if [[ -n "${title}" ]] && [[ "${title}" != "null" ]]; then
                echo -e "${GREEN}  $((count+1)). ${title}${NC}"
                echo -e "     👍 点赞: ${score}"
                echo -e "     🔗 链接: ${story_url_link}"
                echo ""
                ((count++))
            fi
        fi
    done

    echo -e "${GREEN}✓ 成功获取 ${count} 条 Hacker News${NC}"
    return 0
}

# 智能获取新闻（自动选择最佳源）
smart_fetch_news() {
    local category="$1"
    local limit="${2:-5}"

    case "${category}" in
        tech)
            # 优先使用 Hacker News API
            if ! fetch_hackernews "${limit}"; then
                fetch_rss_news "${category}" "${limit}"
            fi
            ;;
        *)
            # 其他类别使用 RSS
            if ! fetch_rss_news "${category}" "${limit}"; then
                return 1
            fi
            ;;
    esac

    return 0
}

# 导出函数
export -f fetch_rss_news
export -f fetch_hackernews
export -f smart_fetch_news
