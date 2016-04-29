#!/bin/bash
# Vorab:
# 1. apt-get install nfs-kernel-server isc-dhcp-server tftpd-hpa
# 2. TFTP_DIRECTORY="/moredata/linux-boot-server/tftp" in /etc/default/tftpd-hpa
# 3. in /etc/exports je eine Zeile pro Distribution: /moredata/linux-boot-server/nfs/..... *(ro,async,no_root_squash,no_subtree_check)
# 4. dhcpd.conf auf 172.16.0.1 einrichten
# 5. nach iso/ herunterladen: http://de.archive.ubuntu.com/ubuntu/dists/wily/main/installer-i386/current/images/netboot/netboot.tar.gz
# 6. außerdem Images nach Wunsch

set -e

ROOT=/moredata/linux-boot-server
cd $ROOT

mkdir -p nfs/mint-17.3-32bit
mkdir -p nfs/mint-17.3-64bit
mkdir -p nfs/lubuntu-15.10-32bit
mkdir -p nfs/lubuntu-15.10-64bit

[ -e nfs/mint-17.3-32bit/MD5SUMS ] || mount -o loop ./iso/linuxmint-17.3-cinnamon-32bit.iso nfs/mint-17.3-32bit
[ -e nfs/mint-17.3-64bit/MD5SUMS ] || mount -o loop ./iso/linuxmint-17.3-cinnamon-64bit.iso nfs/mint-17.3-64bit
[ -e nfs/lubuntu-15.10-32bit/md5sum.txt ] || mount -o loop ./iso/lubuntu-15.10-desktop-i386.iso nfs/lubuntu-15.10-32bit
[ -e nfs/lubuntu-15.10-64bit/md5sum.txt ] || mount -o loop ./iso/lubuntu-15.10-desktop-i386.iso nfs/lubuntu-15.10-64bit

for i in mint-17.3-32bit mint-17.3-64bit lubuntu-15.10-32bit lubuntu-15.10-64bit; do
    mkdir -p tftp/$i
    cp nfs/$i/casper/initrd.lz tftp/$i/
    cp nfs/$i/casper/vmlinuz tftp/$i/
done

tar -C tftp -xvzf iso/netboot.tar.gz

cat >> tftp/pxelinux.cfg/default <<EOF
label mint-17.3-32bit
   kernel mint-17.3-32bit/vmlinuz
   append boot=casper initrd=mint-17.3-32bit/initrd.lz ip=dhcp showmounts file=/cdrom/preseed/linuxmint.seed netboot=nfs nfsroot=172.16.0.1:$ROOT/nfs/mint-17.3-32bit --

label mint-17.3-64bit
   kernel mint-17.3-64bit/vmlinuz
   append boot=casper initrd=mint-17.3-64bit/initrd.lz ip=dhcp showmounts file=/cdrom/preseed/linuxmint.seed netboot=nfs nfsroot=172.16.0.1:$ROOT/nfs/mint-17.3-64bit --

label lubuntu-15.10-32bit
   kernel lubuntu-15.10-32bit/vmlinuz
   append boot=casper initrd=lubuntu-15.10-32bit/initrd.lz ip=dhcp showmounts file=/cdrom/preseed/lubuntu.seed netboot=nfs nfsroot=172.16.0.1:$ROOT/nfs/lubuntu-15.10-32bit --

label lubuntu-15.10-64bit
   kernel lubuntu-15.10-64bit/vmlinuz
   append boot=casper initrd=lubuntu-15.10-64bit/initrd.lz ip=dhcp showmounts file=/cdrom/preseed/lubuntu.seed netboot=nfs nfsroot=172.16.0.1:$ROOT/nfs/lubuntu-15.10-64bit --
EOF
