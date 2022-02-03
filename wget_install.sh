#!/bin/bash
#skrypt dla konfiguracji PXE
exec > >(tee /home/$USER/log.txt)
mkdir -p script
cd script
copy=./script/copy.sh
if [ -f "$copy" ]; then
    echo "$copy exists."
else 
    wget https://raw.githubusercontent.com/ShogoXY/auto_pxe/main/script/copy.sh
fi

debian_install=./script/debian_install.sh
if [ -f "$debian_install" ]; then
    echo "$debian_install exists."
else 
    wget https://raw.githubusercontent.com/ShogoXY/auto_pxe/main/script/debian_install.sh
fi

debian_live=./script/debian_live.sh
if [ -f "$debian_live" ]; then
    echo "$debian_live exists."
else 
    wget https://raw.githubusercontent.com/ShogoXY/auto_pxe/main/script/debian_live.sh
fi

dhcp=./script/dhcp.sh
if [ -f "$dhcp" ]; then
    echo "$dhcp exists."
else 
    wget https://raw.githubusercontent.com/ShogoXY/auto_pxe/main/script/dhcp.sh
fi

isc=./script/isc.sh
if [ -f "$isc" ]; then
    echo "$isc exists."
else 
    wget https://raw.githubusercontent.com/ShogoXY/auto_pxe/main/script/isc.sh
fi

nmcli=./script/nmcli.sh
if [ -f "$nmcli" ]; then
    echo "$nmcli exists."
else 
    wget https://raw.githubusercontent.com/ShogoXY/auto_pxe/main/script/nmcli.sh
fi

tftp=./script/tftp.sh
if [ -f "$tftp" ]; then
    echo "$tftp exists."
else 
    wget https://raw.githubusercontent.com/ShogoXY/auto_pxe/main/script/tftp.sh
fi

cd ..
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

bash ./script/dhcp.sh
bash ./script/tftp.sh
bash ./script/copy.sh
bash ./script/debian_install.sh





echo -e "

Pamiętaj o ustawieniach karty sieciowej
Nalezy ustawić adres:

192.268.0.2
255.255.255.0
192.168.0.0

oraz należy ustalić na jakim porcie ma być nasłuchiwanie"


bash ./script/nmcli.sh
bash ./script/isc.sh



echo ""
echo ""
echo "Czy chcesz pobrać obraz Live Debian " 
echo "i dodać go do serwera PXE? [y/N] "
read -r -p " " response


if [[ "$response" =~ ^([yY][eE][sS]|[yY]|[tT])$ ]]
then
	bash ./script/debian_live.sh
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
