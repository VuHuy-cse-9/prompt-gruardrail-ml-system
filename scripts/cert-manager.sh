#!/bin/bash

# Install service
echo "Creating service..."
helm upgrade --install cert-manager helm/cert-manager \
             --namespace cert-manager \
             --set crds.enabled=true

# Create ACME Issuer to query Let's Encrypt Certificate
kubectl apply -f helm/cert-manager/acme-issuer.yaml --namespace cert-manager

# Create Certificates for each services. Each certificate would create their owned
# secret, which stores SSL certificates. Service would use this Certificates to verify
# their SSL connection
kubectl apply -f helm/cert-manager/certificates
