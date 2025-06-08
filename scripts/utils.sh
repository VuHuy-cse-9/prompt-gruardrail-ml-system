ensure_namespace() {
  local ns="$1"
  if ! kubectl get namespace "$ns" > /dev/null 2>&1; then
    echo "Creating namespace: $ns"
    kubectl create namespace "$ns"
  else
    echo "Namespace '$ns' already exists."
  fi
}

service_exists() {
  local name="$1"
  local namespace="$2"
  kubectl get svc "$name" -n "$namespace" > /dev/null 2>&1
}