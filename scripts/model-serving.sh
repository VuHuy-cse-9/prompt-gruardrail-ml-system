#!/bin/bash
helm upgrade --install prompt-guardrail ./helm/prompt-guardrail \
    --namespace model-serving
