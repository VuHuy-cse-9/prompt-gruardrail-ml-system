#!/bin/bash

NAMESPACE="logging"

echo "Creating service..."
helm upgrade --install kibana helm/elk_setting/kibana -f helm/elk_setting/kibana/my-values.yaml --namespace $NAMESPACE

