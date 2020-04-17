#!/usr/bin/env bash

function addRepo {
    read -ep "You need to add and enable $1 repositories in order to install $2. Type 'y' if you want to do it now, or 'n' if you have already done that: " answer
    if [[ $answer = "y" ]]
        echo "Adding and enabling $1 repositories..."
        case $distro in
            ubuntu)
                sudo add-apt-repository universe
                sudo apt update
            ;;
            fedora)
                sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
                sudo dnf check-update
            ;;
            opensuse-leap)
                sudo zypper addrepo -f http://download.opensuse.org/distribution/leap/$(grep -oP '(?<=^VERSION_ID=).+' /etc/os-release | tr -d '"')/repo/non-oss/ "Non-OSS Repo"
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
    rm -r tempDir
    echo "Done! Terminating script..."
    exit
}

printf "%s\n" "Install proprietary apps/drivers" "--------------------------------" "Preparing directory for storing packages..."
mkdir tempDir
cd tempDir

distro=$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')
menuitems=( Discord Skype 'VS Code' 'VS Code Insiders' Telegram 'Lexmark Printer Driver' 'Terminate script' )
PS3="Which of these apps/drivers do you want to install?"

select option in ${menuitems};
do
    case $distro in
        debian|ubuntu)
            case $REPLY in
                1)
                    wget -O discord.deb https://discordapp.com/api/download?platform=linux&format=deb
                    sudo apt install $(pwd)/discord.deb
                ;;
                2)
                    wget -O skype.deb https://repo.skype.com/latest/skypeforlinux-64.deb
                    sudo apt install $(pwd)/skype.deb
                ;;
                3)
                    wget -O code.deb https://go.microsoft.com/fwlink/?LinkID=760868
                    sudo apt install $(pwd)/code.deb
                ;;
                4)
                    wget -O code-insiders.deb https://go.microsoft.com/fwlink/?LinkID=760865
                    sudo apt install $(pwd)/code-insiders.deb
                ;;
                5)
                    if [[ $distro = "ubuntu" ]]
                        addRepo "Universe" "Telegram"
                    fi
                    sudo apt install telegram
                ;;
                #6)
                    # .deb package in preparation...
                #;;
                7)
                    terminate
                ;;
                *)
                    echo "You chose invalid option!"
                ;;
            esac
        ;;
        fedora|opensuse-leap|opensuse-tumbleweed)
            case $REPLY in
                1)
                    if [[ $distro = "fedora" ]]
                    then
                        addRepo "RPMFusion" "Discord"
                        sudo dnf install discord
                    else
                        addRepo "Non-OSS" "Discord"
                        sudo zypper install discord
                    fi
                ;;
                2)
                    wget -O skype.rpm https://repo.skype.com/latest/skypeforlinux-64.rpm
                    if [[ $distro = "fedora" ]]
                    then
                        sudo dnf install $(pwd)/skype.rpm
                    else
                        sudo zypper install $(pwd)/skype.rpm
                    fi
                ;;
                3)
                    wget -O code.rpm https://go.microsoft.com/fwlink/?LinkID=760867
                    if [[ $distro = "fedora" ]]
                    then
                        sudo dnf install $(pwd)/code.rpm
                    else
                        sudo zypper install $(pwd)/code.rpm
                    fi
                ;;
                4)
                    wget -O code-insiders.rpm https://go.microsoft.com/fwlink/?LinkID=760866
                    if [[ $distro = "fedora" ]]
                    then
                        sudo dnf install $(pwd)/code-insiders.rpm
                    else
                        sudo zypper install $(pwd)/code-insiders.rpm
                    fi
                ;;
                5)
                    if [[ $distro = "fedora" ]]
                    then
                        addRepo "RPMFusion" "Telegram"
                        sudo dnf install telegram
                    else
                        addRepo "Non-OSS" "Telegram"
                        sudo zypper install telegram
                    fi
                ;;
                #6)
                    # .rpm package in preparation...
                #;;
                7)
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
;
done
