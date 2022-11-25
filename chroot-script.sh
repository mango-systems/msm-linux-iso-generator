#!/bin/bash

# mount none -t proc /proc
# mount none -t sysfs /sys
# mount none -t devpts /dev/pts
export HOME=/root
export LC_ALL=C
# set a custom hostname
echo $pretty_name > /etc/hostname

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

apt update
apt-get update

add-apt-repository multiverse -y
add-apt-repository restricted -y
add-apt-repository universe -y
dpkg --add-architecture i386 
apt update
apt-get update


apt-get install chrome-gnome-shell chome-gnome-shell-pref
#setup flatpak
apt install -y flatpak
apt install gnome-software-plugin-flatpak
su - $SUDO_USER -c "flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo"

#installing important utilities
apt install os-prober

# removing snap

snap remove --purge firefox
snap remove --purge snap-store
snap remove --purge gnome-3-38-2004

snap remove --purge gtk-common-themes
snap remove --purge snapd-desktop-integration
snap remove --purge bare
snap remove --purge core20
snap remove --purge snapd

apt remove --autoremove snapd -y

# nosnap config
touch /etc/apt/preferences.d/nosnap.pref
echo -e "Package: snapd\nPin: release a=*\nPin-Priority: -10" > /etc/apt/preferences.d/nosnap.pref

apt update

apt install --install-suggests gnome-software -y

add-apt-repository ppa:mozillateam/ppa -y
apt update
apt install -t 'o=LP-PPA-mozillateam' firefox

## configuring firefox to allow update
echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:${distro_codename}";' | tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox

## config to prevent firefox from intall snap associated pkg
touch /etc/apt/preferences.d/mozillateamppa

tee -a /etc/apt/preferences.d/mozillateamppa <<EOF
Package: firefox*
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 501
EOF


apt install -y curl git python3 python3-pip software-properties-common ttf-mscorefonts-installer ca-certificates \
gnome-disk-utility mpv htop neofetch openssh-server synaptic ubuntu-restricted-extras \
dconf-editor pavucontrol blueman gnome-sushi ffmpeg ffmpegthumbnailer \
net-tools gthumb python3-yaml tigervnc-standalone-server \
python3-dateutil python3-pyqt5 python3-packaging python3-requests

apt install webp-pixbuf-loader

flatpak install flathub com.belmoussaoui.Decoder com.github.muriloventuroso.pdftricks \
com.github.tchx84.Flatseal com.github.donadigo.appeditor \
com.mattjakeman.ExtensionManager \
org.gnome.Firmware \
org.gnome.clocks de.haeckerfelix.Fragments \
org.x.Warpinator \
org.gnome.SoundRecorder \
com.github.muriloventuroso.easyssh -y

apt install gnome-tweaks gnome-shell-extension-gsconnect \
gnome-shell-extension-material-shell  gnome-shell-extensions

## install grub customizer
add-apt-repository ppa:danielrichter2007/grub-customizer -y
apt install grub-customizer

## folder color nautilus extension
add-apt-repository ppa:costales/folder-color -y
## yaru specific
add-apt-repository ppa:costales/yaru-colors-folder-color -y

apt update
apt-get update
apt install folder-color yaru-colors-folder-color
apt-get install folder-color

apt install nautilus-admin

# install deb-get
curl -sL https://raw.githubusercontent.com/wimpysworld/deb-get/main/deb-get | sudo -E bash -s install deb-get
# install vs-code using deb-get
deb-get update
deb-get install code #use codium for OSS

## install nerd font

cd $HOME/Downloads && echo "[-] Download fonts [-]" && \
su - $SUDO_USER -c "echo \"https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/DroidSansMono.zip\" && \
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/DroidSansMono.zip && \
unzip DroidSansMono.zip -d ~/.fonts && \
fc-cache -fv"

# removing pkgs (bloats)
apt purge eog totem
sudo apt-get purge thunderbird*


### +++++++======+++++++=======++++++======++++++========
##

# generate locales
dpkg-reconfigure locales
# reconfigure resolvconf
dpkg-reconfigure resolvconf
# reconfigure network-manager
cat <<EOF > /etc/NetworkManager/NetworkManager.conf
[main]
rc-manager=resolvconf
plugins=ifupdown,keyfile
dns=dnsmasq

[ifupdown]
managed=false
EOF
dpkg-reconfigure network-manager


# CLEANUP
# rm /etc/resolv.conf
truncate -s 0 /etc/machine-id

# rm /var/lib/dbus/machine-id

# remove diversion
# rm /sbin/initctl
dpkg-divert --rename --remove /sbin/initctl

# Remove upgraded, old linux-kernels if more than one: (FOR FAILSAFE, may throw error)
# ls /boot/vmlinuz-2.6.**-**-generic > list.txt
# sum=$(cat list.txt | grep '[^ ]' | wc -l)

# if [ $sum -gt 1 ]; then
# dpkg -l 'linux-*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d' | xargs sudo apt-get -y purge
# fi

# rm list.txt

# clean up
apt-get clean

rm -rf /tmp/* ~/.bash_history


# [CONFUSION]
# ! error, as these are not mounted
# umount /proc
# umount /sys
# umount /dev/pts

export HISTSIZE=0