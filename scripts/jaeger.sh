#!/bin/bash

NAMESPACE="monitoring"

echo "Creating service..."
helm upgrade --install jaeger helm/jaeger --namespace $NAMESPACE
