#!/bin/bash

# encrypted private key
private_key=./private.key.enc
 
openssl enc -pbkdf2 -aes-256-cbc -pass env:PRIVATE_KEY_PASS \
  -in private.key -out ${private_key}
