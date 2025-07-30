#!/bin/bash

# Claude配置切换脚本
# 用于更改 ~/.claude/settings.json 配置文件中的 ANTHROPIC_BASE_URL 和 ANTHROPIC_AUTH_TOKEN 变量
# 支持多个key和API URL的JSON数组配置格式
# 
# 项目地址: https://github.com/zdev0x/switch-claude.git
# 用法: ./switch-claude.sh <配置名称>

# 启用bash扩展功能
set +o nounset

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_SETTINGS_FILE="$HOME/.claude/settings.json"

# 按优先级查找配置文件位置
find_config_paths() {
    local config_paths=()
    
    # 1. ~/.config/switch-claude/ 目录下的配置文件 (全局配置优先)
    if [ -d "$HOME/.config/switch-claude" ]; then
        for file in "$HOME/.config/switch-claude"/*.json; do
            if [ -f "$file" ]; then
                config_paths+=("$file")
            fi
        done
    fi
    
    # 2. ~/.switch-claude.json (简化全局配置)
    if [ -f "$HOME/.switch-claude.json" ]; then
        config_paths+=("$HOME/.switch-claude.json")
    fi
    
    # 3. 当前目录的 config.json (项目特定配置)
    if [ -f "$(pwd)/config.json" ]; then
        config_paths+=("$(pwd)/config.json")
    fi
    
    # 4. 如果都没找到，检查当前目录的其他 .json 文件
    if [ ${#config_paths[@]} -eq 0 ]; then
        for file in "$(pwd)"/*.json; do
            if [ -f "$file" ]; then
                config_paths+=("$file")
            fi
        done
    fi
    
    printf '%s\n' "${config_paths[@]}"
}

# 获取配置文件的目录（用于兼容性）
get_config_dir() {
    local config_files=($(find_config_paths))
    if [ ${#config_files[@]} -gt 0 ]; then
        dirname "${config_files[0]}"
    else
        pwd
    fi
}

CONFIGS_DIR="$(get_config_dir)"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 显示帮助信息
show_help() {
    echo -e "${BLUE}Claude配置切换脚本${NC}"
    echo ""
    echo "用法:"
    echo "  $0 <配置名称>          # 切换到指定配置"
    echo "  $0 -l, --list         # 列出所有可用配置"
    echo "  $0 -c, --current      # 显示当前配置"
    echo "  $0 -f, --file <文件>  # 指定配置文件"
    echo "  $0 -h, --help         # 显示帮助信息"
    echo ""
    echo "配置文件查找顺序:"
    echo "  1. ~/.config/switch-claude/*.json"
    echo "  2. ~/.switch-claude.json"
    echo "  3. 当前目录/config.json"
    echo "  4. 当前目录/*.json"
    echo ""
    echo "支持的配置文件格式: .json (JSON数组格式)"
    echo ""
    echo "JSON配置文件格式示例:"
    echo '['
    echo '  {'
    echo '    "name": "work",'
    echo '    "description": "工作环境",'
    echo '    "ANTHROPIC_BASE_URL": "https://api.anthropic.com",'
    echo '    "ANTHROPIC_AUTH_TOKEN": "sk-ant-..."'
    echo '  },'
    echo '  {'
    echo '    "name": "personal",'
    echo '    "description": "个人环境",'
    echo '    "ANTHROPIC_BASE_URL": "https://other-api.com",'
    echo '    "ANTHROPIC_AUTH_TOKEN": "cr_..."'
    echo '  }'
    echo ']'
    echo ""
    echo "示例:"
    echo "  $0 work               # 切换到work配置"
    echo "  $0 personal           # 切换到personal配置"
    echo "  $0 -l                 # 列出所有配置"
    echo "  $0 -f config.json work # 使用指定文件切换到work配置"
}

# 列出所有可用配置
list_configs() {
    local config_file="$1"
    
    echo -e "${BLUE}可用配置:${NC}"
    
    local found=0
    local files_to_check=()
    
    if [ -n "$config_file" ]; then
        # 指定了特定文件，按路径优先级查找
        local found_file=""
        for path in "$HOME/.config/switch-claude/$config_file" "$HOME/$config_file" "$(pwd)/$config_file"; do
            if [ -f "$path" ]; then
                found_file="$path"
                break
            fi
        done
        
        if [ -n "$found_file" ]; then
            files_to_check=("$found_file")
        else
            echo -e "${RED}指定的配置文件不存在: $config_file${NC}"
            echo -e "${YELLOW}已在以下位置查找:${NC}"
            echo "  - $HOME/.config/switch-claude/$config_file"
            echo "  - $HOME/$config_file"
            echo "  - $(pwd)/$config_file"
            return 1
        fi
    else
        # 使用新的多路径查找
        local config_paths=($(find_config_paths))
        if [ ${#config_paths[@]} -eq 0 ]; then
            echo -e "${YELLOW}未找到配置文件${NC}"
            echo ""
            echo "请在以下任一位置创建配置文件:"
            echo "  1. $HOME/.config/switch-claude/config.json"
            echo "  2. $HOME/.switch-claude.json"
            echo "  3. $(pwd)/config.json"
            return 1
        fi
        files_to_check=("${config_paths[@]}")
    fi
    
    for file in "${files_to_check[@]}"; do
        local filepath="$file"
        local filename=$(basename "$file")
        
        # 显示配置文件来源
        if [[ "$file" == "$(pwd)/"* ]]; then
            echo -e "${CYAN}文件: $filename ${YELLOW}(当前目录: $(pwd))${NC}"
        elif [[ "$file" == "$HOME/.config/switch-claude/"* ]]; then
            echo -e "${CYAN}文件: $filename ${YELLOW}(~/.config/switch-claude/)${NC}"
        elif [[ "$file" == "$HOME/.switch-claude.json" ]]; then
            echo -e "${CYAN}文件: $filename ${YELLOW}(用户配置)${NC}"
        else
            echo -e "${CYAN}文件: $filename${NC}"
        fi
        
        local configs_data
        configs_data=$(parse_configs_file "$file")
        if [ $? -eq 0 ]; then
            local config_count=$(echo "$configs_data" | jq -r '. | length')
            
            for ((i=0; i<config_count; i++)); do
                local config=$(echo "$configs_data" | jq -r ".[$i]")
                local name=$(echo "$config" | jq -r '.name')
                local description=$(echo "$config" | jq -r '.description // "无描述"')
                local base_url=$(echo "$config" | jq -r '.ANTHROPIC_BASE_URL')
                
                echo -e "  ${GREEN}$name${NC} - $description"
                echo -e "    URL: $base_url"
                found=1
            done
        else
            echo -e "  ${RED}解析失败${NC}"
        fi
        echo ""
    done
    
    if [ $found -eq 0 ]; then
        echo -e "${YELLOW}未找到有效的配置${NC}"
    fi
}

# 显示当前配置
show_current() {
    if [ ! -f "$CLAUDE_SETTINGS_FILE" ]; then
        echo -e "${RED}Claude设置文件不存在: $CLAUDE_SETTINGS_FILE${NC}"
        return 1
    fi
    
    echo -e "${BLUE}当前配置:${NC}"
    local base_url=$(jq -r '.env.ANTHROPIC_BASE_URL // "未设置"' "$CLAUDE_SETTINGS_FILE")
    local auth_token=$(jq -r '.env.ANTHROPIC_AUTH_TOKEN // "未设置"' "$CLAUDE_SETTINGS_FILE")
    
    # 尝试从配置文件中查找匹配的配置
    local config_name="未知"
    local config_description="未设置"
    local config_found=0
    local config_source=""
    
    # 使用新的多路径查找
    local config_paths=($(find_config_paths))
    for file in "${config_paths[@]}"; do
        local configs_data
        configs_data=$(parse_configs_file "$file")
        if [ $? -eq 0 ]; then
            local config_count=$(echo "$configs_data" | jq -r '. | length')
            
            for ((i=0; i<config_count; i++)); do
                local config=$(echo "$configs_data" | jq -r ".[$i]")
                local cfg_base_url=$(echo "$config" | jq -r '.ANTHROPIC_BASE_URL')
                local cfg_auth_token=$(echo "$config" | jq -r '.ANTHROPIC_AUTH_TOKEN')
                
                if [ "$cfg_base_url" = "$base_url" ] && [ "$cfg_auth_token" = "$auth_token" ]; then
                    config_name=$(echo "$config" | jq -r '.name')
                    config_description=$(echo "$config" | jq -r '.description // "无描述"')
                    config_found=1
                    
                    # 标记配置来源
                    if [[ "$file" == "$(pwd)/"* ]]; then
                        config_source=" ${YELLOW}(当前目录: $(pwd))${NC}"
                    elif [[ "$file" == "$HOME/.config/switch-claude/"* ]]; then
                        config_source=" ${YELLOW}(~/.config/switch-claude/)${NC}"
                    elif [[ "$file" == "$HOME/.switch-claude.json" ]]; then
                        config_source=" ${YELLOW}(用户配置)${NC}"
                    fi
                    break
                fi
            done
            
            if [ $config_found -eq 1 ]; then
                break
            fi
        fi
    done
    
    # 显示配置信息
    if [ $config_found -eq 1 ]; then
        echo -e "  name: ${GREEN}$config_name${NC}$config_source"
        echo -e "  description: ${CYAN}$config_description${NC}"
    fi
    
    echo -e "  ANTHROPIC_BASE_URL: ${GREEN}$base_url${NC}"
    if [ "$auth_token" != "未设置" ] && [ ${#auth_token} -gt 20 ]; then
        echo -e "  ANTHROPIC_AUTH_TOKEN: ${GREEN}${auth_token:0:20}...${NC}"
    else
        echo -e "  ANTHROPIC_AUTH_TOKEN: ${GREEN}$auth_token${NC}"
    fi
    
    if [ $config_found -eq 0 ] && [ "$base_url" != "未设置" ]; then
        echo ""
        echo -e "${YELLOW}警告: 当前配置不在任何配置文件中找到${NC}"
    fi
}

# 解析JSON格式的配置文件
parse_configs_file() {
    local config_file="$1"
    
    if ! jq -e . "$config_file" >/dev/null 2>&1; then
        echo "Error: JSON格式错误或文件不存在: $config_file" >&2
        return 1
    fi
    
    local configs_data=$(jq -c . "$config_file")
    
    # 检查是否是数组
    if ! echo "$configs_data" | jq -e 'type == "array"' >/dev/null 2>&1; then
        echo "Error: JSON配置文件必须是数组格式" >&2
        return 1
    fi
    
    echo "$configs_data"
}

# 从配置数组中查找特定配置
find_config_by_name() {
    local configs_data="$1"
    local config_name="$2"
    
    local config_count=$(echo "$configs_data" | jq -r '. | length')
    
    for ((i=0; i<config_count; i++)); do
        local config=$(echo "$configs_data" | jq -r ".[$i]")
        local name=$(echo "$config" | jq -r '.name')
        
        if [ "$name" = "$config_name" ]; then
            echo "$config"
            return 0
        fi
    done
    
    return 1
}

# 切换配置
switch_config() {
    local config_name="$1"
    local specified_file="$2"
    
    if [ -z "$config_name" ]; then
        echo -e "${RED}错误: 请指定配置名称${NC}"
        show_help
        return 1
    fi
    
    # 确定要搜索的配置文件
    local files_to_search=()
    if [ -n "$specified_file" ]; then
        # 指定了特定文件，按路径优先级查找
        local found_file=""
        for path in "$HOME/.config/switch-claude/$specified_file" "$HOME/$specified_file" "$(pwd)/$specified_file"; do
            if [ -f "$path" ]; then
                found_file="$path"
                break
            fi
        done
        
        if [ -n "$found_file" ]; then
            files_to_search=("$found_file")
        else
            echo -e "${RED}错误: 指定的配置文件不存在: $specified_file${NC}"
            echo -e "${YELLOW}已在以下位置查找:${NC}"
            echo "  - $HOME/.config/switch-claude/$specified_file"
            echo "  - $HOME/$specified_file"
            echo "  - $(pwd)/$specified_file"
            return 1
        fi
    else
        # 使用新的多路径查找
        local config_paths=($(find_config_paths))
        if [ ${#config_paths[@]} -eq 0 ]; then
            echo -e "${RED}错误: 未找到JSON配置文件${NC}"
            echo ""
            echo "请在以下任一位置创建配置文件:"
            echo "  1. $HOME/.config/switch-claude/config.json"
            echo "  2. $HOME/.switch-claude.json"
            echo "  3. $(pwd)/config.json"
            return 1
        fi
        files_to_search=("${config_paths[@]}")
    fi
    
    # 搜索指定的配置
    local found_config=""
    local found_file=""
    
    for file in "${files_to_search[@]}"; do
        local configs_data
        configs_data=$(parse_configs_file "$file")
        if [ $? -eq 0 ]; then
            local config
            config=$(find_config_by_name "$configs_data" "$config_name")
            if [ $? -eq 0 ]; then
                found_config="$config"
                found_file="$file"
                break
            fi
        fi
    done
    
    if [ -z "$found_config" ]; then
        echo -e "${RED}错误: 未找到配置 '$config_name'${NC}"
        echo ""
        echo -e "${YELLOW}可用配置:${NC}"
        list_configs "$specified_file"
        return 1
    fi
    
    echo -e "${BLUE}正在切换到配置: ${GREEN}$config_name${NC}"
    
    # 显示配置文件来源
    if [[ "$found_file" == "$(pwd)/"* ]]; then
        echo -e "${CYAN}来源文件: $(basename "$found_file") ${YELLOW}(当前目录: $(pwd))${NC}"
    elif [[ "$found_file" == "$HOME/.config/switch-claude/"* ]]; then
        echo -e "${CYAN}来源文件: $(basename "$found_file") ${YELLOW}(~/.config/switch-claude/)${NC}"
    elif [[ "$found_file" == "$HOME/.switch-claude.json" ]]; then
        echo -e "${CYAN}来源文件: $(basename "$found_file") ${YELLOW}(用户配置)${NC}"
    else
        echo -e "${CYAN}来源文件: $(basename "$found_file")${NC}"
    fi
    
    # 检查Claude设置文件是否存在
    if [ ! -f "$CLAUDE_SETTINGS_FILE" ]; then
        echo -e "${RED}错误: Claude设置文件不存在: $CLAUDE_SETTINGS_FILE${NC}"
        echo -e "${YELLOW}请先运行 claude 命令进行初始化${NC}"
        return 1
    fi
    
    # 备份当前设置
    local backup_file="$CLAUDE_SETTINGS_FILE.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$CLAUDE_SETTINGS_FILE" "$backup_file"
    echo -e "${YELLOW}已备份当前设置到: $backup_file${NC}"
    
    # 提取配置值
    local base_url=$(echo "$found_config" | jq -r '.ANTHROPIC_BASE_URL')
    local auth_token=$(echo "$found_config" | jq -r '.ANTHROPIC_AUTH_TOKEN')
    local description=$(echo "$found_config" | jq -r '.description // ""')
    
    if [ "$base_url" = "null" ] || [ -z "$base_url" ]; then
        echo -e "${RED}错误: 配置中缺少有效的 ANTHROPIC_BASE_URL${NC}"
        return 1
    fi
    
    if [ "$auth_token" = "null" ] || [ -z "$auth_token" ]; then
        echo -e "${RED}错误: 配置中缺少有效的 ANTHROPIC_AUTH_TOKEN${NC}"
        return 1
    fi
    
    # 更新Claude设置文件
    local temp_file=$(mktemp)
    jq --arg base_url "$base_url" --arg auth_token "$auth_token" \
       '.env.ANTHROPIC_BASE_URL = $base_url | .env.ANTHROPIC_AUTH_TOKEN = $auth_token' \
       "$CLAUDE_SETTINGS_FILE" > "$temp_file"
    
    if [ $? -eq 0 ]; then
        mv "$temp_file" "$CLAUDE_SETTINGS_FILE"
        echo -e "${GREEN}✓ 配置切换成功!${NC}"
        echo ""
        echo -e "${BLUE}新配置:${NC}"
        if [ -n "$description" ]; then
            echo -e "  描述: ${CYAN}$description${NC}"
        fi
        echo -e "  ANTHROPIC_BASE_URL: ${GREEN}$base_url${NC}"
        if [ ${#auth_token} -gt 20 ]; then
            echo -e "  ANTHROPIC_AUTH_TOKEN: ${GREEN}${auth_token:0:20}...${NC}"
        else
            echo -e "  ANTHROPIC_AUTH_TOKEN: ${GREEN}$auth_token${NC}"
        fi
    else
        rm -f "$temp_file"
        echo -e "${RED}错误: 无法更新Claude设置文件${NC}"
        return 1
    fi
}

# 检查依赖
check_dependencies() {
    local missing_deps=()
    
    # 检查必需的依赖
    if ! command -v jq &> /dev/null; then
        missing_deps+=("jq")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo -e "${RED}错误: 缺少必要依赖:${NC}"
        for dep in "${missing_deps[@]}"; do
            echo -e "  - $dep"
        done
        echo ""
        echo "请安装缺少的依赖:"
        echo "  Ubuntu/Debian: sudo apt-get install jq"
        echo "  CentOS/RHEL: sudo yum install jq"
        echo "  macOS: brew install jq"
        return 1
    fi
}

# 主函数
main() {
    # 检查依赖
    if ! check_dependencies; then
        exit 1
    fi
    
    local specified_file=""
    
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -l|--list)
                list_configs "$specified_file"
                exit 0
                ;;
            -c|--current)
                show_current
                exit 0
                ;;
            -f|--file)
                if [ -z "$2" ]; then
                    echo -e "${RED}错误: -f/--file 选项需要指定文件名${NC}"
                    exit 1
                fi
                specified_file="$2"
                shift 2
                ;;
            -*)
                echo -e "${RED}错误: 未知选项 $1${NC}"
                show_help
                exit 1
                ;;
            *)
                # 配置名称
                switch_config "$1" "$specified_file"
                exit $?
                ;;
        esac
    done
    
    # 如果没有提供任何参数
    echo -e "${RED}错误: 请指定配置名称或选项${NC}"
    echo ""
    show_help
    exit 1
}

main "$@"