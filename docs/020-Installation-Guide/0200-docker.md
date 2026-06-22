# Docker Compose Installation Guide

## Before installation

To get started with your Cryptlex On-premise installation, you will need the following things prepared in advance:

- If this is your first time installing Cryptlex On-premise, you’ll need to [contact us](mailto:support@cryptlex.com) to schedule a guided installation. We’ll get you set up with a license key, and walk you through the installation process.
- A server meeting the [minimum system requirements](/docs/010-system-requirements.md).

## Installation

Cryptlex On-premise uses [Docker Compose](https://docs.docker.com/compose/) to perform and manage installations. To install Cryptlex On-premise we first need to install and configure Docker Compose.

### Install Docker Compose

Please refer to following installation guide: [https://docs.docker.com/compose/install/](https://docs.docker.com/compose/install/)

### Using Docker Compose

All of the Cryptlex Docker images are available on [Docker Hub](https://hub.docker.com/u/cryptlex). If you’re looking for a complete configuration to get up and running quickly, follow the steps below.

#### Step 1: Create custom A or CNAME records

You will need to create five A or CNAME records for the server machine where you will be deploying Cryptlex. For this tutorial we will choose the following five sub-domains:

`cryptlex-api.mycompany.com` for the Web API Server

`cryptlex-admin-portal.mycompany.com` for the Admin Portal

`cryptlex-customer-portal.mycompany.com` for the Customer Portal

`cryptlex-reseller-portal.mycompany.com` for the Reseller Portal

`cryptlex-releases.mycompany.com` for the Release Server

Now to create the records:

- Go to your DNS provider’s website (e.g. [GoDaddy](https://ie.godaddy.com/help/add-a-cname-record-19236) or [Cloudflare](https://www.cloudflare.com/dns/)).
- Create A or CNAME records for the above custom domains.
- Point all of them to the same IP address or hostname of your server.

#### Step 2: Clone the cryptlex-on-premise repository

Next, you need to login into your Linux server machine and clone the [cryptlex-on-premise](https://github.com/cryptlex/cryptlex-on-premise) repository inside any folder and execute the following commands:

```bash
git clone https://github.com/cryptlex/cryptlex-on-premise
cd cryptlex-on-premise
chmod 0600 acme.json
```

The `acme.json` will store the SSL certificates, which will be generated for the above five sub-domains.

#### Step 3: Update the Postgres version

In the `docker-compose.yml` file change the value of `services.database.image` property to the current stable version of [Postgres](https://hub.docker.com/_/postgres). For example, if the latest version is 14.5 then set the value to `postgres:14.5-alpine`. Once the version is set, it cannot be updated later without migrating the database to a newer major version.

#### Step 4: Update the environment variables

The `cryptlex-on-premise` folder contains the following four files with environment variables that need to be updated with the correct values.

**Update `.env` file**

The `.env` file contains the following environment variables which you may need to update:

| Environment Variables    | Description                                                                                                            |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------------- |
| `POSTGRES_DB`            | Name of the database.                                                                                                  |
| `POSTGRES_USER`          | Username of the database user.                                                                                         |
| `POSTGRES_PASSWORD`      | The password of the database user.                                                                                     |
| `EMAIL`                  | Email required for SSL certificate notifications.                                                                      |
| `WEB_API_DOMAIN`         | The domain of the web API server. In this case: `cryptlex-api.mycompany.com`                                           |
| `ADMIN_PORTAL_DOMAIN`    | The domain of the Admin Portal. In this case: `cryptlex-admin-portal.mycompany.com`                                    |
| `RESELLER_PORTAL_DOMAIN` | The domain of the Reseller Portal. In this case: `cryptlex-reseller-portal.mycompany.com`                              |
| `CUSTOMER_PORTAL_DOMAIN` | The domain of the Customer Portal. In this case: `cryptlex-customer-portal.mycompany.com`                              |
| `RELEASE_SERVER_DOMAIN`  | The domain of the release server. In this case: `cryptlex-releases.mycompany.com`                                      |
| `FILE_STORE_ACCESS_KEY`  | Access key for the file store.                                                                                         |
| `FILE_STORE_SECRET_KEY`  | The secret key for the file store.                                                                                     |
| `GOOGLE_CLIENT_ID`       | This is needed in case you want to enable Google SSO.                                                                  |
| `TRAEFIK_BASIC_AUTH`     | [Traefik](https://traefik.io/) is the reverse proxy. You can set the basic auth credentials for the Traefik dashboard. |

**Update `webapi.env` file**

The `webapi.env` file contains the following environment variables which you **must** update:

| Environment Variables     | Description                                                                                                  |
| ------------------------- | ------------------------------------------------------------------------------------------------------------ |
| `ENCRYPTION_KEY`          | Use any random string, this is used to encrypt the private keys and other secrets stored in the database.    |
| `RSA_PASSPHRASE`          | Set the same value as `ENCRYPTION_KEY`. This property is deprecated and will be removed in a future release. |
| `APPLICATION_LICENSE_KEY` | The license key which you get after you purchase the license for the self-hosted Cryptlex server.            |

Other than the above three you need to set environment variables for the email provider, and additionally you can configure other monitoring and error reporting services.

**Update `release-server.env` file**

The `release-server.env` file contains the following environment variables which you may need to update:

| Environment Variables | Description                                                                                               |
| --------------------- | --------------------------------------------------------------------------------------------------------- |
| `FILE_STORE_BUCKET`   | Name of the bucket (folder) where you want to store all your files.                                       |
| `FILE_STORE_REGION`   | This is required in case you are using the AWS S3 file store, otherwise, leave the default value as such. |
| `FILE_STORE_USE_SSL`  | This should only be set to true in case you are using AWS S3.                                             |

#### Step 5: Run Docker Compose

Execute the following commands to start the server:

Ensure you have access to Cryptlex Docker images

```bash
docker login -u $DOCKER_USERNAME
```

### Start the Cryptlex services

```bash
docker compose up -d
```

### Check the logs for any errors

```bash
docker compose logs -t -f
```

The [Traefik](https://traefik.io/) reverse proxy server configured in the `docker-compose.yml` file will automatically generate SSL certificates for the above-mentioned domains and store them in `acme.json`. Additionally, it will automatically route the traffic to the respective containers.

#### Step 6: Signup for the Cryptlex account

Next, you need to open the dashboard in the browser and create your Cryptlex account, which can be done at the following URL: **https://cryptlex-admin-portal.mycompany.com/auth/signup.**

<Alert> Only one Cryptlex account can be created in the on-premise version. </Alert>

### Docker Compose file details

In the [docker-compose.yml](https://github.com/cryptlex/cryptlex-on-premise/blob/master/docker-compose.yml) file you will find the `database`, `filestore`, `cache`, `web-api`, `admin-portal`, `reseller-portal`, `customer-portal`, `release-server`, and `reverseproxy` services. Read below to better understand how each service is configured.

#### Database service

It contains the Postgres database server, which is used to store all the Cryptlex data.

#### Cache service

It uses [Valkey](https://valkey.io/) to store the cache data. If no Valkey database is provided it defaults to memory.

#### Filestore service

It stores release files using Minio, an AWS S3 compatible object storage server. In case you do not want to use Cryptlex [release management](https://cryptlex.com/docs/release-management/creating-releases) API, this service can be commented out in the `docker-compose.yml` file.

#### Web API service

It is the core service that runs the Cryptlex web API server.

#### Admin Portal service

This service runs the Cryptlex admin portal.

#### Reseller Portal service

This service runs the Cryptlex reseller portal.

#### Customer Portal service

This service runs the Cryptlex customer portal.

#### Release server service

It handles the upload and download of releases you create in Cryptlex. In case you do not want to use Cryptlex [release management](/docs/release-management/creating-releases) API, this service can be commented out in the `docker-compose.yml` file.

#### Reverse proxy service

It uses [Traefik](https://traefik.io/) reverse proxy server to route the traffic and automatically generates and renews the SSL certificates for the `WEB_API_DOMAIN` , `RELEASE_SERVER_DOMAIN`, `ADMIN_PORTAL_DOMAIN`, `RESELLER_PORTAL_DOMAIN and CUSTOMER_PORTAL_DOMAIN`.

### Traefik admin dashboard

Traefik provides a dashboard that can be used to monitor the health and status of the self-hosted Cryptlex instance. You can access the Traefik dashboard at the following URL: **https://cryptlex-admin-portal.mycompany.com/traefik**

You will need to put in the credentials set in the `.env` file to access the dashboard.

### Checking logs

Docker compose writes the **stdout** and **stderr** logs of each container in a JSON file located in `/var/lib/docker/containers/[container-id]/[container-id]-json.log.`

To prevent logs from taking up the whole disk space, `20MB` limit has been applied to all the containers in the `docker-compose.yml` file. You can change that as per your requirements.

To view the logs in realtime you can execute the following command:

```bash
docker compose logs -t -f
```

## Upgrading

First login to your Linux server machine where Cryptlex is deployed and go to the directory where the `cryptlex-on-premise` repository was initially cloned. Then execute the following commands:

### Execute the update script

```bash
./update.sh
```

### Check container logs

```bash
docker compose logs -t -f
```

<Alert> **Note:** The average downtime during the update is less than 1 minute. </Alert>