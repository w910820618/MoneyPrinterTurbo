# Docker Deployment Guide

This guide explains how to deploy MoneyPrinterTurbo using Docker with proper security practices for API keys.

## 🚨 Security First

**Never put API keys directly in Dockerfile or docker-compose.yml files!** This would expose your keys in version control and create security risks.

## 🐳 Docker Deployment Methods

### Method 1: Using .env file (Recommended)

#### Step 1: Create Environment File

```bash
# Copy the environment template
cp env.example .env

# Edit the .env file with your actual API keys
nano .env
```

Your `.env` file should look like this:
```bash
# Pexels API Keys (comma-separated for multiple keys)
PEXELS_API_KEYS=your_actual_pexels_key_here

# Pixabay API Keys (comma-separated for multiple keys)
PIXABAY_API_KEYS=your_actual_pixabay_key_here

# OpenAI API Key
OPENAI_API_KEY=your_actual_openai_key_here
```

#### Step 2: Deploy with docker-compose

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Method 2: Using Environment Variables Directly

#### Option A: Export in shell

```bash
# Set environment variables
export PEXELS_API_KEYS="your_pexels_key"
export PIXABAY_API_KEYS="your_pixabay_key"
export OPENAI_API_KEY="your_openai_key"

# Start services
docker-compose up -d
```

#### Option B: Inline with docker-compose

```bash
# Start with inline environment variables
PEXELS_API_KEYS="your_pexels_key" \
PIXABAY_API_KEYS="your_pixabay_key" \
OPENAI_API_KEY="your_openai_key" \
docker-compose up -d
```

### Method 3: Using docker run

```bash
# Build the image
docker build -t moneyprinterturbo .

# Run with environment variables
docker run -d \
  --name moneyprinterturbo-api \
  -p 8080:8080 \
  -e PEXELS_API_KEYS="your_pexels_key" \
  -e PIXABAY_API_KEYS="your_pixabay_key" \
  -e OPENAI_API_KEY="your_openai_key" \
  -v $(pwd):/MoneyPrinterTurbo \
  moneyprinterturbo \
  python3 main.py

# Run web UI
docker run -d \
  --name moneyprinterturbo-webui \
  -p 8501:8501 \
  -e PEXELS_API_KEYS="your_pexels_key" \
  -e PIXABAY_API_KEYS="your_pixabay_key" \
  -e OPENAI_API_KEY="your_openai_key" \
  -v $(pwd):/MoneyPrinterTurbo \
  moneyprinterturbo \
  streamlit run ./webui/Main.py --browser.serverAddress=127.0.0.1 --server.enableCORS=True --browser.gatherUsageStats=False
```

## 🔧 Production Deployment

### Using Docker Secrets (Docker Swarm)

```yaml
# docker-compose.prod.yml
version: '3.8'
services:
  webui:
    image: moneyprinterturbo
    ports:
      - "8501:8501"
    secrets:
      - pexels_api_keys
      - pixabay_api_keys
      - openai_api_key
    environment:
      - PEXELS_API_KEYS_FILE=/run/secrets/pexels_api_keys
      - PIXABAY_API_KEYS_FILE=/run/secrets/pixabay_api_keys
      - OPENAI_API_KEY_FILE=/run/secrets/openai_api_key

secrets:
  pexels_api_keys:
    external: true
  pixabay_api_keys:
    external: true
  openai_api_key:
    external: true
```

Create secrets:
```bash
echo "your_pexels_key" | docker secret create pexels_api_keys -
echo "your_pixabay_key" | docker secret create pixabay_api_keys -
echo "your_openai_key" | docker secret create openai_api_key -
```

### Using Kubernetes Secrets

```yaml
# k8s-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: moneyprinterturbo-secrets
type: Opaque
data:
  pexels-api-keys: <base64-encoded-pexels-key>
  pixabay-api-keys: <base64-encoded-pixabay-key>
  openai-api-key: <base64-encoded-openai-key>
---
# k8s-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: moneyprinterturbo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: moneyprinterturbo
  template:
    metadata:
      labels:
        app: moneyprinterturbo
    spec:
      containers:
      - name: moneyprinterturbo
        image: moneyprinterturbo:latest
        ports:
        - containerPort: 8080
        env:
        - name: PEXELS_API_KEYS
          valueFrom:
            secretKeyRef:
              name: moneyprinterturbo-secrets
              key: pexels-api-keys
        - name: PIXABAY_API_KEYS
          valueFrom:
            secretKeyRef:
              name: moneyprinterturbo-secrets
              key: pixabay-api-keys
        - name: OPENAI_API_KEY
          valueFrom:
            secretKeyRef:
              name: moneyprinterturbo-secrets
              key: openai-api-key
```

## 🛠️ Custom Dockerfile (Optional)

If you need to customize the Dockerfile, here's an example:

```dockerfile
FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    imagemagick \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /MoneyPrinterTurbo

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create non-root user for security
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /MoneyPrinterTurbo
USER appuser

# Expose ports
EXPOSE 8080 8501

# Default command (can be overridden)
CMD ["python3", "main.py"]
```

## 🔍 Verification

### Check if environment variables are loaded

```bash
# Check environment variables in running container
docker exec moneyprinterturbo-api env | grep -E "(PEXELS|PIXABAY|OPENAI)"

# Check logs for configuration loading
docker-compose logs api | grep -i "environment\|config"
```

### Test API endpoints

```bash
# Test API health
curl http://localhost:8080/ping

# Test web UI
curl http://localhost:8501
```

## 🚨 Security Best Practices

### 1. Never commit API keys
```bash
# Ensure .env is in .gitignore
echo ".env" >> .gitignore
git add .gitignore
git commit -m "Add .env to gitignore"
```

### 2. Use different keys for different environments
```bash
# Development
PEXELS_API_KEYS=dev_key1,dev_key2
PIXABAY_API_KEYS=dev_key1,dev_key2
OPENAI_API_KEY=dev_openai_key

# Production
PEXELS_API_KEYS=prod_key1,prod_key2,prod_key3
PIXABAY_API_KEYS=prod_key1,prod_key2,prod_key3
OPENAI_API_KEY=prod_openai_key
```

### 3. Rotate keys regularly
```bash
# Example rotation schedule
# Month 1: key1,key2,key3
# Month 2: key2,key3,key4
# Month 3: key3,key4,key5
```

### 4. Use secrets management in production
- Docker Swarm secrets
- Kubernetes secrets
- HashiCorp Vault
- AWS Secrets Manager
- Azure Key Vault

## 🔧 Troubleshooting

### Environment variables not working

```bash
# Check if .env file exists
ls -la .env

# Check environment variables in container
docker exec moneyprinterturbo-api printenv | grep -E "(PEXELS|PIXABAY|OPENAI)"

# Check docker-compose configuration
docker-compose config
```

### Container not starting

```bash
# Check container logs
docker-compose logs api
docker-compose logs webui

# Check container status
docker-compose ps
```

### Permission issues

```bash
# Fix file permissions
chmod 600 .env
chown $USER:$USER .env
```

## 📋 Complete Deployment Checklist

- [ ] Copy `env.example` to `.env`
- [ ] Add actual API keys to `.env`
- [ ] Ensure `.env` is in `.gitignore`
- [ ] Test with `docker-compose up -d`
- [ ] Verify services are running: `docker-compose ps`
- [ ] Check logs: `docker-compose logs -f`
- [ ] Test web UI: http://localhost:8501
- [ ] Test API: http://localhost:8080/docs
- [ ] Verify environment variables: `docker exec moneyprinterturbo-api env | grep API`

## 🎯 Quick Start Commands

```bash
# 1. Setup environment
cp env.example .env
nano .env  # Add your API keys

# 2. Deploy
docker-compose up -d

# 3. Check status
docker-compose ps
docker-compose logs -f

# 4. Access services
# Web UI: http://localhost:8501
# API Docs: http://localhost:8080/docs
``` 