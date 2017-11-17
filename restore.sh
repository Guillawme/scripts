#!/usr/bin/env bash

# Restore script based on rsync.
# Restores from a backup located on a local filesystem (other partition, external
# drive, etc.).

# Adapted from <https://blog.interlinked.org/tutorials/rsync_time_machine.html>
# and <https://blog.interlinked.org/tutorials/rsync_addendum.yaml.html>


### Configuration: ###

# BKP is the backup directory to restore.
# LOC is the local directory where the backup contents will be copied.
# By default, BKP and LOC are read from command-line arguments.
BKP=$1
LOC=$2


### Do not edit after this line. ###

# If no BKP and LOC are provided as command-line arguments, display a short
# usage guide.
if [ $# != 2 ]; then
    echo "Usage: ./restore.sh BKP LOC"
    echo "BKP is the backup directory to restore."
    echo "LOC is the local directory where the backup contents will be copied."
    echo "LOC will be created if it does not already exist."
    exit 0
fi

# We cannot restore if the backup directory is not present (typically, this
# directory would be on an external drive, therefore we cannot assume it's
# always present).
if [ ! -d $BKP ]; then
    echo "Backup directory not found."
    echo "Please plug your external drive. :-)"
    exit 0
fi

# Sanity check: if the local directory doesn't exist, create it and inform the user.
if [ ! -d $LOC ]; then
    echo "Creating local directory" $LOC
    mkdir -p $LOC
fi

# If this script runs on a Mac, we need the -E option to preserve "extended
# attributes" in restored files (this option apparently doesn't exist in rsync
# found on other systems).
if [ `uname` = "Darwin" ]; then
    echo "Mac detected. Preserving extended attributes."
    alias rsync="rsync -E"
fi

# Get current date to name restore log file.
DATE=`date "+%Y-%m-%d_%H-%M-%S"`

# Restore: copy BKP to LOC, preserving all file properties (owner, permissions,
# modification time, extended attributes, etc.).
rsync -azxP \
      --human-readable \
      --log-file=$LOC/$DATE-restore.log \
      --delete \
      $BKP $LOC

