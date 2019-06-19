#!/bin/sh

# usage:
# restore <timestamp>        - restore from primary S3 store
# restore <timestamp> sync   - restore from sync S3 store (mandates additional environment variables)

# set defaults

if [ -z "$BACKUP_DIR" ]; then
  export BACKUP_DIR=/pgbackup
fi
if [ -z "$S3_PROTOCOL" ]; then
  export S3_PROTOCOL=https
fi
if [ -z "$S3_SYNC_PROTOCOL" ]; then
  export S3_SYNC_PROTOCOL=https
fi
if [ -z "$S3_BUCKET" ]; then
  export S3_BUCKET="pgbackup"
fi
if [ -z "$S3_SYNC_BUCKET" ]; then
  export S3_SYNC_BUCKET="$S3_BUCKET"
fi

. /usr/bin/setpwd.sh

export DUMP_FILE="$BACKUP_DIR/$PG_SCHEMA-$DB_ENV-$1.dump"

if [ ! -d "$BACKUP_DIR" ]; then
  echo mkdir -p "$BACKUP_DIR"
  mkdir -p "$BACKUP_DIR"
fi

if [ "$2" = "sync" ]; then
  if [ -n "$S3_SYNC_HOST" ]; then
    export MC_HOST_sync="$S3_SYNC_PROTOCOL://$S3_SYNC_ACCESS_KEY:$S3_SYNC_SECRET_KEY@$S3_SYNC_HOST"
    echo "mc cp sync/$S3_SYNC_BUCKET/$PG_SCHEMA-$DB_ENV-$1.dump $BACKUP_DIR from $S3_SYNC_HOST"
    mc cp sync/$S3_SYNC_BUCKET/$PG_SCHEMA-$DB_ENV-$1.dump $BACKUP_DIR
  fi
else
  if [ -n "$S3_HOST" ]; then
    export MC_HOST_store="$S3_PROTOCOL://$S3_ACCESS_KEY:$S3_SECRET_KEY@$S3_HOST"
    echo "mc cp store/$S3_BUCKET/$PG_SCHEMA-$DB_ENV-$1.dump $BACKUP_DIR from $S3_HOST"
    mc cp store/$S3_BUCKET/$PG_SCHEMA-$DB_ENV-$1.dump $BACKUP_DIR
  fi
fi


if [ ! -f "$DUMP_FILE" ]; then
  echo "dump file $DUMP_FILE is missing - cannot restore database"
  exit 1
fi

echo "pg_restore -v -c -w -h $PG_HOST -p $PG_PORT -U $PG_USER -n $PG_SCHEMA -d $PG_DB $DUMP_FILE"
pg_restore -v -c -w -h $PG_HOST -p $PG_PORT -U $PG_USER -n $PG_SCHEMA -d $PG_DB $DUMP_FILE
