# General Setting

**Overview**: Add this chart to Helm repo, it contains all repo for elasticsearch stack

```bash
helm repo add elastic https://Helm.elastic.co
```

# Elasticsearch

Step 1: Pull elasticsearch chart. We would use version `8.5.1`

```bash
helm pull elastic/elasticsearch --version 8.5.1
tar -xzf elasticsearch-8.5.1.tgz
```

Step 3: Editing elasticsearch configuration file

3.1. Edit number of pods for testing

```yaml
replicas: 1
minimumMasterNodes: 1
```

3.2 For Computational Resources, we keep the default setting. We tried to reduce to computational setting, which made the service didn’t work smoothly as we though.

```yaml
resources:
  requests:
    cpu: "1000m"
    memory: "2Gi"
  limits:
    cpu: "1000m"
    memory: "2Gi"
```

3.3. antiAffinity. We turn antiAffinity to sort. From the comment

> *Hard means that by default pods will only be scheduled if there are enough nodes for them and that they will never end up on the same node. Setting this to soft will do this "best effort"*
> 

```yaml
antiAffinity: "soft"
```

3.4. For clarity, we set `fullnameOverride = "elasticsearch”`

Step 5. Deploying elasticsearch

```yaml
#!/bin/bash

NAMESPACE="logging"

echo "Creating service..."
helm upgrade --install elasticsearch helm/ELK/elasticsearch -f helm/ELK/elasticsearch/my-values.yaml --namespace $NAMESPACE
```

**Step 6**: After deploying elasticsearch, look into `elasticsearch-credentials` to get elasticsearch’s username and password

```bash
kubectl get secrets elasticsearch-credentials -o json
```

You would see password at data field (it is encoded with base64).

```bash
"data": {
  "password": "QXNpZEQ2MXo0a2RINHlncQ==", # AsidD61z4kdH4ygq
  "username": "ZWxhc3RpYw==" # elastic
},
```

or more elegant command:

```bash
kubectl get secret elasticsearch-credentials -n logging -o jsonpath='{.data.password}' | base64 --decode
```

# Kibana

Step 1: Pull Kibana chart. We would use version `8.5.1`

```bash
helm pull elastic/kibana --version 8.5.1
tar -xzf kibana-8.5.1.tgz
```

Step 2: Edit Kibana Configuration file

2.1. Since we set `fullnameOverride = elasticsearch` , change these variable to match its names too! (You can get the name by `kubectl get secrets -n logging` )

```yaml
elasticsearchHosts: "https://elasticsearch:9200"
elasticsearchCertificateSecret: elasticsearch-certs
elasticsearchCertificateAuthoritiesFile: ca.crt
elasticsearchCredentialSecret: elasticsearch-credentials
```

2.2. Computational resource. We should keep the resources unchanged

```yaml
resources:
  requests:
    cpu: "1000m"
    memory: "2Gi"
  limits:
    cpu: "1000m"
    memory: "2Gi"
```

2.3. For clarity, we set `fullnameOverride: "kibana"` 

Step 3: Deploying

```yaml
#!/bin/bash

NAMESPACE="logging"

echo "Creating service..."
helm upgrade --install kibana helm/ELK/kibana -f helm/ELK/kibana/my-values.yaml --namespace $NAMESPACE
```

Step 4: Port-forwarding service `kibana` to access the UI

```bash
kubectl port-forward svc/kibana 5601:5601
```

Use elasticsearch’s username (elastic) and password to access to Kibana.

# Filebeat

Step 1: Pull Filebeat chart. We would use version `8.5.1`

```bash
helm pull elastic/filebeat --version 8.5.1
tar -xzf kibana-8.5.1.tgz
```

Step 2: Edit Configuration file

2.1 Change every `elasticsearch-master` to `elasticsearch`

That all you need~

Step 3. Deploying

```bash
#!/bin/bash

NAMESPACE="logging"

echo "Creating service..."
helm upgrade --install filebeat helm/ELK/filebeat --namespace $NAMESPACE
```

# Discussion

1. ELasticsearch is a database. To visualize it, we must use Kibana.