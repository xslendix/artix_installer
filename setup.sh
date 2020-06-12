#!/usr/bin/env bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

echo -e "GET http://google.com HTTP/1.0\n\n" | nc google.com 80 > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "Online! Continuing setup..."
else
    echo "Offline! Quitting..."
    exit 1
fi

echo -n "Are you installing on a laptop? [y/N]: "
read -n1 laptop

if [ $laptop = "y" ] then
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

echo -n "Root password: "
stty -echo
read root_password
stty echo

echo "Now you will need to make the partitions.\nSwap not recommended."
read -n 1 -s

cfdisk /dev/sda

echo -e "Now you need to format the partitions.\nUse commands like 'mkfs.ext4 -L ROOT /dev/sda1' or 'mkfs.ext4 -L HOME /dev/sdb1'."
echo -e "Dont forget to 'mkfs.ext4 -L BOOT /dev/sda4'\n\n^D to exit."

bash

echo "Mounting partitions..."

echo -n "Mounting ROOT... "
if [ -d /dev/disk/by-label/ROOT ]
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
if [ -d /dev/disk/by-label/HOME ] then
	mount /dev/disk/by-label/HOME /mnt/home
	echo "[  DONE  ]"
else
	echo "[ IGNORE ]"
fi

echo -n "Mounting BOOT... "
if [ -d /dev/disk/by-label/BOOT ] then
	mount /dev/disk/by-label/BOOT /mnt/boot
	echo "[  DONE  ]"
else
	echo "[ FAILED ]"
	echo "Cannot find BOOT partition! Quitting..."
	exit 1
fi

