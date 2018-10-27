#!/bin/sh

export DUMP_FILE="$BACKUP_DIR/$PG_SCHEMA-$DB_ENV-$(date +"%F-%H%M%S").dump"

if [ ! -d "$BACKUP_DIR" ]; then

  echo mkdir -p "$BACKUP_DIR"
  mkdir -p "$BACKUP_DIR"

fi

echo "pg_dump -v -Fc --no-acl --no-owner -h $PG_HOST -p $PG_PORT -n $PG_SCHEMA -U $PG_USER -w $PG_DB > $DUMP_FILE"
pg_dump -v -Fc --no-acl --no-owner -h $PG_HOST -p $PG_PORT -n $PG_SCHEMA -U $PG_USER -w $PG_DB > $DUMP_FILE

if [ -n "S3_HOST" ]; then

  export MC_HOSTS_store="$S3_PROTOCOL://$S3_ACCESS_KEY:$S3_SECRET_KEY@$S3_HOST"
  echo "mc cp $DUMP_FILE store/$S3_BUCKET"
  mc cp $DUMP_FILE store/$S3_BUCKET

fi
