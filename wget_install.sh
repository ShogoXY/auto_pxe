#!/bin/bash
#skrypt dla konfiguracji PXE
exec > >(tee /home/$USER/log.txt)
mkdir -p script
cd script
copy=./copy.sh
if [ -f "$copy" ]; then
    echo "$copy exists."
else 
    wget https://raw.githubusercontent.com/ShogoXY/auto_pxe/main/script/copy.sh
fi

debian_install=./debian_install.sh
if [ -f "$debian_install" ]; then
    echo "$debian_install exists."
else 
    wget https://raw.githubusercontent.com/ShogoXY/auto_pxe/main/script/debian_install.sh
fi

debian_live=./debian_live.sh
if [ -f "$debian_live" ]; then
    echo "$debian_live exists."
else 
    wget https://raw.githubusercontent.com/ShogoXY/auto_pxe/main/script/debian_live.sh
fi

dhcp=./dhcp.sh
if [ -f "$dhcp" ]; then
    echo "$dhcp exists."
else 
    wget https://raw.githubusercontent.com/ShogoXY/auto_pxe/main/script/dhcp.sh
fi

isc=./isc.sh
if [ -f "$isc" ]; then
    echo "$isc exists."
else 
    wget https://raw.githubusercontent.com/ShogoXY/auto_pxe/main/script/isc.sh
fi

nmcli=./nmcli.sh
if [ -f "$nmcli" ]; then
    echo "$nmcli exists."
else 
    wget https://raw.githubusercontent.com/ShogoXY/auto_pxe/main/script/nmcli.sh
fi

tftp=./tftp.sh
if [ -f "$tftp" ]; then
    echo "$tftp exists."
else 
    wget https://raw.githubusercontent.com/ShogoXY/auto_pxe/main/script/tftp.sh
fi

cd ..
clear
echo -e "
PXE server setup script for Legacy and UEFI, 
It set default Debian 11 netinstall image

Before starting, change the network adapter settings to a static address
You need to set the address:

192.168.0.2
255.255.255.0
192.168.0.0

and you need to determine on which port you want to listen


Installing the necessary components
and running the script

The script will also allow you to set the IP address
later in the program

Press any key to continue ...
or CTRL-C to cancel"
read -n 1 -s -r -p  ""

clear
echo -e "
------------------------
Installing req. in a moment...
------------------------
"
printf "
----Requirment----	----Extra----
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
lynx
nfs-kernel-server")


sudo apt-get -y install $packages

echo -e "
------------------------
DHCP Setting script
------------------------
"
bash ./script/dhcp.sh
echo -e "
------------------------
TFTP Setting script
------------------------
"
bash ./script/tftp.sh
echo -e "
------------------------
Copying necassary files
------------------------
"
bash ./script/copy.sh

echo -e "
------------------------
Downloading ISO
------------------------
"
bash ./script/debian_install.sh


echo -e "
------------------------
Downloading live ISO
------------------------
"

echo ""
echo ""
echo "Do you want to download Debian Live ISO " 
echo "and add it to PXE server? [y/N] "


while read -r -p " " debiso
do
if [[ "$debiso" =~ ^([yY][eE][sS]|[yY]|[tT])$ ]]
then
	bash ./script/debian_live.sh
	
	echo "Do you want to download other ISO?  [y/N]"
	continue

else

	echo "Thank you!"
fi
break
done

echo -e "
------------------------
Network Card Settings
------------------------
"
echo -e "
Remember your network settings
Address must be set:
192.268.0.2
255.255.255.0
192.168.0.0
and you need to determine on which port you want to listen"


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
echo "Press [Enter] to quit..."
echo ""
echo "------------------------------------------"
read -p ""
sudo systemctl restart isc-dhcp-server.service 



printf "
script log saved in /home/$USER/log.txt
To edit PXE menu you can use links below:
for UEFI:
/srv/tftp/uefi_menu_edit
and 
for LEGACY
/srv/tftp/bios_menu_edit
"
sudo systemctl restart lighttpd.service 
sleep 3
sudo systemctl restart tftpd-hpa.service 
