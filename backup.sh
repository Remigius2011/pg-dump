#!/bin/sh

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

export DUMP_FILE="$BACKUP_DIR/$PG_SCHEMA-$DB_ENV-$(date +"%F-%H%M%S").dump"

if [ ! -d "$BACKUP_DIR" ]; then
  echo mkdir -p "$BACKUP_DIR"
  mkdir -p "$BACKUP_DIR"
fi

echo "pg_dump -v -w -Fc -h $PG_HOST -p $PG_PORT -n $PG_SCHEMA -U $PG_USER $PG_DB -f $DUMP_FILE"
pg_dump -v -w -Fc -h $PG_HOST -p $PG_PORT -n $PG_SCHEMA -U $PG_USER $PG_DB -f $DUMP_FILE

if [ -n "$S3_HOST" ]; then

  export MC_HOST_store="$S3_PROTOCOL://$S3_ACCESS_KEY:$S3_SECRET_KEY@$S3_HOST"
  echo "mc cp $DUMP_FILE store/$S3_BUCKET on $S3_HOST"
  mc cp $DUMP_FILE store/$S3_BUCKET

  if [ -n "$BACKLOG" ]; then
    BACKLOG_FILE="$PG_SCHEMA-$DB_ENV-$(date --date="-$BACKLOG day" +"%F-%H%M%S").dump"
    echo "deleting files before $BACKLOG_FILE"

    for FILE in $(mc ls store/$S3_BUCKET | grep "$PG_SCHEMA-$DB_ENV-" | cut -d' ' -f7-); do 
      if [ "$FILE" \< "$BACKLOG_FILE" ]; then
        echo "delete file $FILE"
        mc rm "store/$S3_BUCKET/$FILE"
      fi
    done
  fi
fi

if [ -n "$S3_SYNC_HOST" ]; then

  export MC_HOST_sync="$S3_SYNC_PROTOCOL://$S3_SYNC_ACCESS_KEY:$S3_SYNC_SECRET_KEY@$S3_SYNC_HOST"
  echo "mc cp $DUMP_FILE sync/$S3_SYNC_BUCKET on $S3_SYNC_HOST"
  mc cp $DUMP_FILE sync/$S3_SYNC_BUCKET

  if [ -n "$BACKLOG" ]; then
    BACKLOG_FILE="$PG_SCHEMA-$DB_ENV-$(date --date="-$BACKLOG day" +"%F-%H%M%S").dump"
    echo "deleting files before $BACKLOG_FILE"

    for FILE in $(mc ls sync/$S3_SYNC_BUCKET | grep "$PG_SCHEMA-$DB_ENV-" | cut -d' ' -f7-); do 
      if [ "$FILE" \< "$BACKLOG_FILE" ]; then
        echo "delete file $FILE"
        mc rm "sync/$S3_SYNC_BUCKET/$FILE"
      fi
    done
  fi
fi
