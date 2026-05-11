### Introduction

In this guide, you'll install the **Cryptlex Enterprise Helm chart** to deploy the application on your Kubernetes cluster. You'll then set up an **Ingress Resource** to route traffic from your domains to the Cryptlex Enterprise back-end services. After configuring the Ingress, you'll install **Cert-Manager** in your cluster to automatically provision **Let's Encrypt** TLS certificates, securing your Ingresses.

**Helm** is a package manager for Kubernetes that simplifies application deployment, upgrade, and lifecycle management using Helm Charts.

***

#### Prerequisites

Before you begin, ensure you have the following:

* A **Kubernetes 1.28+** cluster with `kubectl` configured to connect to it.
* **Helm 3** installed on your local machine.
* A fully registered domain name with at least four available **A** or **CNAME** records.

This guide uses the following example domains:

* `license-api.mycompany.com`
* `license-admin-portal.mycompany.com`
* `license-customer-portal.mycompany.com`
* `releases.mycompany.com`

***

#### Step 1 — Installing the NGINX Ingress Controller

Start by installing the **NGINX Ingress Controller** using Helm.

The NGINX Ingress Controller will expose your services to the internet via a Load Balancer.

First, create a file called `ingress.yaml` with the following content:

```yaml
controller:
  publishService:
    enabled: true
  service:
    enabled: true
    externalTrafficPolicy: "Local"
```

Then, run the following commands:

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx --values ingress.yaml
```

To watch the Load Balancer become available:

```bash
kubectl get services -o wide -w ingress-nginx-controller
```

Once ready, the Ingress Controller will route HTTP and HTTPS traffic to the appropriate backend services defined in your Ingress Resources.

***

#### Step 2 — Create DNS Records

Create **A** or **CNAME** records for the external IP address of the Ingress Controller you just installed.

To find the external IP:

```bash
kubectl get services -o wide -w ingress-nginx-controller
```

Then, go to your DNS provider (e.g., GoDaddy or Cloudflare) and create the following records:

| Subdomain                               | Purpose         |
| --------------------------------------- | --------------- |
| `license-api.mycompany.com`             | Web API Server  |
| `license-admin-portal.mycompany.com`    | Admin Portal    |
| `license-customer-portal.mycompany.com` | Customer Portal |
| `releases.mycompany.com`                | Release Server  |

Point all of them to the same external IP.

***

#### Step 3 — Securing the Ingress Using Cert-Manager

To enable HTTPS, install **Cert-Manager** to your Kubernetes cluster.

Run the following commands:

```bash
helm repo add jetstack https://charts.jetstack.io --force-update
helm upgrade --install cert-manager jetstack/cert-manager \
  --create-namespace --namespace cert-manager --atomic \
  --set crds.enabled=true
```

Once installed, Cert-Manager will automatically issue and renew Let's Encrypt TLS certificates for your Ingress resources.

***

#### Step 4 — Installing the Cryptlex Enterprise Helm Chart

**Step 4.1 — Choosing a Database**

Cryptlex requires a **PostgreSQL** database.

* For **staging/testing**, the Helm chart can deploy a bundled Postgres instance using a Persistent Volume Claim.
* For **production**, it's recommended to use an external managed PostgreSQL service for reliability and scalability.

**Step 4.2 — Choosing a File Store**

Cryptlex uses an **AWS S3-compatible** file store for release artifacts.

* The Helm chart includes a bundled **MinIO** instance for staging/testing environments.
* For **production**, it's best to use a managed S3-compatible storage service (e.g., AWS S3, Wasabi).

<Alert> Note: If you're not using Cryptlex's release management API, this service is optional. </Alert>

**Step 4.3 — Download and Customize the Helm Values File**

Download the default configuration file:

```bash
curl -O https://raw.githubusercontent.com/cryptlex/helm-charts/master/cryptlex/cryptlex-enterprise/values.yaml
```

Create separate config files for each environment:

```bash
cp values.yaml staging.yaml
cp values.yaml production.yaml
```

Update these files with environment-specific values (database, file store, domain names, etc.).

**Step 4.4 — Install Cryptlex Enterprise Using Helm**

Add the Cryptlex Helm chart repository:

```bash
helm repo add cryptlex https://cryptlex.github.io/helm-charts --force-update
```

Deploy for each environment:

**Staging:**

```bash
kubectl create namespace cryptlex-stg
helm upgrade --install cryptlex-enterprise-stg \
  --values staging.yaml \
  --namespace cryptlex-stg cryptlex/cryptlex-enterprise
```

**Production:**

```bash
kubectl create namespace cryptlex
helm upgrade --install cryptlex-enterprise \
  --values production.yaml \
  --namespace cryptlex cryptlex/cryptlex-enterprise
```

***

#### Step 5 — Create Your Cryptlex Account

Once deployed, open the admin portal in your browser and create your Cryptlex account:

```
https://license-admin-portal.mycompany.com/auth/signup
```

<Alert> Note: You can only create **one Cryptlex account** per environment. </Alert>

***

#### Upgrading Your Deployment

Regularly upgrade the applications in your cluster to receive the latest security patches and features.

Run the following commands to upgrade:

##### Update all helm repos
```bash
helm repo update
```

##### Upgrade NGINX Ingress

```bash
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx --values ingress.yaml
```

##### Upgrade staging environment

```bash
helm upgrade --install cryptlex-enterprise-stg \
  --values staging.yaml \
  --namespace cryptlex-stg cryptlex/cryptlex-enterprise
```

##### Upgrade production environment

```bash
helm upgrade --install cryptlex-enterprise \
  --values production.yaml \
  --namespace cryptlex cryptlex/cryptlex-enterprise
```

To upgrade **Cert-Manager**, refer to the official guide: [https://cert-manager.io/docs/installation/upgrading/](https://cert-manager.io/docs/installation/upgrading/)
