#!/bin/bash

NAMESPACE="logging"

echo "Creating service..."
helm upgrade --install filebeat helm/elk_setting/filebeat --namespace $NAMESPACE

