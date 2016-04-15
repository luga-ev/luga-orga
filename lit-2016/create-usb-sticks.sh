#!/bin/bash

while :; do
  xmessage "Neuen Stick einlegen" &

  echo "Warte auf Entfernen des alten Sticks..."
  while grep sdb1 /proc/partitions; do sleep 0.1; done
  echo "Warte auf neuen Stick..."
  until grep sdb1 /proc/partitions; do sleep 0.1; done

  mount /dev/sdb1 /mnt
  unetbootin method=diskimage imgfile=/home/carina/linuxmint-17.1-cinnamon-64bit-de-20150308.iso in
stalltype=USB targetdrive=/dev/sdb1 autoinstall=yes
  umount /mnt
  sync
done
