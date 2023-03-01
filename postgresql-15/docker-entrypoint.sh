#!/bin/bash
set -e

if [ -z "$DBNAME" ]
then
    exec "$@"
else
    export PGPASSFILE=/home/.pgpass
    echo "$HOST:$PORT:*:$USER:$PASSWORD" > /home/.pgpass
    chmod 0600 /home/.pgpass

    if [ "$DBNAME" == "ALL" ]
    then
        databases=`/usr/bin/psql -U $USER -d postgres -h $HOST -p $PORT -q -t -c "SELECT datname from pg_database"`
        for db in $databases; do
            if [[ "$db" != "template1" ]] && [[ "$db" != "template0" ]] ; then
                echo "dumping database $db"
                /usr/bin/pg_dump -U $USER -h $HOST -p $PORT -Fc $db > $db.backup
            fi
        done
        echo "done"
    else
        echo "dumping database $DBNAME"
        /usr/bin/pg_dump -U $USER -h $HOST -p $PORT -Fc $DBNAME > $DBNAME.backup
        echo "done"
    fi
fi
