#!/bin/bash

NAMESPACE="logging"

echo "Creating service..."
helm upgrade --install filebeat helm/ELK/filebeat --namespace $NAMESPACE

