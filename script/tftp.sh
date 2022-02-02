#!/bin/bash

filetftp=/etc/default/tftpd-hpa.bak
if [ -f "$filetftp" ]; then
    echo "$filetftp exists."
else 
    echo "$filetftp does not exist. Create Copy"
    sudo cp /etc/default/tftpd-hpa /etc/default/tftpd-hpa.bak
fi

printf "
#/etc/default/tftpd-hpa

TFTP_USERNAME=\"tftp\"
TFTP_DIRECTORY=\"/srv/tftp\"
TFTP_ADDRESS=\"0.0.0.0:69\"
TFTP_OPTIONS=\"--secure\"
" |sudo tee -a /etc/default/tftpd-hpa > /dev/null
