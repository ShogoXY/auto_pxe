#!/bin/bash

filedhcp=/etc/dhcp/dhcpd.conf.bak
if [ -f "$filedhcp" ]; then
    echo "$filedhcp exists."
else 
    echo "$filedhcp does not exist. Create Copy"
    sudo cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bak
fi


printf "
default-lease-time 600;
max-lease-time 7200;

allow booting;
#option architecture-type code 93 = unsigned integer 16;

# in this example, we serve DHCP requests from 192.168.0.(3 to 253)
# and we have a router at 192.168.0.1
subnet 192.168.0.0 netmask 255.255.255.0 {
  range 192.168.0.3 192.168.0.253;
  option broadcast-address 192.168.0.255;
  option routers 192.168.0.1;             # our router
  option domain-name-servers 192.168.0.1; # our router has DNS functionality
  next-server 192.168.0.2;                # our Server
#  filename \"pxelinux.0\"; # setting a default, might be wrong for \"non defaults\"
}
option architecture code 93 = unsigned integer 16 ;
if option architecture = 00:06 {
  filename \"efi64/syslinux.efi\";
} elsif option architecture = 00:07 {
  filename \"efi64/syslinux.efi\";
} elsif option architecture = 00:09 {
  filename \"efi64/syslinux.efi\";
} else {
  filename \"pxelinux.0\";
}

class \"httpclients\" {
      match if substring (option vendor-class-identifier, 0, 10) = \"HTTPClient\";
      option vendor-class-identifier \"HTTPClient\";
      filename \"efi64/syslinux.efi\";
    }
" |sudo tee /etc/dhcp/dhcpd.conf > /dev/null
              
