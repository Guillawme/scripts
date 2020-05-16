#!/usr/bin/env bash

# Backup script based on rsync
# Creates incremental snapshots in a manner similar to Apple's Time Machine and
# stores them on a remote host
# Based on <https://wiki.archlinux.org/index.php/Rsync#Snapshot_backup>

### Configuration: ###

# SRC is the local directory to backup
# DEST is the remote location where to store backups
SRC=/directory/to/backup
LOG_DIR=$SRC/backup_logs
REMOTE_USER=user@remote.host
REMOTE_DIR=/home/user/backups
DEST=$REMOTE_USER:$REMOTE_DIR

# Get current date to name backup folder
DATE=$(date "+%Y-%m-%d_%H-%M-%S")

# EXCLUDE lists patterns of file and path names to exclude from backups
EXCLUDE="--exclude-from=$HOME/.config/rsync/exclude_backup"

# LINK specifies how to link to a previous backup to avoid transfering files
# that are already present on the remote location
LINK="--link-dest=$REMOTE_DIR/latest"

# Options for rsync
# Local options
OPTS='--compress --checksum --chmod=D700,F600 --recursive --links --times --delete --delete-excluded --human-readable --partial --progress --stats'
LOG="--log-file=$LOG_DIR/$DATE.log"
# Remote options
#REMOTE_OPTS="--remote-option=--log-file=$REMOTE_DIR/$DATE.log"

# Prepare log file
touch "$LOG_DIR/$DATE.log"

# Backup
rsync "$OPTS $LINK $EXCLUDE $LOG $SRC/ $DEST/$DATE/"

# Update `latest' symlink to point to most recent backup (i.e. the one that
# rsync just created)
ssh $REMOTE_USER "rm -f $REMOTE_DIR/latest; ln -s $REMOTE_DIR/$DATE $REMOTE_DIR/latest"
