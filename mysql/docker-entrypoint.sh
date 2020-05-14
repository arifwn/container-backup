#!/bin/sh
set -e

if [ -z "$DBNAME" ]
then
    exec "$@"
else
    if [ "$DBNAME" == "ALL" ]
    then
        databases=`mysql --host=$HOST --port=$PORT -u$USER -p$PASSWORD -e "SHOW DATABASES;"`
        for db in $databases; do
            if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != "sys" ]] && [[ "$db" != "Database" ]] ; then
                    echo "running mysqldump --max_allowed_packet=1073741824 --host $HOST --port $PORT -u$USER -p$PASSWORD $db > $db.sql"
                    mysqldump --max_allowed_packet=1073741824 --host $HOST --port $PORT -u$USER -p$PASSWORD $db > $db.sql
            fi
        done

    else
        echo "running mysqldump --max_allowed_packet=1073741824 --host $HOST --port $PORT -u$USER -p$PASSWORD $DBNAME > $DBNAME.sql"
        exec mysqldump --max_allowed_packet=1073741824 --host $HOST --port $PORT -u$USER -p$PASSWORD $DBNAME > $DBNAME.sql
        echo "done"
    fi
fi
