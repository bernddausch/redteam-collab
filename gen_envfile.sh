#!/bin/bash

# Generate a random alphanumeric string of specified length
generate_secret() {
  < /dev/urandom tr -dc 'A-Za-z0-9' | head -c "$1"
}

# Output .env contents
cat <<EOF > .env
# Main configuration
TRAEFIK_PORT=9443
TRAEFIK_DOMAIN=red.local

# GlAuth configuration
LDAP_BASEDN=dc=red,dc=local
LDAP_ORG=redinfra
BREAKGLASS_USER=redinfraadmin
BREAKGLASS_PASS=$(generate_secret 32)
DEFAULT_USER=mubix
DEFAULT_PASS=$(generate_secret 32)

# SSH configuration
SSH_LDAP_USER=svc-ssh
SSH_LDAP_PASSWORD=$(generate_secret 32)

# Gitea configuration
GITEA_DB_USER=gitea
GITEA_DB_PASS=$(generate_secret 32)
GITEA_DB_VERSION=14
GITEA_LDAP_BIND_USER=svc-gitea
GITEA_LDAP_BIND_PASSWORD=$(generate_secret 32)

# Hedgedoc configuration
HEDGEDOC_DB_PASS=$(generate_secret 32)
HEDGEDOC_DB_VERSION=14
HEDGEDOC_SESSION_SECRET=$(generate_secret 64)
HEDGEDOC_LDAP_BIND_USER=svc-hedgedoc
HEDGEDOC_LDAP_BIND_PASSWORD=$(generate_secret 32)

# Minio 
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=$(generate_secret 32)
MINIO_LDAP_BIND_USER=svc-minio
MINIO_LDAP_BIND_PASSWORD=$(generate_secret 32)

# OnlyOffice configuration
ONLYOFFICE_JWT_SECRET=$(generate_secret 48)
EOF

echo ".env file generated with secure random values."
