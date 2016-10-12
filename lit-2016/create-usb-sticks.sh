#!/bin/bash

while :; do
  xmessage "Neuen Stick einlegen" &

  echo "Warte auf Entfernen des alten Sticks..."
  while grep sdb1 /proc/partitions; do sleep 0.1; done
  echo "Warte auf neuen Stick..."
  until grep sdb1 /proc/partitions; do sleep 0.1; done

  mount /dev/sdb1 /mnt
  unetbootin method=diskimage imgfile=/home/iblech/Downloads/linuxmint-17.3-cinnamon-32bit.iso installtype=USB targetdrive=/dev/sdb1
  umount /mnt
  sync
done
