#!/bin/bash
echo ""
echo "Czy chcesz automatycznie nadać adres statyczny"
echo "na adres 192.168.0.2"
echo "jeśli nie, script ustawi DHCP"


echo "Jesteś pewien? [y/N] "
read -r -p " " response


if [[ "$response" =~ ^([yY][eE][sS]|[yY]|[tT])$ ]]
then
	echo ""
	echo "proszę wybrać kartę sieciową podając jej numer"
	echo ""
	nmcli -t -f DEVICE,NAME c show |cat -b
	echo ""
	echo "Podaj numer"
	echo ""
	read -p "" nr
	nn=$(nmcli -t -f NAME c show  |sed -n "$nr"p)
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
	echo "proszę wybrać kartę sieciową podając jej numer"
	echo "by zmienić ustawienia karty na DHCP"
	echo ""
	nmcli -t -f NAME c show |cat -b
	echo ""
	echo "Podaj numer"
	echo ""
	read -p "" nr
	nn=$(nmcli -t -f NAME c show  |sed -n "$nr"p)
	echo $nn
	
	
	nmcli connection modify "$nn" ipv4.method auto
	# set gateway
	nmcli connection modify "$nn" ipv4.gateway ""
	
	nmcli connection modify "$nn" ipv4.addresses ""
	
	nmcli connection down "$nn"; nmcli connection up "$nn"
fi

