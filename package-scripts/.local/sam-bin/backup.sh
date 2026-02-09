#!/bin/sh

HELP_STRING=$(cat <<END
Make backups, primarily invoked via cron.

Usage: $0 [OPTION] --source SOURCE --dest DEST

Options:

--archive (the default)
    Make a simple .tar.gz of SOURCE and put it in DEST.

--incremental
    Make a backup via rsync, which hard links unchanged files from the previous
    backup. Poor man's version control, basically.

Examples:

    I don't touch these files, I just want some kind of backup:
    $0 --archive --source /save/me/please --dest /saved/ya

    I frequently change these files and might want a version from weeks ago, so
    I set a high --max-versions. But now I have lots of versions that take up
    lots of space, so I use --incremental:
    $0 --max-versions 30 --incremental --source /important/project --dest /project_backups

    This folder contains lots of tiny files that suck to transport over the network:
    $0 --archive --source /really/big/files --dest /syncthing/synced_backups

Notes:
- Local backups only; use something like syncthing to get tars over the network.
- Log files go in DEST.
- Backups contain the full filepath of the source so you know they came from
- When in doubt, use --archive (the default).
END
)



# TODO assert dependencies are installed (mainly rsync)

# TODO cycle detection. shouldn't be allowed to make a backup that contains the
# previous BACKUPS_DIR

# TODO incremental and archive should be different functions maybe idk who cares

# TODO we need help text like this from the previous version, but accurate:
# For example: when source_dirs is "/foo/bar/whatever /foo/bar/another", you'll
# get this:
#     $backups_dir/01-02-03/foo/bar/whatever/<whatever's contents>
#     $backups_dir/01-02-03/foo/bar/another/<another's contents>
#     $backups_dir/01-02-03/backup.log

################################# Parse input ##################################

SOURCE=""
BACKUPS_DIR=""
MAX_VERSIONS=3
BACKUP_TYPE="archive"

while [ $# -gt 0 ]; do
    if [ "$1" = "--source" ]; then
        SOURCE="$2"
        shift
        shift
    elif [ "$1" = "--dest" ] || [ "$1" = "--destination" ]; then
        BACKUPS_DIR="$2"
        shift
        shift
    elif [ "$1" = "--max-versions" ]; then
        MAX_VERSIONS="$2"
        shift
        shift
    elif [ "$1" = "--incremental" ]; then
        BACKUP_TYPE='incremental'
        shift
    elif [ "$1" = "--archive" ]; then
        BACKUP_TYPE='archive'
        shift
    elif [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
        echo "$HELP_STRING"
        exit 0
    else
        echo "Unrecognized argument '$1'" >&2
        exit 1
    fi
done

if [ -z "$SOURCE" ]; then
    echo "Argument required: --source" >&2
    exit 1
fi
if [ -z "$BACKUPS_DIR" ]; then
    echo "Argument required: --dest" >&2
    exit 1
fi

# I don't fully remember why these have to be absolute paths. Probably something
# with rsync. Doesn't really matter though, just go along with it.
if [ ! $(echo "$SOURCE" | cut -c 1) = '/' ]; then
    echo "Source must be an absolute path" >&2
    exit 1
fi
if [ ! $(echo "$BACKUPS_DIR" | cut -c 1) = '/' ]; then
    echo "Dest must be an absolute path" >&2
    exit 1
fi

if [ "$MAX_VERSIONS" -le 0 ]; then
    echo "--max-versions must be positive, got '$MAX_VERSIONS'" >&2
    exit 1
fi

########################### Do the actual backing up ###########################

mkdir --parents "$BACKUPS_DIR"
# rsync's '--link-dest' is relative to rsync's DESTINATION directory, but we
# need an absolute path:
cd "$BACKUPS_DIR"
BACKUPS_DIR=$(pwd)

# Must set this variable before creating today's backup otherwise the 'ls'
# timestamp sorting will be wrong:
PREVIOUS_BACKUP_ROOT=$(ls -t | head -1)
# BTW rsync knows how to handle a nonexistant '--link-dest', so this script
# doesn't need to differentiate between "command to make the first backup" and
# "command to make subsequent backups"

# This variable must be defined in this scope for the later redirection to work:
# DATE="$(date -I)" # Can use this for daily backups. Multiple in a day will just keep the latest
DATE="$(date +'%F_%H-%M-%S')"
NEW_BACKUP_ROOT="$BACKUPS_DIR/$DATE"
mkdir --parents "$NEW_BACKUP_ROOT"

{
    echo "It is currently $DATE"
    echo "Backing up '$SOURCE' to '$NEW_BACKUP_ROOT'"
    if [ "$BACKUP_TYPE" = 'incremental' ]; then
        echo "(Previous backup is '$PREVIOUS_BACKUP_ROOT')"
    else
        echo "(This is an ARCHIVE, not incremental backup)"
    fi
    echo "--------------------------------------------------------------------------------"
    echo ""

    # Make latest backup.
    if [ "$BACKUP_TYPE" = 'incremental' ]; then
        mkdir --parents "$NEW_BACKUP_ROOT/$SOURCE"
        # (Note that these rsync commands use SOURCE/ instead of SOURCE as to
        # copy contents and not the dir itself.)
        LINKDEST="$BACKUPS_DIR/$PREVIOUS_BACKUP_ROOT$SOURCE" 
        rsync -av --delete --link-dest="$LINKDEST" "$SOURCE/" "$NEW_BACKUP_ROOT$SOURCE"
    elif [ "$BACKUP_TYPE" = 'archive' ]; then
        mkdir --parents "$NEW_BACKUP_ROOT"
        # Using _%_ because having slashes in filenames is nuts
        PERCENTIFIED=$(echo $SOURCE | sed 's/\//_%_/g')
        ARCHIVE_NAME="$PERCENTIFIED.tar.gz"
        echo "Using '$SOURCE' to create archive '$ARCHIVE_NAME' in '$NEW_BACKUP_ROOT'"
        tar --absolute-names -czf "$NEW_BACKUP_ROOT/$ARCHIVE_NAME" "$SOURCE"
    else
        echo "Unrecognized backup type '$BACKUP_TYPE'" >&2
        exit 1
    fi

    # Remove outdated backups.
    while [ $(ls | wc -l) -gt $MAX_VERSIONS ]; do
        OLDEST_BACKUP=$(ls -tr | head -1)
        rm -rf "$OLDEST_BACKUP"
    done

} 1>/tmp/daily_backup_stdout.log 2>/tmp/daily_backup_stderr.log
cat /tmp/daily_backup_stderr.log /tmp/daily_backup_stdout.log > "$NEW_BACKUP_ROOT/backup.log" 
