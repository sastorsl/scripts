#!/bin/bash
# 08.10.2019, Stein Arne Storslett
# Backup file to a backup directory

BACK=back
CURUSER=$(logname 2>/dev/null || whoami)

usage () {
    echo "Will backup any named file to a \"$BACK\" subdirectory"
    echo ""
    echo "usage: backup-file.sh <filename>"
    exit 1
}

setdate () {
    date +%Y%m%d%H%M%S
}

[ $# -ne 1 ] && usage
[ "$1" = "-h" -o "$1" = "--help" ] && usage
FILE=$1

if [ -L "$FILE" ]
then
    echo "File exists but is a symbolic link. Aborting..." >&2
    usage
fi
if [ -e "$FILE" ]
then
    if [ ! -f "$FILE" ]
    then
        echo "File exists but is not a regular file. Aborting..." >&2
        usage
    fi
else
    echo "File does not exist. Aborting..." >&2
    usage
fi

if [[ "$FILE" == *"/"* ]]
then
    echo "Will only work if the file is in the CWD. Please \"cd\" first. Aborting..." >&2
    exit 1
fi

if [ ! -d "$BACK" ]
then
    /bin/mkdir "$BACK"
    EC=$?
    if [ $EC -ne 0 ]
    then
        echo "ERROR $EC creating the \"$BACK\" directory. Aborting..." >&2
        exit 1
    fi
fi

echo "Backup "$FILE" -> $BACK/${FILE}-$(setdate)-${CURUSER:-nouser}"
/bin/cp -p "$FILE" $BACK/${FILE}-$(setdate)-${CURUSER:-nouser}
