#!/bin/bash

export SERVER_HOST=localhost
export RAILS_ROOT=$(realpath ..)

mkdir -p $RAILS_ROOT/ssl/keys
mkdir -p $RAILS_ROOT/ssl/certs

./gen_ca_ssl.sh
./gen_server_ssl.sh
./fix_perms.sh

rm -rf pgconf
