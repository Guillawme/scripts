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
	echo "Usage: smb-drive.sh [connect|co|disconnect|dis] [rw]"
	exit 1
}

connect () {
	# Make sure mount point exists
	if [[ ! -d $MNT ]]; then
		echo "Creating directory " $MNT "as mount point."
		mkdir -p $MNT
	fi

	# Connect in read/write mode if the argument to this function is "rw",
	# otherwise connect in read-only mode
	case $1 in
		"rw")
			echo "Connecting in read/write mode. Be careful!"
			sudo mount -t cifs -o uid=$USER,username=$USERNAME,password=$PASSWORD,$DOMAIN //$SERVER/$DIR $MNT;;
		*)
			sudo mount -t cifs -o username=$USERNAME,password=$PASSWORD,$DOMAIN //$SERVER/$DIR $MNT;;
	esac
}

disconnect () {
	sudo umount $MNT
}

# Pass second command line argument to connect
# so it can decide between read-only and read/write modes
case $1 in
	"connect")
		connect $2;;
	"co")
		connect $2;;
	"disconnect")
		disconnect;;
	"dis")
		disconnect;;
	*)
		echo "Wrong argument"
		usage;;
esac

