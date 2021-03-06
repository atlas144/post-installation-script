#!/usr/bin/env bash

# SPDX-License-Identifier: MIT

# User defined variables
## Applications installed by APT (separated by spaces)
apt="terminator openjdk-13-jdk brave-browser codium thunderbird signal-desktop transmission-gtk libreoffice gimp rhythmbox steam"

## Applications installed by Flatpak (separated by spaces)
flatpak="cc.arduino.arduinoide org.apache.netbeans org.kicad.KiCad io.freetubeapp.FreeTube com.prusa3d.PrusaSlicer"

## Groups where user should be added (separated by commas)
groups="dialout"

# Arguments handling
redirectLong=/dev/null
redirectShort=/dev/stdout

while getopts ":snv" argument; do
    case ${argument} in
        s)  # Silent
            redirectLong=/dev/null
            redirectShort=/dev/null
            ;;
        n)  # Normal
            redirectLong=/dev/null
            redirectShort=/dev/stdout
            ;;
        v)  # Verbose
            redirectLong=/dev/stdout
            redirectShort=/dev/stdout
            ;;
        \?)
            echo "Error: Invalid argument"
            exit 1
            ;;
    esac
done

# Preset beginning
echo -e "Post-Installation Script\n------------------------" > $redirectShort

## Initial update and support SW installation
echo "Starting software update..." > $redirectShort
apt-get update > $redirectLong && apt-get -y upgrade > $redirectLong
echo "DONE" > $redirectShort
echo "Starting installation of support SW..." > $redirectShort
apt-get -y install apt-transport-https wget > $redirectLong
echo "DONE" > $redirectShort

## User programs preinstallation setup
### Flatpak setup
echo "Checking Flatpak presence..." > $redirectShort

if ! flatpak --version > /dev/null 2> /dev/null
then
    echo "Flatpak is not installed. Starting installation..." > $redirectShort
    apt-get -y install flatpak > $redirectLong
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    echo -e "DONE\nFlatpak is succesfully installed. Now you must restart the computer."
    exit 0
else
    echo "Flatpak is already installed" > $redirectShort
fi

### Brave repository setup
echo "Adding Brave repository..." > $redirectShort
wget -qO /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | tee /etc/apt/sources.list.d/brave-browser-release.list > $redirectLong
echo "DONE" > $redirectShort

### VSCodium repository setup
echo "Adding VSCodium repository..." > $redirectShort
wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
    | gpg --dearmor > /usr/share/keyrings/vscodium-archive-keyring.gpg
echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] https://download.vscodium.com/debs vscodium main' \
    | tee /etc/apt/sources.list.d/vscodium.list > $redirectLong
echo "DONE" > $redirectShort

### Signal repository setup
echo "Adding Signal repository..." > $redirectShort
wget -qO - https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > /usr/share/keyrings/signal-desktop-keyring.gpg

echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' |\
tee /etc/apt/sources.list.d/signal-xenial.list > $redirectLong
echo "DONE" > $redirectShort


## User programs installation
### APT programs installation
echo "Starting installation of following programs (by APT): $apt..." > $redirectShort
apt-get update > $redirectLong && apt-get -y install $apt > $redirectLong
echo "DONE" > $redirectShort

### Flatpak programs installation
echo "Starting installation of following programs (by Flatpak): $flatpak..." > $redirectShort
flatpak install -y --noninteractive flathub $flatpak > $redirectLong
echo "DONE" > $redirectShort

# Settings
## Adding records to .bashrc file
echo "Setting default apps..." > $redirectShort
echo "export BROWSER=/usr/bin/brave-browser" >> "/home/$SUDO_USER/.bashrc"
echo "DONE" > $redirectShort

echo "Setting shell prompt..." > $redirectShort
echo "export PS1=\"\[\033[38;5;76m\]\[$(tput bold)\]??????(\[$(tput sgr0)\]\[\033[38;5;255m\]\[$(tput bold)\]\u\[$(tput sgr0)\]\[\033[38;5;76m\]\[$(tput bold)\]@\[$(tput sgr0)\]\[\033[38;5;255m\]\[$(tput bold)\]\H\[$(tput sgr0)\]\[\033[38;5;76m\]\[$(tput bold)\])-[\[$(tput sgr0)\]\[\033[38;5;255m\]\[$(tput bold)\]\w\[$(tput sgr0)\]\[\033[38;5;76m\]\[$(tput bold)\]]\n?????????\\$\[$(tput sgr0)\] \"" >> "/home/$SUDO_USER/.bashrc"
echo "DONE" > $redirectShort

## Adding user to groups
echo "Adding user to following groups: $groups..." > $redirectShort
usermod -aG $groups $SUDO_USER
echo "DONE" > $redirectShort

## Applications config
### VSCodium
if [[ ! -d "/home/$SUDO_USER/.config/VSCodium" ]]
then
    if [[ ! -d "/home/$SUDO_USER/.config" ]]
    then
        echo "Creating \"~/.config\" folder..." > $redirectShort
        mkdir "/home/$SUDO_USER/.config/VSCodium"
        echo "DONE" > $redirectShort
    fi

    echo "Creating \"~/.config/VSCodium\" folder..." > $redirectShort
    mkdir "/home/$SUDO_USER/.config/VSCodium"
    echo "DONE" > $redirectShort
fi

echo "Creating product.json file..." > $redirectShort
echo "{
  \"extensionsGallery\": {
    \"serviceUrl\": \"https://marketplace.visualstudio.com/_apis/public/gallery\",
    \"cacheUrl\": \"https://vscode.blob.core.windows.net/gallery/index\",
    \"itemUrl\": \"https://marketplace.visualstudio.com/items\",
    \"controlUrl\": \"\",
    \"recommendationsUrl\": \"\"
  }
}" > "/home/$SUDO_USER/.config/VSCodium/product.json"
echo "DONE" > $redirectShort
