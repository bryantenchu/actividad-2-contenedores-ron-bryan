#!/bin/bash

# ===========================================
# Script para eliminar recursos de AWS
# Fintech Application
# ===========================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

CLUSTER_NAME="fintech-cluster"
REGION="us-east-1"

echo -e "${RED}=========================================${NC}"
echo -e "${RED}   ⚠️  ELIMINACIÓN DE RECURSOS AWS      ${NC}"
echo -e "${RED}=========================================${NC}"
echo ""
echo -e "${YELLOW}Esto eliminará:${NC}"
echo "  - Todos los recursos de Kubernetes en el namespace fintech"
echo "  - El cluster EKS completo"
echo "  - Los volúmenes EBS asociados"
echo ""
read -p "¿Estás seguro? (escribir 'yes' para confirmar): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Cancelado"
    exit 0
fi

K8S_DIR="$(dirname "$0")"

# Eliminar recursos de Kubernetes
echo -e "${YELLOW}🗑️ Eliminando recursos de Kubernetes...${NC}"

kubectl delete -f "$K8S_DIR/ingress-alb.yaml" --ignore-not-found=true
kubectl delete -f "$K8S_DIR/network-policy.yaml" --ignore-not-found=true
kubectl delete -f "$K8S_DIR/hpa.yaml" --ignore-not-found=true
kubectl delete -f "$K8S_DIR/resource-quota.yaml" --ignore-not-found=true
kubectl delete -f "$K8S_DIR/frontend-service.yaml" --ignore-not-found=true
kubectl delete -f "$K8S_DIR/frontend-deployment.yaml" --ignore-not-found=true
kubectl delete -f "$K8S_DIR/backend-service.yaml" --ignore-not-found=true
kubectl delete -f "$K8S_DIR/backend-deployment.yaml" --ignore-not-found=true
kubectl delete -f "$K8S_DIR/postgres-service.yaml" --ignore-not-found=true
kubectl delete -f "$K8S_DIR/postgres-deployment.yaml" --ignore-not-found=true
kubectl delete -f "$K8S_DIR/postgres-pvc.yaml" --ignore-not-found=true
kubectl delete -f "$K8S_DIR/storage-class.yaml" --ignore-not-found=true
kubectl delete -f "$K8S_DIR/frontend-configmap.yaml" --ignore-not-found=true
kubectl delete -f "$K8S_DIR/backend-configmap.yaml" --ignore-not-found=true
kubectl delete -f "$K8S_DIR/postgres-configmap.yaml" --ignore-not-found=true
kubectl delete -f "$K8S_DIR/postgres-secret.yaml" --ignore-not-found=true
kubectl delete -f "$K8S_DIR/namespace.yaml" --ignore-not-found=true

echo -e "${GREEN}✅ Recursos de Kubernetes eliminados${NC}"

# Preguntar si eliminar el cluster
echo ""
read -p "¿Eliminar también el cluster EKS? (escribir 'yes' para confirmar): " confirm_cluster

if [ "$confirm_cluster" == "yes" ]; then
    echo -e "${YELLOW}🗑️ Eliminando cluster EKS (esto puede tomar 10-15 minutos)...${NC}"
    eksctl delete cluster --name $CLUSTER_NAME --region $REGION
    echo -e "${GREEN}✅ Cluster EKS eliminado${NC}"
fi

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}✅ Limpieza completada${NC}"
echo -e "${GREEN}=========================================${NC}"
