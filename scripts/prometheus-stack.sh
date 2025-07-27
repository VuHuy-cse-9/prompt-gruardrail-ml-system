#!/bin/bash

NAMESPACE="monitoring"

echo "Creating service..."
helm upgrade --install kube-prom-stack helm/kube-prometheus-stack --namespace $NAMESPACE\
             --set grafana.ingress.hosts[0]="grafana.$EXTERNAL_IP.nip.io"
