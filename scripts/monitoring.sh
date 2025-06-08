#!/bin/bash

source ./scripts/utils.sh

NAMESPACE="monitoring"
SERIVE_NAME="promt-guardrail"

# Step 1: Create name space
ensure_namespace $NAMESPACE

# Step 2: Switch name space
kubectl ns $NAMESPACE

# Step 3: Deploy nginx-controller
if service_exists "${SERIVE_NAME}-opentelemetry-collector" $NAMESPACE; then
  echo "Service exists"
else
  echo "Creating service..."
  helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
  helm install promt-guardrail open-telemetry/opentelemetry-collector \
    --set mode=deployment \
    --set image.repository="ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-k8s" \
    --set command.name="otelcol-k8s"
fi
