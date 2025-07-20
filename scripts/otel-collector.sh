#!/bin/bash

NAMESPACE="monitoring"

echo "Creating service..."
helm upgrade --install otel-collector helm/otel-collector  \
              --namespace $NAMESPACE
