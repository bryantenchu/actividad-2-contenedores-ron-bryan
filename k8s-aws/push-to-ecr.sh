#!/bin/bash

# ===========================================
# Script para subir imágenes a ECR
# Fintech Application
# ===========================================

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Variables - MODIFICAR SEGÚN TU CONFIGURACIÓN
REGION="us-east-1"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

# Directorio raíz del proyecto
PROJECT_DIR="$(dirname "$0")/.."

echo -e "${YELLOW}🐳 Subiendo imágenes a Amazon ECR...${NC}"
echo -e "${YELLOW}   Registry: ${ECR_REGISTRY}${NC}"

# Login a ECR
echo -e "${YELLOW}🔐 Autenticando con ECR...${NC}"
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_REGISTRY

# Crear repositorios si no existen
echo -e "${YELLOW}📦 Creando repositorios ECR...${NC}"

aws ecr create-repository \
    --repository-name fintech-backend \
    --region $REGION 2>/dev/null || echo "Repositorio fintech-backend ya existe"

aws ecr create-repository \
    --repository-name fintech-frontend \
    --region $REGION 2>/dev/null || echo "Repositorio fintech-frontend ya existe"

# Construir y subir Backend
echo -e "${YELLOW}⚙️ Construyendo imagen del Backend...${NC}"
docker build -t fintech-backend:latest "$PROJECT_DIR/fintech-back-docker"

echo -e "${YELLOW}📤 Subiendo Backend a ECR...${NC}"
docker tag fintech-backend:latest ${ECR_REGISTRY}/fintech-backend:latest
docker push ${ECR_REGISTRY}/fintech-backend:latest

# Construir y subir Frontend
echo -e "${YELLOW}🎨 Construyendo imagen del Frontend...${NC}"
docker build -t fintech-frontend:latest "$PROJECT_DIR/fintech-front-docker"

echo -e "${YELLOW}📤 Subiendo Frontend a ECR...${NC}"
docker tag fintech-frontend:latest ${ECR_REGISTRY}/fintech-frontend:latest
docker push ${ECR_REGISTRY}/fintech-frontend:latest

echo ""
echo -e "${GREEN}✅ Imágenes subidas exitosamente a ECR${NC}"
echo ""
echo -e "${YELLOW}📝 URIs de las imágenes:${NC}"
echo "   Backend:  ${ECR_REGISTRY}/fintech-backend:latest"
echo "   Frontend: ${ECR_REGISTRY}/fintech-frontend:latest"
echo ""
echo -e "${YELLOW}⚠️ IMPORTANTE: Actualiza los deployments con estas URIs${NC}"
