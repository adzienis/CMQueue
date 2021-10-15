#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE app_production;
    GRANT ALL PRIVILEGES ON DATABASE app_production TO $POSTGRES_USER;
EOSQL

