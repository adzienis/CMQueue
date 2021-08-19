#!/bin/bash

certs_root="./scripts"
root="$certs_root/$1"

mkdir -p $root
mkdir -p $root/keys
mkdir -p $root/certs

cp $certs_root/certs/ca.crt $root/certs

openssl req -new -nodes -out client.csr  \
  -keyout $root/keys/client.key -subj "/CN=$1"
openssl x509 -req -in client.csr -days 365 \
    -CA $certs_root/certs/ca.crt -CAkey $certs_root/keys/ca.key -CAcreateserial \
    -out $root/certs/client.crt
rm client.csr

tar --directory=$root -czvf $root/package.tar.gz certs/ca.crt certs/client.crt keys/client.key
