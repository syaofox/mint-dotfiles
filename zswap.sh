#!/bin/bash
# 一键优化：Linux Mint 22.2 (Ubuntu 24.04) + 16GB AI 满载专用
# 强制 lz4 + 25% 池 + swappiness=100

set -e

echo "检测到 Linux Mint 22.2，启动一键优化..."

# 1. 备份 GRUB
sudo cp /etc/default/grub /etc/default/grub.bak.mint-ai-$(date +%F) 2>/dev/null || true

# 2. 读取现有的 GRUB_CMDLINE_LINUX 参数
GRUB_FILE="/etc/default/grub"
EXISTING_CMDLINE=$(grep '^GRUB_CMDLINE_LINUX=' "$GRUB_FILE" 2>/dev/null | cut -d'=' -f2- | sed 's/^"//;s/"$//' || echo "")

# 定义要添加的 zswap 参数
ZSWAP_PARAMS="zswap.enabled=1 zswap.max_pool_percent=25 zswap.compressor=lz4"

# 3. 检查并添加 zswap 参数（如果不存在）
if [ -z "$EXISTING_CMDLINE" ]; then
    # 如果不存在 GRUB_CMDLINE_LINUX 行，创建新行
    echo "GRUB_CMDLINE_LINUX=\"$ZSWAP_PARAMS\"" | sudo tee -a "$GRUB_FILE" > /dev/null
    echo "已创建新的 GRUB_CMDLINE_LINUX 参数"
else
    # 如果已存在，检查是否需要添加参数
    NEW_CMDLINE="$EXISTING_CMDLINE"
    
    # 检查每个参数是否存在，不存在则添加
    if [[ "$NEW_CMDLINE" != *"zswap.enabled=1"* ]]; then
        NEW_CMDLINE="$NEW_CMDLINE zswap.enabled=1"
    fi
    if [[ "$NEW_CMDLINE" != *"zswap.max_pool_percent=25"* ]]; then
        NEW_CMDLINE="$NEW_CMDLINE zswap.max_pool_percent=25"
    fi
    if [[ "$NEW_CMDLINE" != *"zswap.compressor=lz4"* ]]; then
        NEW_CMDLINE="$NEW_CMDLINE zswap.compressor=lz4"
    fi
    
    # 如果参数有变化，更新文件
    if [ "$NEW_CMDLINE" != "$EXISTING_CMDLINE" ]; then
        # 删除旧行并添加新行
        sudo sed -i '/^GRUB_CMDLINE_LINUX=/d' "$GRUB_FILE"
        echo "GRUB_CMDLINE_LINUX=\"$NEW_CMDLINE\"" | sudo tee -a "$GRUB_FILE" > /dev/null
        echo "已更新 GRUB_CMDLINE_LINUX 参数（保留原有参数）"
    else
        echo "GRUB_CMDLINE_LINUX 已包含所需的 zswap 参数，无需更新"
    fi
fi

# 4. 设置 swappiness=100（Mint 默认 60）
echo "vm.swappiness=100" | sudo tee /etc/sysctl.d/99-mint-ai-optimize.conf > /dev/null

# 5. 更新 GRUB（Mint 用 update-grub）
sudo update-grub