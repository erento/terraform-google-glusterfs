#!/bin/bash -x

while [[ -z $(cat /proc/partitions | grep sdb) ]]; do
	echo "waiting for /dev/sdb"
	sleep 1
done

#check for file system and create it if needed
sudo file -sL /dev/disk/by-id/google-gluster | grep XFS || sudo mkfs.xfs -f -i size=512 /dev/disk/by-id/google-gluster
#mount to a dir
sudo mkdir -p /data/brick1 && echo '/dev/disk/by-id/google-gluster /data/brick1 xfs defaults 1 2' | sudo tee -a /etc/fstab && sudo mount -a && mount
#update and install the server
sudo apt-get -y update
sudo apt-get -y install glusterfs-server >>/tmp/start.log

CLUSTER_SIZE="$(seq 0 $(expr ${cluster_size} - 1))"
# run only in the first host
if [[ $HOSTNAME =~ -0$ ]]; then
	# wait for all of the peer to be online
	for peer in $CLUSTER_SIZE; do
		COMMAND="sudo gluster peer probe ${server_prefix}-$peer"
		$COMMAND
		while [ $? -ne 0 ]; do sleep 1 && $COMMAND; done
	done
	# create and start all volume names
	for volume_name in ${volume_names}; do
		if [[ -z $(sudo gluster volume list | grep $volume_name) ]]; then
			sudo gluster volume create $volume_name replica ${replicas_number} $(for peer in $CLUSTER_SIZE; do echo -n "${server_prefix}-$peer:/data/brick1/$volume_name "; done) force
			if [ ! -z "${user}" ]; then
				sudo gluster volume set $volume_name storage.owner-uid `id -u ${user}`
			fi
			if [ ! -z "${group}" ]; then
				sudo gluster volume set $volume_name storage.owner-gid `id -u ${group}`
			fi
			sudo gluster volume start $volume_name
		fi
	done
fi
