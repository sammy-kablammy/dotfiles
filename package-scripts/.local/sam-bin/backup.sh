#!/bin/sh

# TODO tar before backing up, this makes backups more portable

# Script to make daily backups. Non-daily intervals will need some modification.

# Currently, if you run multiple backups on the same day, it just keeps the
# latest one. So feel free to run this several times a day in a cronjob in case
# the system is off sometimes.

# For example: when source_dirs is "/foo/bar/whatever /foo/bar/another", you'll
# get this:
#     $backups_dir/01-02-03/foo/bar/whatever/<whatever's contents>
#     $backups_dir/01-02-03/foo/bar/another/<another's contents>
#     $backups_dir/01-02-03/backup.log

# These variables are intended to be overridden.
test -z "$backups_dir" && backups_dir="/home/sam/kablam/.sam_backups/"
test -z "$how_many_days_to_keep" && how_many_days_to_keep=14
# Dirs to be backed up. (do not put spaces in filenames or else the file-space
# continuum may collapse into a black hole and kill everyone ok thank you)
test -z "$source_dirs" && source_dirs="
/home/sam/kablam/notes
"

################################################################################

mkdir --parents "$backups_dir"
cd "$backups_dir"
# rsync's '--link-dest' is relative to rsync's DESTINATION directory, but we
# need an absolute path:
backups_dir_absolute_path=$(pwd)

# Must set this variable before creating today's backup otherwise the 'ls'
# timestamp sorting will be wrong:
yesterday_backup_root=$(ls -t | head -1)

# This variable must be defined in this scope for the later redirection to work:
today_backup_root="$backups_dir/$(date -I)"
mkdir --parents "$today_backup_root"

{
    echo "Backing up '$source_dirs' to '$today_backup_root'..."
    echo "(yesterday_backup_root is '$yesterday_backup_root')"
    echo "----------------------------------------------------------------------"

    # Make today's backup.
    for source_dir in $source_dirs; do
        # rsync knows how to handle '--link-dest' being broken, so this script
        # doesn't need to differentiate between "command to make the first
        # backup" and "command to make subsequent backups"
        mkdir --parents "$today_backup_root$source_dir"
        # (Note that these rsync commands use source_dir/ instead of
        # source_dir as to copy contents and not the dir itself.)
        # Also note that $source_dir already contains a leading slash.
        linkdest="$backups_dir_absolute_path/$yesterday_backup_root$source_dir" 
        rsync -av --delete --link-dest="$linkdest" "$source_dir/" "$today_backup_root$source_dir"
    done

    # Remove outdated backups.
    while [ $(ls | wc -l) -gt "$how_many_days_to_keep" ]; do
        oldest_backup=$(ls -tr | head -1)
        rm -rf "$oldest_backup"
    done

} 1>/tmp/daily_backup_stdout.log 2>/tmp/daily_backup_stderr.log
cat /tmp/daily_backup_stderr.log /tmp/daily_backup_stdout.log > "$today_backup_root/backup.log" 
