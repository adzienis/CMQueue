#!/bin/bash

docker run --env-file=.env.prod --network=prod_prod test:latest
