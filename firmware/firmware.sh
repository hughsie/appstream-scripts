#!/usr/bin/bash

if [ ! -d /mnt/downloads ]; then
	echo "Getting firmware..."
	sshfs 558a7dace0b8cdf9750000df@beta-lvfs.rhcloud.com:/var/lib/openshift/558a7dace0b8cdf9750000df/app-root/data /mnt
	should_unmount="true"
fi

# copy files to the signing server
for i in $( ls /mnt/uploads/*.cab ); do
	echo "Attempting to sign file: $i"
	cp --no-preserve=mode,ownership $i /srv/fwsignd/source/
done

# wait for files to be signed
while [ "$(ls -A /srv/fwsignd/source/)" ]; do
	echo "Waiting for fwsignd..."
	sleep 1
done

# move new files back from the signing server
for i in $( ls /srv/fwsignd/destination/*.cab ); do
	echo "Uploading new signed file: $i"
	cp --no-preserve=mode,ownership $i /mnt/downloads
	rm $i
done

# archive new files
for i in $( ls /mnt/uploads/*.cab ); do
	echo "Archiving file: $i"
	mv $i /mnt/archive/
done

echo "Building firmware..."
appstream-builder							\
	--api-version=0.9						\
	--max-threads=1							\
	--log-dir=/mnt/logs						\
	--temp-dir=/tmp/lvfs						\
	--cache-dir=../cache						\
	--packages-dir=/mnt/downloads					\
	--output-dir=/mnt/downloads					\
	--basename=firmware						\
	--uncompressed-icons						\
	--origin=lvfs

echo "Mirroring firmware..."
appstream-util mirror-local-firmware /mnt/downloads/firmware.xml.gz https://beta-lvfs.rhcloud.com/downloads/

echo "Signing metadata..."
cp --no-preserve=mode,ownership /mnt/downloads/firmware.xml.gz /srv/fwsignd/source/

# wait for files to be signed
while [ "$(ls -A /srv/fwsignd/source/)" ]; do
	echo "Waiting for fwsignd..."
	sleep 1
done

# copy new files back from the signing server
echo "Uploading signed firmware"
cp --no-preserve=mode,ownership /srv/fwsignd/destination/firmware.xml.gz.asc /mnt/downloads
rm /srv/fwsignd/destination/firmware.xml.gz.asc

if [ -n ${should_unmount} ]; then
	sudo umount /mnt
fi
