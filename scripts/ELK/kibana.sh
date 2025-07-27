#!/bin/bash

NAMESPACE="logging"

echo "Creating service..."
helm upgrade --install kibana helm/ELK/kibana -f helm/ELK/kibana/my-values.yaml --namespace $NAMESPACE\
             --set ingress.hosts[0].host="kibana.$EXTERNAL_IP.nip.io"

