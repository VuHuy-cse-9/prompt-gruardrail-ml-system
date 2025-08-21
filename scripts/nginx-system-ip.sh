#!/bin/bash
export EXTERNAL_IP=$(kubectl get service nginx-ingress-controller \
  --namespace nginx-system \
  --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "External IP: $EXTERNAL_IP"
