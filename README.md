# Cryptlex On-premise

Cryptlex On-premise provides a fully self-hosted deployment of Cryptlex for organizations that require complete control over infrastructure, data residency, security, and network environments.

It includes all major Cryptlex platform capabilities, including license management, activations, floating licenses, trials, entitlements, release management, and APIs, while allowing deployment within your own infrastructure.

Cryptlex On-premise can be deployed in:

* private cloud environments
* enterprise data centers
* staging and production clusters
* regulated or compliance sensitive environments

---

## Documentation

| Topic                                                                        | Description                          |
| ---------------------------------------------------------------------------- | ------------------------------------ |
 | [docs/000-overview.md](docs/000-overview.md)                                     | Overview of Cryptlex On-premise      |
 | [docs/010-system-requirements.md](docs/010-system-requirements.md)               | Hardware and software requirements   |
 | [docs/000-overview.md#server-layout](docs/000-overview.md#server-layout)         | Recommended deployment architectures |
 | [docs/025-configuring-client-libraries.md](docs/025-configuring-client-libraries.md) | Configure SDKs for On-premise        |
 | [docs/030-monitoring-your-instance.md](docs/030-monitoring-your-instance.md)     | Monitoring and observability setup   |

---

## Architecture Overview

Cryptlex On-premise consists of multiple independently scalable services:

* Cryptlex Web API
* Cryptlex Release Server
* PostgreSQL
* Redis
* Reverse proxy (Traefik)
* MinIO or S3 compatible storage

The services can be deployed either:

* on a single server for development/testing
* across multiple servers for staging and production environments

---

## Deployment Models

### Single Server Deployment

Recommended for:

* development environments
* testing
* low volume deployments

Features:

* simple deployment
* minimal infrastructure requirements
* all services hosted together

---

### Distributed Deployment

Recommended for:

* production environments
* high availability deployments
* scalable enterprise workloads

Features:

* external PostgreSQL
* external Redis
* load balancer support
* horizontal scaling
* storage redundancy support

---

## System Requirements

### Minimum Requirements

| Resource   | Requirement        |
| ---------- | ------------------ |
| CPU        | Dual core          |
| Memory     | 1 GB minimum       |
| Storage    | 5 GB minimum       |
| Docker     | 20.10.22 or higher |
| PostgreSQL | 13.x or higher     |

### Recommended Production Requirements

| Resource | Recommendation                |
| -------- | ----------------------------- |
| CPU      | Quad core or higher           |
| Memory   | 4 GB or higher                |
| Storage  | SSD backed persistent storage |
| Database | Managed PostgreSQL cluster    |
| Cache    | Dedicated Redis instance      |

---

## Configuring Client Libraries

By default, Cryptlex SDKs communicate with `api.cryptlex.com`.

For On-premise deployments, configure your applications to use your self-hosted Cryptlex endpoint.

Example using LexActivator:

```c
status = SetCryptlexHost("https://cryptlex-api.mycompany.com");
```

See:

* [Configuring client libraries](docs/025-configuring-client-libraries.md)

---

## Monitoring

Cryptlex supports integrations with:

* New Relic
* Bugsnag

This allows monitoring of:

* service health
* application errors
* infrastructure stability
* alerting workflows

See:
* [Monitoring your instance](docs/030-monitoring-your-instance.md)

---

## Storage Components

### PostgreSQL

Primary database service used by Cryptlex Enterprise.

### Redis

Caching service used for performance optimization.

### MinIO / S3 Compatible Storage

Object storage service used for application file storage.

---

## Supported Platforms

Cryptlex On-premise can run on:

* Linux
* Windows
* macOS

Provided Docker requirements are met.

---

## Support

For assistance, enterprise inquiries, or deployment guidance:

* [support@cryptlex.com](mailto:support@cryptlex.com)

---

## License

Commercial software.
Contact Cryptlex for licensing details.