#!/bin/bash

echo "Creating service..."
helm upgrade --install nginx-ingress helm/nginx-ingress --namespace nginx-system
