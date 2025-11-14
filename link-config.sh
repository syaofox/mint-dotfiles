#!/bin/bash

# 获取脚本所在目录（项目根目录）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/config"
HOME_DIR="${HOME}"
TARGET_DIR="${HOME_DIR}/.config"
BACKUP_DIR="${TARGET_DIR}/.backup"

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 检查 config 目录是否存在
if [ ! -d "${CONFIG_DIR}" ]; then
    echo -e "${RED}错误: ${CONFIG_DIR} 目录不存在${NC}"
    exit 1
fi

# 创建备份目录（如果不存在）
if [ ! -d "${BACKUP_DIR}" ]; then
    mkdir -p "${BACKUP_DIR}"
fi

# 遍历 config 目录下的所有子目录
for dir in "${CONFIG_DIR}"/*; do
    # 检查是否为目录
    if [ ! -d "${dir}" ]; then
        continue
    fi
    
    # 获取目录名
    dirname=$(basename "${dir}")
    source_path="${dir}"
    target_link="${TARGET_DIR}/${dirname}"
    
    # 如果目标位置不存在，直接创建链接
    if [ ! -e "${target_link}" ]; then
        ln -s "${source_path}" "${target_link}"
        echo -e "${GREEN}✓${NC} 创建链接: ${dirname} -> ${source_path}"
        continue
    fi
    
    # 如果目标位置是符号链接
    if [ -L "${target_link}" ]; then
        current_target=$(readlink -f "${target_link}")
        expected_target=$(readlink -f "${source_path}")
        
        # 检查链接目标是否正确
        if [ "${current_target}" = "${expected_target}" ]; then
            echo -e "${GREEN}✓${NC} 链接已存在且正确: ${dirname}"
        else
            # 链接目标不正确，删除后重新创建
            rm "${target_link}"
            ln -s "${source_path}" "${target_link}"
            echo -e "${YELLOW}⚠${NC} 更新链接: ${dirname} -> ${source_path}"
        fi
        continue
    fi
    
    # 如果目标位置存在非链接文件/目录，备份后覆盖
    if [ -e "${target_link}" ]; then
        backup_path="${BACKUP_DIR}/${dirname}.$(date +%Y%m%d_%H%M%S)"
        mv "${target_link}" "${backup_path}"
        ln -s "${source_path}" "${target_link}"
        echo -e "${YELLOW}⚠${NC} 备份并创建链接: ${dirname} (备份到 ${backup_path})"
    fi
done

echo -e "\n${GREEN}完成！所有配置目录已链接到 ${TARGET_DIR}${NC}"
