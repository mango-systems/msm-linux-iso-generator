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
    ubuntu-gnome-desktop
    # ubuntu-gnome-wallpapers

## MSM CUSTOM LINUX SCRIPTS HERE
### +++++++======+++++++=======++++++======++++++========

apt update
apt-get update

add-apt-repository multiverse -y
add-apt-repository restricted -y
add-apt-repository universe -y
# dpkg --add-architecture i386 
apt update
apt-get update


# apt-get install chrome-gnome-shell chome-gnome-shell-pref
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

sudo add-apt-repository ppa:helkaluin/webp-pixbuf-loader -y
apt install webp-pixbuf-loader

flatpak install flathub \
com.belmoussaoui.Decoder \
com.github.tchx84.Flatseal \
com.github.donadigo.appeditor \
com.mattjakeman.ExtensionManager \
org.gnome.Firmware \
org.gnome.clocks \
de.haeckerfelix.Fragments \
org.x.Warpinator \
io.github.fabrialberio.pinapp \
org.gnome.SoundRecorder \
com.github.GradienceTeam.Gradience \
io.github.realmazharhussain.GdmSettings \
 io.github.hakandundar34coding.system-monitoring-center \
-y

# IDEAS for flatpak apps: Time Switch, Proton up qt(gaming related), Bottles, Warpinator

apt install gnome-tweaks gnome-shell-extensions

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
## PROPRIORTARY
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


## INSTALLING GTK THEME - Jasper
# NOTE: To enable theme, configure dconf override
# mkdir /tmp
cd /tmp
git clone https://github.com/vinceliuice/Jasper-gtk-theme.git
cd Jasper-gtk-theme
chmod +x install.sh
./install.sh
# Identifier: Jasper-Dark 

## ADW-GTK3 theme
cd /tmp
# Download latest version
curl -s https://api.github.com/repos/lassekongo83/adw-gtk3/releases/latest \
| grep "browser_download_url.*tar.xz" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -qi -
# extract files to /usr/share/themes
ADW=$(ls adw*.tar.xz)
tar -xf "$ADW" -C /usr/share/themes


### INSTALLING ICON THEME
## Colloid icon theme
cd /tmp
git clone https://github.com/vinceliuice/Colloid-icon-theme.git
cd Colloid-icon-theme 
chmod +x install.sh
./install.sh  --theme teal --scheme default

## Reversal icon theme
# cd /tmp
# git clone https://github.com/yeyushengfan258/Reversal-icon-theme.git
# cd Reversal-icon-theme
# chmod +x install.sh
# ./install.sh

### Installing extensions
cd /tmp
wget https://raw.githubusercontent.com/msm-linux/msm-linux-iso-generator/main/assets/install-gnome-shell-extension.py
chmod +x install-gnome-shell-extension.py

# extension IDs
# 5338 - https://extensions.gnome.org/extension/5338/aylurs-widgets/
# 517 - https://extensions.gnome.org/extension/517/caffeine/
# 906 - https://extensions.gnome.org/extension/906/sound-output-device-chooser/ [not compatible]
# 19 - https://extensions.gnome.org/extension/19/user-themes/
## planned: quick settings tweaker, bookmarked in telegram
## install GS CONNECT manually


for ext in 5338 517 19
do
    ./install-gnome-shell-extension.py $ext
done


## Install Plymouth theme
# theme: cuts
cd /tmp
git clone https://github.com/adi1090x/plymouth-themes.git
cd plymouth-themes
cd pack_1
sudo cp -r cuts /usr/share/plymouth/themes/
sudo update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/cuts/cuts.plymouth 100
# select the theme manually
sudo update-alternatives --config default.plymouth
#(select the number for installed theme, cuts in this case)
sudo update-initramfs -u


## REMINDER!
# configure gconf for user themes, DONE, may fail

# Setup grub for CD
# install plymouth theme, done
# install Grub theme, DONE
# setup tlp
# calamares configs
# system monitoring tool, DONE
# apps from msm system, inspiration like pinapp, DONE
# config aylur's widget via gconf. DONE
# use adw3-gtk theme for better support with Gradience flatpak, DONE
# use default yaru theme for better default theme, DONE, but may have to manually change value [untested]
# install fonts rubik, DONE
# firefox profile
# create wallpaper packs and then configure in gconf, DONE
# compile glib gschema gconf, DONE
# config skel folder for default files
# setup ocs-url (NOT NOW)

# ERROR: current wallpaper is too big > 200MB, which is bloat. reduce it..., DONE

# CREATE MANIFEST: https://help.ubuntu.com/community/LiveCDCustomizationFromScratch, in create-iso.....sh

# customise lsb_release and os_release, DONE

## REMINDER: in gnome 43 there is an option name changed to legacy app, so the gconf value might change

# install custom grub2 theme, DONE
## UNTESTED with 1080p wallpaper
cd /tmp
git clone https://github.com/msm-linux/grub2-themes-mango-customised.git custom-grub
cd custom-grub
chmod +x ./install.sh
sudo ./install.sh -s 1080p -t vimix -i vimix

# installing RUBIK font
cd /tmp
git clone https://github.com/googlefonts/rubik.git
cd rubik
cd ./fonts/otf
cp Rubik* /usr/local/share/fonts

# install Wallpapers (CUSTOM)
cd /tmp
wget https://raw.githubusercontent.com/msm-linux/msm-linux-iso-generator/main/assets/mango_wallpapers_1.0.deb
dpkg -i mango_wallpapers_1.0.deb

# compile glib gschema
cd /tmp
wget -q https://raw.githubusercontent.com/msm-linux/msm-linux-iso-generator/main/assets/10_ubuntu-settings.gschema.override
cp ubuntu-settings.gschema.override /usr/share/glib-2.0/schemas/
glib-compile-schemas /usr/share/glib-2.0/schemas/

### Configuring
## make variables here
# /etc/lsb_release
sed -i 's/Ubuntu 22.10/Mango linux/g' /etc/lsb-release
# /etc/os-release 
sed -i 's/Ubuntu 22.10/Mango linux/g' /etc/os-release


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