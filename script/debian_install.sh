#!/bin/bash
echo ""
echo ""
echo "Proszę wybrać która wersja systemu ma być pobrana"
echo ""
a1=$(lynx -dump -listonly https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/ |uniq -f 1|grep 'https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-1.*.iso'|sed "s|https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/||g"|cut -c 7-)

a2=$(lynx -dump -listonly https://cdimage.debian.org/cdimage/unofficial/non-free/cd-including-firmware/current/amd64/iso-cd/ |uniq -f 1|grep 'https://cdimage.debian.org/cdimage/unofficial/non-free/cd-including-firmware/current/amd64/iso-cd/firmware-1.*.iso'|sed "s|https://cdimage.debian.org/cdimage/unofficial/non-free/cd-including-firmware/current/amd64/iso-cd/||g"|cut -c 7-)

link1=$(lynx -dump -listonly https://cdimage.debian.org/debian-cd/current/amd64/iso-cd |uniq -f 1|grep 'https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-1.*.iso'|cut -c 7-)
link2=$(lynx -dump -listonly https://cdimage.debian.org/cdimage/unofficial/non-free/cd-including-firmware/current/amd64/iso-cd/  |uniq -f 1|grep 'https://cdimage.debian.org/cdimage/unofficial/non-free/cd-including-firmware/current/amd64/iso-cd/firmware-1.*.iso'|cut -c 7-)


echo -e "\t 1 " $a1 
echo -e "\t 2 " $a2
echo ""
echo "Podaj wartość 1 lub 2"

while read -r deb
do

if [[ "$deb" == "1" ]]
then
wget -O /home/$USER/debian.iso $link1


elif [[ "$deb" == "2" ]]
then
wget -O /home/$USER/debian.iso $link2
else
	echo "proszę podać odpowiednią wartość 1 lub 2"
	continue
fi
break
done



sudo mkdir -p /srv/tftp/debian11
sudo mkdir -p /srv/tftp/iso
sudo mkdir -p /srv/tftp/iso/debian
sudo mount /home/$USER/debian.iso /mnt

echo -e"
-------------------------
kopiowanie plików
-------------------------
"

sudo gcp -rf /mnt/. /srv/tftp/debian11/
sudo umount /mnt
sudo rm /home/$USER/debian.iso



printf "
UI menu.c32

LABEL Debian net
        MENU LABEL ^1. Debian
        KERNEL debian11/install.amd/vmlinuz
        append initrd=debian11/install.amd/initrd.gz
" | sudo tee -a /srv/tftp/pxelinux.cfg/default > /dev/null

printf "
UI menu.c32
#TIMEOUT 50
#PROMPT 1 
LABEL Debian net
        MENU LABEL ^1. Debian
        KERNEL ::debian11/install.amd/vmlinuz
        append initrd=::debian11/install.amd/initrd.gz
	TEXT HELP
		DEBIAN by TFTP
	ENDTEXT

LABEL Debian Http
	MENU LABEL ^2. Debian by HTTPS
        KERNEL http://192.168.0.2/debian11/install.amd/vmlinuz
        append initrd=http://192.168.0.2/debian11/install.amd/initrd.gz
	TEXT HELP
		Debian using HTTP server
	ENDTEXT
"
