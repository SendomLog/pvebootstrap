function brew_install() {
	quiet=false

	while getopts ":q" opt; do
		case $opt in
		q)
			quiet=true
			;;
		?)
			echo "Unrecognized argument"
			echo "Usage: brew_install -q package_name"
			return 1
			;;
		esac
	done

	shift "$((OPTIND - 1))"
	if [ -z "$1" ]; then
		echo "Usage: brew_install [-q] package_name"
	fi

	if [[ ! -e /usr/local/bin/$1 ]]; then
		if [ "$quiet" = false ]; then
			echo "Installing $1"
		fi
		brew install $1
	else
		if [ "$quiet" = false ]; then
			echo "You have installed $1"
		fi
	fi
}

# 定义备份文件后缀常量
BACKUP_SUFFIX="_sdzbackup"

function sdz_backup_file() {
	if [ $# != 1 ]; then
		echo "Usage: backup_file pat_to_file"
		return 1
	fi

	if [[ -e $1 ]]; then
		original_file="$1"
		backup_file="$1$BACKUP_SUFFIX"

		mv "$original_file" "$backup_file"
		echo "File '$original_file' has been backed up to '$backup_file'"
	else
		echo "File '$1' does not exist."
		return 1
	fi
}

# copy to path and create this path if not exist
function sdz_cp_file() {
	if [ $# != 2 ]; then
		echo "Usage: bs_cp file destination"
	fi

	test -d "$2" || mkdir -p "$2" && cp "$1" "$2"
}

# fanqiang is not necessary in tt network
function not_tt_network() {
	ssid=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk '/ SSID/ {print substr($0, index($0, $2))}')
	if [[ $ssid = *"Bytedance"* ]]; then
		return 1
	else
		return 0
	fi
}
