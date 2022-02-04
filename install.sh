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

clear
echo -e "
------------------------
Za chwilę nastąpi instalacja niezbędnych składników
------------------------
"
printf "
----Niezbędne----	----Dodatkowe----
syslinux-common		lynx
syslinux-efi		network-manager
isc-dhcp-server		rsync
tftpd-hpa		
pxelinux
lighttpd
nfs-kernel-server


"

for i in `seq 1 9`;
        do
                echo -ne "   $i..." \\r
        	sleep 1
        done    




sudo apt-get update
packages=$(printf "

syslinux-common
syslinux-efi
isc-dhcp-server
tftpd-hpa
pxelinux
network-manager
rsync
lighttpd
nfs-kernel-server")


sudo apt-get -y install $packages

echo -e "
------------------------
Ustawienie DHCP
------------------------
"
bash ./script/dhcp.sh
echo -e "
------------------------
Ustawienie TFTP
------------------------
"
bash ./script/tftp.sh
echo -e "
------------------------
Kopiowanie niezbędnych plików
------------------------
"
bash ./script/copy.sh

echo -e "
------------------------
Pobieranie obrazu ISO
------------------------
"
bash ./script/debian_install.sh


echo -e "
------------------------
Pobieranie obrazu live ISO
------------------------
"

echo ""
echo ""
echo "Czy chcesz pobrać obraz Live Debian " 
echo "i dodać go do serwera PXE? [y/N] "


while read -r -p " " debiso
do
if [[ "$debiso" =~ ^([yY][eE][sS]|[yY]|[tT])$ ]]
then
	bash ./script/debian_live.sh
	
	echo "Czy chcesz pobrać inny obraz  [y/N]"
	continue

else

	echo "Dziękuję!"
fi
break
done

echo -e "
------------------------
Ustawienia karty sieciowej
------------------------
"
echo -e "

Pamiętaj o ustawieniach karty sieciowej
Nalezy ustawić adres:

192.268.0.2
255.255.255.0
192.168.0.0

oraz należy ustalić na jakim porcie ma być nasłuchiwanie"


de=$(echo $DESKTOP_SESSION)


if [[ "$de" != "" ]]
then
	bash ./script/nmcli.sh
else
	bash ./script/interfaces.sh
fi


echo ""
echo "------------------------------------------"
echo ""
echo "Naciśnij [Enter] aby zakończyć..."
echo ""
echo "------------------------------------------"
read -p ""
sudo systemctl restart isc-dhcp-server.service 



printf "

log skryptu zapisany w /home/$USER/log.txt

by edytować menu można zkożystać z :
/srv/tftp/uefi_menu_edit
oraz
/srv/tftp/bios_menu_edit
"
sudo systemctl restart lighttpd.service 
sleep 3
sudo systemctl restart tftpd-hpa.service 
