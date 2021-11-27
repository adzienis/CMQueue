#!/bin/bash

db_id=$(docker ps -aqf "name=server_prod")

docker stop $db_id
docker rm $db_id


