#!/bin/bash

# 获取Debian版本号
getDebianVersion() {
	cat /etc/debian_version | awk -F"." '{print $1}'
}

# 映射Debian版本号到对应的代号
mapDebianVersion() {
	local version="$1"
	case "$version" in
	12) echo "bookworm" ;;
	11) echo "bullseye" ;;
	10) echo "buster" ;;
	9) echo "stretch" ;;
	8) echo "jessie" ;;
	7) echo "wheezy" ;;
	6) echo "squeeze" ;;
	*) echo "" ;;
	esac
}

# 显示警告信息
showWarning() {
	whiptail --title "Warning" --msgbox "$1" 10 60
}

# 修改Debian源为ustc.edu.cn
changeDebianSource() {
	local sver
	sver=$(getDebianVersion)
	local currentDebianVersion="$sver"
	sver=$(mapDebianVersion "$sver")

	if [ -z "$sver" ]; then
		showWarning "Not supported! 您的版本不支持！无法继续。"
		exit 1
	fi

	local securitySource

	if [ $currentDebianVersion -gt 10 ]; then
		securitySource="
deb https://mirrors.ustc.edu.cn/debian-security/ stable-security main contrib non-free
deb-src https://mirrors.ustc.edu.cn/debian-security/ stable-security main contrib non-free
"
	else
		securitySource="
deb https://mirrors.ustc.edu.cn/debian-security/ $sver/updates main contrib non-free
deb-src https://mirrors.ustc.edu.cn/debian-security/ $sver/updates main contrib non-free
"
	fi

	local OPTION
	local L="en"

	if [ $L != "en" ]; then
		OPTION=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "配置apt镜像源:" 25 60 15 \
			"b" "更换为国内源" \
			"c" "关闭企业更新源" \
			"d" "还原配置" \
			"q" "返回主菜单" \
			3>&1 1>&2 2>&3)
	else
		OPTION=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "Config apt source:" 25 60 15 \
			"b" "Change to cn source." \
			"c" "Disable enterprise." \
			"d" "Undo Change." \
			"q" "Main menu." \
			3>&1 1>&2 2>&3)
	fi

	handleOption "$OPTION" "$sver" "$securitySource"
}

# 处理选项
handleOption() {
	local OPTION="$1"
	local sver="$2"
	local securitySource="$3"

	case "$OPTION" in
	a | A)
		handleOptionA "$sver" "$securitySource"
		;;
	b | B)
		handleOptionB "$sver" "$securitySource"
		;;
	c | C)
		handleOptionC "$sver" "$securitySource"
		;;
	d | D)
		handleOptionD
		;;
	q)
		echo "q"
		;;
	esac
}

# 处理选项A
handleOptionA() {
	local sver="$1"
	local securitySource="$2"

	if (whiptail --title "Yes/No Box" --yesno "修改为ustc.edu.cn源，禁用企业订阅更新源，添加非订阅更新源(ustc.edu.cn),修改ceph镜像更新源" 10 60); then
		if [ $(grep "ustc.edu.cn" /etc/apt/sources.list | wc -l) = 0 ]; then
			cp /etc/apt/sources.list /etc/apt/sources.list.bak
			cp /etc/apt/sources.list.d/pve-no-sub.list /etc/apt/sources.list.d/pve-no-sub.list.bak
			cp /etc/apt/sources.list.d/pve-enterprise.list /etc/apt/sources.list.d/pve-enterprise.list.bak
			cp /etc/apt/sources.list.d/ceph.list /etc/apt/sources.list.d/ceph.list.bak

			cat >/etc/apt/sources.list <<EOF
deb https://mirrors.ustc.edu.cn/debian/ $sver main contrib non-free
deb-src https://mirrors.ustc.edu.cn/debian/ $sver main contrib non-free
deb https://mirrors.ustc.edu.cn/debian/ $sver-updates main contrib non-free
deb-src https://mirrors.ustc.edu.cn/debian/ $sver-updates main contrib non-free
deb https://mirrors.ustc.edu.cn/debian/ $sver-backports main contrib non-free
deb-src https://mirrors.ustc.edu.cn/debian/ $sver-backports main contrib non-free
$securitySource
EOF
			echo "deb http://mirrors.ustc.edu.cn/proxmox/debian/pve/ $sver pve-no-subscription" >/etc/apt/sources.list.d/pve-no-sub.list
			sed -i 's|deb|#deb|' /etc/apt/sources.list.d/pve-enterprise.list
			echo "deb http://mirrors.ustc.edu.cn/proxmox/debian/ceph-luminous $sver main" >/etc/apt/sources.list.d/ceph.list

			if [ $bver -gt 11 ]; then
				su -c 'echo "APT::Get::Update::SourceListWarnings::NonFreeFirmware \"false\";" > /etc/apt/apt.conf.d/no-bookworm-firmware.conf'
			fi

			showWarning "apt source has been changed successfully! 软件源已更换成功！"
			apt-get update
			apt-get -y install net-tools
		else
			showWarning "Already changed apt source to ustc.edu.cn! 已经更换apt源为 ustc.edu.cn"
		fi

		if [ -z "$1" ]; then
			changeDebianSource
		fi
	fi
}

# 处理选项B
handleOptionB() {
	local sver="$1"
	local securitySource="$2"
	local L="en"

	local sourceList=("aliyun.com" "ustc.edu.cn")
	local OPTION

	if [ $L != "en" ]; then
		OPTION=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "配置apt镜像源:" 25 60 15 \
			"a" "aliyun.com" \
			"b" "ustc.edu.cn" \
			"q" "返回主菜单" \
			3>&1 1>&2 2>&3)
	else
		OPTION=$(whiptail --title " PveTools   Version : 2.3.8 " --menu "Config apt source:" 25 60 15 \
			"a" "aliyun.com" \
			"b" "ustc.edu.cn" \
			"q" "Main menu." \
			3>&1 1>&2 2>&3)
	fi

	local exitstatus=$?
	if [ $exitstatus = 0 ]; then
		local selectedSource
		case "$OPTION" in
		a)
			selectedSource="aliyun.com"
			;;
		b)
			selectedSource="ustc.edu.cn"
			;;
		q)
			changeDebianSource
			;;
		esac

		if (whiptail --title "Yes/No Box" --yesno "修改更新源为$selectedSource?" 10 60); then
			if [ $(grep "$selectedSource" /etc/apt/sources.list | wc -l) = 0 ]; then
				cp /etc/apt/sources.list /etc/apt/sources.list.bak

				cat >/etc/apt/sources.list <<EOF
deb https://mirrors.$selectedSource/debian/ $sver main contrib non-free
deb-src https://mirrors.$selectedSource/debian/ $sver main contrib non-free
deb https://mirrors.$selectedSource/debian/ $sver-updates main contrib non-free
deb-src https://mirrors.$selectedSource/debian/ $sver-updates main contrib non-free
deb https://mirrors.$selectedSource/debian/ $sver-backports main contrib non-free
deb-src https://mirrors.$selectedSource/debian/ $sver-backports main contrib non-free
$securitySource
EOF
				echo "deb http://mirrors.ustc.edu.cn/proxmox/debian/pve/ $sver pve-no-subscription" >/etc/apt/sources.list.d/pve-no-sub.list

				showWarning "apt source has been changed successfully! 软件源已更换成功！"
				apt-get update
				apt-get -y install net-tools
			else
				showWarning "Already changed apt source to $selectedSource! 已经更换apt源为 $selectedSource"
			fi
		else
			changeDebianSource
		fi
		changeDebianSource
	else
		changeDebianSource
	fi
}

# 处理选项C
handleOptionC() {
	local sver="$1"
	local securitySource="$2"

	if (whiptail --title "Yes/No Box" --yesno "禁用企业订阅更新源?" 10 60); then
		if [ -f /etc/apt/sources.list.d/pve-no-sub.list ]; then
			echo "deb http://mirrors.ustc.edu.cn/proxmox/debian/pve/ $sver pve-no-subscription" >/etc/apt/sources.list.d/pve-no-sub.list
		else
			showWarning "apt source has been changed successfully! 软件源已更换成功！"
		fi

		if [ $(grep "^deb" /etc/apt/sources.list.d/pve-enterprise.list | wc -l) != 0 ]; then
			sed -i 's|deb|#deb|' /etc/apt/sources.list.d/pve-enterprise.list
			showWarning "apt source has been changed successfully! 软件源已更换成功！"
		else
			showWarning "apt source has been changed successfully! 软件源已更换成功！"
		fi
		changeDebianSource
	fi
}

# 处理选项D
handleOptionD() {
	cp /etc/apt/sources.list.bak /etc/apt/sources.list
	cp /etc/apt/sources.list.d/pve-no-sub.list.bak /etc/apt/sources.list.d/pve-no-sub.list
	cp /etc/apt/sources.list.d/pve-enterprise.list.bak /etc/apt/sources.list.d/pve-enterprise.list
	cp /etc/apt/sources.list.d/ceph.list.bak /etc/apt/sources.list.d/ceph.list
	showWarning "apt source has been changed successfully! 软件源已更换成功！"
	changeDebianSource
}
