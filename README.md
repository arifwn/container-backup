These containers can be use to schedule periodic offsite backup via kubernetes cron job functionality.


Build
-----
`docker build -t arifwn/container-backup:mysql ./mysql/`
`docker build -t arifwn/container-backup:b2 ./backblaze-b2`

Run
---
- Periodically dump a MySQL database into a volume:
    `docker run --rm --tty --interactive --volume "/test/:/dump/" --env HOST=host --env PORT=3306 --env DBNAME=dbname --env USER=root --env PASSWORD=password arifwn/container-backup:mysql`

- Periodically dump ALL MySQL database into a volume:
    `docker run --rm --tty --interactive --volume "/test/:/dump/" --env HOST=host --env PORT=3306 --env DBNAME=ALL --env USER=root --env PASSWORD=password arifwn/container-backup:mysql`

- Periodically archive every top-level folder inside a volume into a separate archive and upload it into a b2 bucket, retaining the last 7 daily backups, the last 8 weekly backups, and the last 12 monthly backups

`docker run --rm --tty --interactive --volume "<target dir>:/source" \
--env SYSTEM_NAME=name \
--env BUCKET_NAME=bucker \
--env B2_ACCOUNT_ID=accountid \
--env B2_API_KEY=key \
--env SOURCE_DIR=/source/ arifwn/container-backup:b2`

