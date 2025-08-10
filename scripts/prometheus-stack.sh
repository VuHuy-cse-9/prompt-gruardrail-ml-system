#!/bin/bash

echo "Creating service..."
helm upgrade --install kube-prom-stack helm/kube-prometheus-stack --namespace monitoring
