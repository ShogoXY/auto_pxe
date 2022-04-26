#!/bin/bash

echo ""
echo "Do you want to set static addres automatically"
echo "to address 192.168.0.2"
echo "If you select scrip set the DHCP"


echo "Are you sure? [y/N] "
read -r -p " " response


if [[ "$response" =~ ^([yY][eE][sS]|[yY]|[tT])$ ]]
then
	echo ""
	echo "Please select network card by choosing the number"
	echo ""
	nmcli -t -f DEVICE,NAME c show |cat -b
	echo ""
	echo "Select number"
	echo ""
	read -p "" nr
	nn=$(nmcli -t -f NAME c show  |sed -n "$nr"p)
	dev=$(nmcli -t -f DEVICE c show  |sed -n "$nr"p)
	echo $nn
	
	nmcli connection modify "$nn" ipv4.addresses 192.168.0.2/24
	# set gateway
	nmcli connection modify "$nn" ipv4.gateway 192.168.0.1
	# set DNS
	#nmcli ""connewction" modify" "$nn" ipv4.dns 10.0.0.1
	# set manual for static setting (it's [auto] for DHCP)
	nmcli connection modify "$nn" ipv4.method manual
	# restart the "interface" to reload settings
	nmcli connection down "$nn"; nmcli connection up "$nn"
else
	echo ""
	echo "Please select network card by choosing the number"
	echo "to set setting to DHCP"
	echo ""
	nmcli -t -f NAME c show |cat -b
	echo ""
	echo "Select number"
	echo ""
	read -p "" nr
	nn=$(nmcli -t -f NAME c show  |sed -n "$nr"p)
	echo $nn
	echo ""
	
	
	nmcli connection modify "$nn" ipv4.method auto
	# set gateway
	nmcli connection modify "$nn" ipv4.gateway ""
	
	nmcli connection modify "$nn" ipv4.addresses ""
	
	nmcli connection down "$nn"; nmcli connection up "$nn"
fi

printf "
###########################################################

Remember to determinate the port for listening
by editing the file:
/etc/default/isc-dhcp-server

Do you want to do that automatically right now? [y/N] "
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
printf "/srv/tftp/iso/debian-net	192.168.0.0/24(ro,no_root_squash,no_subtree_check)
" |sudo tee -a /etc/exports >> /dev/null
sudo exportfs -av
else
        echo -e "
        DO not forget set IP address and determinate port for listening:
        
        /etc/default/isc-dhcp-server
        "
fi
