#!/bin/bash

# encrypted private key
private_key=./private.key.enc

# decrypt the key
openssl enc -in ${private_key} \
    -d -pbkdf2 \
    -pass env:PRIVATE_KEY_PASS > private.key

exec bash -c "nginx -g 'daemon off;'"
