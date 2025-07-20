#!/bin/bash

NAMESPACE="nginx-system"

echo "Creating service..."
helm upgrade --install nginx-ingress helm/ingress-nginx  \
              --namespace $NAMESPACE
