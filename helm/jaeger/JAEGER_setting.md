Reference: https://github.com/jaegertracing/jaeger-operator

**Step 1**: Add jaeger to helm repo

```yaml
helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
helm repo update
```

**Step 2**: Pull helm repo. Currently, we use Jaeger Chart version `3.4.1`

```yaml
helm pull jaegertracing/jaeger --version 3.4.1
tar -xzf jaeger-3.4.1.tgz
```

**Step 3**: Edit value file

🪵 **All In One Service**

3.1. We deploy Jaeger in allInOne mode. We set the image tag to 1.71.0

```yaml
allInOne:
  enabled: true
  replicas: 1
```

3.2 In allInOne service, we set image into fixed version

```yaml
...
	image:
	    registry: ""
	    repository: jaegertracing/all-in-one
	    tag: "1.71.0"
	    digest: ""
	    pullPolicy: IfNotPresent
	    pullSecrets: []
	  extraEnv: []
	  extraSecretMounts:
		  []
```

3.3 Then, we limit its resource can use

```yaml
 ...
  # Set Computational Resources
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 256m
      memory: 128Mi
```

🪵 Storage: We change storage from Cassandra to Memory (For testing only).

```yaml
provisionDataStore:
  cassandra: false
  elasticsearch: false
  kafka: false

storage:
  # allowed values (cassandra, elasticsearch, grpc-plugin, badger, memory)
  type: memory
  memory:
    extraEnv: []
```

3.4. Fore clarity set the `fullnameOverride: "jaeger”`

**Step 4**: Deploying the service

```bash
helm upgrade --install jaeger /path/to/jaeger/chart --namespace $NAMESPACE
```

**Step 5**: Access Jaeger Query UI through port 16686

```bash
kubectl port-forward svc/jaeger-query 16686:16686
```