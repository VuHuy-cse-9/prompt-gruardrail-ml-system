#!/bin/bash

NAMESPACE="monitoring"

echo "Creating service..."
helm upgrade --install otel-collector helm_charts/otel-collector  \
              --namespace $NAMESPACE
