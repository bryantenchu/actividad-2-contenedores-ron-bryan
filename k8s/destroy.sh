#!/bin/bash

# ===========================================
# Script para eliminar todos los recursos
# Fintech Application
# ===========================================

set -e

echo "🗑️ Eliminando recursos de Fintech..."

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

K8S_DIR="$(dirname "$0")"

echo -e "${YELLOW}Eliminando todos los recursos del namespace fintech...${NC}"

# Eliminar en orden inverso
kubectl delete -f "$K8S_DIR/ingress.yaml" --ignore-not-found=true
kubectl delete -f "$K8S_DIR/network-policy.yaml" --ignore-not-found=true
kubectl delete -f "$K8S_DIR/hpa.yaml" --ignore-not-found=true
kubectl delete -f "$K8S_DIR/resource-quota.yaml" --ignore-not-found=true
kubectl delete -f "$K8S_DIR/frontend-service.yaml" --ignore-not-found=true
kubectl delete -f "$K8S_DIR/frontend-deployment.yaml" --ignore-not-found=true
kubectl delete -f "$K8S_DIR/backend-service.yaml" --ignore-not-found=true
kubectl delete -f "$K8S_DIR/backend-deployment.yaml" --ignore-not-found=true
kubectl delete -f "$K8S_DIR/postgres-service.yaml" --ignore-not-found=true
kubectl delete -f "$K8S_DIR/postgres-deployment.yaml" --ignore-not-found=true
kubectl delete -f "$K8S_DIR/postgres-pv.yaml" --ignore-not-found=true
kubectl delete -f "$K8S_DIR/frontend-configmap.yaml" --ignore-not-found=true
kubectl delete -f "$K8S_DIR/backend-configmap.yaml" --ignore-not-found=true
kubectl delete -f "$K8S_DIR/postgres-configmap.yaml" --ignore-not-found=true
kubectl delete -f "$K8S_DIR/postgres-secret.yaml" --ignore-not-found=true
kubectl delete -f "$K8S_DIR/namespace.yaml" --ignore-not-found=true

echo -e "${GREEN}✅ Todos los recursos han sido eliminados${NC}"
