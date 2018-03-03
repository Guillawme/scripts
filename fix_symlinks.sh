#! /usr/bin/env bash

# Fix broken symlinks caused by restoration of backups stored on an
# NTFS-formatted external drive. Use with care! Especially, check links before
# attempting to fix them.

BROKEN_SYMLINKS=$1

echo "#! /usr/bin/env bash" > fix_symlinks.sh
awk \
    'BEGIN {FS="."} {print "rm " FILENAME " && ln -s .." $3 " " FILENAME;}' \
    $BROKEN_SYMLINKS \
    >> fix_symlinks.sh

echo "Double check that fix_symlinks.sh will do the correct thing, and run it."

