#!/bin/bash
#skrypt dla konfiguracji PXE
exec > >(tee /home/$USER/log.txt)

clear
echo -e "
Skrypt ustawiający server PXE 
Dla BIOS oraz UEFI, Obraz instalacji Debian 11
Przed uruchomieniem należy zmienić ustawienia karty sieciowej na adres statyczny
Nalezy ustawić adres:

192.168.0.2
255.255.255.0
192.168.0.0

oraz należy ustalić na jakim porcie ma być nasłuchiwanie

Instalacja potrzebnych składników
oraz uruchmienie skryptu

Skryp pozwoli również na ustawienie adresu IP
w dalszej cześci programu

Naciśnij dowolny klawisz aby kontynuować ...
lub CTRL-C aby anulować"
read -n 1 -s -r -p  ""


echo -e "
------------------------
za chwilę nastąpi instalacja niezbędnych składników
------------------------
"
for i in `seq 1 9`;
        do
                echo -ne "   $i..." \\r
        	sleep 1
        done    



sudo apt-get update
packages=$(printf "
git
syslinux-common
syslinux-efi
isc-dhcp-server
tftpd-hpa
pxelinux
network-manager
gcp
lighttpd
nfs-kernel-server")


sudo apt-get -y install $packages

bash ./scrip/dhcp.sh
bash ./scrip/tftp.sh
bash ./scrip/copy.sh
bash ./scrip/debian_install.sh





echo -e "

Pamiętaj o ustawieniach karty sieciowej
Nalezy ustawić adres:

192.268.0.2
255.255.255.0
192.168.0.0

oraz należy ustalić na jakim porcie ma być nasłuchiwanie"


bash ./scrip/nmcli.sh
bash ./scrip/isc.sh



echo ""
echo ""
echo "Czy chcesz pobrać obraz Live Debian " 
echo "i dodać go do serwera PXE? [y/N] "
read -r -p " " response


if [[ "$response" =~ ^([yY][eE][sS]|[yY]|[tT])$ ]]
then
	bash ./scrip/debian_live.sh
else
	echo "Dziękuję!"
fi
echo ""
echo "------------------------------------------"
echo ""
read -p "Naciśnij [Enter] aby zakończyć..."
echo ""
echo "------------------------------------------"
sudo systemctl restart isc-dhcp-server.service 



printf "

log skryptu zapisany w /home/$USER/log.txt

by edytować menu można zkożystać z :
/srv/tftp/uefi_menu_edit
oraz
/srv/tftp/bios_menu_edit"
sleep 3
sudo systemctl restart tftpd-hpa.service 

