#!/usr/bin/env bash

# SPDX-License-Identifier: MIT

# User defined variables

## Applications installed by APT
APT="terminator openjdk-11-jdk brave-browser codium thunderbird signal-desktop transmission-gtk libreoffice gimp rhythmbox steam"

## Applications installed by Flatpak
FLATPAK="com.gitlab.davem.ClamTk cc.arduino.arduinoide org.apache.netbeans org.kicad.KiCad io.freetubeapp.FreeTube com.prusa3d.PrusaSlicer"

# Script preset

echo "Post-Installation Script\n------------------------"

## Initial SW update and installation

echo -n "Starting software update..."
apt-get update > /dev/null && apt-get -y upgrade > /dev/null
echo " DONE"
echo -n "Starting installation of support SW..."
apt-get install apt-transport-https wget > /dev/null
echo " DONE"

# Preinstallation setup

## Flatpak
echo "Checking Flatpak presence"

if ! flatpak --version > /dev/null
then
    echo -n "Flatpak is not installed. Starting installation..."
    apt-get install flatpak > /dev/null
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    echo "DONE\nFlatpak is succesfully installed. Now you must restart the computer."
    exit 0
else
    echo "Flatpak is already installed"
fi

## Brave
wget -qO /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list > /dev/null

## VSCodium
wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
    | gpg --dearmor \
    | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg
echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] https://download.vscodium.com/debs vscodium main' \
    | sudo tee /etc/apt/sources.list.d/vscodium.list > /dev/null

### Signal

wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
cat signal-desktop-keyring.gpg | tee -a /usr/share/keyrings/signal-desktop-keyring.gpg > redirectLong

echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' |\
tee -a /etc/apt/sources.list.d/signal-xenial.list > redirectLong

# User programs installation

## APT
echo "Starting installation of following programs (by APT): $APT"
apt-get -y install $APT > /dev/null
echo "DONE"

## Flatpak
echo "Starting installation of following programs (by Flatpak): $FLATPAK"
flatpak install -y --noninteractive flathub $FLATPAK > /dev/null
echo "DONE"

