#!/bin/bash

#chmod og-rwx $RAILS_ROOT/ssl/keys $RAILS_ROOT/ssl/certs
#openssl req -new -x509 -days 365 -nodes -out $RAILS_ROOT/ssl/certs/ca.crt \
#  -keyout $RAILS_ROOT/ssl/keys/ca.key -subj "/CN=root-ca"

mkdir -p keys certs
chmod og-rwx keys certs
openssl req -new -x509 -days 365 -nodes -out certs/ca.crt \
  -keyout keys/ca.key -subj "/CN=root-ca"

mkdir -p pgconf
cp certs/ca.crt pgconf/ca.crt
