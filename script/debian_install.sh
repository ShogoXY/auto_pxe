#!/bin/bash

echo "Please cgose what version should be downloaded"
echo ""
a1=$(lynx -dump -listonly https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/ |uniq -f 1|grep 'https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-1.*.iso'|sed "s|https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/||g"|cut -c 7-)

a2=$(lynx -dump -listonly https://cdimage.debian.org/cdimage/unofficial/non-free/cd-including-firmware/current/amd64/iso-cd/ |uniq -f 1|grep 'https://cdimage.debian.org/cdimage/unofficial/non-free/cd-including-firmware/current/amd64/iso-cd/firmware-1.*.iso'|sed "s|https://cdimage.debian.org/cdimage/unofficial/non-free/cd-including-firmware/current/amd64/iso-cd/||g"|cut -c 7-)

link1=$(lynx -dump -listonly https://cdimage.debian.org/debian-cd/current/amd64/iso-cd |uniq -f 1|grep 'https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-1.*.iso'|cut -c 7-)
link2=$(lynx -dump -listonly https://cdimage.debian.org/cdimage/unofficial/non-free/cd-including-firmware/current/amd64/iso-cd/  |uniq -f 1|grep 'https://cdimage.debian.org/cdimage/unofficial/non-free/cd-including-firmware/current/amd64/iso-cd/firmware-1.*.iso'|cut -c 7-)


echo -e "\t 1 " $a1 
echo -e "\t 2 " $a2
echo ""
echo "Please choose 1 or 2"

while read -r deb
do

if [[ "$deb" == "1" ]]
then
wget -O /home/$USER/debian.iso $link1


elif [[ "$deb" == "2" ]]
then
wget -O /home/$USER/debian.iso $link2
else
	echo "Please choose 1 or 2"
	continue
fi
break
done



sudo mkdir -p /srv/tftp/iso
sudo mkdir -p /srv/tftp/iso/debian-net


sudo mount /home/$USER/debian.iso /mnt

echo -e"
-------------------------
Copy ISO file 
-------------------------
"

sudo rsync -ah --info=progress2 /mnt/. /srv/tftp/iso/debian-net/
sudo umount /mnt
sudo rm /home/$USER/debian.iso



printf "
UI menu.c32

LABEL Debian net
        MENU LABEL ^1. Debian
        KERNEL iso/debian-net/install.amd/vmlinuz
        append initrd=iso/debian-net/install.amd/initrd.gz
	TEXT HELP
		DEBIAN by TFTP
	ENDTEXT
" | sudo tee /srv/tftp/pxelinux.cfg/default >> /dev/null

printf "
UI menu.c32
#TIMEOUT 50
#PROMPT 1 
LABEL Debian net
        MENU LABEL ^1. Debian
        KERNEL ::iso/debian-net/install.amd/vmlinuz
        append initrd=::iso/debian-net/install.amd/initrd.gz
	TEXT HELP
		DEBIAN by TFTP
	ENDTEXT

LABEL Debian Http
	MENU LABEL ^2. Debian by HTTPS
        KERNEL http://192.168.0.2/iso/debian-net/install.amd/vmlinuz
        append initrd=http://192.168.0.2/iso/debian-net/install.amd/initrd.gz
	TEXT HELP
		Debian using HTTP server
	ENDTEXT
" |sudo tee /srv/tftp/efi64/pxelinux.cfg/default >> /dev/null
