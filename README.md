# Mango Linux ISO Generator and Customiser - Debian/Ubuntu
Generates a customised Debian based system from create-so-from-scratch.sh script.
## Instructions
```bash
# set name of your linux
your_linux_name="custom-linux-test"

git clone https://github.com/msm-linux/msm-linux-iso-generator.git $your_linux_name

cd $your_linux_name

## now customise ./create-iso-from-scratch.sh to fit your use
# making script executable
chmod +x create-iso-from-scratch.sh

# executing script
./create-iso-from-scratch.sh
```
## NOTE, To see debootstrap releases scripts
```bash
ls /usr/share/debootstrap/scripts/
```

## Clean Up
```bash
## terminal param set: (default)
# $ your_linux_name="custom-linux-test"
# currently in $your_linux_name base dir
sudo chown $USER .
cd ..
sudo rm -rf $your_linux_name
```

## Dependencies:
    - binutils
    - debootstrap
    - squashfs-tools
    - xorriso
    - grub-pc-bin
    - grub-efi-amd64-bin 
    - mtools

## Bookmarks
    https://help.ubuntu.com/community/LiveCDCustomizationFromScratch

