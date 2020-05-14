
Build
-----
`docker build -t arifwn/container-backup:mysql ./mysql/`

Run
---
`docker run --rm --tty --interactive --volume "/test/:/dump/" --env HOST=host --env PORT=3306 --env DBNAME=dbname --env USER=root --env PASSWORD=password arifwn/container-backup:mysql`