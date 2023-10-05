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

exitstatus=$?
if [ $exitstatus = 0 ]; then
	case "$OPTION" in
	b | B)
		echo "选择了更换源"
		source $current_path/changeDebianSource/changeDebianSource.sh
		changeDebianSource
		;;
	x | X)
		echo "关于脚本"
		;;
	esac
fi
