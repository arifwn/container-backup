#!/bin/sh
set -e

if [ -z "$TARGET" ]
then
    exec "$@"
else
    if [ -z "$PRIVATE_KEY" ]
    then
        echo "syncing files to $TARGET"
        exec /usr/bin/rsync -e "ssh -o StrictHostKeyChecking=no" -avzh /source/ $TARGET --ignore-errors
        echo "done"
    else
        echo "$PRIVATE_KEY" > /home/.ssh-private-key
        chmod 0600 /home/.ssh-private-key
        echo "using PRIVATE_KEY"

        echo "syncing files to $TARGET"
        exec /usr/bin/rsync -e "ssh -o StrictHostKeyChecking=no -i /home/.ssh-private-key" -avzh /source/ $TARGET --ignore-errors
        echo "done"
    fi
fi
