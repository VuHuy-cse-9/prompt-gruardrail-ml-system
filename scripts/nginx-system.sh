#!/bin/bash

echo "Creating service..."
helm upgrade --install nginx-ingress helm_charts/nginx-ingress --namespace nginx-system
