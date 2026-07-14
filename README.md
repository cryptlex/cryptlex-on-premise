# Cryptlex On-premise

Self-host the complete Cryptlex platform — web API, portals, release server, database, cache, and file store — on a single server using Docker Compose. It has all the features of SaaS Cryptlex, and regular releases keep you up to date.

This repository is for single-server deployments. For high-availability deployments on Kubernetes, use the [Cryptlex Helm charts](https://github.com/cryptlex/helm-charts).

## Architecture

![Single Server Layout](assets/cryptlex-on-premise.png)

`docker-compose.yml` defines the following services:

| Service           | Purpose                                                |
| ----------------- | ------------------------------------------------------ |
| `web-api`         | Core Cryptlex web API                                  |
| `admin-portal`    | Admin portal                                           |
| `customer-portal` | Customer portal                                        |
| `reseller-portal` | Reseller portal                                        |
| `release-server`  | Handles upload and download of releases                |
| `database`        | PostgreSQL database storing all Cryptlex data          |
| `cache`           | Valkey (Redis-compatible) cache                        |
| `filestore`       | MinIO, S3-compatible object storage for release files  |
| `reverse-proxy`   | Traefik — routes traffic and manages SSL certificates  |

If you don't use [release management](https://cryptlex.com/docs/release-management/overview), you can comment out the `release-server` and `filestore` services in `docker-compose.yml`.

## Requirements

- A Cryptlex license key and access to the private Docker images. If you are installing for the first time, [contact us](mailto:support@cryptlex.com) to schedule a guided installation.
- A server (Linux, Windows, or macOS) with:
  - Docker 20.10.22 or higher
  - dual-core CPU (quad-core recommended for higher volumes)
  - 6 GB memory
  - 5 GB+ storage (grows with the number of licenses and activations)
- Ports 80 and 443 reachable from the internet, required by Let's Encrypt to issue SSL certificates. To use your own certificates instead, see [Custom SSL certificates](#custom-ssl-certificates).

## Installation

### 1. Create DNS records

Create five A or CNAME records at your DNS provider, all pointing to the IP address or hostname of your server:

| Sub-domain (example)                     | Service         |
| ---------------------------------------- | --------------- |
| `cryptlex-api.mycompany.com`             | Web API         |
| `cryptlex-admin-portal.mycompany.com`    | Admin Portal    |
| `cryptlex-customer-portal.mycompany.com` | Customer Portal |
| `cryptlex-reseller-portal.mycompany.com` | Reseller Portal |
| `cryptlex-releases.mycompany.com`        | Release Server  |

### 2. Clone the repository

```bash
git clone https://github.com/cryptlex/cryptlex-on-premise
cd cryptlex-on-premise
chmod 600 acme.json
```

`acme.json` stores the Let's Encrypt SSL certificates; Traefik requires it to have `600` permissions.

### 3. Configure environment variables

**`.env`**

| Variable                                            | Description                                                 |
| --------------------------------------------------- | ----------------------------------------------------------- |
| `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD` | Database name and credentials.                              |
| `EMAIL`                                             | Email address for SSL certificate notifications.            |
| `*_DOMAIN` (five variables)                         | The five domains created in step 1.                         |
| `FILE_STORE_ACCESS_KEY`, `FILE_STORE_SECRET_KEY`    | Credentials for the file store.                             |
| `GOOGLE_CLIENT_ID`                                  | Optional — only needed to enable Google SSO.                |
| `MAXMIND_ACCOUNT_ID`, `MAXMIND_LICENSE_KEY`         | Optional — MaxMind credentials for GeoIP.                   |

**`web-api.env`**

| Variable                  | Description                                                                                      |
| ------------------------- | ------------------------------------------------------------------------------------------------ |
| `ENCRYPTION_KEY`          | Any random string — used to encrypt the private keys and other secrets stored in the database.   |
| `RSA_PASSPHRASE`          | Same value as `ENCRYPTION_KEY`. Deprecated; will be removed in a future release.                 |
| `APPLICATION_LICENSE_KEY` | The license key for your on-premise Cryptlex server.                                             |

Additionally, configure the `SMTP_*` and `EMAIL_*` sender settings so the server can send emails.

**`release-server.env`**

| Variable                                 | Description                                                       |
| ---------------------------------------- | ----------------------------------------------------------------- |
| `FILE_STORE_BUCKET`                      | Name of the bucket where release files are stored.                |
| `FILE_STORE_REGION`, `FILE_STORE_USE_SSL` | Only change these if you use AWS S3 instead of the bundled MinIO. |

### 4. Start the services

Log in to Docker Hub with the account that has access to the Cryptlex images, then start the stack:

```bash
docker login -u $DOCKER_USERNAME
docker compose up -d
```

Check the logs for any errors:

```bash
docker compose logs -t -f
```

Traefik automatically obtains SSL certificates for the five domains, stores them in `acme.json`, and routes traffic to the respective containers.

> **Note:** `docker-compose.yml` pins the PostgreSQL version. Once the database has data, moving to a newer major version requires a database migration.

### 5. Create your account

Open `https://<ADMIN_PORTAL_DOMAIN>/auth/signup` in the browser and sign up. Only one account can be created on an on-premise instance.

## Custom SSL certificates

To use your own SSL certificates instead of Let's Encrypt, follow the steps in [ssl/README](ssl/README).

## Configuring client libraries

By default, Cryptlex SDKs send requests to `api.cryptlex.com`. Point them to your on-premise web API endpoint instead — this is the only integration change; everything else works as described in [Using LexActivator](https://cryptlex.com/docs/node-locked-licenses/using-lexactivator).

**LexActivator** — call `SetCryptlexHost()` (available in all language bindings):

```c
status = SetCryptlexHost("https://cryptlex-api.mycompany.com");
```

**LexFloatServer** — set `cryptlexHost` in its `config.yml`:

```yaml
server:
  cryptlexHost: https://cryptlex-api.mycompany.com
```

## Updating

From the directory where you cloned this repository:

```bash
./update.sh
```

The script pulls the latest images and restarts the updated services; average downtime is under a minute. Check the logs afterwards with `docker compose logs -t -f`.

## Monitoring

Cryptlex integrates with [OpenTelemetry](https://opentelemetry.io/) to collect metrics and traces from your instance, which you can export to any OTel-compatible backend — Grafana, Datadog, New Relic, Elastic, Splunk, etc. — to monitor health, set up alerts, and troubleshoot issues.

To enable it, uncomment and set the following variables in `web-api.env`:

| Variable                       | Description                                                            |
| ------------------------------ | ---------------------------------------------------------------------- |
| `OTEL_EXPORTER_OTLP_ENDPOINT`  | OTLP endpoint of your monitoring backend.                              |
| `OTEL_ENABLEMETRICS`           | Set to `true` to export metrics.                                       |
| `OTEL_ENABLETRACES`            | Set to `true` to export traces.                                        |
| `OTEL_EXPORTER_OTLP_HEADERS`   | Headers for backend authentication, as comma-separated `key=value` pairs. |

## Support

For assistance, enterprise inquiries, or deployment guidance, contact [support@cryptlex.com](mailto:support@cryptlex.com).

## License

Commercial software — contact Cryptlex for licensing details.