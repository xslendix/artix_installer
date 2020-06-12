#!/usr/bin/env bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

echo -n "Are you installing on a laptop? [y/N]: "
read -n1 laptop

if [ $laptop = "y" ] then
	laptop=true
else
	laptop=false
end

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


