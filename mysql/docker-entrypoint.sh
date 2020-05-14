#!/bin/sh
set -e

if [ -z "$DBNAME" ]
then
    exec mysqldump --host $HOST --port $PORT -u$USER -p$PASSWORD $DBNAME > $DBNAME.sql
else
    exec "$@"
fi
