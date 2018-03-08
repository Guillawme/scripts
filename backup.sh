#!/usr/bin/env bash

# Backup script based on rsync.
# Creates incremental snapshots in a manner similar to Apple's Time Machine, but
# with two advantages: it should work on any system where bash and rsync are
# installed, and on a Mac it offers the possibility to backup only a certain
# directory (whereas Time Machine only does full backups).

# Adapted from <https://blog.interlinked.org/tutorials/rsync_time_machine.html>
# and <https://blog.interlinked.org/tutorials/rsync_addendum.yaml.html>


### Configuration: ###

# SRC is the local directory to backup.
# DEST is the external drive where to store backups.
# By default, SRC and DEST are read from command-line arguments.
# EXCLUDE points to a file containing a list of paths to exclude from backups;
# by default this file is `$HOME/.rsync/exclude' (see rsync doc for details).
SRC=$1
DEST=$2
EXCLUDE=$HOME/.rsync/exclude


### Do not edit after this line. ###

# If no SRC and DEST are provided as command-line arguments, display a short
# usage guide.
if [ $# != 2 ]; then
    echo "Usage: ./backup.sh SRC DEST"
    echo "SRC is the source directory to backup."
    echo "DEST is the destination directory where to store backups."
    exit 0
fi

# We cannot backup if the destination directory is not present (typically, this
# directory would be on an external drive, therefore we cannot assume it's
# always present).
if [ ! -d $DEST ]; then
    echo "Destination directory not found."
    echo "Please plug your external drive. :-)"
    exit 0
fi

# Sanity check: if the local directory doesn't exist, we need to tell the user.
if [ ! -d $SRC ]; then
    echo "Local directory not found."
    echo "Please specify an existing directory to backup."
    exit 0
fi

# If the EXCLUDE file doesn't exist, subsequent rsync commands will fail,
# therefore we need to make sure this file exists.
if [ ! -f $EXCLUDE ]; then
    touch $EXCLUDE
fi

# Get current date to name backup folder.
DATE=`date "+%Y-%m-%d_%H-%M-%S"`

# If this script runs on a Mac, we need the -E option to preserve "extended
# attributes" in backups (this option apparently doesn't exist in rsync found on
# other systems).
if [ `uname` = "Darwin" ]; then
    echo "Mac detected. Preserving extended attributes."
    alias rsync="rsync -E"
fi

# Backup: copy SRC to DEST, preserving all file properties (owner, permissions,
# modification time, extended attributes, etc.), and taking advantage of the
# most recent backup (if available) to save disk space.

# If an older backup already exists, we can save disk space with the --link-dest
# option. Otherwise we proceed with the first backup without this option.
if [ -L $DEST/latest ]; then
    rsync --recursive \
          --links \
          --perms \
          --executability \
          --acls \
          --xattrs \
          --owner \
          --group \
          --devices \
          --specials \
          --times \
          --delete \
          --delete-excluded \
          --update \
          --one-file-system \
          --human-readable \
          --progress \
          --stats \
          --log-file=$DEST/$DATE-backup.log \
          --exclude-from=$EXCLUDE \
          --link-dest=$DEST/latest \
          $SRC $DEST/$DATE-backup
    # Update `latest' symlink to point to most recent backup (i.e. the one that
    # rsync just created).
    rm -f $DEST/latest
    ln -s $DEST/$DATE-backup $DEST/latest
else
    rsync --recursive \
          --links \
          --perms \
          --executability \
          --acls \
          --xattrs \
          --owner \
          --group \
          --devices \
          --specials \
          --times \
          --delete \
          --delete-excluded \
          --update \
          --one-file-system \
          --human-readable \
          --progress \
          --stats \
          --log-file=$DEST/$DATE-backup.log \
          --exclude-from=$EXCLUDE \
          $SRC $DEST/$DATE-backup
    # Create `latest' symlink so next backup can detect this first backup and
    # save disk space using it.
    ln -s $DEST/$DATE-backup $DEST/latest
fi

