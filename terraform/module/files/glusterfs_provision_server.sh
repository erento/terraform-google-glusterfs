#!/bin/bash -x

while [[ -z `cat /proc/partitions | grep sdb` ]]; do echo "waiting for /dev/sdb"; sleep 1; done
echo -e "# static IP
     auto ens4:0
     iface ens4:0 inet static
       address '${static_ip}'
       netmask 255.255.255.0" | sudo tee -a /etc/network/interfaces

sudo ifup ens4:0
sudo file -sL /dev/sdb | grep XFS || sudo mkfs.xfs -f -i size=512 /dev/sdb
sudo mkdir -p /data/brick1 && echo '/dev/sdb /data/brick1 xfs defaults 1 2' | sudo tee -a /etc/fstab && sudo mount -a && mount
yes | sudo apt-get update
yes | sudo apt-get install glusterfs-server >> /tmp/start.log
