#!/bin/sh
set -e

if [ -z "$SOURCE_DIR" ]
then
    exec "$@"
else
    exec run-backup.sh
fi
