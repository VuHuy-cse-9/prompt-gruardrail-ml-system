# Serving Service

## 1. Start on local machine
```
uvicorn app:app --workers 4 --host 0.0.0.0  --port 12345
```

## 2. Start with Docker
Step 1: Build docker image
```
docker build -t docker.io/vnminhhuy2001/prompt-guardrail-service:0.0.1 .
```

Step 2: Start service
```
docker run -p 12345:8000 --name docker.io/vnminhhuy2001/prompt-guardrail-service -d prompt-guardrail-service:0.0.1
```