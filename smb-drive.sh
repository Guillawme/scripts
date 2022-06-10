#!/usr/bin/env bash

# Connect or disconnect a SMB network drive

# Mount point
# Set this to a location where your user account has write access
MNT=/mnt/my-smb-drive

# Connection details
USERNAME=
PASSWORD=
DOMAIN=
SERVER=
DIR=

usage () {
	echo "Usage: smb-drive.sh [connect|co|disconnect|dis]"
	exit 1
}

connect () {
	# Make sure mount point exists
	if [[ ! -d $MNT ]]; then
		echo "Creating directory " $MNT "as mount point."
		mkdir -p $MNT
	fi

	# Connect
	sudo mount -t cifs -o username=$USERNAME,password=$PASSWORD,$DOMAIN //$SERVER/$DIR $MNT
}

disconnect () {
	sudo umount $MNT
}

case $1 in
	"connect")
		connect;;
	"co")
		connect;;
	"disconnect")
		disconnect;;
	"dis")
		disconnect;;
	*)
		echo "Wrong argument"
		usage;;
esac

