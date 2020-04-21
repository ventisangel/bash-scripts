#!/usr/bin/env bash

function addRepo {
    read -rp "You need to add and enable $1 repositories in order to install $2. Type 'y' if you want to do it now, or 'n' if you have already done that: " answer
    if [[ "$answer" = "y" ]]; then
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
        unset answer
    fi
}

function terminate {
    cd ..
    echo "Removing temporary directory..."
    rm -r /tmp/tempDir
    echo "Done! Terminating script..."
    exit
}

printf "%s\n" "Install proprietary apps/drivers" "--------------------------------" "Preparing directory for storing packages..."
mkdir /tmp/tempDir
echo "Entering created directory..."
cd /tmp/tempDir || exit

distro=$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')
menuitems=( 'Discord' 'Skype' 'VS Code' 'VS Code Insiders' 'Telegram' 'Lexmark Printer Driver' 'Terminate script' )
PS3="Which of these apps/drivers do you want to install? "

trap "echo You cannot interrupt execution of this script, please wait..." SIGINT SIGQUIT SIGTERM

select option in "${menuitems[@]}"
do
    case $distro in
        debian|ubuntu)
            case $option in
                'Discord')
                    wget -O discord.deb https://discordapp.com/api/download\?platform=linux\&format=deb
                    sudo apt-get install ./discord.deb
                ;;
                'Skype')
                    wget -O skype.deb https://repo.skype.com/latest/skypeforlinux-64.deb
                    sudo apt-get install ./skype.deb
                ;;
                'VS Code')
                    wget -O code.deb https://go.microsoft.com/fwlink/\?LinkID=760868
                    sudo apt-get install ./code.deb
                ;;
                'VS Code Insiders')
                    wget -O code-insiders.deb https://go.microsoft.com/fwlink/\?LinkID=760865
                    sudo apt-get install ./code-insiders.deb
                ;;
                'Telegram')
                    if [[ "$distro" = "ubuntu" ]]; then
                        addRepo "Universe" "Telegram"
                    fi
                    sudo apt-get install telegram
                ;;
                #'Lexmark Printer Driver')
                    # .deb package in preparation...
                #;;
                'Terminate script')
                    terminate
                ;;
                *)
                    echo "You chose invalid option!"
                ;;
            esac
        ;;
        fedora|opensuse-leap|opensuse-tumbleweed)
            case $option in
                'Discord')
                    if [[ "$distro" = "fedora" ]]; then
                        addRepo "RPMFusion" "Discord"
                        sudo dnf install discord
                    else
                        addRepo "Non-OSS" "Discord"
                        sudo zypper install discord
                    fi
                ;;
                'Skype')
                    wget -O skype.rpm https://repo.skype.com/latest/skypeforlinux-64.rpm
                    if [[ "$distro" = "fedora" ]]; then
                        sudo dnf install ./skype.rpm
                    else
                        sudo zypper install ./skype.rpm
                    fi
                ;;
                'VS Code')
                    wget -O code.rpm https://go.microsoft.com/fwlink/\?LinkID=760867
                    if [[ "$distro" = "fedora" ]]; then
                        sudo dnf install ./code.rpm
                    else
                        sudo zypper install ./code.rpm
                    fi
                ;;
                'VS Code Insiders')
                    wget -O code-insiders.rpm https://go.microsoft.com/fwlink/\?LinkID=760866
                    if [[ "$distro" = "fedora" ]]; then
                        sudo dnf install ./code-insiders.rpm
                    else
                        sudo zypper install ./code-insiders.rpm
                    fi
                ;;
                'Telegram')
                    if [[ "$distro" = "fedora" ]]; then
                        addRepo "RPMFusion" "Telegram"
                        sudo dnf install telegram
                    else
                        addRepo "Non-OSS" "Telegram"
                        sudo zypper install telegram
                    fi
                ;;
                #'Lexmark Printer Driver')
                    # .rpm package in preparation...
                #;;
                'Terminate script')
                    terminate
                ;;
                *)
                    echo "You chose invalid option!"
                ;;
            esac
        ;;
        *)
            echo "Your system is not supported!"
        ;;
    esac
done
