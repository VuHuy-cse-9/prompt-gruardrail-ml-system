# Prompt Guardrail Service

## Table of Contents

[1. System architecture with Kubernetes](#1-system-architecture-with-kubernetes-k8s)

[2. Local deployment using docker compose](#2-local-deployment-with-docker-compose)

[3. Deployment on Google Cloud Platform](#3-deployment-on-google-cloud-platform)

[4. Setup CI/CD](#4-setup-cicd)


## 1. System architecture with Kubernetes (K8s)
![](assets/archi.png)

## 2. Local Deployment with docker compose

Create `.env` file in api, which is given in .env.example
```
OLTP_ENDPOINT="grpc://otel-collector:4317"
OLTP_INSECURE = true
SERVICE_NAME="prompt_guardrail"
```

Launch docker compose
```bash
docker compose up -d
```

Open `localhost:12345` in web browser and you should have the following **FastAPI** doc.
![](images/fastapi_doc.png)

You can access different tool at:
- **prometheus**: `localhost:9090`
- **grafana**: `localhost:3000`
- **Jaeger**: `localhost:16686`


## 3. Deployment on Google Cloud Platform


### 3.1 Create clusters with `terraform`
You need **terraform** to setup the clusters. [Instal guide here](https://computingforgeeks.com/how-to-install-terraform-on-ubuntu/).

Authenticate
```bash
gcloud auth application-default login
```
Launch GKE cluster generation & GCE instance for Jenkins
```bash
cd iac/terraform
terraform init
terraform plan
terraform apply
```


### 3.2 Deploy clusters
**Nginx Ingress Controller**
Deploying nginx ingress controller in nginx-system namespace.
```bash
./scripts/nginx-system.sh
```

**Monitoring**
Run below command to start Otel Collector, Prometheus, Jaeger, and Grafana dashboard
```
./scripts/monitoring.sh
```

**Prometheus**
We need additional setting to instruct Prometheus the Otel collector to grab the metrics. Following this [intruction](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/additional-scrape-config.md), run the below command
```
cd helm/prometheus
kubectl create secret generic additional-scrape-configs --from-file=prometheus-additional.yaml --dry-run=client -oyaml > additional-scrape-configs.yaml
kubectl apply -f additional-scrape-configs.yaml -n monitoring
```

Then, edit the promtheus object. First get the promtheus name
```
kubectl get prometheus
```
Then edit it configuration file

```
kubectl edit prometheus <prometheus_name>
```

Below the spec key, add the `additionalScrapeConfigs` keys with its value
```
apiVersion: monitoring.coreos.com/v1
kind: Prometheus
metadata:
  name: prometheus
  labels:
    prometheus: prometheus
spec:
  # Add this
  additionalScrapeConfigs:
    name: additional-scrape-configs
    key: prometheus-additional.yaml
```


**Grafana**

**Application**


## 4. Setup CI/CD
GitHub Actions is utilized for the CI/CD processes in this project. There are two workflows:

- **Unittest**: This workflow handles linting and unit tests. It is triggered with every push to any branch.
- **Deployment**: This workflow is activated after a merge or a push to the `master` branch, except when the changes are limited to markdown files. It builds new Docker images and pushes them to Docker Hub, using the commit hash as the image tag. Once the new Docker images are pushed, the application is automatically updated with these images.

**Unit test workflow**
![](images/workflow-unittest.png)

**Deployment workflow**
![](images/workflow-deployment.png)

In order to use this CI/CD, follow the following guide.

### 4.2 Setup github action secrets & variables