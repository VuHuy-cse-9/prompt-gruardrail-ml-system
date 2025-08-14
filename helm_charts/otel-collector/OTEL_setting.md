# Otel Collector

Reference: https://github.com/open-telemetry/opentelemetry-helm-charts

**Step 1**: Add open-telemetry chart to Helm Repo

```yaml
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm repo update
```

**Step 2**: Pull `opentelemetry-collector` repo. I use chart version `0.129.0`

```bash
helm pull open-telemetry/opentelemetry-collector --version 0.129.0
tar -xzf opentelemetry-collector-0.129.0.tgz
```

**Step 3**: Setting configuration for Otel Collector. Edit the file values.yaml/config

**Step 3.1**: Set exporters, receivers for Otel Collector.

```yaml
config:
	# Add exporters
	exporters:
		otlp: # Send OLTP's trace to Jaeger Collector
	      endpoint: jaeger-collector.monitoring.svc.cluster.local:4317
	      tls:
	        insecure: true
	  prometheus: # Exposes metrics in Prometheus format, must be 0.0.0.0
	      endpoint: 0.0.0.0:9090
	...
	service:
		pipelines:
			logs: {} # We don't collect logs
			metrics:
				exporters:
          - prometheus
        processors:
          - memory_limiter
          - batch
        receivers:
          - otlp
          # If service exposes metrics endpoint.
          # Set target scrape endpoint at receiver.promtheus
          - prometheus 
      traces:
        exporters:
          - otlp
        processors:
          - memory_limiter
          - batch
        receivers:
          - otlp # We set Jaeger collector's endpoint for the OLTP's receiver 
      
```

Step 3.2: Set Computation Resource for Otel Collector

```yaml
resources:
  limits:
    cpu: 250m
    memory: 512Mi
```

Step 3.3: Set fullNameOverride & Deployment mode

- For clarity, we set fullnameOverride=otel-collector
- Use mode = deployment

Step 3.4: Set otel image

```yaml
image:
  # If you want to use the core image `otel/opentelemetry-collector`, you also need to change `command.name` value to `otelcol`.
  repository: otel/opentelemetry-collector-contrib
  pullPolicy: IfNotPresent
  # Overrides the image tag whose default is the chart appVersion.
  tag: "0.130.0"
  # When digest is set to a non-empty value, images will be pulled by digest (regardless of tag value).
  digest: ""
```

Step 3.5: Enable Service to expose port 8888

```yaml
ports:
	metrics:
    # The metrics port is disabled by default. However you need to enable the port
    # in order to use the ServiceMonitor (serviceMonitor.enabled) or PodMonitor (podMonitor.enabled).
    enabled: true
    containerPort: 8888
    servicePort: 8888
    protocol: TCP
```

# Discussion

### 1. Receivers

**Overview**: **Receivers** are responsible for **receiving telemetry data** from various sources.

Receivers can accept: 1) Traces, 2) Metrics, and 3) Logs.

| Receiver | Description |
| --- | --- |
| otlp | Accepts OTLP (OpenTelemetry Protocol) — standard protocol for sending telemetry |
| prometheus | Scrapes metrics from Prometheus-compatible endpoints |
| jaeger | Accepts spans from Jaeger clients |
| zipkin | Accepts traces from Zipkin |
| filelog | Reads logs from files |
| hostmetrics | Collects host-level metrics (CPU, RAM, disk, etc.) |

```yaml
recievers:
	# Accept traces sent by Jaeger Client
	jaeger:
    protocols:
      grpc:
        endpoint: ${env:MY_POD_IP}:14250
      thrift_http:
        endpoint: ${env:MY_POD_IP}:14268
      thrift_compact:
        endpoint: ${env:MY_POD_IP}:6831
	# Accept telemetry data sent by opentelemetry instrumentation
	otlp:
    protocols:
      grpc:
        endpoint: ${env:MY_POD_IP}:4317
      http:
        endpoint: ${env:MY_POD_IP}:4318
  # Scrapes metrics from Prometheus-compatible endpoints
  prometheus:
    config:
      scrape_configs:
        - job_name: opentelemetry-collector
          scrape_interval: 10s
          static_configs:
            - targets:
                - ${env:MY_POD_IP}:8888
  # Accept trace send by zipkin
  zipkin:
      endpoint: ${env:MY_POD_IP}:9411
```

### 2. Exporters

**Overview**: **Exporters** are responsible for **sending telemetry data to a backend** (e.g., observability platform, another collector, or storage system).

Exporters can receive: 1) Traces, 2) Metrics, and 3) Logs.

| Exporter | Description |
| --- | --- |
| otlp | Sends data using OTLP protocol to another collector or backend |
| logging | Outputs data to console/logs (for debugging) |
| prometheusremotewrite | Exports metrics to Prometheus remote write endpoint |
| jaeger | Sends traces to Jaeger backend |
| zipkin | Exports traces to Zipkin |
| awsxray | Sends traces to AWS X-Ray |
| googlecloud | Sends data to Google Cloud Operations (formerly Stackdriver) |
| prometheus | Exposes metrics in Prometheus format |

```yaml
exporters:
  debug: {}
  # Export traces using OTLP format
  otlp:
    endpoint: jaeger-collector.monitoring.svc.cluster.local:4317
    tls:
      insecure: true
```

### 3. Default values

1. **Auto-scaling** is disable by default. It enables, it can scale up to 10 pods, and scaling metric is CPU utilization (80%).
    
    ```yaml
    autoscaling:
      enabled: false
      minReplicas: 1
      maxReplicas: 10
      behavior: {}
      targetCPUUtilizationPercentage: 80
      # targetMemoryUtilizationPercentage: 80
      # Supply an array of custom metrics to be used for autoscaling. It includes externalMetrics, objectMetrics, and podsMetrics.
      additionalMetrics: []
    ```