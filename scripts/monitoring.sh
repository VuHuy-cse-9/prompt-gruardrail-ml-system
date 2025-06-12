#!/bin/bash

source ./scripts/utils.sh

NAMESPACE="monitoring"
SERVICE_NAME="promt-guardrail"
KUBE_STACK_SERVICE_NAME="${SERVICE_NAME}-prom-gra"

# Step 1: Create name space
ensure_namespace $NAMESPACE

# Step 2: Deploy nginx-controller
if service_exists "otel-collector" $NAMESPACE; then
  echo "Service ${SERVICE_NAME} exists"
else
  echo "Creating service..."
  echo "Install Otel collector"
  helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
  helm upgrade --install $SERVICE_NAME open-telemetry/opentelemetry-collector \
    -f helm/otel_collector/my_values.yaml \
    --set mode=deployment \
    --namespace $NAMESPACE
fi

if service_exists "${KUBE_STACK_SERVICE_NAME}-grafana"  $NAMESPACE; then
  echo "Service ${KUBE_STACK_SERVICE_NAME} exists"
else
  echo "Install Kube-prometheus-grafana stack"
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  helm repo update
  helm upgrade --install ${KUBE_STACK_SERVICE_NAME} prometheus-community/kube-prometheus-stack --namespace $NAMESPACE
fi

if service_exists "jaeger-collector"  $NAMESPACE; then
  echo "Service jaeger-collector exists"
else
  helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
  helm upgrade --install jaeger jaegertracing/jaeger -n monitoring \
              --set fullnameOverride="jaeger"\
              --values helm/jaeger/values.yaml
fi