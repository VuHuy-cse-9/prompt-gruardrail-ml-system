#!/bin/bash

source ./scripts/utils.sh

NAMESPACE="nginx-system"
SERIVE_NAME="promt-guardrail"

# Step 1: Create name space
ensure_namespace $NAMESPACE

# Step 2: Switch name space
kubectl ns $NAMESPACE

# Step 3: Deploy nginx-controller
if service_exists "${SERIVE_NAME}-nginx-ingress-controller" $NAMESPACE; then
  echo "Service exists"
else
  echo "Creating service..."
  kubectl apply -f https://raw.githubusercontent.com/nginx/kubernetes-ingress/v5.0.0/deploy/crds.yaml
  helm install promt-guardrail oci://ghcr.io/nginx/charts/nginx-ingress --version 2.1.0
fi
