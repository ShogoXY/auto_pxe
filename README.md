# Automatic PXE server for Debian 11



Bash scrip what create PXE server on Debian 11  
It create full server for Legacy and UEFI

What it can do:
* auto set the static IP (you can back to DHCP with one of the scrip `nmcli.sh`)
* auto install dependency
* download Debian netboot for PXE and copy nesessey file
* set dhcp server
* set tftp server
* set isc-dhcp-server
* set lighttp
* download live Debian iso and copy nesessery file
* put it all together in PXE menu


# Install
Scrip was tested on Debian 11  
by using git
```
git clone https://github.com/ShogoXY/auto_pxe
cd auto_pxe
chmod +x install.sh
./install.sh 
```
or without git just using wget

```
wget https://raw.githubusercontent.com/ShogoXY/auto_pxe/main/wget_install.sh
chmod +x wget_install.sh
./wget_install.sh
```

>This script is in Polish language  
>English version in progress
