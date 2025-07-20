# Prometheus & Grafana

Reference: https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack

**Step 1**: Add prometheus to helm repo

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

**Step 2**:  Search prometheus app

```python
helm search repo prometheus
```

**Step 3**: Helm pull kube-prometheus-stack. I use kube-promtheus-stack version 75.12.0

```json
helm pull prometheus-community/kube-prometheus-stack --version 75.12.0
```

Step 4: Edit Prometheus configuration.

4.1 Add `additionalScrapeConfigs` at prometheus.prometheusSpec

```yaml
...
prometheusSpec:
	additionalScrapeConfigs:
	# We would like promtheus to scrape metrics from otel collector.
	- job_name: "otel_collector"
	  static_configs:
	  - targets: ["otel-collector.monitoring.svc.cluster.local:8888"]
```

4.2 Limit computational resource allocates for alertmanager

```yaml
alertmanager:
	alertmanagerSpec:
		resources:
			requests:
			  memory: 400Mi
```

4.3: Limit computational resource allocates for prometheusOperator

```yaml
prometheusOperator:
	resources:
    limits:
      cpu: 200m
      memory: 200Mi
    requests:
      cpu: 100m
      memory: 100Mi
```

Step 5: Edit Grafana configuration.

Edit Grafana username and password

```yaml
grafana:
	adminUser: huyvu
	adminPassword: huyvu_grafana_2025
```

Step 6: Deploy the service

```bash
NAMESPACE="monitoring"
helm upgrade --install kube-prom-stack helm/kube-prometheus-stack --namespace $NAMESPACE
```

# Discussion

### 1. Prometheus Operator Image Version

**Overview**: 

- Currently, the image version is `v0.83.0`. It is specified at Chart.yaml
- The image is pulled from [quay.io](http://quay.io/)/prometheus-operator/prometheus-operator

### 2. Data Retention

**Overview**:

- The default value for data retention is 10 days, which is set at prometheus.prometheusSpec.retention.

### 3. Grafana Computational Resource:

Note: Grafana doesn’t have resoures’s attribute. So we cannot set computational resources for Grafana.