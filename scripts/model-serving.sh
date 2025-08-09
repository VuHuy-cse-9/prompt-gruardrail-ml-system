#!/bin/bash
helm upgrade --install promt-guardrail ./helm/prompt-guardrail \
    --namespace model-serving
    # --set ingress.host="app.${EXTERNAL_IP}.nip.io"
