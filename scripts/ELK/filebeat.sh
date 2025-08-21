#!/bin/bash

NAMESPACE="logging"

echo "Creating service..."
helm upgrade --install filebeat helm_charts/elk_setting/filebeat --namespace $NAMESPACE

