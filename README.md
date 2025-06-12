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
Where:
- `OLTP_ENDPOINT`: Our api service would push metrics & spans to Otel Collector using this URI. It send through port 4117 since we use gRPC. Since api service and Otel collector is in the same internal network, otel-collector, the name of otel collector's container, is used as a domain name.

- `OLTP_INSECURE`: We don't SSL since they communicate within the same internal network (Same when we deploy on Kubernetes)

- `SERVICE_NAME`: Our api use SERVICE_NAME as an identity so that we can recognize when we view JaegerUI or Grafana.

Launch docker compose
```bash
docker compose up -d
```

After this command, these services would be launched up:
1. api: Our prompt guardrail service. The docker image is built using api/Dockerfile.
2. otel-collector: Otel Collector service.
3. jaeger: Jaeger, recieves spans from otel collector.
4. prometheus: constantly grabs metrics exposed by Otel Collector.
5. grafana: Query metrics from prometheus, exposes them to dashboard.
6. node_exporter: Collect system metrics, exposes them to prometheus.

Now, we would discuss a little bit about how each service work:
**api**: After this service is launched up, it would pull the model's checkpoint from my huggingface hub. The way I trained the model is discussed in notebook folder. After setting up, you can go to `http://localhost:12345/docs`, and try the service.
**otel-collector**: I specify the otel-collector configuration in `monitoring/otel_collector/config.yaml`. In this file, I tell otel collector the URI of jaeger and the port that it should expose for promtheus to grab metrics.
**jaeger**: No configration is required. After it starts up, you can go to `http://localhost:16686` to view it UI. The spans of api should show up after you do several query in api.
**prometheus**: I configure prometheus to collect metrics from otel collector and node-exporter in `monitoring/prometheus/config.yml`.
**grafana**: It's the place for you to visualize metrics collected from promtheus. 

## 3. Provisioning Infrastructure on Google Cloud with Terraform
Overview: In this step, you would provision Google Cloud infrastructure using Terraform. I have setup all the Terraform's configuration at iac/terraform folder.

Before you begin, you should install **terraform** on your machine by following this [guide](https://computingforgeeks.com/how-to-install-terraform-on-ubuntu/).

After that, authenticate you google cloud account using below command:
```bash
gcloud auth application-default login
```

After everything is completed, run below code to provision you infrastructure.
```bash
cd iac/terraform
terraform init
terraform plan
terraform apply
```

After this command, you would provision GKE to allocate:
1. A Cluster with 3 nodes, each node is a e2-medium with 80GB disk size. These nodes locates at zone: asia-southeast1-a. 
2. A Compute instance: e2-standard-4 for deploying Jenkins. 
3. A firewall allow rules, so that we can access Jenkins from public IP.

Finally, connect to your cluster by run the below command (you should have installed kubernetes):
```
gcloud container clusters get-credentials <your_project_id>-gke --zone asia-southeast1-a --project <your_project_id>
```

Run the below command to see there are three nodes on your cluster:
```
kubectl get nodes
```

## 4. Deploying your service on your cluster

**Overview**: In this step, we use Helm to deploy our app in our cluster. These app would be setup on three distinct namespaces: 1. api app would deploy on model-serving namespace, 2. Otel Collector, Jaeger, Prometheus, Grafana, and Node exporter would deploy on monitoring namespace, 3. An ingress controller, so we can access our app by domain.
To launch up all the services in docker-compose, run the below scripts:
```
./scripts/nginx-system.sh
./scripts/monitoring.sh
./scripts/model-serving.sh
```

In order to let these services connect to each other, we need addtional setting that I would discuss below.

### a. Prometheus

In docker compose, I define a prometheus configuration file at monitoring/promtheus/config.yml. For kubernetes, we would have to do the same thing. We follow the [intruction](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/additional-scrape-config.md) to setup that for promtheus as follow:

Step 1. First, we tell promtheus that it should collect metrics from otel collector by defining a yaml file at `helm/promtheus/promtheus-additional.yaml`. In this file, I show promtheus the URL of Otel collector, which is `otel-collector.monitoring.svc.cluster.local`, FQDN (fully qualified domain name) in Kubernets.

Step 2. Then run the below command:
```
cd helm/prometheus
kubectl create secret generic additional-scrape-configs --from-file=prometheus-additional.yaml --dry-run=client -oyaml > additional-scrape-configs.yaml

kubectl apply -f additional-scrape-configs.yaml -n monitoring
```

Step 3. In order for prometheus to recognize the object you have just created by additional-scrape-configs.yaml, I edit promtheus's object as follow

```
# Final promtheus object
kubectl get promtheus

# Edit it
kubectl edit prometheus <prometheus_name>
```

Step 4: Add the below content as a child of the `spec` key:
```
spec:
  ...
  additionalScrapeConfigs:
    name: additional-scrape-configs
    key: prometheus-additional.yaml
  ...
```

Step 5: Restart the promtheus service
```
helm upgrade --install promt-guardrail-prom-gra prometheus-community/kube-prometheus-stack --namespace monitoring
```

### b. Otel Collector
Overview: we need to tell Otel collector the URI if Jaeger as well as the port it should expose for promtheus to grab. From this [discussion](https://github.com/open-telemetry/opentelemetry-collector-contrib/discussions/31415), I override some of the default value, which is defined at helm/otel_collector/my_values.yaml. I have already applied this value at the `scripts/monitoring.sh`, so we don't have to do anthing.

### c. Grafana:
Overview: TODO: Write how to setup API.


## 5. Setup CI/CD
