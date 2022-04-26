#!/bin/bash

printf "

-----------------------------

Set the static addres on network card

-----------------------------
"

count=$(basename -a /sys/class/net/*|cat -b|wc -l)

zero=0
echo ""
echo "Select the network card by choosing the number"
echo ""
basename -a /sys/class/net/*|cat -b

echo ""
echo -e "\n Choose number \n"
while read -r nr
do
	if [ "$nr" -le "$count" ] && [ "$nr" -gt "$zero" ]; then

	echo "Choose number"
	echo ""
	

	nn=$(basename -a /sys/class/net/*|sed -n "$nr"p)
	echo ""
	echo "You select the netowrk card $nn"
	sleep 3
else
	echo "Please select number from 1 to $count"
	continue
fi
break
done




printf "
----------------------------

Dou you want to change the network card address?
It could provide some issues
Do you want to do that right now? [y/N]

----------------------------
"

read -r -p response

if [[ "$response" =~ ^([yY][eE][sS]|[yY]|[tT])$ ]]
then


	

inter=/etc/default/isc-dhcp-server.bak
if [ -f "$inter" ]; then
    echo "$inter exists."
else 
    echo "$inter does not exist. Create Copy"
    sudo cp /etc/network/interfaces /etc/network/interfaces.bak
fi


sudo sed -i -z "s/iface $nn inet dhcp/iface $nn inet static\naddress 192.168.0.2\ngateway 192.168.0.0\nnetmask 255.255.255.0/g" /etc/network/interfaces    


echo ""
echo "Address changed"
echo ""
cat /etc/network/interfaces
echo ""
echo "###########################################################"
echo ""
echo "remember to determine the port for listening "
echo "you can do that editing file:"
echo ""
echo "/etc/default/isc-dhcp-server"
echo ""
echo "Do you want to do that automatically right now? [y/N] "
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
INTERFACESv4=\"$nn\"
INTERFACESv6=\"\"
" |sudo tee /etc/default/isc-dhcp-server >> /dev/null

sudo cat /etc/default/isc-dhcp-server |tail -4

sudo sed -i -e 's|/var/www/html"|/srv/tftp"|g' /etc/lighttpd/lighttpd.conf    
sudo sed -i -e 's/RPCMOUNTDOPTS/#RPCMOUNTDOPTS/g' /etc/default/nfs-kernel-server
sudo sed -i -e '/#RPCMOUNTDOPTS/a RPCMOUNTDOPTS="-p 40000"' /etc/default/nfs-kernel-server
printf "/srv/tftp/iso/debian-net	192.168.0.0/24(ro,no_root_squash,no_subtree_check)
" |sudo tee -a /etc/exports >> /dev/null
sudo exportfs -av

sudo ifdown $nn
echo ""
sleep 5
sudo ifup $nn

   fi

    else
        echo ""
        echo "Remember to set the IP addres and determine the port for listening:"
        echo ""
        echo "/etc/default/isc-dhcp-server"
        echo ""
		
		sudo sed -i -z "s/iface $nn inet static\naddress 192.168.0.2\ngateway 192.168.0.0\nnetmask 255.255.255.0/iface $nn inet dhcp/g" /etc/network/interfaces    
		cat /etc/network/interfaces
		sudo ifdown $nn
	echo ""
	sleep 5
	sudo ifup $nn
	
		
fi

