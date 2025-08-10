#!/bin/bash

echo "Creating service..."
helm upgrade --install jaeger helm/jaeger --namespace monitoring