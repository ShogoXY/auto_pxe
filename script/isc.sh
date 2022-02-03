#!/bin/bash

printf "
###########################################################

pamiętaj by ustawić port nasłuchiwania w

/etc/default/isc-dhcp-server

Czy chcesz zrobić to teraz? [y/N] "
read -r -p " " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY]|[tT])$ ]]
then


FILE=/etc/default/isc-dhcp-server.bak
if [ -f "$FILE" ]; then
    echo "$FILE exists."
else 
    echo "$FILE does not exist. Create Copy"
    sudo cp /etc/default/isc-dhcp-server /etc/default/isc-dhcp-server.bak
fi


printf "
# Defaults for isc-dhcp-server (sourced by /etc/init.d/isc-dhcp-server)

# Path to dhcpd's config file (default: /etc/dhcp/dhcpd.conf).
#DHCPDv4_CONF=/etc/dhcp/dhcpd.conf
#DHCPDv6_CONF=/etc/dhcp/dhcpd6.conf

# Path to dhcpd's PID file (default: /var/run/dhcpd.pid).
#DHCPDv4_PID=/var/run/dhcpd.pid
#DHCPDv6_PID=/var/run/dhcpd6.pid

# Additional options to start dhcpd with.
#	Don't use options -cf or -pf here; use DHCPD_CONF/ DHCPD_PID instead
#OPTIONS=\"\"

# On what interfaces should the DHCP server (dhcpd) serve DHCP requests?
#	Separate multiple interfaces with spaces, e.g. \"eth0 eth1\".
INTERFACESv4=\"$dev\"
INTERFACESv6=\"\"
" |sudo tee /etc/default/isc-dhcp-server >> /dev/null

sudo sed -i -e 's|/var/www/html"|/srv/tftp"|g' /etc/lighttpd/lighttpd.conf    
sudo sed -i -e 's/RPCMOUNTDOPTS/#RPCMOUNTDOPTS/g' /etc/default/nfs-kernel-server
sudo sed -i -e '/#RPCMOUNTDOPTS/a RPCMOUNTDOPTS="-p 40000"' /etc/default/nfs-kernel-server
printf "/srv/tftp/iso/debian-net	192.168.0.0/24(ro,no_root_squash,no_subtree_check)" |sudo tee -a /etc/exports >> /dev/null
sudo exports -av
else
        echo -e "
        Pamiętaj o zmianie adresu IP oraz nasłuchiwaniu w:
        
        /etc/default/isc-dhcp-server
        "
fi
