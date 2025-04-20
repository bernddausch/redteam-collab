#!/bin/bash

source .env
mkdir -p ./certs
cd ./certs || exit 1
# Generate a self-signed certificate for Glauth
# Ensure the directory exists
mkdir -p ./glauth
# Change to the glauth directory
cd ./glauth || exit 1
# Generate a self-signed certificate for Glauth
# This command generates a new RSA key and a self-signed certificate valid for 365 days
openssl req -x509 -newkey rsa:4096 -keyout glauth.key -out glauth.crt -days 365 -nodes -subj '/CN=auth.${TRAEFIK_DOMAIN}'