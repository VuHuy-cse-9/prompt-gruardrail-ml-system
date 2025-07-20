# Deploying App on Kubernetes with Helm

## Step 1: Deploy Nginx ingress controller:
```bash
# Create namespace
kubectl create namespace nginx-system

# Install CRDs
kubectl apply -f https://raw.githubusercontent.com/nginx/kubernetes-ingress/v5.0.0/deploy/crds.yaml

# Install nginx-controller with Helm
helm install promt-guardrail oci://ghcr.io/nginx/charts/nginx-ingress --version 2.1.0 --namespace nginx-system
```

or deploy with scrip
```bash
./scripts/nginx-system.sh
```

## Step 2: Deploying monitoring service

```bash
# Create namespace
kubectl create namespace monitoring

# Deploying Otel Collector
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm install otel-collector open-telemetry/opentelemetry-collector --set mode=deployment --set image.repository="ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-k8s" --set command.name="otelcol-k8s" --namespace monitoring
```

or deploy with script
```bash
./scripts/monitoring.sh
```

## Step 3: Deploying model
```bash
# Create namespace
kubectl create namespace model-serving

# Deploying app
helm upgrade --install promptguard . --namespace model-serving
```

helm upgrade --install promptguard . --namespace default

or deploy with script
```bash
./scripts/model-serving.sh
```

cd elasticsearch
helm -n logging install elasticsearch .