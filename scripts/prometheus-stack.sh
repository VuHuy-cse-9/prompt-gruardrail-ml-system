#!/bin/bash

echo "Creating service..."
helm upgrade --install kube-prom-stack helm_charts/kube-prometheus-stack --namespace monitoring
