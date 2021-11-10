#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE app_development;
    CREATE DATABASE app_test;
    CREATE DATABASE production;
    GRANT ALL PRIVILEGES ON DATABASE app_development, app_test, production TO $POSTGRES_USER;
EOSQL

