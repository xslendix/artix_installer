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

echo "Laptop is now equal to ${laptop}."

echo -n "Username: "
read username

echo -n "User password: "
stty -echo
read password
stty echo
echo ""

echo -n "Root password: "
stty -echo
read root_password
stty echo
echo ""

echo -e "Now you will need to make the partitions.\nSwap not recommended."
echo "Press any key to continue."
read -n 1 -s

cfdisk /dev/sda

echo -e "Now you need to format the partitions.\nUse commands like 'mkfs.ext4 -L ROOT /dev/sda1' or 'mkfs.ext4 -L HOME /dev/sdb1'."
echo -e "Dont forget to 'mkfs.ext4 -L BOOT /dev/sda4'\n\n^D to exit."

bash

echo "Mounting partitions..."

echo -n "Mounting ROOT... "
if [ -d /dev/disk/by-label/ROOT ]; then
	mount /dev/disk/by-label/ROOT /mnt
	echo "[  DONE  ]"
else
	echo "[ FAILED ]"	
	echo "Cannot find ROOT partition! Quitting..."
	exit 1
fi

mkdir /mnt/boot
mkdir /mnt/home

echo -n "Mounting HOME... "
if [ -d /dev/disk/by-label/HOME ]; then
	mount /dev/disk/by-label/HOME /mnt/home
	echo "[  DONE  ]"
else
	echo "[ IGNORE ]"
fi

echo -n "Mounting BOOT... "
if [ -d /dev/disk/by-label/BOOT ]; then
	mount /dev/disk/by-label/BOOT /mnt/boot
	echo "[  DONE  ]"
else
	echo "[ FAILED ]"
	echo "Cannot find BOOT partition! Quitting..."
	exit 1
fi

pacman -Syy

echo "Installing base system..."
basestrap /mnt base base-devel openrc

echo "Installing the Linux kernel..."
basestrap /mnt linux linux-firmware

echo "Generating fstab..."
fstabgen -U /mnt >>/mnt/etc/fstab








