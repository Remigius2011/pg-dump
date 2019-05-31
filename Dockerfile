
# uses the following environment variables (see also backup.sh):
# PG_HOST the DB host
# PG_PORT the DB port
# PG_USER the user
# PG_PASSWORD the password (typically stored as a secret)
# PG_SCHEMA the schema
# PG_DB the database
# DB_ENV the database environment (used as a tag in the dump file name)
# BACKUP_DIR the directory in which the dump file is created
# S3_PROTOCOL protocol used to acces minio - http or https
# S3_HOST the s3 host (and port)
# S3_ACCESS_KEY the s3 access key
# S3_SECRET_KEY the s3 secret key
# S3_BUCKET the s3 bucket

FROM postgres:11-alpine

# defaults for some environment variables

ENV PG_PORT 5432
ENV PG_USER postgres
ENV BACKUP_DIR /pgbackup
ENV DB_ENV prod
ENV S3_PROTOCOL https
ENV S3_BUCKET pgbackup

COPY backup.sh /usr/bin/backup.sh
COPY restore.sh /usr/bin/restore.sh
COPY setpwd.sh /usr/bin/setpwd.sh

RUN chmod +x /usr/bin/backup.sh && chmod +x /usr/bin/restore.sh && chmod +x /usr/bin/setpwd.sh

# add coreutils for date -d options
# add mc (minio client)
# see also https://github.com/minio/mc/blob/master/Dockerfile.release

RUN \
    apk add --no-cache coreutils && \
    apk add --no-cache ca-certificates && \
    apk add --no-cache --virtual .build-deps curl && \
    curl https://dl.minio.io/client/mc/release/linux-amd64/mc > /usr/bin/mc && \
    chmod +x /usr/bin/mc && apk del .build-deps

CMD ["/bin/sh", "-c" , ". /usr/bin/backup.sh" ]
