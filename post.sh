#!/usr/bin/env bash

echo -n "Username: "
read username

#mv -v /home/${username}/.bashrc.orig /home/${username}/.bashrc

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

ln -s /etc/runit/sv/connmand /run/runit/service/.
sv start connmand

echo "Giving permissions"
usermod -a -G video,audio,input,power,storage,optical,lp,scanner,dbus,adbusers,uucp,vboxusers $username

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
pacman -S xorg xorg-xinit --ignore xorg-server-xdmx --noconfirm

echo "Installing vim..."
pacman -S vim --noconfirm

echo "Installing gui stuff..."
pacman -S i3-gaps i3lock i3status polybar dmenu xcompmgr feh xfce4-clipman-plugin xfce4-screenshooter unclutter feh --noconfirm

echo "Configuring i3..."
echo -e ". ~/.xprofile\nssh-agent i3" > /home/$username/.xinitrc

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

echo "Installing fish..."
pacman -S fish --noconfirm

echo "Setting fish as default shell..."
chsh $username -s /usr/bin/fish

echo "Installing dash..."
pacman -S dash --noconfirm

echo "Replacing /bin/sh with dash..."
ln -s dash /bin/sh

echo "Installing git and other essentials..."
pacman -S git python python-pip pyalpm firefox ranger mpv subversion --noconfirm

echo "Installing NeoVim..."
pacman -S neovim --noconfirm
pip install neovim

echo "Installing newsboat, ranger and mpv..."
pacman -S newsboat ranger mpv --noconfirm

if $noptimus; then
	echo "Configuring nVidia Optimus..."
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
fi

echo "Copying config files..."
cd /home/$username
svn checkout https://github.com/xslendix/artix_installer/trunk/.config
curl -fsSL https://raw.githubusercontent.com/xslendix/artix_installer/master/.xprofile > /home/$username/.xprofile

cd /home/$username
svn checkout 'https://github.com/xslendix/artix_installer/trunk/.local'
chmod +x -R /home/$username/.local/bin

echo "Installing NeoVim plug-ins..."
nvim +PlugInstall +UpdateRemotePlugins +qall

echo "Getting background image..."
curl -fsSL https://raw.githubusercontent.com/xslendix/artix_installer/master/bg.jpg > /home/$username/.config/i3/bg.jpg

echo "Cloning st..."
sudo -u $username git clone --depth 1 https://github.com/LukeSmithxyz/st /tmp/st

echo "Cd-ing in /tmp/st..."
cd /tmp/st

echo "Downloading patch file..."
if sudo -u $username curl -fsSL https://raw.githubusercontent.com/xslendix/artix_installer/master/st.patch > st.patch; then
	echo "Applying patch..."
	sudo -u $username patch -i st.patch
fi

echo "Compiling st..."
sudo -u $username make

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
chown -R $username .
su $username bash -c "makepkg -si"
pacman -U *.tar.xz

pacman -S "Installing some nice fonts..."
pacman -S otf-font-awesome ttf-font-awesome ttf-roboto-mono ttf-roboto --noconfirm

pacman -S "Installing dunst, pywal"
pacman -S dunst python-pywal --noconfirm

chmod +w -R /home/${username}
chown -R $username /home/${username}

rm /home/$username/post.sh














