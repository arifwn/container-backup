#!/bin/sh
set -e

system_name="$SYSTEM_NAME"
bucket_name="$BUCKET_NAME"
mail_recipient=""

b2_account_id="$B2_ACCOUNT_ID"
b2_api_key="$B2_API_KEY"

tar_command="/usr/bin/env tar"
b2_command="/usr/bin/env b2"

tmp_dir="/tmp"

if [ -z "$TMP_DIR" ]
then
    tmp_dir="/tmp"
else
    tmp_dir="$TMP_DIR"
fi


if [ -z "$BUCKET_NAME" ]
then
    echo "BUCKET_NAME not specified"
    exec "$@"
else
    echo "uploading files to $BUCKET_NAME"
    $b2_command authorize_account "$b2_account_id" "$b2_api_key"

    # create tarball of /source
    cd /source
    echo "creating backup tarball $tmp_dir/${system_name}.tar.gz"
    $tar_command --ignore-failed-read -czf $tmp_dir/${system_name}.tar.gz ./

    # upload to b2
    echo "uploading to b2..."
    $b2_command upload-file --noProgress $bucket_name $tmp_dir/${system_name}.tar.gz "${system_name}.tar.gz"

    exitcode=$?
    if [ "$exitcode" != "1" ] && [ "$exitcode" != "0" ]
    then
        rm $tmp_dir/${system_name}.tar.gz
        return
    fi

    if [ $? -eq 0 ]
    then
        if [ -z "$DELETE_SOURCE_AFTER_SUCCESSFUL_UPLOAD" ]
        then
            echo "skip source cleanup"
        else
            echo "deleting /source ..."
            rm -rf /source/*
        fi
    fi

    rm $tmp_dir/${system_name}.tar.gz

    echo "done"
fi
