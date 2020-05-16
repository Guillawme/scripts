#! /usr/bin/env bash

# Set up locations to synchronize (always with a trailing slash, meaning
# synchronize the *contents* of these two directories)
EXTERNAL_DRIVE=/media/usb_disk/data/
LAPTOP=$HOME/data/

# Set up files to exclude from synchronization
EXCLUDE="--exclude-from=$HOME/.config/rsync/exclude_sync"

# Set up options
# I don't use --delete to avoid losing files; I prefer the minor annoyance
# of deleted files that reappear because I forgot to delete them on one
# side of the synchronization
OPTS='--checksum --recursive --links --times --update --one-file-system --human-readable --progress --stats'

# Always bring back new files from the thumb drive first
rsync "$OPTS $EXCLUDE $EXTERNAL_DRIVE $LAPTOP"

# Push new files on the laptop side to the thumb drive
rsync "$OPTS $EXCLUDE $LAPTOP $EXTERNAL_DRIVE"
