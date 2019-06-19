
postgresql backup container
===========================

this container can be added to a postgresql container deployment to perform backups using `pg_dump`.
the dump files will be written to a directory given in the environment variable `BACKUP_DIR`
(default: `/pgbackup`) which can be mounted as a docker volume. if the corresponding environment variables
are defined, it writes the dump file to an s3 compatible object store (e.g. a [minio](https://www.minio.io/) server).

configuration
-------------

the following environment vartiables can be used:

| name | default | description |
|---|---|---|
| PG_HOST | | the DB host |
| PG_PORT | 5432 | the DB port |
| PG_USER | `postgres` | the user |
| PG_PASSWORD | | the password (typically stored as a secret) |
| PG_SCHEMA | | the schema |
| PG_DB | | the database |
| DB_ENV | `prod` | the database environment (used as a tag in the dump file name) |
| BACKUP_DIR | `/pgbackup` | the directory in which the dump file is created |
| S3_PROTOCOL | `https` | protocol used to access minio - http or https |
| S3_HOST | | the s3 host (and port) |
| S3_ACCESS_KEY | | the s3 access key |
| S3_SECRET_KEY | | the s3 secret key |
| S3_BUCKET | `pgbackup` | the s3 bucket |
| S3_SYNC_PROTOCOL | `https` | protocol for sync copy - http or https |
| S3_SYNC_HOST | | the s3 host for sync copy |
| S3_SYNC_ACCESS_KEY | | the s3 access key for sync copy |
| S3_SYNC_SECRET_KEY | | the s3 secret key for sync copy |
| S3_SYNC_BUCKET | `$S3_BUCKET` | the s3 bucket for sync copy |

if necessary, an http proxy can be defined using the environment variables `HTTP_PROXY` and/or `HTTPS_PROXY`.

the dump file is only copied to the S3 bucket if the environment variable `S3_HOST` has a non-empty value. obviously,
in this case also the credentials `S3_ACCESS_KEY` and `S3_SECRET_KEY` must be set. the target bucket must be created
beforehand.

the image can be used to run a container once, in which case a single dump is created. also it can be deployed as a k8s `CronJob`
for recurrent execution, e.g. to create off-site backups of a popstgresql database in regular time intervals.

if a second copy is desired (e.g. for an additional off-site backup), a second S3 store can bve defined using the environment variables
`S3_SYNC_PROTOCOL` (optional), `S3_SYNC_HOST`, `S3_SYNC_ACCESS_KEY`, `S3_SYNC_SECRET_KEY` and `S3_SYNC_BUCKET` (optional).

usage
-----

run e.g. as

```
$ docker run -it --rm -e PG_HOST=<postgresql host> -e PG_PORT=<postgresql port> -e PG_SCHEMA=<schema> -e PG_DB=<database> -e PG_PASSWORD=<postgres password> -e S3_HOST=<s3 host> -e S3_ACCESS_KEY=<s3 access key> -e S3_SECRET_KEY=<s3 secret key> remigius65/pg-dump
```

to restore a backup, you can run it by invoking the script `restore.sh` which takes the full backup timestamp as a parameter. if `sync`is added as a second parameter,
the backup file is taken from the sync copy (i.e. using environment variables `S3_SYNC_*`).
