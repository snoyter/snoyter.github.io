#!/bin/bash
echo "navi" > /etc/hostname
ln -svf /usr/share/zoneinfo/Asia/Novosibirsk /etc/localtime
hwclock --systohc
echo -e "en_US.UTF-8 UTF-8\nru_RU.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo 'LANG="ru_RU.UTF-8"' > /etc/locale.conf
echo 'KEYMAP=ru' >> /etc/vconsole.conf
echo 'FONT=cyr-sun16' >> /etc/vconsole.conf

echo '127.0.0.1	localhost' > /etc/hosts
echo '::1		localhost' >> /etc/hosts
echo '127.0.1.1	navi.localdomain navi' >> /etc/hosts

mkinitcpio -p linux
passwd

pacman -Sy grub --noconfirm
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
pacman -S dialog wpa_supplicant --noconfirm

useradd -m -g users -G wheel -s /bin/bash snoyter
passwd snoyter
echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers

echo '[multilib]' >> /etc/pacman.conf
echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf
pacman -Syy 

pacman -S xorg-server xorg-drivers xorg-xinit --noconfirm
pacman -S ttf-hack --noconfirm
pacman -S networkmanager --noconfirm
pacman -S xf86-video-intel lib32-intel-dri --noconfirm
pacman -S i3-wm --noconfirm

echo 'exec i3' > /home/snoyter/.xinitrc

mkdir /etc/systemd/system/getty@tty1.service.d
echo "[Service]" > /etc/systemd/system/getty@tty1.service.d/override.conf
echo "ExecStart=" >> /etc/systemd/system/getty@tty1.service.d/override.conf
echo "ExecStart=-/usr/bin/agetty —autologin snoyter —noclear %I $TERM" >> /etc/systemd/system/getty@tty1.service.d/override.conf

systemctl enable NetworkManager

exit