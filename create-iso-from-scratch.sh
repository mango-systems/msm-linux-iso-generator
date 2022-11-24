#!/bin/bash

## Run as sudo
## Bookmark: https://help.ubuntu.com/community/LiveCDCustomizationFromScratch

## Variables
host_release=jammy

target_release=jammy
chroot_folder=chroot

# base_asset_repo_link=
pretty_name="msm linux"
output_iso_name=msm-linux
#----------main------------
## Setting up dependencies
sudo apt-get install \
    binutils \
    debootstrap \
    squashfs-tools \
    xorriso \
    grub-pc-bin \
    grub-efi-amd64-bin \
    mtools
##


sudo debootstrap --arch=amd64 $target_release $chroot_folder
sudo mount --bind /dev chroot/dev

sudo cp /etc/hosts chroot/etc/hosts
sudo cp /etc/resolv.conf chroot/etc/resolv.conf
sudo cp /etc/apt/sources.list chroot/etc/apt/sources.list

sudo sed s/$host_release/$target_release/ < /etc/apt/sources.list > chroot/etc/apt/sources.list


# CHROOT ENV
sudo chroot $chroot_folder "$SHELL" -i

mount none -t proc /proc
mount none -t sysfs /sys
mount none -t devpts /dev/pts
export HOME=/root
export LC_ALL=C

apt-get update
apt-get install --yes dbus
dbus-uuidgen > /var/lib/dbus/machine-id
# create diversion
dpkg-divert --local --rename --add /sbin/initctl

apt-get --yes upgrade

## packeges for live system
# apt-get install --yes ubuntu-standard casper lupin-casper
# apt-get install --yes discover laptop-detect os-prober
apt-get install --yes linux-generic

apt-get install -y \
    sudo \
    ubuntu-standard \
    casper \
    discover \
    laptop-detect \
    os-prober \
    network-manager \
    resolvconf \
    net-tools \
    wireless-tools \
    wpagui \
    locales \
    grub-common \
    grub-gfxpayload-lists \
    grub-pc \
    grub-pc-bin \
    grub2-common

apt install --yes plymouth plymouth-themes 

# apt install firmware-linux 

## Graphical installer (optional)
# apt-get --yes install ubiquity-frontend-gtk
apt-get install -y \
   ubiquity \
   ubiquity-casper \
   ubiquity-frontend-gtk \
   ubiquity-slideshow-ubuntu \
   ubiquity-ubuntu-artwork

## SETUP DE / Window Manager (CUSTOM)
apt-get install -y \
    plymouth-theme-ubuntu-logo \
    ubuntu-gnome-desktop \
    ubuntu-gnome-wallpapers

## MSM CUSTOM LINUX SCRIPTS HERE
### +++++++======+++++++=======++++++======++++++========
##

# CLEANUP

rm /var/lib/dbus/machine-id

# remove diversion
rm /sbin/initctl
dpkg-divert --rename --remove /sbin/initctl

# Remove upgraded, old linux-kernels if more than one: 
ls /boot/vmlinuz-2.6.**-**-generic > list.txt
sum=$(cat list.txt | grep '[^ ]' | wc -l)

if [ $sum -gt 1 ]; then
dpkg -l 'linux-*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d' | xargs sudo apt-get -y purge
fi

rm list.txt

# clean up
apt-get clean

rm -rf /tmp/*

rm /etc/resolv.conf

umount -lf /proc
umount -lf /sys
umount -lf /dev/pts
exit

### EXITED CUSTOM CD

# If you also bound your /dev to the chroot, you should unbind that. 
# sudo umount /chroot/dev
workdir=pwd

sudo umount $workdir/chroot/dev
sudo umount $workdir/chroot/run

## CREATE CD ====>
mkdir -p image/{casper,isolinux,install}

# copy kernal image:
sudo cp chroot/boot/vmlinuz-**-**-generic image/casper/vmlinuz
sudo cp chroot/boot/initrd.img-**-**-generic image/casper/initrd
# copy memtest86 binary
sudo cp chroot/boot/memtest86+.bin image/install/memtest86+
# Download and extract memtest86 binary (UEFI):
wget --progress=dot https://www.memtest86.com/downloads/memtest86-usb.zip -O image/install/memtest86-usb.zip
unzip -p image/install/memtest86-usb.zip memtest86-usb.img > image/install/memtest86
rm -f image/install/memtest86-usb.zip

## GRUB CONFIGURATION
touch image/ubuntu
#Create image/isolinux/grub.cfg:
cat <<EOF > image/isolinux/grub.cfg

search --set=root --file /ubuntu

insmod all_video

set default="0"
set timeout=30

menuentry "Try Ubuntu FS without installing" {
   linux /casper/vmlinuz boot=casper nopersistent toram quiet splash ---
   initrd /casper/initrd
}

menuentry "Install Ubuntu FS" {
   linux /casper/vmlinuz boot=casper only-ubiquity quiet splash ---
   initrd /casper/initrd
}

menuentry "Check disc for defects" {
   linux /casper/vmlinuz boot=casper integrity-check quiet splash ---
   initrd /casper/initrd
}

menuentry "Test memory Memtest86+ (BIOS)" {
   linux16 /install/memtest86+
}

menuentry "Test memory Memtest86 (UEFI, long load time)" {
   insmod part_gpt
   insmod search_fs_uuid
   insmod chain
   loopback loop /install/memtest86
   chainloader (loop,gpt1)/efi/boot/BOOTX64.efi
}
EOF

## CREATE MANIFEST:
sudo chroot $chroot_folder dpkg-query -W --showformat='${Package} ${Version}\n' | sudo tee image/casper/filesystem.manifest
sudo cp -v image/casper/filesystem.manifest image/casper/filesystem.manifest-desktop
sudo sed -i '/ubiquity/d' image/casper/filesystem.manifest-desktop
sudo sed -i '/casper/d' image/casper/filesystem.manifest-desktop
sudo sed -i '/discover/d' image/casper/filesystem.manifest-desktop
sudo sed -i '/laptop-detect/d' image/casper/filesystem.manifest-desktop
sudo sed -i '/os-prober/d' image/casper/filesystem.manifest-desktop

## COMPRESS THE CHROOT
# create squashfs
sudo mksquashfs chroot image/casper/filesystem.squashfs
# Write the filesystem.size
printf $(sudo du -sx --block-size=1 chroot | cut -f1) > image/casper/filesystem.size

### CREATE DISKDEFINES
# Create file image/README.diskdefines:
cat <<EOF > image/README.diskdefines
#define DISKNAME  Ubuntu from scratch msm
#define TYPE  binary
#define TYPEbinary  1
#define ARCH  amd64
#define ARCHamd64  1
#define DISKNUM  1
#define DISKNUM1  1
#define TOTALNUM  0
#define TOTALNUM0  1
EOF

### Create ISO Image for a LiveCD (BIOS + UEFI)
# Create a grub UEFI image

cd image

grub-mkstandalone \
   --format=x86_64-efi \
   --output=isolinux/bootx64.efi \
   --locales="" \
   --fonts="" \
   "boot/grub/grub.cfg=isolinux/grub.cfg"

# Create a FAT16 UEFI boot disk image containing the EFI bootloader:
(
   cd isolinux && \
   dd if=/dev/zero of=efiboot.img bs=1M count=10 && \
   sudo mkfs.vfat efiboot.img && \
   LC_CTYPE=C mmd -i efiboot.img efi efi/boot && \
   LC_CTYPE=C mcopy -i efiboot.img ./bootx64.efi ::efi/boot/
)

# Create a grub BIOS image
grub-mkstandalone \
   --format=i386-pc \
   --output=isolinux/core.img \
   --install-modules="linux16 linux normal iso9660 biosdisk memdisk search tar ls" \
   --modules="linux16 linux normal iso9660 biosdisk search" \
   --locales="" \
   --fonts="" \
   "boot/grub/grub.cfg=isolinux/grub.cfg"

# Combine a bootable Grub cdboot.img:
cat /usr/lib/grub/i386-pc/cdboot.img isolinux/core.img > isolinux/bios.img

# Generate md5sum.txt:
sudo /bin/bash -c "(find . -type f -print0 | xargs -0 md5sum | grep -v -e 'md5sum.txt' -e 'bios.img' -e 'efiboot.img' > md5sum.txt)"

# Create iso from the image directory using the command-line:
sudo xorriso \
   -as mkisofs \
   -iso-level 3 \
   -full-iso9660-filenames \
   -volid $pretty_name \
   -output "../$output_iso_name.iso" \
   -eltorito-boot boot/grub/bios.img \
      -no-emul-boot \
      -boot-load-size 4 \
      -boot-info-table \
      --eltorito-catalog boot/grub/boot.cat \
      --grub2-boot-info \
      --grub2-mbr /usr/lib/grub/i386-pc/boot_hybrid.img \
   -eltorito-alt-boot \
      -e EFI/efiboot.img \
      -no-emul-boot \
   -append_partition 2 0xef isolinux/efiboot.img \
   -m "isolinux/efiboot.img" \
   -m "isolinux/bios.img" \
   -graft-points \
      "/EFI/efiboot.img=isolinux/efiboot.img" \
      "/boot/grub/bios.img=isolinux/bios.img" \
      "."

## NOTE: file may not be accessible to local user as created by sudo run chown then