# Deploying App on Kubernetes with Helm


## Step 1: Create namespace and switch to that ns
```
cd mychart/templates
kubectl apply -f namespace.yaml
kubectl ns app-namespace
```

## Step 2: Deploy ingress controller
We follow this document to install ingress controller: [ingress-controller document](https://docs.nginx.com/nginx-ingress-controller/installation/installing-nic/installation-with-helm/). 

You should change kubectl into your namespace before installing nginx-controller.

```bash
# Install CRDs
kubectl apply -f https://raw.githubusercontent.com/nginx/kubernetes-ingress/v5.0.0/deploy/crds.yaml

# Install nginx-controller with Helm
helm install my-release oci://ghcr.io/nginx/charts/nginx-ingress --version 2.1.0
```

## Step 3: Deploying our app
```
helm upgrade --install promptguard .
```