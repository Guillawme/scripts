#!/usr/bin/env bash

# Improved `cp' command based on rsync.
# Makes sure the entire content of a directory, including hidden .files, is
# copied over. DANGER: This version DELETES files on the receiving side that
# don't exist on the sending side. USE WITH EXTREME CAUTION.

### Configuration: ###

# SRC is the directory to copy, with trailing slash to designate its content.
# DEST is the destination directory, no trailings slash.
# By default, SRC and DEST are read from command-line arguments.
SRC=$1
DEST=$2

### Do not edit after this line. ###

# If no SRC and DEST are provided as command-line arguments, display a short
# usage guide.
if [ $# != 2 ]; then
    echo "Usage: rcopy.sh SRC DEST"
    echo "SRC is the source directory to copy, no trailing slash."
    echo "DEST is the destination directory, no trailing slash."
    exit 0
fi

# Sanity check: if the source directory doesn't exist, we need to tell the user.
if [ ! -d $SRC ]; then
    echo "Source directory not found."
    echo "Please specify an existing directory to copy."
    exit 0
fi

# We cannot copy if the destination directory is not present (typically, this
# directory would be on an external drive, therefore we cannot assume it's
# always present).
if [ ! -d $DEST ]; then
    echo "Destination directory not found."
    echo "Please plug your external drive or check you typed the correct path. :-)"
    exit 0
fi

# Copy SRC to DEST, preserving all file properties (owner, permissions,
# modification time, etc.). Symbolic links are copied as links, i.e. the file or
# directory they point to is not copied.
# rsync -auPh is safe to use, so replicate it here.

# Options below, in the order they appear, are equivalent to:
# -a "archive" (which itself means -rlptgoD)
# -u "update" (skip files newer on receiver side)
# -P: --partial --progress
# -h "human-readable"
# More options that are normally safe: --executability to stats
# DANGER: --delete will delete files on the receiver side that don't exist
# anymore on the sender side. Useful to reclaim disk space, but use carefully...

rsync \
    --recursive \
    --links \
    --perms \
    --times \
    --group \
    --owner \
    --devices \
    --specials \
    --update \
    --partial \
    --progress \
    --human-readable \
    --executability \
    --acls \
    --xattrs \
    --one-file-system \
    --stats \
    --delete \
    $SRC $DEST

