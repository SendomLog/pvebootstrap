#!/bin/bash

function changeDebianSource() {
	# 显示菜单
	OPTION=$(whiptail --title " 更改源 " --menu "
# 请选择相应的版本：" 25 60 15 \
		"b" "pve7" \
		"c" "pve8" \
		3>&1 1>&2 2>&3)
	exitstatus=$?
	if [ $exitstatus = 0 ]; then
		case "$OPTION" in
		b | B)
			echo "选择了pve7"
			;;
		c | C)
			echo "选择了pve8"
			;;
		esac
	fi
}
