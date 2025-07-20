#!/bin/bash

NAMESPACE="logging"

echo "Creating service..."
helm upgrade --install elasticsearch helm/ELK/elasticsearch -f helm/ELK/elasticsearch/my-values.yaml --namespace $NAMESPACE
