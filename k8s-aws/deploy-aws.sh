#!/bin/bash

# ===========================================
# Script de despliegue en AWS EKS
# Fintech Application
# ===========================================

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Variables
REGION="us-east-1"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}   Despliegue en EKS - Fintech App      ${NC}"
echo -e "${BLUE}=========================================${NC}"

# Verificar conexión al cluster
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}❌ No se puede conectar al cluster EKS${NC}"
    echo "Ejecutar: aws eks update-kubeconfig --region $REGION --name fintech-cluster"
    exit 1
fi

echo -e "${GREEN}✅ Conectado al cluster EKS${NC}"

K8S_DIR="$(dirname "$0")"

# Actualizar imágenes en los deployments con las URIs de ECR
echo -e "${YELLOW}🔄 Actualizando URIs de imágenes en deployments...${NC}"

# Backend
sed -i "s|image: fintech-backend:latest|image: ${ECR_REGISTRY}/fintech-backend:latest|g" "$K8S_DIR/backend-deployment.yaml"

# Frontend
sed -i "s|image: fintech-frontend:latest|image: ${ECR_REGISTRY}/fintech-frontend:latest|g" "$K8S_DIR/frontend-deployment.yaml"

# 1. Crear namespace
echo -e "${YELLOW}📦 Creando namespace...${NC}"
kubectl apply -f "$K8S_DIR/namespace.yaml"

# 2. Crear StorageClass para EBS
echo -e "${YELLOW}💾 Creando StorageClass EBS...${NC}"
kubectl apply -f "$K8S_DIR/storage-class.yaml"

# 3. Aplicar secrets y configmaps
echo -e "${YELLOW}🔐 Aplicando secrets y configmaps...${NC}"
kubectl apply -f "$K8S_DIR/postgres-secret.yaml"
kubectl apply -f "$K8S_DIR/postgres-configmap.yaml"
kubectl apply -f "$K8S_DIR/backend-configmap.yaml"
kubectl apply -f "$K8S_DIR/frontend-configmap.yaml"

# 4. Crear PVC
echo -e "${YELLOW}💾 Creando PersistentVolumeClaim...${NC}"
kubectl apply -f "$K8S_DIR/postgres-pvc.yaml"

# 5. Desplegar PostgreSQL
echo -e "${YELLOW}🐘 Desplegando PostgreSQL...${NC}"
kubectl apply -f "$K8S_DIR/postgres-deployment.yaml"
kubectl apply -f "$K8S_DIR/postgres-service.yaml"

# Esperar a PostgreSQL
echo -e "${YELLOW}⏳ Esperando a que PostgreSQL esté listo...${NC}"
kubectl wait --for=condition=ready pod -l app=postgres -n fintech --timeout=300s

# 6. Desplegar Backend
echo -e "${YELLOW}⚙️ Desplegando Backend...${NC}"
kubectl apply -f "$K8S_DIR/backend-deployment.yaml"
kubectl apply -f "$K8S_DIR/backend-service.yaml"

# Esperar a Backend
echo -e "${YELLOW}⏳ Esperando a que Backend esté listo...${NC}"
kubectl wait --for=condition=ready pod -l app=backend -n fintech --timeout=300s

# 7. Desplegar Frontend
echo -e "${YELLOW}🎨 Desplegando Frontend...${NC}"
kubectl apply -f "$K8S_DIR/frontend-deployment.yaml"
kubectl apply -f "$K8S_DIR/frontend-service.yaml"

# 8. Aplicar recursos adicionales
echo -e "${YELLOW}📊 Aplicando HPA y Resource Quotas...${NC}"
kubectl apply -f "$K8S_DIR/resource-quota.yaml"
kubectl apply -f "$K8S_DIR/hpa.yaml"

# 9. Aplicar Network Policies
echo -e "${YELLOW}🔒 Aplicando Network Policies...${NC}"
kubectl apply -f "$K8S_DIR/network-policy.yaml"

# 10. Aplicar Ingress ALB
echo -e "${YELLOW}🌐 Aplicando Ingress ALB...${NC}"
kubectl apply -f "$K8S_DIR/ingress-alb.yaml"

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}✅ Despliegue completado exitosamente!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""

# Mostrar estado
echo -e "${YELLOW}📋 Estado de los pods:${NC}"
kubectl get pods -n fintech

echo ""
echo -e "${YELLOW}🔗 Servicios:${NC}"
kubectl get services -n fintech

echo ""
echo -e "${YELLOW}🌐 Ingress:${NC}"
kubectl get ingress -n fintech

# Obtener URL del ALB
echo ""
echo -e "${YELLOW}⏳ Esperando URL del ALB (puede tomar unos minutos)...${NC}"
sleep 30

ALB_URL=$(kubectl get ingress fintech-ingress -n fintech -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)

if [ -n "$ALB_URL" ]; then
    echo ""
    echo -e "${GREEN}=========================================${NC}"
    echo -e "${GREEN}🌍 Aplicación disponible en:${NC}"
    echo -e "${GREEN}   http://${ALB_URL}${NC}"
    echo -e "${GREEN}=========================================${NC}"
else
    echo -e "${YELLOW}⚠️ ALB aún no tiene URL asignada. Verificar con:${NC}"
    echo "   kubectl get ingress -n fintech -w"
fi

echo ""
echo -e "${YELLOW}📝 Comandos útiles:${NC}"
echo "   kubectl get all -n fintech"
echo "   kubectl logs -f deployment/backend -n fintech"
echo "   kubectl logs -f deployment/frontend -n fintech"
echo "   kubectl get ingress -n fintech -w"
