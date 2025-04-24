# Red Team Collaboration Infrastructure

This bundle contains Docker Compose files for several self-hosted services, along with a pre-generated `.env` file containing randomized secure secrets.

## 📦 Included Services

- Excalidraw (Diagramming)
- Gitea (Self-hosted Git service)
- Vaultwarden (Bitwarden-compatible password manager)
- HedgeDoc (Collaborative markdown notes)
- GlAuth (SSO/Identity provider)
- CyberChef (Cyber security tool)
- OnlyOffice Document Server (Online document editing)

---

## 🛠️ Usage
(need to update this)

### 1. Setup

Make sure Docker is installed.

Start each of the services like this:

```bash
# Generate the ENV file with randomized values:
./gen_envfile.sh
# Generate Glauth Config (YOU SHOULD EDIT YOUR .ENV FIRST)
./gen_glauth.sh
# Create shared network
docker create web
# Supporting Services
docker compose -f docker-compose.glauth.yml -f docker-compose.traefik.yml up -d
# Non-dependant Applications
docker compose -f docker-compose.cyberchef.yml -f docker-compose.excalidraw.yml up -d
# File Storage
docker compose -f docker-compose.minio.yml up -d
# Scratch Pad
docker compose -f docker-compose.hedgedoc.yml up -d
# Git server (Needs manual setup for LDAP)
docker compose -f docker-compose.gitea.yml up -d
# Shared Document Editing
docker compose -f docker-compose.onlyoffice.yml up -d
# Password and Secrets Storage
docker compose -f docker-compose.vaultwarden.yml up -d
```

The `.env` file is automatically loaded if it resides in the same directory.

---

## 🔐 Security

- Keep the `.env` file secret and secure.
- Replace secrets before moving to production.


---

## 💬 Support

Questions or suggestions? Feel free to ask or contribute!


## Why?

I'm trying to make a setup that is easy for people to use.

I haven't seen a lot of talks about the infrastructure that people set up
inside Red Teams to support themselves and the collaboration between team members
