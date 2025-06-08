#!/bin/bash

source ./scripts/utils.sh

NAMESPACE="model-serving"
SERIVE_NAME="promt-guardrail"

# Step 1: Create name space
ensure_namespace $NAMESPACE

# Step 2: Switch name space
kubectl ns $NAMESPACE

# Step 3: Deploy/Upgrade nginx-controller
helm upgrade --install $SERIVE_NAME ./helm/mychart --namespace $NAMESPACE
