#!/bin/bash

NAMESPACE="logging"

echo "Creating service..."
helm upgrade --install kibana helm_charts/elk_setting/kibana -f helm_charts/elk_setting/kibana/my-values.yaml --namespace $NAMESPACE

