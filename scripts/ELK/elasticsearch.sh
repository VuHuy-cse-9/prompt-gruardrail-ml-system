#!/bin/bash

NAMESPACE="logging"

echo "Creating service..."
helm upgrade --install elasticsearch helm/elk_setting/elasticsearch -f helm/elk_setting/elasticsearch/my-values.yaml --namespace $NAMESPACE
