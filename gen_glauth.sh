#!/usr/bin/env bash
set -euo pipefail

# -- CONFIGURATION: adjust names to match your .env keys --
# Map each GLAUTH username to its corresponding env‑var name holding the plain‑text password
declare -A USERS=(
  [redinfraadmin]=BREAKGLASS_PASS
  [svc-ssh]=SSH_LDAP_PASSWORD
  [svc-gitea]=GITEA_LDAP_BIND_PASSWORD
  [svc-hedgedoc]=HEDGEDOC_LDAP_BIND_PASSWORD
  [svc-minio]=MINIO_LDAP_BIND_PASSWORD
  [mubix]=DEFAULT_PASS
)

# -- Load environment variables from .env --
if [[ ! -f .env ]]; then
  echo "Error: .env file not found in $(pwd)" >&2
  exit 1
fi

# Export all variables declared in .env
set -o allexport
# shellcheck disable=SC1091
source .env
set +o allexport

# -- Compute SHA256 hashes --
declare -A HASHES
for user in "${!USERS[@]}"; do
  varname=${USERS[$user]}
  pass=${!varname:-}
  if [[ -z "$pass" ]]; then
    echo "Warning: $varname is empty or undefined" >&2
  fi
  # Compute hash and strip leading "(stdin)= "
  HASHES[$user]=$(printf '%s' "$pass" | openssl dgst -sha256 | sed 's/^.*= //')
done

# -- Write out glauth config.cfg --
CONF_FILE="./configs/glauth/config.cfg"
cat > "$CONF_FILE" <<EOF
#################
# glauth.conf

debug = true
watchconfig = true

[ldap]
  enabled = true
  listen = "0.0.0.0:389"
  tls = true
  tlsCertPath = "/app/certs/glauth.crt"
  tlsKeyPath = "/app/certs/glauth.key"

[ldaps]
  enabled = true
  listen = "0.0.0.0:636"
  cert = "/app/certs/glauth.crt"
  key = "/app/certs/glauth.key"

[tracing]
  enabled = false

[backend]
  datastore = "config"
  baseDN = "${LDAP_BASEDN}"
  anonymousdse = true

[behaviors]
  # Ignore all capabilities restrictions, for instance allowing every user to perform a search
  IgnoreCapabilities = true
  LimitFailedBinds = true
  NumberOfFailedBinds = 3
  PeriodOfFailedBinds = 10
  BlockFailedBindsFor = 60
  PruneSourceTableEvery = 600
  PruneSourcesOlderThan = 600

#################
# The users section contains a hardcoded list of valid users.
#   to create a passSHA256 manually:   echo -n "mysecret" | openssl dgst -sha256

### ADMINISTRATORS (Starting from 1000, GID 501)
[[users]]
  name = "redinfraadmin"
  uidnumber = 1001
  primarygroup = 501
  mail = "redinfraadmin@${TRAEFIK_DOMAIN}"
  passsha256 = "${HASHES[redinfraadmin]}" # from \$${USERS[redinfraadmin]}
  [[users.capabilities]]
    action = "search"
    object = "*"

### SERVICE ACCOUNTS (Starting from 2000, GID 502)
[[users]]
  name = "svc-ssh"
  mail = "svc-ssh@${TRAEFIK_DOMAIN}"
  uidnumber = 2001
  primarygroup = 502
  passsha256 = "${HASHES[svc-ssh]}" # from \$${USERS[svc-ssh]}

[[users]]
  name = "svc-gitea"
  mail = "svc-gitea@${TRAEFIK_DOMAIN}"
  uidnumber = 2002
  primarygroup = 502
  passsha256 = "${HASHES[svc-gitea]}" # from \$${USERS[svc-gitea]}

[[users]]
  name = "svc-hedgedoc"
  mail = "svc-hedgedoc@${TRAEFIK_DOMAIN}"
  uidnumber = 2003
  primarygroup = 502
  passsha256 = "${HASHES[svc-hedgedoc]}" # from \$${USERS[svc-hedgedoc]}

[[users]]
  name = "svc-minio"
  mail = "svc-minio@${TRAEFIK_DOMAIN}"
  uidnumber = 2004
  primarygroup = 502
  passsha256 = "${HASHES[svc-minio]}" # from \$${USERS[svc-minio]}

### USERS (Starting from 5000, GID 503)
[[users]]
  name = "mubix"
  givenname="Rob"
  sn="Fuller"
  mail = "mubix@${TRAEFIK_DOMAIN}"
  uidnumber = 5001
  primarygroup = 503
  loginShell = "/bin/bash"
  homeDir = "/home/mubix"
  passsha256 = "${HASHES[mubix]}" # from \$${USERS[mubix]}
  sshkeys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC7k5Z4b1j8f5m6"
  ]
  
# More info here: https://glauth.github.io/docs/file.html

#################
# The groups section contains a hardcoded list of valid users.
[[groups]]
  name = "admin"
  gidnumber = 501

[[groups]]
  name = "service"
  gidnumber = 502
  [[groups.capabilities]]
    action = "search"
    object = "*"

[[groups]]
  name = "general"
  gidnumber = 503
  
#################
# Enable and configure the optional REST API here.
[api]
  enabled = true
  internals = true # debug application performance
  tls = false # enable TLS for production!!
  listen = "0.0.0.0:5555"
  cert = "cert.pem"
  key = "key.pem"
EOF

echo "Generated $CONF_FILE with updated passsha256 values."
