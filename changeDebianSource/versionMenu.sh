#!/bin/bash

function changeDebianSourceItem() {
	# 显示菜单
	OPTION=$(whiptail --title " 更改源 " --menu "
# 请选择相应的版本：" 25 60 15 \
		"b" "删除pve自带的企业源" \
		"c" "Proxmox软件源更换" \
		"d" "Debian系统源更换" \
		"e" "LXC仓库源更换" \
		"f" "CEPH源更换" \
		3>&1 1>&2 2>&3)
	exitstatus=$?
	if [ $exitstatus = 0 ]; then
		case "$OPTION" in
		b | B)
			echo "删除pve自带的企业源"
			;;
		c | C)
			echo "Proxmox软件源更换"
			;;
		d | D)
			echo "Debian系统源更换"
			;;
		e | E)
			echo "LXC仓库源更换"
			;;
		f | F)
			echo "CEPH源更换"
			;;
		esac
	fi
}
