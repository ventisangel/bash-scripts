#!/usr/bin/env sh
# I actually use variable "word splitting" to my advantage
#	shellcheck disable=SC2086

addRepo() {
	printf "You need to add and enable %s repositories in order to install %s." "%1" "$2"
	printf "Add repositoriestory? [y/n] "
	read -r answer
	if [ "$answer" = "y" ]; then
		echo "Adding and enabling $1 repositories..."
		case $distro in
		ubuntu)
			sudo add-apt-repository universe
			sudo apt-get update
			;;
		fedora)
			sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-"$(rpm -E %fedora)".noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$(rpm -E %fedora)".noarch.rpm
			sudo dnf check-update
			;;
		opensuse-leap)
			sudo zypper addrepo -f http://download.opensuse.org/distribution/leap/"$(grep -oP '(?<=^VERSION_ID=).+' /etc/os-release | tr -d '"')"/repo/non-oss/ "Non-OSS Repo"
			sudo zypper refresh
			;;
		opensuse-tumbleweed)
			sudo zypper addrepo -f http://download.opensuse.org/tumbleweed/repo/non-oss/ "Non-OSS Repo"
			sudo zypper refresh
			;;
		esac
	fi
}

# select loop
menu() {
	i=0
	for item in "$@"; do
		i=$((i + 1))
		echo "$i) $item"
	done
	printf "%s: " "$PS3"
	read -r option
}

# greeter
printf "\nInstall proprietary apps/drivers\n"
printf "%s\n" "--------------------------------"
printf "Preparing directory for storing packages...\n"

# working dir
mkdir /tmp/tempDir
echo "Entering created directory..."
cd /tmp/tempDir || exit 1

distro=$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')
menuitems='Discord Skype VS-Code VS-Code-Insiders Telegram Terminate'
PS3='Which of these apps/drivers do you want to install? '

# main loop
while :; do
	# select opt
	menu $menuitems

	case $option in
	# discord
	1)
		if [ "$distro" = 'debian' ] || [ "$distro" = 'ubuntu' ]; then
			wget -O discord.deb https://discordapp.com/api/download\?platform=linux\&format=deb
			sudo apt-get install ./discord.deb
		elif [ "$distro" = 'fedora' ]; then
			addRepo "RPMFusion" "Discord"
			sudo dnf install discord
		elif [ "$distro" = 'opensuse-leap' ] || [ "$distro" = 'opensuse-tumbleweed' ]; then
			addRepo "Non-OSS" "Discord"
			sudo zypper install discord
		fi
		;;
	# skype
	2)
		if [ "$distro" = 'debian' ] || [ "$distro" = 'ubuntu' ]; then
			wget -O skype.deb https://repo.skype.com/latest/skypeforlinux-64.deb
			sudo apt-get install ./skype.deb
		elif [ "$distro" = 'fedora' ]; then
			wget -O skype.rpm https://repo.skype.com/latest/skypeforlinux-64.rpm
			sudo dnf install ./skype.rpm
		elif [ "$distro" = 'opensuse-leap' ] || [ "$distro" = 'opensuse-tumbleweed' ]; then
			wget -O skype.rpm https://repo.skype.com/latest/skypeforlinux-64.rpm
			sudo zypper install ./skype.rpm
		fi
		;;
	# vs code
	3)
		if [ "$distro" = 'debian' ] || [ "$distro" = 'ubuntu' ]; then
			wget -O code.deb https://go.microsoft.com/fwlink/\?LinkID=760868
			sudo apt-get install ./code.deb
		elif [ "$distro" = 'fedora' ]; then
			wget -O code.rpm https://go.microsoft.com/fwlink/\?LinkID=760867
			sudo dnf install ./code.rpm
		elif [ "$distro" = 'opensuse-leap' ] || [ "$distro" = 'opensuse-tumbleweed' ]; then
			wget -O code.rpm https://go.microsoft.com/fwlink/\?LinkID=760867
			sudo zypper install ./code.rpm
		fi
		;;
	# insider
	4)
		if [ "$distro" = 'debian' ] || [ "$distro" = 'ubuntu' ]; then
			wget -O code-insiders.deb https://go.microsoft.com/fwlink/\?LinkID=760865
			sudo apt-get install ./code-insiders.deb
		elif [ "$distro" = 'fedora' ]; then
			wget -O code-insiders.rpm https://go.microsoft.com/fwlink/\?LinkID=760866
			sudo dnf install ./code-insiders.rpm
		elif [ "$distro" = 'opensuse-leap' ] || [ "$distro" = 'opensuse-tumbleweed' ]; then
			wget -O code-insiders.rpm https://go.microsoft.com/fwlink/\?LinkID=760866
			sudo zypper install ./code-insiders.rpm
		fi
		;;
	# telegram
	5)
		if [ "$distro" = 'debian' ]; then
			sudo apt-get install telegram
		elif [ "$distro" = 'ubuntu' ]; then
			addRepo "Universe" "Telegram"
			sudo apt-get install telegram
		elif [ "$distro" = 'fedora' ]; then
			addRepo "RPMFusion" "Telegram"
			sudo dnf install telegram
		elif [ "$distro" = 'opensuse-leap' ] || [ "$distro" = 'opensuse-tumbleweed' ]; then
			addRepo "Non-OSS" "Telegram"
			sudo zypper install telegram
		fi
		;;
	*)
		break
		;;
	esac
done

cd ..
echo "Removing temporary directory..."
rm -r /tmp/tempDir
echo "Done! Terminating script..."
exit 0
