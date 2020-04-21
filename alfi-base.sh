#!/bin/bash
loadkeys ru
setfont cyr-sun16
timedatectl set-ntp true

(
echo o; 
echo n; echo; echo; echo; echo +100M;
echo n; echo; echo; echo; echo +20G;
echo n; echo; echo; echo; echo +1024M;
echo n; echo p; echo; echo; 
echo a; echo 1;
echo w; 
) | fdisk /dev/nvme0n1

mkfs.ext2  /dev/nvme0n1p1 -L boot
mkfs.ext4  /dev/nvme0n1p2 -L root
mkswap /dev/nvme0n1p3 -L swap
mkfs.ext4  /dev/nvme0n1p4 -L home

mount /dev/nvme0n1p2 /mnt
mkdir /mnt/{boot,home}
mount /dev/nvme0n1p1 /mnt/boot
swapon /dev/nvme0n1p3
mount /dev/nvme0n1p4 /mnt/home

pacman -Sy reflector --noconfirm
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
reflector -c "RU" -f 12 -l 10 -n 12 --save /etc/pacman.d/mirrorlist

pacstrap /mnt base base-devel linux linux-firmware netctl
genfstab -pU /mnt >> /mnt/etc/fstab
arch-chroot /mnt sh -c "$(curl -fsSL https://snoyter.github.io/alfi-config.sh)"
