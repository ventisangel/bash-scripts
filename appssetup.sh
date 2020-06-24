#!/usr/bin/env bash

function addRepo {
    read -rp "You need to add and enable $1 repositories in order to install $2. Type 'y' if you want to do it now, or 'n' if you have already done that: " answer
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
        unset answer
    fi
}

function addGoogleRepoKey {
    read -rp "You need to download and install appropriate signing key in order to install packages from Google Linux Software Repositories. Type 'y' if you want to do it now, or 'n' if you have already done that: " answer
    if [ "$answer" = "y" ]; then
        echo "Downloading and installing Google Linux Software Repositories package signing key..."
        wget -O google_linux_signing_key.pub https://dl.google.com/linux/linux_signing_key.pub
        case $distro in
            debian|ubuntu)
                sudo apt-key add google_linux_signing_key.pub
            ;;
            fedora|opensuse-leap|opensuse-tumbleweed)
                sudo rpm --import google_linux_signing_key.pub
            ;;
        esac
        unset answer
    fi
}

function installDepsLexmark {
    echo "Installing dependencies..."
    case $distro in
        debian)
            wget https://github.com/ventisangel/bash-scripts/raw/master/lexmark/debian-deps.tar.gz
            tar --extract --gzip --file="debian-deps.tar.gz" --overwrite
            sudo apt-get install ./libstdc++5_3.3.6-30_i386.deb ./libcupsimage2_2.2.10-6+deb10u3_i386.deb
        ;;
        ubuntu)
            wget https://github.com/ventisangel/bash-scripts/raw/master/lexmark/ubuntu-deps.tar.gz
            tar --extract --gzip --file="ubuntu-deps.tar.gz" --overwrite
            sudo apt-get install ./libstdc++5_3.3.6-30ubuntu2_i386.deb ./libcupsimage2_2.3.1-9ubuntu1.1_i386.deb
        ;;
        fedora)
            wget https://github.com/ventisangel/bash-scripts/raw/master/lexmark/fedora-deps.tar.gz
            tar --extract --gzip --file="fedora-deps.tar.gz" --overwrite
            sudo dnf install ./compat-libstdc++-33-3.2.3-68.16.fc26.1.i686.rpm ./cups-libs-2.2.12-8.fc30.i686.rpm
        ;;
        opensuse-leap|opensuse-tumbleweed)
            wget https://github.com/ventisangel/bash-scripts/raw/master/lexmark/opensuse-deps.tar.gz
            tar --extract --gzip --file="opensuse-deps.tar.gz" --overwrite
            sudo zypper install ./libstdc++33-32bit-3.3.3-lp152.41.1.x86_64.rpm ./libcupsimage2-32bit-2.2.7-lp152.8.1.x86_64.rpm
        ;;
    esac
}

function installNode {
    echo "Downloading Node.js package..."
    nodeVer=$(curl -s https://nodejs.org/download/release/latest/ | grep "linux-x64.tar.gz" | cut -d '"' -f 2)
    wget -O nodejs.tar.gz https://nodejs.org/download/release/latest/"$nodeVer"
    echo "Installing Node.js..."
    sudo tar --extract --gzip --file="nodejs.tar.gz" --overwrite
    folderName=$(echo "$nodeVer" | cut -d '.' -f 1,2,3)
    sudo chmod -R 777 "$folderName"
    cd "$folderName"
    sudo mv --update --target-directory=/usr/bin bin/*
    sudo mv --update --target-directory=/usr/include include/*
    sudo mv --update --target-directory=/usr/lib lib/*
    sudo mv --update --target-directory=/usr/share share/systemtap
    sudo mv --update --target-directory=/usr/share/doc share/doc/*
    sudo mv --update --target-directory=/usr/share/man/man1 share/man/man1/*
    cd ..
    unset nodeVer
    unset folderName
}

function buildBrackets {
    installNode
    sudo npm install -g grunt-cli
    echo "Downloading packages..."
    linkRelease=$(curl -s https://api.github.com/repos/adobe/brackets/releases/latest | grep -oP '(?<="tarball_url": ").*(?=",)')
    linkShell=$(curl -s https://api.github.com/repos/adobe/brackets-shell/releases/latest | grep -oP '(?<="tarball_url": ").*(?=",)')
    wget -O brackets.tar.gz "$linkRelease"
    wget -O brackets-shell.tar.gz "$linkShell"
    echo "Extracting application components..."
    mkdir build
    sudo tar --extract --gzip --file="brackets.tar.gz" --overwrite --directory=/tmp/tempDir/build
    sudo tar --extract --gzip --file="brackets-shell.tar.gz" --overwrite --directory=/tmp/tempDir/build
    sudo chmod -R 777 build
    cd build/adobe-brackets-shell*/
    npm install
    grunt
    cd ../adobe-brackets*/
    npm install
    grunt build
    cd ../..
    unset linkRelease
    unset linkShell
}

function installPowerShell {
    link=$(curl -s https://api.github.com/repos/PowerShell/PowerShell/releases/latest | grep -oP '(?<="browser_download_url":").*?(?=")' | grep linux-x64.tar.gz)
    wget -O powershell.tar.gz "$link"
    read -rp ""
    mkdir ~/.pwsh
    sudo tar --extract --gzip --file="powershell.tar.gz" --overwrite --directory=~/.pwsh
    echo "In order to use PowerShell, type '~/.pwsh/pwsh'"
    unset link
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
cd /tmp/tempDir || exit

distro=$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')
menuitems=( 'Discord' 'Skype' 'VS Code' 'VS Code Insiders' 'Telegram' 'MS Teams' 'Google Chrome' 'Google Earth' 'Opera' 'Brackets' 'PowerShell' 'Lexmark Printer Driver' 'Terminate script' )
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
                    if [ "$distro" = "ubuntu" ]; then
                        addRepo "Universe" "Telegram"
                    fi
                    sudo apt-get install telegram-desktop
                ;;
                'MS Teams')
                    wget -O ms-teams.deb https://go.microsoft.com/fwlink/p/\?linkid=2112886
                    sudo apt-get install ./ms-teams.deb
                ;;
                'Google Chrome')
                    addGoogleRepoKey
                    wget -O google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
                    sudo apt-get install ./google-chrome.deb
                ;;
                'Google Earth')
                    addGoogleRepoKey
                    wget -O google-earth.deb http://dl.google.com/dl/earth/client/current/google-earth-pro-stable_current_amd64.deb
                    sudo apt-get install ./google-earth.deb
                ;;
                'Opera')
                    wget -O opera.deb https://download.opera.com/download/get/\?partner=www\&opsys=Linux\&package=DEB
                    sudo apt-get install ./opera.deb
                ;;
                'Brackets')
                    buildBrackets
                ;;
                'PowerShell')
                    installPowerShell
                ;;
                'Lexmark Printer Driver')
                    sudo dpkg --add-architecture i386
                    installDepsLexmark
                    wget https://github.com/ventisangel/bash-scripts/raw/master/lexmark/lexmark-driver.tar.gz
                    sudo tar --extract --gzip --file="lexmark-driver.tar.gz" --no-overwrite-dir --directory=/
                    sudo ldconfig
                    #sudo apt-get install ./lxkbZ600drv.deb
                    sudo systemctl restart cups.service
                ;;
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
                    if [ "$distro" = "fedora" ]; then
                        addRepo "RPMFusion" "Discord"
                        sudo dnf install discord
                    else
                        addRepo "Non-OSS" "Discord"
                        sudo zypper install discord
                    fi
                ;;
                'Skype')
                    wget -O skype.rpm https://repo.skype.com/latest/skypeforlinux-64.rpm
                    if [ "$distro" = "fedora" ]; then
                        sudo dnf install ./skype.rpm
                    else
                        sudo zypper install ./skype.rpm
                    fi
                ;;
                'VS Code')
                    wget -O code.rpm https://go.microsoft.com/fwlink/\?LinkID=760867
                    if [ "$distro" = "fedora" ]; then
                        sudo dnf install ./code.rpm
                    else
                        sudo zypper install ./code.rpm
                    fi
                ;;
                'VS Code Insiders')
                    wget -O code-insiders.rpm https://go.microsoft.com/fwlink/\?LinkID=760866
                    if [ "$distro" = "fedora" ]; then
                        sudo dnf install ./code-insiders.rpm
                    else
                        sudo zypper install ./code-insiders.rpm
                    fi
                ;;
                'Telegram')
                    if [ "$distro" = "fedora" ]; then
                        addRepo "RPMFusion" "Telegram"
                        sudo dnf install telegram-desktop
                    else
                        addRepo "Non-OSS" "Telegram"
                        sudo zypper install telegram-desktop
                    fi
                ;;
                'MS Teams')
                    wget -O ms-teams.rpm https://go.microsoft.com/fwlink/p/\?linkid=2112907
                    if [ "$distro" = "fedora" ]; then
                        sudo dnf install ./ms-teams.rpm
                    else
                        sudo zypper install ./ms-teams.rpm
                    fi
                ;;
                'Google Chrome')
                    addGoogleRepoKey
                    wget -O google-chrome.rpm https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
                    if [ "$distro" = "fedora" ]; then
                        sudo dnf install ./google-chrome.rpm
                    else
                        sudo zypper install ./google-chrome.rpm
                    fi
                ;;
                'Google Earth')
                    addGoogleRepoKey
                    wget -O google-earth.rpm http://dl.google.com/dl/earth/client/current/google-earth-pro-stable-current.x86_64.rpm
                    if [ "$distro" = "fedora" ]; then
                        sudo dnf install ./google-earth.rpm
                    else
                        sudo zypper install ./google-earth.rpm
                    fi
                ;;
                'Opera')
                    wget -O opera.rpm https://download.opera.com/download/get/\?partner=www\&opsys=Linux\&package=RPM
                    if [ "$distro" = "fedora" ]; then
                        sudo dnf install ./opera.rpm
                    else
                        sudo zypper install ./opera.rpm
                    fi
                ;;
                'Brackets')
                    buildBrackets
                ;;
                'PowerShell')
                    installPowerShell
                ;;
                'Lexmark Printer Driver')
                    installDepsLexmark
                    wget https://github.com/ventisangel/bash-scripts/raw/master/lexmark/lexmark-driver.tar.gz
                    sudo tar --extract --gzip --file="lexmark-driver.tar.gz" --no-overwrite-dir --directory=/
                    sudo ldconfig
                    #if [ "$distro" = "fedora" ]; then
                        #sudo dnf install ./lxkbZ600drv.rpm
                    #else
                        #sudo zypper install ./lxkbZ600drv.rpm
                    #fi
                    sudo systemctl restart cups.service
                ;;
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
