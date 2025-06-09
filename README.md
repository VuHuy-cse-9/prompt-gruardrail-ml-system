# Note

### Port Forwarding:
kubectl port-forward -n monitoring svc/promt-guardrail-prom-gra-grafana 3000:80
kubectl port-forward -n monitoring svc/promt-guardrail-prom-gra-k-prometheus 9090:9090
kubectl port-forward -n monitoring svc/otel-collector 8889:8889
kubectl port-forward -n monitoring svc/jaeger-query 16686:16686
kubectl port-forward -n model-serving svc/promt-guardrail 8005:8005



### URLs:
Prometheus urls: prometheus-operated.monitoring.svc.cluster.local

### Let Minikube's service has external IP
```
minikube tunnel
```


### Edit Prometheus configuration

Reference: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/additional-scrape-config.md

