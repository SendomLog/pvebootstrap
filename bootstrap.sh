#!bin/bash

[ -z "${BRANCH}" ] && export BRANCH="main"

if [[ -e ~/.pvebootstrap ]]; then
	rm -rf ~/.pvebootstrap
fi

# 0 备份过, 1 未备份
function not_source_backed() {
	if [[ -e /etc/apt/sources.list.bak ]]; then
		return 0
	else
		return 1
	fi
}

if not_source_backed; then
	echo "已经备份"
else
	source changeDebianSource.sh
	changeDebianSource
fi

# brew install git

# git clone --depth=1 -b ${BRANCH} https://github.com/bestswifter/pvebootstrap.git ~/.pvebootstrap
# cd ~/.pvebootstrap
# bash install.sh
