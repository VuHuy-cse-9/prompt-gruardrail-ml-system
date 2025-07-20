#!/bin/bash

NAMESPACE="logging"

echo "Creating service..."
helm upgrade --install kibana helm/ELK/kibana -f helm/ELK/kibana/my-values.yaml --namespace $NAMESPACE

