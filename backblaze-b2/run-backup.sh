#!/usr/bin/env bash

system_name="$SYSTEM_NAME"
bucket_name="$BUCKET_NAME"
mail_recipient=""

b2_account_id="$B2_ACCOUNT_ID"
b2_api_key="$B2_API_KEY"

last_dir=`pwd`
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source_dir="$SOURCE_DIR"
backup_dir=/tmp/


tar_command="/usr/bin/env tar"
b2_command="/usr/bin/env b2"
python_command="/usr/bin/env python"
mail_command="/usr/bin/env mail"
delete_filter_script='trim-backup-filter.py'


delete_filter_script_path="${script_dir}/${delete_filter_script}"


notify_admins () {
    recipients="$1"
    subject="$2"
    body="$3"
    echo "---"
    echo "$subject"
    echo "$body"
    echo '---'
    # echo "$body" | mail -s "$subject" "$recipients"
}

backup_to_b2() {
    bucket="$1"
    source_path="$2"
    dest_path="$3"

    echo "$b2_command upload-file --noProgress $bucket $source_path $dest_path"
    $b2_command upload-file --noProgress $bucket "$source_path" "$dest_path"

    exitcode=$?
    if [ "$exitcode" != "1" ] && [ "$exitcode" != "0" ]
    then
        sleep 5
        $b2_command upload-file --noProgress $bucket "$source_path" "$dest_path"
    else
        return
    fi

    exitcode=$?
    if [ "$exitcode" != "1" ] && [ "$exitcode" != "0" ]
    then
        sleep 5
        $b2_command upload-file --noProgress $bucket "$source_path" "$dest_path"
    else
        return
    fi

    exitcode=$?
    if [ "$exitcode" != "1" ] && [ "$exitcode" != "0" ]
    then
        return 1
    fi

    return
}


echo "backup started started: `date`"

$b2_command authorize_account "$b2_account_id" "$b2_api_key"


# create tarballs of all directories under source_dir
for target in $source_dir*/ ; do
    echo "creating tarball of directory $target"

    cd $target
    basename=${PWD##*/}

    cd $source_dir
    $tar_command --ignore-failed-read -czf ${backup_dir}/${basename}.tar.gz $basename

    exitcode=$?
    if [ "$exitcode" != "1" ] && [ "$exitcode" != "0" ]
    then
        echo "- Could not create file: ${basename}.tar.gz" >&2
        notify_admins "$mail_recipient" "[$system_name] Could not create file: ${basename}.tar.gz" "Could not create file: ${basename}.tar.gz"
        exit 1
    else
        backup_to_b2 $bucket_name "${backup_dir}/${basename}.tar.gz" "`date +\%Y-\%m-\%d`/${basename}.tar.gz"
    fi

    exitcode=$?
    if [ "$exitcode" != "1" ] && [ "$exitcode" != "0" ]
    then
        echo "- Could not upload file" >&2
        notify_admins "$mail_recipient" "[$system_name] Could not upload file: ${backup_dir}/${basename}.tar.gz" "Could not upload file: ${backup_dir}/${basename}.tar.gz"
    else
        uploads_counter=$((uploads_counter + 1))
    fi

    rm "${backup_dir}/${basename}.tar.gz"

    tarballs_counter=$((tarballs_counter + 1))
    echo "+ ${basename}.tar.gz created"
done

# identify old backups that need to be purged

list_of_backups=`/bin/mktemp`
list_of_backups_to_delete=`/bin/mktemp`

# list all backups (in json format): 
echo "+retrieving backup list..."
$b2_command list-file-names $bucket_name "" 4000 > $list_of_backups

if [ $? -eq 0 ]
then
    echo "+ backup list retrieved: $list_of_backups"
else
    echo "- Could not retrieve backup list" >&2
    notify_admins "$mail_recipient" "[$system_name] Could not retrieve backup list" "Could not retrieve backup list"
    exit 1
fi

# pass it to external python script to determine which backup to delete
# returns a list of file id
$python_command $delete_filter_script_path $list_of_backups > $list_of_backups_to_delete

if [ $? -eq 0 ]
then
    echo "+ backup list processed: $list_of_backups_to_delete"
else
    echo "- Could not process backup list" >&2
    notify_admins "$mail_recipient" "[$system_name] Could not process backup list" "Could not process backup list"
    exit 1
fi


#delete the backups
deletes_counter=0
while read target_backup; do
    echo $target_backup
    echo "$b2_command delete-file-version $target_backup"
    $b2_command delete-file-version $target_backup

    if [ $? -eq 0 ]
    then
        deletes_counter=$((deletes_counter + 1))
        echo "+ deleted: $target_backup"
    else
        echo "- Could not delete $target_backup" >&2
        notify_admins "$mail_recipient" "[$system_name] Could not delete $target_backup" "Could not delete $target_backup"
        exit 1
    fi

done <$list_of_backups_to_delete


echo "${tarballs_counter} tarballs created, ${uploads_counter} tarballs uploaded, ${deletes_counter} old backups deleted"

# sanity check:
# if no tarball created, raise alert
if [ "$tarballs_counter" -eq "0" ]; then
    echo "- no tarball created! sending alert!"
    notify_admins "$mail_recipient" "[$system_name] No tarball created. Possible backup issue!" "No tarball created. Possible backup issue!"
    exit 1
fi

# if no file uploaded, raise alert
if [ "$uploads_counter" -eq "0" ]; then
    echo "- no tarball uploaded! sending alert!"
    notify_admins "$mail_recipient" "[$system_name] No tarball uploaded. Possible backup issue!" "No tarball uploaded. Possible backup issue!"
    exit 1
fi

# if uploaded counter is lower than tarball counter
if [ "$uploads_counter" -lt "$tarballs_counter" ]; then
    echo "- not all tarballs are uploaded!"
    notify_admins "$mail_recipient" "[$system_name] Not all tarballs are uploaded. Possible backup issue!" "Not all tarballs are uploaded. Possible backup issue!"
    exit 1
fi

# if too many old backups deleted, raise alert
ceiling=$((tarballs_counter * 2))
if [ "$deletes_counter" -gt "$ceiling" ]; then
    echo "- too many old backups deleted!"
    notify_admins "$mail_recipient" "[$system_name] Possible backup issue!" "The number of deleted old backups seems to be larger than usual. Possible backup issue!"
    exit 1
fi

echo "sanity check passed. backup completed at `date`"
