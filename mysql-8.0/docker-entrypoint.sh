#!/bin/bash
set -e

SINGLE_TRANSACTION_OPT=""
if [[ "$USE_SINGLE_TRANSACTION" == "true" || "$USE_SINGLE_TRANSACTION" == "1" || "$USE_SINGLE_TRANSACTION" == "yes" ]]; then
    SINGLE_TRANSACTION_OPT="--single-transaction"
fi

NO_TABLESPACES_OPT="--no-tablespaces"

COLUMN_STATISTICS_OPT=""
if [[ "$NO_COLUMN_STATISTICS" == "true" || "$NO_COLUMN_STATISTICS" == "1" || "$NO_COLUMN_STATISTICS" == "yes" ]]; then
    COLUMN_STATISTICS_OPT="--column-statistics=0"
fi

BINLOG_POSITION_OPT=""
if [[ "$BACKUP_BINLOG_POSITION" == "true" || "$BACKUP_BINLOG_POSITION" == "1" || "$BACKUP_BINLOG_POSITION" == "yes" ]]; then
    if [[ "$USE_SOURCE_DATA" == "true" || "$USE_SOURCE_DATA" == "1" || "$USE_SOURCE_DATA" == "yes" ]]; then
        BINLOG_POSITION_OPT="--source-data=2"
    else
        BINLOG_POSITION_OPT="--master-data=2"
    fi
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
                    echo "running mysqldump --max_allowed_packet=1073741824 $SINGLE_TRANSACTION_OPT $NO_TABLESPACES_OPT $COLUMN_STATISTICS_OPT --routines --triggers --events $BINLOG_POSITION_OPT --host $HOST --port $PORT -u$USER -p$PASSWORD $db > $db.sql"
                    mysqldump --max_allowed_packet=1073741824 $SINGLE_TRANSACTION_OPT $NO_TABLESPACES_OPT $COLUMN_STATISTICS_OPT --routines --triggers --events $BINLOG_POSITION_OPT --host $HOST --port $PORT -u$USER -p$PASSWORD $db | gzip -c > $db.sql.gz

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
        echo "running mysqldump --max_allowed_packet=1073741824 $SINGLE_TRANSACTION_OPT $NO_TABLESPACES_OPT $COLUMN_STATISTICS_OPT --routines --triggers --events $BINLOG_POSITION_OPT --host $HOST --port $PORT -u$USER -p$PASSWORD $DBNAME > $DBNAME.sql"
        exec mysqldump --max_allowed_packet=1073741824 $SINGLE_TRANSACTION_OPT $NO_TABLESPACES_OPT $COLUMN_STATISTICS_OPT --routines --triggers --events $BINLOG_POSITION_OPT --host $HOST --port $PORT -u$USER -p$PASSWORD $DBNAME | gzip -c > $DBNAME.sql.gz
        echo "done"
    fi
fi
