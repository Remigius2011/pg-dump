#!/bin/sh

echo $PG_HOST:$PG_PORT:$PG_DB:$PG_USER:$PG_PASSWORD > /root/.pgpass
chmod 0600 /root/.pgpass
