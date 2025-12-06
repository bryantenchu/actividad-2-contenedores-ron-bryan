# Kubernetes Manifests - Fintech Application

Este directorio contiene los manifiestos de Kubernetes para desplegar la aplicación Fintech.

## 📁 Estructura de Archivos

```
k8s/
├── namespace.yaml          # Namespace para aislar recursos
├── postgres-secret.yaml    # Credenciales de PostgreSQL
├── postgres-configmap.yaml # Script de inicialización de BD
├── postgres-pv.yaml        # PersistentVolume y PVC
├── postgres-deployment.yaml# Deployment de PostgreSQL
├── postgres-service.yaml   # Service de PostgreSQL
├── backend-configmap.yaml  # Configuración del backend
├── backend-deployment.yaml # Deployment del backend
├── backend-service.yaml    # Service del backend
├── frontend-configmap.yaml # Configuración del frontend
├── frontend-deployment.yaml# Deployment del frontend
├── frontend-service.yaml   # Service del frontend (NodePort)
├── ingress.yaml           # Ingress para routing externo
├── hpa.yaml               # Horizontal Pod Autoscaler
├── network-policy.yaml    # Políticas de red
├── resource-quota.yaml    # Límites de recursos
├── deploy.sh              # Script de despliegue
└── destroy.sh             # Script de eliminación
```

## 🚀 Requisitos Previos

1. **Kubernetes Cluster** (minikube, kind, k3s, o cloud provider)
2. **kubectl** instalado y configurado
3. **Docker** para construir las imágenes

## 📦 Construcción de Imágenes

Antes de desplegar, necesitas construir las imágenes Docker:

```bash
# Desde el directorio raíz del proyecto

# Construir imagen del backend
docker build -t fintech-backend:latest ./fintech-back-docker

# Construir imagen del frontend
docker build -t fintech-frontend:latest ./fintech-front-docker
```

### Para Minikube
Si usas Minikube, carga las imágenes al cluster:

```bash
# Usar el Docker daemon de Minikube
eval $(minikube docker-env)

# Reconstruir las imágenes
docker build -t fintech-backend:latest ./fintech-back-docker
docker build -t fintech-frontend:latest ./fintech-front-docker
```

### Para Kind
Si usas Kind:

```bash
# Construir y cargar imágenes
docker build -t fintech-backend:latest ./fintech-back-docker
docker build -t fintech-frontend:latest ./fintech-front-docker

kind load docker-image fintech-backend:latest
kind load docker-image fintech-frontend:latest
```

## 🎯 Despliegue

### Opción 1: Usar el script automatizado

```bash
cd k8s
chmod +x deploy.sh
./deploy.sh
```

### Opción 2: Despliegue manual paso a paso

```bash
# 1. Crear namespace
kubectl apply -f namespace.yaml

# 2. Crear secrets y configmaps
kubectl apply -f postgres-secret.yaml
kubectl apply -f postgres-configmap.yaml
kubectl apply -f backend-configmap.yaml
kubectl apply -f frontend-configmap.yaml

# 3. Crear storage
kubectl apply -f postgres-pv.yaml

# 4. Desplegar PostgreSQL
kubectl apply -f postgres-deployment.yaml
kubectl apply -f postgres-service.yaml

# 5. Esperar a PostgreSQL
kubectl wait --for=condition=ready pod -l app=postgres -n fintech --timeout=120s

# 6. Desplegar Backend
kubectl apply -f backend-deployment.yaml
kubectl apply -f backend-service.yaml

# 7. Desplegar Frontend
kubectl apply -f frontend-deployment.yaml
kubectl apply -f frontend-service.yaml

# 8. (Opcional) Aplicar recursos adicionales
kubectl apply -f resource-quota.yaml
kubectl apply -f hpa.yaml
kubectl apply -f network-policy.yaml
kubectl apply -f ingress.yaml
```

## 🌐 Acceso a la Aplicación

### NodePort (por defecto)
```bash
# Frontend
http://localhost:30000

# Si usas Minikube
minikube service frontend -n fintech
```

### Con Ingress
1. Agregar al archivo `/etc/hosts`:
   ```
   127.0.0.1 fintech.local
   ```

2. Habilitar Ingress en Minikube:
   ```bash
   minikube addons enable ingress
   ```

3. Acceder a: `http://fintech.local`

## 📊 Comandos Útiles

```bash
# Ver todos los recursos
kubectl get all -n fintech

# Ver pods
kubectl get pods -n fintech

# Ver logs del backend
kubectl logs -f deployment/backend -n fintech

# Ver logs del frontend
kubectl logs -f deployment/frontend -n fintech

# Ver logs de PostgreSQL
kubectl logs -f deployment/postgres -n fintech

# Describir un pod
kubectl describe pod <pod-name> -n fintech

# Ejecutar shell en un pod
kubectl exec -it <pod-name> -n fintech -- /bin/sh

# Port-forward para acceso directo
kubectl port-forward service/frontend 3000:3000 -n fintech
kubectl port-forward service/backend 3001:3000 -n fintech

# Ver HPA status
kubectl get hpa -n fintech

# Ver eventos
kubectl get events -n fintech --sort-by='.lastTimestamp'
```

## 🗑️ Limpieza

```bash
# Usar script
chmod +x destroy.sh
./destroy.sh

# O eliminar el namespace (elimina todo)
kubectl delete namespace fintech

# Eliminar PersistentVolume (manual, ya que está fuera del namespace)
kubectl delete pv postgres-pv
```

## 🔧 Arquitectura en Kubernetes

```
┌─────────────────────────────────────────────────────────────────┐
│                        Namespace: fintech                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────┐    ┌──────────────────┐                   │
│  │   Ingress        │────│  Frontend        │                   │
│  │   (fintech.local)│    │  Service:30000   │                   │
│  └──────────────────┘    │  (NodePort)      │                   │
│                          └────────┬─────────┘                   │
│                                   │                              │
│                          ┌────────▼─────────┐                   │
│                          │  Frontend Pods   │                   │
│                          │  (2 replicas)    │                   │
│                          │  React + Vite    │                   │
│                          └────────┬─────────┘                   │
│                                   │                              │
│                          ┌────────▼─────────┐                   │
│                          │  Backend         │                   │
│                          │  Service:3000    │                   │
│                          │  (ClusterIP)     │                   │
│                          └────────┬─────────┘                   │
│                                   │                              │
│                          ┌────────▼─────────┐                   │
│                          │  Backend Pods    │                   │
│                          │  (2 replicas)    │                   │
│                          │  NestJS          │                   │
│                          └────────┬─────────┘                   │
│                                   │                              │
│                          ┌────────▼─────────┐                   │
│                          │  PostgreSQL      │                   │
│                          │  Service:5432    │                   │
│                          │  (ClusterIP)     │                   │
│                          └────────┬─────────┘                   │
│                                   │                              │
│                          ┌────────▼─────────┐                   │
│                          │  PostgreSQL Pod  │                   │
│                          │  (1 replica)     │                   │
│                          │  + PVC           │                   │
│                          └──────────────────┘                   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## ⚠️ Notas Importantes

1. **Imágenes**: Los deployments usan `imagePullPolicy: IfNotPresent`. Asegúrate de que las imágenes estén disponibles localmente o cambiar a un registry.

2. **Producción**: Para producción, considera:
   - Usar un registry de imágenes (Docker Hub, ECR, GCR)
   - Configurar TLS en el Ingress
   - Usar Secrets encriptados (Sealed Secrets, Vault)
   - Configurar backups para PostgreSQL

3. **Recursos**: Los límites de recursos están configurados para desarrollo. Ajustar según necesidades de producción.
