#!/bin/bash

docker build -t ghcr.io/adzienis/cmqueue  ..
docker push ghcr.io/adzienis/cmqueue

ssh ${PROD_USERNAME}@${PROD_HOST} << EOF
docker pull ghcr.io/adzienis/cmqueue:latest
docker stop cmqueue
docker rm cmqueue

docker run -p 3000:3000 --add-host=host.docker.internal:host-gateway --env-file=.env --name=cmqueue -d -t ghcr.io/adzienis/cmqueue:latest

EOF

