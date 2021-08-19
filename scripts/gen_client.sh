#!/bin/bash

openssl req -new -nodes -out client.csr \
  -keyout keys/client.key -subj "/CN=test"
chmod og-rwx keys/*
openssl x509 -req -in client.csr -days 365 \
    -CA certs/ca.crt -CAkey keys/ca.key -CAcreateserial \
    -out certs/client.crt
rm client.csr
