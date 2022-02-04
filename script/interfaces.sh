#!/bin/bash

printf "

-----------------------------

Ustawienie adresu statycznego na karcie sieciowej

-----------------------------
"

count=$(basename -a /sys/class/net/*|cat -b|wc -l)

zero=0
echo ""
echo "Proszę wybrać kartę sieciową podając jej numer"
echo ""
basename -a /sys/class/net/*|cat -b

echo ""
echo -e "\n Podaj numer \n"
while read -r nr
do
	if [ "$nr" -le "$count" ] && [ "$nr" -gt "$zero" ]; then

	echo "Podaj numer"
	echo ""
	

	nn=$(basename -a /sys/class/net/*|sed -n "$nr"p)
else
	echo "Podaj cyfrę od 1 do $count"
	continue
fi
break
done




printf "
----------------------------

Czy chcesz zmienić adres karty sieciowej?
Może to powodować błędy
Czy chcesz to zrobić teraz ? [y/N]

----------------------------
"

reaad -r -p response

if [[ "$response" =~ ^([yY][eE][sS]|[yY]|[tT])$ ]]
then


	

inter=/etc/default/isc-dhcp-server.bak
if [ -f "$inter" ]; then
    echo "$inter exists."
else 
    echo "$inter does not exist. Create Copy"
    sudo cp /etc/network/interfaces /etc/network/interfaces.bak
fi


sudo sed -i -e -z "s/iface $nn inet dhcp/iface $nn inet static\naddress 192.168.0.2\ngateway 192.168.0.0\nnetmask 255.255.2550/g" /etc/network/interfaces    


echo ""
echo "adres zmieniony"
echo ""
cat /etc/network/interfaces
echo ""
echo "###########################################################"
echo ""
echo "pamiętaj by ustawić port nasłuchiwania w"
echo ""
echo "/etc/default/isc-dhcp-server"
echo ""
echo "Czy chcesz zrobić to teraz? [y/N] "
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

sudo ifdown $nn
echo ""
sleep 5
sudo ifup $nn

   fi

    else
        echo ""
        echo " Pamiętaj o zmianie adresu IP oraz nasłuchiwaniu w:"
        echo ""
        echo "/etc/default/isc-dhcp-server"
        echo ""
		
		sudo sed -i -e -z "s/iface $nn inet static\naddress 192.168.0.2\ngateway 192.168.0.0\nnetmask 255.255.2550/iface $nn inet dhcp/g" /etc/network/interfaces    
		cat /etc/network/interfaces
		sudo ifdown $nn
	echo ""
	sleep 5
	sudo ifup $nn
	
		
fi

