#!/bin/bash

echo "Creating service..."
helm upgrade --install jaeger helm/jaeger --namespace monitoring\
             --set allInOne.ingress.hosts[0]="jaeger.${EXTERNAL_IP}.nip.io"
