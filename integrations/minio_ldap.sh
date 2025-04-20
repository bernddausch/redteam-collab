#!/bin/bash

# This script configures MinIO to use LDAP for authentication.

until mc alias set redinfra http://minio:9000 $MINIO_ROOT_USER "$MINIO_ROOT_PASSWORD"; do sleep 2; done

mc idp ldap add redinfra \
 server_addr=glauth:636 \
 tls_skip_verify=on \
 lookup_bind_dn="cn=$MINIO_LDAP_BIND_USER,$LDAP_BASEDN" \
 lookup_bind_password="$MINIO_LDAP_BIND_PASSWORD" \
 user_dn_search_base_dn="ou=users,$LDAP_BASEDN" \
 user_dn_search_filter="(uid=%s)" \
 group_search_base_dn="ou=users,$LDAP_BASEDN" \
 group_search_filter="(&(objectclass=posixGroup)(uniqueMember=%d))"

# --json is used to avoid the `could not open a new TTY: open /dev/tty: no such device or address.` error
mc --json admin service restart redinfra
sleep 5 # Wait for MinIO to restart
mc idp ldap policy attach redinfra consoleAdmin --group "ou=general,ou=users,$LDAP_BASEDN"
