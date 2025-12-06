# Kubernetes en AWS EKS - Fintech Application

Este directorio contiene los manifiestos de Kubernetes optimizados para **Amazon EKS**.

## 📁 Estructura de Archivos

```
k8s-aws/
├── namespace.yaml           # Namespace fintech
├── storage-class.yaml       # StorageClass para EBS gp3
├── postgres-secret.yaml     # Credenciales PostgreSQL
├── postgres-configmap.yaml  # Script de inicialización
├── postgres-pvc.yaml        # PersistentVolumeClaim (EBS)
├── postgres-deployment.yaml # Deployment PostgreSQL
├── postgres-service.yaml    # Service PostgreSQL
├── backend-configmap.yaml   # Configuración Backend
├── backend-deployment.yaml  # Deployment Backend
├── backend-service.yaml     # Service Backend
├── frontend-configmap.yaml  # Configuración Frontend
├── frontend-deployment.yaml # Deployment Frontend
├── frontend-service.yaml    # Service Frontend
├── ingress-alb.yaml         # Ingress con AWS ALB
├── hpa.yaml                 # Horizontal Pod Autoscaler
├── network-policy.yaml      # Network Policies
├── resource-quota.yaml      # Resource Quotas
├── create-eks-cluster.sh    # Script crear cluster EKS
├── push-to-ecr.sh           # Script subir imágenes a ECR
├── deploy-aws.sh            # Script de despliegue
└── destroy-aws.sh           # Script de eliminación
```

## 🚀 Requisitos Previos

### 1. Herramientas necesarias
```bash
# AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Docker
sudo apt-get install docker.io
```

### 2. Configurar AWS CLI
```bash
aws configure
# AWS Access Key ID: <tu-access-key>
# AWS Secret Access Key: <tu-secret-key>
# Default region name: us-east-1
# Default output format: json
```

## 📋 Despliegue Paso a Paso

### Paso 1: Crear Cluster EKS
```bash
cd k8s-aws
chmod +x *.sh
./create-eks-cluster.sh
```

Este script:
- ✅ Crea un cluster EKS con nodos t3.medium
- ✅ Instala AWS Load Balancer Controller
- ✅ Instala EBS CSI Driver para almacenamiento persistente
- ✅ Configura OIDC para IAM Roles

### Paso 2: Subir Imágenes a ECR
```bash
./push-to-ecr.sh
```

Este script:
- ✅ Crea repositorios en ECR
- ✅ Construye las imágenes Docker
- ✅ Sube las imágenes a ECR

### Paso 3: Desplegar la Aplicación
```bash
./deploy-aws.sh
```

Este script:
- ✅ Aplica todos los manifiestos de Kubernetes
- ✅ Actualiza las URIs de las imágenes automáticamente
- ✅ Muestra la URL del ALB cuando esté disponible

## 🌐 Acceso a la Aplicación

Después del despliegue, obtén la URL del ALB:

```bash
kubectl get ingress -n fintech
```

La aplicación estará disponible en:
```
http://<alb-dns-name>
```

## 🏗️ Arquitectura en AWS

```
┌─────────────────────────────────────────────────────────────────────────┐
│                              AWS Cloud                                   │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   ┌─────────────────────────────────────────────────────────────────┐   │
│   │                        Amazon EKS                                │   │
│   ├─────────────────────────────────────────────────────────────────┤   │
│   │                                                                  │   │
│   │  ┌──────────────┐                                               │   │
│   │  │  Application │    ┌─────────────────────────────────────┐   │   │
│   │  │  Load        │    │        Namespace: fintech            │   │   │
│   │  │  Balancer    │    │                                      │   │   │
│   │  │  (ALB)       │    │  ┌──────────┐    ┌──────────┐       │   │   │
│   │  └──────┬───────┘    │  │ Frontend │    │ Backend  │       │   │   │
│   │         │            │  │ (2 pods) │───▶│ (2 pods) │       │   │   │
│   │         │            │  └──────────┘    └────┬─────┘       │   │   │
│   │         │            │                       │              │   │   │
│   │         │            │                 ┌─────▼─────┐       │   │   │
│   │         ▼            │                 │ PostgreSQL│       │   │   │
│   │  ┌──────────────┐    │                 │  (1 pod)  │       │   │   │
│   │  │   Ingress    │────│                 └─────┬─────┘       │   │   │
│   │  │   ALB        │    │                       │              │   │   │
│   │  └──────────────┘    └───────────────────────│──────────────┘   │   │
│   │                                              │                   │   │
│   └──────────────────────────────────────────────│───────────────────┘   │
│                                                  │                       │
│   ┌──────────────────────────────────────────────▼───────────────────┐   │
│   │                        Amazon EBS (gp3)                          │   │
│   │                        10GB - PostgreSQL Data                    │   │
│   └──────────────────────────────────────────────────────────────────┘   │
│                                                                          │
│   ┌──────────────────────────────────────────────────────────────────┐   │
│   │                        Amazon ECR                                 │   │
│   │   - fintech-backend:latest                                       │   │
│   │   - fintech-frontend:latest                                      │   │
│   └──────────────────────────────────────────────────────────────────┘   │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

## 📊 Servicios AWS Utilizados

| Servicio | Uso | Costo Estimado |
|----------|-----|----------------|
| **EKS** | Cluster Kubernetes | ~$0.10/hora |
| **EC2** | Worker Nodes (t3.medium x2) | ~$0.08/hora |
| **EBS** | Almacenamiento PostgreSQL (gp3) | ~$0.08/GB/mes |
| **ALB** | Load Balancer | ~$0.02/hora |
| **ECR** | Container Registry | ~$0.10/GB/mes |

**Costo estimado total**: ~$150-200/mes (con 2 nodos t3.medium)

## 📝 Comandos Útiles

```bash
# Ver estado del cluster
kubectl get nodes
kubectl get all -n fintech

# Ver pods
kubectl get pods -n fintech -o wide

# Ver logs
kubectl logs -f deployment/backend -n fintech
kubectl logs -f deployment/frontend -n fintech
kubectl logs -f deployment/postgres -n fintech

# Describir recursos
kubectl describe pod <pod-name> -n fintech
kubectl describe ingress fintech-ingress -n fintech

# Ver eventos
kubectl get events -n fintech --sort-by='.lastTimestamp'

# Ver HPA
kubectl get hpa -n fintech

# Port-forward para debug
kubectl port-forward service/backend 3001:3000 -n fintech
kubectl port-forward service/frontend 3000:3000 -n fintech

# Escalar manualmente
kubectl scale deployment backend --replicas=3 -n fintech

# Ver URL del ALB
kubectl get ingress -n fintech -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}'
```

## 🔒 Seguridad

### Implementado:
- ✅ Secrets de Kubernetes para credenciales
- ✅ Network Policies para segmentación de red
- ✅ Resource Quotas para limitar consumo
- ✅ EBS encriptado por defecto
- ✅ IAM Roles para Service Accounts (IRSA)

### Recomendado para Producción:
- [ ] Usar AWS Secrets Manager o Vault
- [ ] Habilitar HTTPS con certificado ACM
- [ ] Configurar WAF en el ALB
- [ ] Habilitar CloudWatch Logs
- [ ] Configurar alertas con CloudWatch Alarms
- [ ] Implementar backup de PostgreSQL con AWS Backup

## 🔐 Habilitar HTTPS (Opcional)

1. Crear certificado en ACM:
```bash
aws acm request-certificate \
    --domain-name fintech.tudominio.com \
    --validation-method DNS
```

2. Actualizar `ingress-alb.yaml`:
```yaml
annotations:
  alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS": 443}]'
  alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:region:account:certificate/xxx
  alb.ingress.kubernetes.io/ssl-redirect: "443"
```

## 🗑️ Limpieza

```bash
# Eliminar aplicación y cluster
./destroy-aws.sh

# O eliminar solo la aplicación (mantener cluster)
kubectl delete namespace fintech
```

## ⚠️ Notas Importantes

1. **Costos**: EKS genera costos por hora. Elimina el cluster cuando no lo uses.

2. **Región**: Los scripts usan `us-east-1` por defecto. Modifica según necesidad.

3. **Imágenes**: Asegúrate de que las imágenes estén en ECR antes de desplegar.

4. **PostgreSQL**: En producción, considera usar **Amazon RDS** en lugar de PostgreSQL en pods.

5. **Backups**: Configura backups automáticos para los volúmenes EBS.
