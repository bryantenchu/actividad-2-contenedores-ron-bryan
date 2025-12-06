#!/bin/bash

# ===========================================
# Script para crear cluster EKS en AWS
# Fintech Application
# ===========================================

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Variables - MODIFICAR SEGÚN TU CONFIGURACIÓN
CLUSTER_NAME="fintech-cluster"
REGION="us-east-1"
NODE_TYPE="t3.medium"
MIN_NODES=2
MAX_NODES=5
DESIRED_NODES=2

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}   Creación de Cluster EKS - Fintech    ${NC}"
echo -e "${BLUE}=========================================${NC}"

# Verificar AWS CLI
if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI no está instalado${NC}"
    echo "Instalar: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    exit 1
fi

# Verificar eksctl
if ! command -v eksctl &> /dev/null; then
    echo -e "${RED}❌ eksctl no está instalado${NC}"
    echo "Instalar: https://eksctl.io/installation/"
    exit 1
fi

# Verificar kubectl
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl no está instalado${NC}"
    exit 1
fi

# Verificar credenciales AWS
echo -e "${YELLOW}🔐 Verificando credenciales AWS...${NC}"
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}❌ Credenciales AWS no configuradas${NC}"
    echo "Ejecutar: aws configure"
    exit 1
fi

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo -e "${GREEN}✅ AWS Account: $AWS_ACCOUNT_ID${NC}"

# Crear cluster EKS
echo -e "${YELLOW}🚀 Creando cluster EKS (esto puede tomar 15-20 minutos)...${NC}"

eksctl create cluster \
    --name $CLUSTER_NAME \
    --region $REGION \
    --nodegroup-name fintech-nodes \
    --node-type $NODE_TYPE \
    --nodes $DESIRED_NODES \
    --nodes-min $MIN_NODES \
    --nodes-max $MAX_NODES \
    --managed \
    --with-oidc \
    --ssh-access \
    --ssh-public-key ~/.ssh/id_rsa.pub \
    --alb-ingress-access \
    --full-ecr-access

echo -e "${GREEN}✅ Cluster EKS creado exitosamente${NC}"

# Actualizar kubeconfig
echo -e "${YELLOW}📋 Actualizando kubeconfig...${NC}"
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME

# Instalar AWS Load Balancer Controller
echo -e "${YELLOW}⚙️ Instalando AWS Load Balancer Controller...${NC}"

# Crear IAM Policy para ALB Controller
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.6.0/docs/install/iam_policy.json

aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json 2>/dev/null || echo "Policy ya existe"

# Crear service account para ALB Controller
eksctl create iamserviceaccount \
    --cluster=$CLUSTER_NAME \
    --namespace=kube-system \
    --name=aws-load-balancer-controller \
    --role-name AmazonEKSLoadBalancerControllerRole \
    --attach-policy-arn=arn:aws:iam::${AWS_ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy \
    --approve \
    --override-existing-serviceaccounts

# Instalar ALB Controller con Helm
helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
    -n kube-system \
    --set clusterName=$CLUSTER_NAME \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller

# Instalar EBS CSI Driver
echo -e "${YELLOW}💾 Instalando EBS CSI Driver...${NC}"

eksctl create iamserviceaccount \
    --name ebs-csi-controller-sa \
    --namespace kube-system \
    --cluster $CLUSTER_NAME \
    --role-name AmazonEKS_EBS_CSI_DriverRole \
    --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
    --approve

eksctl create addon \
    --name aws-ebs-csi-driver \
    --cluster $CLUSTER_NAME \
    --service-account-role-arn arn:aws:iam::${AWS_ACCOUNT_ID}:role/AmazonEKS_EBS_CSI_DriverRole \
    --force

# Limpiar
rm -f iam_policy.json

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}✅ Cluster EKS listo!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo -e "${YELLOW}📝 Siguiente paso: Subir imágenes a ECR y desplegar la aplicación${NC}"
echo "   ./push-to-ecr.sh"
echo "   ./deploy-aws.sh"
