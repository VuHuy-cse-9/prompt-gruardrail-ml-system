#!/bin/bash
helm upgrade --install prompt-guardrail ./helm_charts/prompt-guardrail \
    --namespace model-serving
