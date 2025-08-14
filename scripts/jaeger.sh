#!/bin/bash

echo "Creating service..."
helm upgrade --install jaeger helm_charts/jaeger --namespace monitoring