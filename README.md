# Bash scripts

Scripts published here are created in order to help users in configuring their GNU/Linux distros after installation. They're all tested with shellcheck, although currently I recommend using them by more advanced users.

POSIX versions are available in another repo. GUI versions (made with Zenity and KDialog) will be available as separate scripts.

## Supported distros
* Ubuntu
* Debian
* Fedora
* openSUSE

## Scripts' descriptions
* *appssetup.sh* - this script lets user install some proprietary apps without having to search for them on different websites and manually download packages

## How to use
Choose target directory on your disk by moving into it with ```cd```, for example: ```cd ~/Downloads```, and then download any of these scripts with ```wget https://github.com/ventisangel/bash-scripts/raw/master/<scriptname>.sh```. You don't need to download additional files published here, because it'll be done during scripts' execution if needed. Remember also to change permissions for downloaded scripts in order to be able to execute them with ```chmod +x <scriptname>.sh```.

## Feedback
Feel free to leave any opinions about these scripts - it'll help me improve them and I'll be glad to hear from you :)
