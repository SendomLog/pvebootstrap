#!/bin/bash

current_path=$(cd "$(dirname "$0")" && pwd)
source $current_path/config/config.sh

# 显示菜单
OPTION=$(whiptail --title " $PVE_BOOT_STRAP (Version: $PVE_TOOLS_VERSION) " --menu "
Github: $GITHUB_URL
# 请选择相应的配置：" 25 60 15 \
	"b" "更换源" \
	"x" "关于脚本" \
	3>&1 1>&2 2>&3)
