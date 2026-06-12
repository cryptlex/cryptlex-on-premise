# Migrating to the Traefik v3 setup

> Temporary document — delete once all customers are on the new setup.

## What changed

- **Traefik 1.7 → v3.7.** Static config moved from `traefik.toml` (deleted) to the `command:` flags in `docker-compose.yml`; TLS/custom-cert config moved to `dynamic/tls.yml`.
- **Valkey cache enabled** (`cache` service, Redis-compatible); `web-api` uses it via `REDIS_URL`.
- **`geoip` service removed** — web-api uses the MaxMind credentials directly.
- **`dashboard` service removed** (replaced by the portals) along with `dashboard.env`, and the Traefik admin dashboard (`TRAEFIK_BASIC_AUTH`) is gone.
- **Internal services no longer published on random host ports** (`ports:` → `expose:`); only Traefik's 80/443 are exposed.

## Migration steps

1. Backup the old files: `cp docker-compose.yml docker-compose.yml.bak && cp .env .env.bak`
2. `docker compose down` (data in named volumes is preserved).
3. Replace `docker-compose.yml` and `update.sh`, add `dynamic/tls.yml`, delete `traefik.toml` and `dashboard.env`.
4. In `.env`: remove `DASHBOARD_DOMAIN` and `TRAEFIK_BASIC_AUTH`; keep everything else as the customer had it.
5. Reset `acme.json` — the v1 ACME format is incompatible with v3, and v3 requires strict permissions:
   ```bash
   > acme.json && chmod 600 acme.json
   ```
   Certificates re-issue automatically on first start.
6. Custom SSL certs (non-Let's Encrypt): follow `ssl/README`.
7. `docker compose up -d`

## Verify

- `docker compose ps` — all services up; `database` and `cache` healthy.
- `docker compose logs reverse-proxy` — no ACME/TLS errors.
- Portals and web API load over HTTPS with a valid certificate.

## Keep in mind

- Customers must be off the legacy dashboard URL before migrating; its DNS record can be dropped afterwards.
- Let's Encrypt re-issues certs for all domains on first start, so 80/443 must be reachable from the internet.
- Customer-specific customizations (external Postgres/S3, extra services) must be ported by hand — diff against `docker-compose.yml.bak`.
- The network MTU override (1300) is now commented out, so the recreated network uses the default 1500. Re-enable it (see the comment in `docker-compose.yml`) only for hosts on VPN/overlay networks with MTU below 1500.
- The project name is now pinned (`name: cryptlex-on-premise`). Before migrating, run `docker volume ls` — if the customer's volumes are not named `cryptlex-on-premise_database_data` / `cryptlex-on-premise_filestore_data` (i.e. they deployed from a differently named directory), starting the new stack would create fresh empty volumes instead of using their data. In that case the existing volumes must first be copied to ones carrying the `cryptlex-on-premise_` prefix (renaming the deployment directory alone does not rename volumes).
