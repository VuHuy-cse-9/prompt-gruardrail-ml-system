#!/bin/bash

echo "Creating service..."
helm upgrade --install cert-manager helm/cert-manager \
             --namespace cert-manager \
             --set crds.enabled=true
kubectl apply -f helm/cert-manager/acme-issuer.yaml --namespace cert-manager