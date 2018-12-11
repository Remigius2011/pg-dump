#!/bin/sh

# usage: restore <timestamp>

. /usr/bin/setpwd.sh

echo $PG_HOST:$PG_PORT:$PG_DB:$PG_USER:$PG_PASSWORD > /root/.pgpass && chmod 0600 /root/.pgpass

export DUMP_FILE="$BACKUP_DIR/$PG_SCHEMA-$DB_ENV-$1.dump"

if [ ! -d "$BACKUP_DIR" ]; then

  echo mkdir -p "$BACKUP_DIR"
  mkdir -p "$BACKUP_DIR"

fi

if [ -n "S3_HOST" ]; then

  export MC_HOSTS_store="$S3_PROTOCOL://$S3_ACCESS_KEY:$S3_SECRET_KEY@$S3_HOST"
  echo "mc cp store/$S3_BUCKET/$PG_SCHEMA-$DB_ENV-$1.dump $BACKUP_DIR"
  mc cp store/$S3_BUCKET/$PG_SCHEMA-$DB_ENV-$1.dump $BACKUP_DIR

fi

if [ ! -f "$DUMP_FILE" ]; then

  echo "dump file $DUMP_FILE is not a file"
  exit 1

fi

echo "pg_restore -v -c -w -h $PG_HOST -p $PG_PORT -U $PG_USER -n $PG_SCHEMA -d $PG_DB $DUMP_FILE"
pg_restore -v -c -w -h $PG_HOST -p $PG_PORT -U $PG_USER -n $PG_SCHEMA -d $PG_DB $DUMP_FILE
