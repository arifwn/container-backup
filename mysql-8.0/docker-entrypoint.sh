#!/bin/bash
set -e

SINGLE_TRANSACTION_OPT=""
if [[ "$USE_SINGLE_TRANSACTION" == "true" || "$USE_SINGLE_TRANSACTION" == "1" || "$USE_SINGLE_TRANSACTION" == "yes" ]]; then
    SINGLE_TRANSACTION_OPT="--single-transaction"
fi

if [ -z "$DBNAME" ]
then
    exec "$@"
else
    if [ "$DBNAME" == "ALL" ]
    then
        databases=`mysql --host=$HOST --port=$PORT -u$USER -p$PASSWORD -e "SHOW DATABASES;"`
        for db in $databases; do
            if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != "sys" ]] && [[ "$db" != "Database" ]] ; then
                    echo "running mysqldump --max_allowed_packet=1073741824 $SINGLE_TRANSACTION_OPT --routines --triggers --events --master-data=2 --host $HOST --port $PORT -u$USER -p$PASSWORD $db > $db.sql"
                    mysqldump --max_allowed_packet=1073741824 $SINGLE_TRANSACTION_OPT --routines --triggers --events --master-data=2 --host $HOST --port $PORT -u$USER -p$PASSWORD $db | gzip -c > $db.sql.gz

                    if [ -z "$SLEEP_DELAY" ]
                    then
                        echo ""
                    else
                        echo "Sleeping for $SLEEP_DELAY seconds"
                        sleep "$SLEEP_DELAY"
                    fi
            fi
        done

    else
        echo "running mysqldump --max_allowed_packet=1073741824 $SINGLE_TRANSACTION_OPT --routines --triggers --events --master-data=2 --host $HOST --port $PORT -u$USER -p$PASSWORD $DBNAME > $DBNAME.sql"
        exec mysqldump --max_allowed_packet=1073741824 $SINGLE_TRANSACTION_OPT --routines --triggers --events --master-data=2 --host $HOST --port $PORT -u$USER -p$PASSWORD $DBNAME | gzip -c > $DBNAME.sql.gz
        echo "done"
    fi
fi
