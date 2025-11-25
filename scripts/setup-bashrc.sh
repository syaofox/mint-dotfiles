#!/bin/bash

# .bashrc 配置脚本
# 用于添加自定义环境变量、别名和提示符样式

set -e

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# 检查 .bashrc 文件
BASHRC_FILE="${HOME}/.bashrc"

if [ ! -f "$BASHRC_FILE" ]; then
    print_warning ".bashrc 文件不存在，正在创建..."
    touch "$BASHRC_FILE"
fi

# 备份 .bashrc
BACKUP_FILE="${BASHRC_FILE}.bak.$(date +%Y%m%d_%H%M%S)"
cp "$BASHRC_FILE" "$BACKUP_FILE"
print_info "已备份 .bashrc 到: $BACKUP_FILE"

echo -e "${BLUE}=== 配置 .bashrc ===${NC}\n"

# 标记，用于判断是否需要添加分隔符
NEED_SEPARATOR=false

# 1. 添加 UV_CACHE_DIR 环境变量
echo -e "${BLUE}1. 配置 UV_CACHE_DIR 环境变量${NC}"

if grep -q "export UV_CACHE_DIR=" "$BASHRC_FILE" 2>/dev/null; then
    print_warning "UV_CACHE_DIR 已存在，跳过"
else
    echo "" >> "$BASHRC_FILE"
    echo "export UV_CACHE_DIR=/mnt/github/.uv_cache" >> "$BASHRC_FILE"
    print_success "已添加 UV_CACHE_DIR 环境变量"
    NEED_SEPARATOR=true
fi

# 2. 添加自定义别名
echo -e "\n${BLUE}2. 配置自定义别名${NC}"

# 检查是否已有 custom alias 标记
if grep -q "# custom alias" "$BASHRC_FILE" 2>/dev/null; then
    print_info "自定义别名区域已存在，检查各个别名..."
    
    # 检查并添加每个别名
    ALIAS_ADDED=false
    
    if ! grep -q 'alias adult=' "$BASHRC_FILE" 2>/dev/null; then
        # 在 # custom alias 行后插入
        sed -i '/# custom alias/a alias adult="cd /mnt/dnas/data/adult/; pwd"' "$BASHRC_FILE"
        print_success "已添加别名: adult"
        ALIAS_ADDED=true
    else
        print_info "别名 adult 已存在"
    fi
    
    if ! grep -q 'alias ytd=' "$BASHRC_FILE" 2>/dev/null; then
        # 使用单引号包裹整个 alias 定义，内部的双引号和单引号需要转义
        sed -i '/# custom alias/a alias ytd='\''yt-dlp -f "bestvideo+bestaudio/best" -o "~/Videos/ytb-down/%(title)s.%(ext)s"'\''' "$BASHRC_FILE"
        print_success "已添加别名: ytd"
        ALIAS_ADDED=true
    else
        print_info "别名 ytd 已存在"
    fi
    
    if ! grep -q 'alias lzd=' "$BASHRC_FILE" 2>/dev/null; then
        sed -i '/# custom alias/a alias lzd='\''lazydocker'\''' "$BASHRC_FILE"
        print_success "已添加别名: lzd"
        ALIAS_ADDED=true
    else
        print_info "别名 lzd 已存在"
    fi
    
    if ! grep -q 'alias tts=' "$BASHRC_FILE" 2>/dev/null; then
        sed -i '/# custom alias/a alias tts='\''cd /mnt/github/index-tts && bash run_webui.sh'\''' "$BASHRC_FILE"
        print_success "已添加别名: tts"
        ALIAS_ADDED=true
    else
        print_info "别名 tts 已存在"
    fi
    
    if ! grep -q 'alias comfy=' "$BASHRC_FILE" 2>/dev/null; then
        sed -i '/# custom alias/a alias comfy='\''cd /mnt/github/ComfyUI && bash run.sh'\''' "$BASHRC_FILE"
        print_success "已添加别名: comfy"
        ALIAS_ADDED=true
    else
        print_info "别名 comfy 已存在"
    fi
    
    if [ "$ALIAS_ADDED" = false ]; then
        print_info "所有别名已存在"
    fi
else
    echo "" >> "$BASHRC_FILE"
    echo "# custom alias" >> "$BASHRC_FILE"
    echo 'alias adult="cd /mnt/dnas/data/adult/; pwd"' >> "$BASHRC_FILE"
    echo 'alias ytd='"'"'yt-dlp -f "bestvideo+bestaudio/best" -o "~/Videos/ytb-down/%(title)s.%(ext)s"'"'" >> "$BASHRC_FILE"
    echo 'alias lzd='"'"'lazydocker'"'" >> "$BASHRC_FILE"
    echo 'alias tts='"'"'cd /mnt/github/index-tts && bash run_webui.sh'"'" >> "$BASHRC_FILE"
    echo 'alias comfy='"'"'cd /mnt/github/ComfyUI && bash run.sh'"'" >> "$BASHRC_FILE"
    print_success "已添加所有自定义别名"
    NEED_SEPARATOR=true
fi

# 3. 添加 uv shell completion
echo -e "\n${BLUE}3. 配置 uv shell completion${NC}"

if grep -q 'eval "$(uv generate-shell-completion bash)"' "$BASHRC_FILE" 2>/dev/null; then
    print_warning "uv shell completion 已存在，跳过"
else
    # 检查 uv 是否已安装
    if command -v uv &> /dev/null; then
        echo 'eval "$(uv generate-shell-completion bash)"' >> "$BASHRC_FILE"
        print_success "已添加 uv shell completion"
        NEED_SEPARATOR=true
    else
        print_warning "uv 未安装，跳过 shell completion 配置"
    fi
fi

# 4. 配置提示符样式
echo -e "\n${BLUE}4. 配置提示符样式${NC}"

PS1_LINE='PS1='\''\[\e[38;5;76m\]\u\[\e[0m\] in \[\e[38;5;111m\]\w\[\e[0m\] \\$ '\'''

if grep -q "^PS1=" "$BASHRC_FILE" 2>/dev/null || grep -q "^export PS1=" "$BASHRC_FILE" 2>/dev/null; then
    print_warning "PS1 已存在，检查是否需要更新..."
    
    # 检查是否已经是目标样式
    if grep -q "PS1='\[\e\[38;5;76m\]\\u\[\e\[0m\] in \[\e\[38;5;111m\]\\w\[\e\[0m\]" "$BASHRC_FILE" 2>/dev/null; then
        print_info "PS1 已是目标样式"
    else
        read -p "PS1 已存在但不同，是否要替换？(y/N): " replace_ps1
        if [[ "$replace_ps1" =~ ^[Yy]$ ]]; then
            # 删除旧的 PS1 行
            sed -i '/^PS1=/d; /^export PS1=/d' "$BASHRC_FILE"
            echo "" >> "$BASHRC_FILE"
            echo "# prompt style" >> "$BASHRC_FILE"
            echo "$PS1_LINE" >> "$BASHRC_FILE"
            print_success "已更新提示符样式"
        else
            print_info "保留原有 PS1 配置"
        fi
    fi
else
    echo "" >> "$BASHRC_FILE"
    echo "# prompt style" >> "$BASHRC_FILE"
    echo "$PS1_LINE" >> "$BASHRC_FILE"
    print_success "已添加提示符样式"
    NEED_SEPARATOR=true
fi

# 显示配置摘要
echo -e "\n${BLUE}=== 配置摘要 ===${NC}"
echo -e "${GREEN}已完成的配置：${NC}"
echo "  • UV_CACHE_DIR 环境变量"
echo "  • 自定义别名 (adult, ytd, lzd, tts, comfy)"
echo "  • uv shell completion"
echo "  • 自定义提示符样式"

echo -e "\n${BLUE}提示：${NC}"
echo "  • 备份文件: $BACKUP_FILE"
echo "  • 运行 'source ~/.bashrc' 或重新打开终端以应用更改"
echo "  • 使用 'alias' 命令查看所有别名"

echo -e "\n${GREEN}配置完成！${NC}"

