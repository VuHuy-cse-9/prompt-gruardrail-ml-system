#!/bin/bash

NAMESPACE="logging"

echo "Creating service..."
helm upgrade --install elasticsearch helm_charts/elk_setting/elasticsearch -f helm_charts/elk_setting/elasticsearch/my-values.yaml --namespace $NAMESPACE
