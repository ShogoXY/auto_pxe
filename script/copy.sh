#!/bin/bash


sudo mkdir -p /srv/tftp/pxelinux.cfg
sudo mkdir -p /srv/tftp/efi64
sudo mkdir -p /srv/tftp/efi64/pxelinux.cfg

sudo rsync -ah --info=progress2 /usr/lib/PXELINUX/pxelinux.0 /srv/tftp
sudo rsync -ah --info=progress2 /usr/lib/syslinux/modules/bios/ldlinux.c32 /srv/tftp
sudo rsync -ah --info=progress2 /usr/lib/syslinux/modules/bios/libutil.c32 /srv/tftp
sudo rsync -ah --info=progress2 /usr/lib/syslinux/modules/bios/menu.c32 /srv/tftp


sudo rsync -ah --info=progress2 /usr/lib/SYSLINUX.EFI/efi64/syslinux.efi /srv/tftp/efi64
sudo rsync -ah --info=progress2 /usr/lib/syslinux/modules/efi64/ldlinux.e64 /srv/tftp/efi64
sudo rsync -ah --info=progress2 /usr/lib/syslinux/modules/efi64/libutil.c32 /srv/tftp/efi64
sudo rsync -ah --info=progress2 /usr/lib/syslinux/modules/efi64/menu.c32 /srv/tftp/efi64
sudo rsync -ah --info=progress2 /usr/lib/syslinux/modules/efi64/libcom32.c32 /srv/tftp/efi64
