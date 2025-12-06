#!/bin/bash

# ===========================================
# Script de despliegue para Kubernetes
# Fintech Application
# ===========================================

set -e

echo "🚀 Iniciando despliegue de Fintech en Kubernetes..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verificar que kubectl está instalado
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl no está instalado. Por favor instálalo primero.${NC}"
    exit 1
fi

# Verificar conexión al cluster
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}❌ No se puede conectar al cluster de Kubernetes.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Conexión al cluster verificada${NC}"

# Directorio de manifiestos
K8S_DIR="$(dirname "$0")"

# 1. Crear namespace
echo -e "${YELLOW}📦 Creando namespace...${NC}"
kubectl apply -f "$K8S_DIR/namespace.yaml"

# 2. Aplicar secrets y configmaps
echo -e "${YELLOW}🔐 Aplicando secrets y configmaps...${NC}"
kubectl apply -f "$K8S_DIR/postgres-secret.yaml"
kubectl apply -f "$K8S_DIR/postgres-configmap.yaml"
kubectl apply -f "$K8S_DIR/backend-configmap.yaml"
kubectl apply -f "$K8S_DIR/frontend-configmap.yaml"

# 3. Crear persistent volumes
echo -e "${YELLOW}💾 Creando persistent volumes...${NC}"
kubectl apply -f "$K8S_DIR/postgres-pv.yaml"

# 4. Desplegar PostgreSQL
echo -e "${YELLOW}🐘 Desplegando PostgreSQL...${NC}"
kubectl apply -f "$K8S_DIR/postgres-deployment.yaml"
kubectl apply -f "$K8S_DIR/postgres-service.yaml"

# Esperar a que PostgreSQL esté listo
echo -e "${YELLOW}⏳ Esperando a que PostgreSQL esté listo...${NC}"
kubectl wait --for=condition=ready pod -l app=postgres -n fintech --timeout=120s

# 5. Desplegar Backend
echo -e "${YELLOW}⚙️ Desplegando Backend...${NC}"
kubectl apply -f "$K8S_DIR/backend-deployment.yaml"
kubectl apply -f "$K8S_DIR/backend-service.yaml"

# Esperar a que Backend esté listo
echo -e "${YELLOW}⏳ Esperando a que Backend esté listo...${NC}"
kubectl wait --for=condition=ready pod -l app=backend -n fintech --timeout=180s

# 6. Desplegar Frontend
echo -e "${YELLOW}🎨 Desplegando Frontend...${NC}"
kubectl apply -f "$K8S_DIR/frontend-deployment.yaml"
kubectl apply -f "$K8S_DIR/frontend-service.yaml"

# 7. Aplicar recursos opcionales
echo -e "${YELLOW}📊 Aplicando HPA y Resource Quotas...${NC}"
kubectl apply -f "$K8S_DIR/resource-quota.yaml"
kubectl apply -f "$K8S_DIR/hpa.yaml"

# 8. Aplicar Network Policies (opcional)
echo -e "${YELLOW}🔒 Aplicando Network Policies...${NC}"
kubectl apply -f "$K8S_DIR/network-policy.yaml"

# 9. Aplicar Ingress (si tienes ingress controller)
echo -e "${YELLOW}🌐 Aplicando Ingress...${NC}"
kubectl apply -f "$K8S_DIR/ingress.yaml" 2>/dev/null || echo -e "${YELLOW}⚠️ Ingress no aplicado (puede requerir ingress controller)${NC}"

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
echo -e "${YELLOW}📝 Para acceder a la aplicación:${NC}"
echo "   Frontend (NodePort): http://localhost:30000"
echo "   Backend (interno): http://backend:3000"
echo ""
echo -e "${YELLOW}📝 Comandos útiles:${NC}"
echo "   kubectl logs -f deployment/backend -n fintech"
echo "   kubectl logs -f deployment/frontend -n fintech"
echo "   kubectl get all -n fintech"
