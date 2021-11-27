#!/bin/bash

most_recent_backup=$(ssh adzienis@office-hours-01.andrew.cmu.edu "ls /home/adzienis/cmqueue/db_backups" | tail -1)

scp -r adzienis@office-hours-01.andrew.cmu.edu:/home/adzienis/cmqueue/db_backups/$most_recent_backup .

docker-compose -p staging -f docker-compose.staging.yml stop web
docker-compose -p staging -f docker-compose.staging.yml stop worker
PGPASSWORD=postgres psql -h localhost -U postgres -d postgres -c "drop database production;"
PGPASSWORD=postgres psql -h localhost -U postgres -d postgres < $most_recent_backup

# cleanup

rm -rf $most_recent_backup

docker-compose -p staging -f docker-compose.staging.yml up -d web
docker-compose -p staging -f docker-compose.staging.yml  up -d worker

