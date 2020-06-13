#!/usr/bin/env bash

echo -n "Username: "
read username

mv -v /home/${username}/.bashrc.orig /home/${username}/.bashrc

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

noptimus=false

if [ "$laptop" = "y" ]; then
	laptop=true
	
	echo -n "Do you want to use nVidia Optimus? [y/N]: "
	read -n1 noptimus

	if [ "$noptimus" = "y" ]; then
		noptimus=true
	else
		noptimus=false
	fi
else
	laptop=false
fi

echo -n "Using nvidia? [y/N]: "
read -n1 nvidiaq

if [ "$nvidiaq" = "y" ]; then
	nvidiaq=true
else
	nvidiaq=false
fi

echo "Installing on laptop: ${laptop}"
echo "Installing with nVidia: ${nvidiaq}"
echo "Installing with nVidia Optimus: ${noptimus}"

echo "Updating..."
pacman -Syyu --noconfirm

echo "Installing Xorg..."
pacman -S xorg --ignore xorg-server-xdmx --noconfirm

echo "Installing vim..."
pacman -S vim --noconfirm

echo "Installing i3-gaps, polybar, dmenu, xcompmgr and feh..."
pacman -S i3-gaps i3lock i3status polybar dmenu xcompmgr feh xfce4-clipman-plugin xfce4-screenshooter --noconfirm

echo "Getting background image..."
curl -fsSL https://raw.githubusercontent.com/xslendix/artix_installer/master/bg.jpg > /home/$username/.config/i3/bg.jpg

echo "Configuring i3..."
curl -fsSL https://raw.githubusercontent.com/xslendix/artix_installer/master/configs/i3/config > /home/$username/.config/i3/config

echo "Configuring polybar"
curl -fsSL https://raw.githubusercontent.com/xslendix/artix_installer/master/configs/polybar/config > /home/$username/.config/polybar/config

if $nvidiaq; then
	echo "Installing nvidia drivers..."
	pacman -S nvidia --noconfirm

	echo "Backing up xconfig..."
	if cp -v /etc/X11/xorg.conf /etc/X11/xorg.conf.old; then
		echo "Configuring nVidia drivers..."
		nvidia-xconfig
	else
		echo "/etc/X11/xorg.conf could not be copied! It either doesn't exist or the disk has a problem. Abandoning nVidia config!"
	fi
fi

echo "Installing xrandr..."
pacman -S xorg-xrandr --noconfirm

echo "Installing LightDM..."
pacman -S lightdm lightm-gtk-greeter lightdm-openrc

echo "Adding LightDM"
rc-update add dbus default
rc-update add xdm default
rc-update add lightdm default

echo "Installing fish..."
pacman -S fish --noconfirm

echo "Configuring fish..."
curl -fsSL https://raw.githubusercontent.com/xslendix/artix_installer/master/configs/fish/config.fish > /home/$username/.config/fish/config.fish

echo "Installing dash"
sudo pacman -S dash --noconfirm

echo "Replacing /bin/sh with dash"
ln -s dash /bin/sh

echo "Installing git and other essentials..."
pacman -S git python python-pip pyalpm firefox ranger mpv  --noconfirm

echo "Installing NeoVim..."
pip install neovim

echo "Configuring NeoVim..."
# TODO: Add configuration steps here!

echo "Configuring ranger..."
# TODO: Add configuration steps here!

if $nvidiaq; then
	if $noptimus; then
		echo "Configuring nVidia Optimus"
		echo "Section "OutputClass"
    Identifier "intel"
    MatchDriver "i915"
    Driver "modesetting"
EndSection

Section "OutputClass"
    Identifier "nvidia"
    MatchDriver "nvidia-drm"
    Driver "nvidia"
    Option "AllowEmptyInitialConfiguration"
    Option "PrimaryGPU" "yes"
    ModulePath "/usr/lib/nvidia/xorg"
    ModulePath "/usr/lib/xorg/modules"
EndSection" > /etc/X11/xorg.conf.d/10-nvidia-drm-outputclass.conf

		sed -i '1s/^/xrandr --dpi 96\n/' /home/$username/.xinitrc
		sed -i '1s/^/xrandr --auto\n/' /home/$username/.xinitrc
		sed -i '1s/^/xrandr --setprovideroutputsource modesetting NVIDIA-0\n/' /home/$username/.xinitrc

		echo "#!/bin/sh
xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --auto" > /etc/lightdm/display_setup.sh
		chmod +x /etc/lightdm/display_setup.sh

		echo "Configuing LightDM"
		echo "[LightDM]
logind-check-graphical=true
run-directory=/run/lightdm
[Seat:*]
greeter-session=lightdm-gtk-greeter     
session-wrapper=/etc/lightdm/Xsession   
display-setup-script=/etc/lightdm/display_setup.sh
[XDMCPServer]
[VNCServer]
" > /etc/lightdm/lightdm.conf
	else
		echo "Configuring LightDM"
		echo "[LightDM]
logind-check-graphical=true
run-directory=/run/lightdm
[Seat:*]
greeter-session=lightdm-gtk-greeter     
session-wrapper=/etc/lightdm/Xsession   
[XDMCPServer]
[VNCServer]
" > /etc/lightdm/lightdm.conf
	fi
else
	echo "Configuring LightDM"
	echo "[LightDM]
logind-check-graphical=true
run-directory=/run/lightdm
[Seat:*]
greeter-session=lightdm-gtk-greeter     
session-wrapper=/etc/lightdm/Xsession   
[XDMCPServer]
[VNCServer]
" > /etc/lightdm/lightdm.conf
fi

echo "Making configuration directories"
mkdir -p /home/$username/.config/{i3,fish,polybar}

echo "Cloning st..."
git clone --depth 1 https://github.com/LukeSmithxyz/st /tmp/st

echo "Cd-ing in /tmp/st"
cd /tmp/st

echo "Downloading patch file..."
if curl -fsSL https://raw.githubusercontent.com/xslendix/artix_installer/master/st.patch > st.patch; then
	echo "Applying patch..."
	patch st.patch
fi

echo "Compiling st..."
make

echo "Installing st..."
make install

echo "Cd-ing into /tmp"
cd /tmp

echo "Downloading pikaur and cd-ing into it..."
git clone --depth 1 https://aur.archlinux.org/pikaur.git
cd pikaur

echo "Opening PKGBUILD..."
vim PKGBUILD

echo "Installing pikaur..."
su $username bash -c "makepkg -si"





















