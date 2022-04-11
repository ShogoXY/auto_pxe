#!/bin/bash

####
#
# script for download live iso of Debian every variant form current debian page
#
####


echo -e "
Proszę wybrać obraz ISO z listy poniżej.
Program automatycznie pobierze obraz,
a następnie automatycznie rozpakuje go do folder /srv/tftp/iso/ 
oraz automatycznie doda pozycję wyboru w PXE Menu dla legacy jak i UEFI.
"



lynx -dump -listonly https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/ |uniq -f 1|grep 'https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/debian-live-11.*.iso'|sed "s|https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/||g"|cut -c 7-|cat -b
count=$(lynx -dump -listonly https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/ |uniq -f 1|grep 'https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/debian-live-11.*.iso'|sed "s|https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/||g"|cut -c 7-|wc -l)

zero=0

echo -e "\n Podaj numer \n"
while read -r iso
do
	if [ "$iso" -le "$count" ] && [ "$iso" -gt "$zero" ]; then

link=$(lynx -dump -listonly https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/ |uniq -f 1|grep 'https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/debian-live-11.*.iso'|cut -c 7-|sed -n "$iso"p)

else
	echo "Podaj cyfrę od 1 do $count"
	continue
fi
break
done



#echo $link
wget $link

 
usun=$(lynx -dump -listonly https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/ |uniq -f 1|grep 'https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/debian-live-11.*.iso'|sed "s|https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/||g"|cut -c 7-|sed -n "$iso"p)

folder=$(echo $usun|rev|cut -c 5-|rev|sed "s|-live-11.2.0-amd64||g")

#echo $folder

sudo mkdir -p /srv/tftp/iso/$folder
sudo umount /mnt
sudo mount $usun /mnt
sudo apt-get install gcp -y
sudo rsync -ah --info=progress2 /mnt/* /srv/tftp/iso/$folder

vm=$(ls /mnt/live/ |grep vmlinuz)
ini=$(ls /mnt/live/ |grep initrd)
#echo $vm
#echo $ini
sudo umount /mnt
printf "/srv/tftp/iso/$folder	192.168.0.0/24(ro,no_root_squash,no_subtree_check)
" |sudo tee -a /etc/exports >> /dev/null
sudo exports -av

echo "plik został rozpakowany do folderu /srv/tftp/iso/$folder"
echo ""
echo "czy chcesz usunąć plik ISO? [y/N]"

read -r -p " " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY]|[tT])$ ]]
then
	sudo rm $usun
else
	echo "plik nie został usunięty"
fi

fol=$(echo "${folder^^}" |sed "s/-/ /g")
#echo $fol


####
#
#add to legacy menu
#
####

echo -e " 
LABEL $folder 
	MENU LABEL ^$fol
	KERNEL iso/$folder/live/$vm
	APPEND initrd=iso/$folder/live/$ini nfsroot=192.168.0.2:/srv/tftp/iso/$folder/ ro netboot=nfs vga=0x317 boot=live ip=dhcp ---
	TEXT HELP
		Live ISO of $fol - using TFTP
	ENDTEXT
" |sudo tee -a /srv/tftp/pxelinux.cfg/default >> /dev/null

####
#
#add to UEFI menu
#
####

echo -e "
LABEL $folder
	MENU LABEL ^$fol
	KERNEL http://192.168.0.2/iso/$folder/live/$vm
	APPEND initrd=http://192.168.0.2/iso/$folder/live/$ini nfsroot=192.168.0.2:/srv/tftp/iso/$folder/ ro netboot=nfs boot=live ip=dhcp ---
	TEXT HELP
		$fol Live ISO using HTTP
	ENDTEXT
" |sudo tee -a /srv/tftp/efi64/pxelinux.cfg/default >> /dev/null
