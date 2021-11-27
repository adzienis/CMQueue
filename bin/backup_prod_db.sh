#!/bin/bash

db_id=$(docker ps -aqf "name=pg_prod")

docker exec $db_id pg_dumpall -U production -f backup.sql
docker cp $db_id:/backup.sql $PWD/"backup_$(date +%s)".sql

