#!/usr/bin/env bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

if ping -q -w 1 -c 1 google.com > /dev/null; then
    echo "Online! Continuing setup..."
else
    echo "Offline! Quitting..."
    exit 1
fi

echo -n "Are you installing on a laptop? [y/N]: "
read -n1 laptop

if [ "$laptop" = "y" ]; then
	laptop=true
else
	laptop=false
fi

echo "Updating..."
pacman -Syyu --noconfirm

echo "Installing Xorg..."
pacman -S xorg --ignore xorg-server-xdmx --noconfirm

echo "Installing nvidia drivers..."
pacman -S nvidia-lts --noconfirm

echo "Installing vim"
pacman -S vim --noconfirm

echo "Installing i3-gaps, polybar, dmenu, xcompmgr and feh"
pacman -S i3-gaps i3lock i3status polybar dmenu xcompmgr feh xfce4-clipman-plugin xfce4-screenshooter --noconfirm








