#!/bin/bash

#openssl req -new -nodes -out server.csr \
#  -keyout $RAILS_ROOT/ssl/keys/server.key -subj "/CN=$SERVER_HOST"
#openssl x509 -req -in server.csr -days 365 \
#  -CA $RAILS_ROOT/ssl/certs/ca.crt -CAkey $RAILS_ROOT/ssl/keys/ca.key -CAcreateserial \
#  -out $RAILS_ROOT/ssl/certs/server.crt

#sudo rm server.csr

openssl req -new -nodes -out server.csr \
  -keyout pgconf/server.key -subj "/CN=localhost"
openssl x509 -req -in server.csr -days 365 \
  -CA certs/ca.crt -CAkey keys/ca.key -CAcreateserial \
  -out pgconf/server.crt
rm server.csr

chmod og-rwx pgconf/*

cp -r pgconf ../
