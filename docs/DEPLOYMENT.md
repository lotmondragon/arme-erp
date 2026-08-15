# Guía de Despliegue - ARME-ERP

## Entornos

### Desarrollo Local
- Backend: http://localhost:5070
- Auth: http://localhost:5080
- Frontend vía Docker Compose (nginx): http://localhost:8080
- Frontend vía `ng serve` (sin Docker): http://localhost:4200
- PostgreSQL: localhost:5432

### Staging/Producción
- Configurar según infraestructura

---

## Despliegue con Docker Compose

### 1. Preparación

```bash
# Clonar repositorio
git clone <repo-url>
cd arme-erp

# Verificar que Docker está corriendo
docker --version
docker-compose --version
```

### 2. Configuración

Editar `docker-compose.yml` si es necesario:
- Cambiar contraseñas de PostgreSQL
- Ajustar puertos si hay conflictos
- Configurar variables de entorno

### 3. Despliegue

```bash
# Build y start
docker-compose up --build -d

# Verificar servicios
docker-compose ps

# Ver logs
docker-compose logs -f api
docker-compose logs -f auth
docker-compose logs -f web
```

### 4. Verificación

```bash
# Health checks
curl http://localhost:5070/health
curl http://localhost:5080/health

# Swagger API
open http://localhost:5070/swagger

# Frontend (servido por nginx dentro de Docker Compose)
open http://localhost:8080
```

---

## Despliegue en Kubernetes

### 1. Prerequisitos

- Cluster de Kubernetes configurado
- `kubectl` instalado y configurado
- Registro de contenedores (Docker Hub, ACR, GCR, etc.)

### 2. Build y Push de Imágenes

```bash
# Variables
export REGISTRY=your-registry.azurecr.io
export VERSION=1.0.0

# Build imágenes
docker build -t $REGISTRY/arme-erp/api:$VERSION -f backend/src/ArmeErp.WebApi/Dockerfile backend/
docker build -t $REGISTRY/arme-erp/auth:$VERSION -f backend/src/ArmeErp.AuthServer/Dockerfile backend/src/ArmeErp.AuthServer/
docker build -t $REGISTRY/arme-erp/web:$VERSION -f frontend/Dockerfile frontend/

# Push imágenes
docker push $REGISTRY/arme-erp/api:$VERSION
docker push $REGISTRY/arme-erp/auth:$VERSION
docker push $REGISTRY/arme-erp/web:$VERSION
```

### 3. Actualizar Manifests

Editar archivos en `infra/k8s/`:

**secrets.yaml**:
```yaml
stringData:
  POSTGRES_PASSWORD: "tu-password-seguro"
  ConnectionStrings__DefaultConnection: "Host=postgres-service;Port=5432;Database=arme_erp;Username=arme;Password=tu-password-seguro"
```

**Deployments** (api, auth, web):
```yaml
image: your-registry.azurecr.io/arme-erp/api:1.0.0
```

### 4. Aplicar Manifests

```bash
# Crear namespace
kubectl apply -f infra/k8s/namespace.yaml

# Aplicar configuración
kubectl apply -f infra/k8s/configmap.yaml
kubectl apply -f infra/k8s/secrets.yaml

# Desplegar base de datos
kubectl apply -f infra/k8s/postgres-deployment.yaml

# Esperar a que PostgreSQL esté listo
kubectl wait --for=condition=ready pod -l app=postgres -n arme-erp --timeout=300s

# Desplegar servicios
kubectl apply -f infra/k8s/auth-deployment.yaml
kubectl apply -f infra/k8s/api-deployment.yaml
kubectl apply -f infra/k8s/web-deployment.yaml

# Configurar ingress
kubectl apply -f infra/k8s/ingress.yaml
```

### 5. Verificación

```bash
# Ver pods
kubectl get pods -n arme-erp

# Ver servicios
kubectl get services -n arme-erp

# Ver logs
kubectl logs -f deployment/api -n arme-erp

# Describir pod si hay errores
kubectl describe pod <pod-name> -n arme-erp
```

### 6. Acceso

```bash
# Port forward para testing
kubectl port-forward service/web-service 8080:80 -n arme-erp
kubectl port-forward service/api-service 5070:80 -n arme-erp

# O configurar Ingress con dominio
```

---

## CI/CD con GitHub Actions

> **Estado real**: los jobs `Build & Test Backend` y `Build Frontend`
> (`.github/workflows/ci.yml`) corren en cada push/PR sin configuración
> adicional y son los que de verdad se ejecutan en este repositorio. Los jobs
> `docker-build` y `deploy` están definidos y son funcionales, pero requieren
> los secrets de infraestructura listados abajo (registro de contenedores,
> kubeconfig) que **no están configurados** en este repo — no hay un cluster
> ni un registry reales detrás. Quedan documentados como el camino a producción,
> no como algo que ya está corriendo.

### 1. Configurar Secrets en GitHub

Ir a Settings > Secrets and variables > Actions:

- `REGISTRY_URL`: URL del registro de contenedores
- `REGISTRY_USERNAME`: Usuario del registro
- `REGISTRY_PASSWORD`: Password/token del registro
- `KUBE_CONFIG`: Contenido del archivo kubeconfig (base64)

```bash
# Obtener kubeconfig en base64
cat ~/.kube/config | base64
```

### 2. Pipeline Automático

El pipeline se ejecuta automáticamente en:
- Push a `main` o `develop`
- Pull requests

Stages:
1. **Build Backend**: Compila y testea .NET
2. **Build Frontend**: Compila Angular
3. **Docker Build**: Construye y pushea imágenes (solo en main)
4. **Deploy**: Despliega a Kubernetes (solo en main)

---

## Rollback

### Docker Compose

```bash
# Detener servicios
docker-compose down

# Checkout a versión anterior
git checkout <commit-hash>

# Rebuild y start
docker-compose up --build -d
```

### Kubernetes

```bash
# Ver historial de deployments
kubectl rollout history deployment/api -n arme-erp

# Rollback a versión anterior
kubectl rollout undo deployment/api -n arme-erp

# Rollback a revisión específica
kubectl rollout undo deployment/api --to-revision=2 -n arme-erp
```

---

## Monitoreo

### Logs

```bash
# Docker Compose
docker-compose logs -f --tail=100 api

# Kubernetes
kubectl logs -f deployment/api -n arme-erp --tail=100
```

### Métricas

```bash
# Kubernetes
kubectl top pods -n arme-erp
kubectl top nodes
```

---

## Troubleshooting

### Backend no inicia

```bash
# Verificar logs
docker-compose logs api

# Verificar conexión a BD
docker-compose exec postgres psql -U arme -d arme_erp -c "SELECT 1;"
```

### Frontend no carga

```bash
# Verificar build
docker-compose logs web

# Verificar nginx config
docker-compose exec web cat /etc/nginx/conf.d/default.conf
```

### Base de datos

```bash
# Conectar a PostgreSQL
docker-compose exec postgres psql -U arme -d arme_erp

# Ver tablas
\dt

# Ver datos
SELECT * FROM "Clients";
```

---

## Backup y Restore

### PostgreSQL Backup

```bash
# Docker Compose
docker-compose exec postgres pg_dump -U arme arme_erp > backup.sql

# Kubernetes
kubectl exec -it postgres-<pod-id> -n arme-erp -- pg_dump -U arme arme_erp > backup.sql
```

### PostgreSQL Restore

```bash
# Docker Compose
docker-compose exec -T postgres psql -U arme arme_erp < backup.sql

# Kubernetes
kubectl exec -i postgres-<pod-id> -n arme-erp -- psql -U arme arme_erp < backup.sql
```

---

## Seguridad

### Checklist Pre-Producción

- [ ] Cambiar todas las contraseñas por defecto
- [ ] Configurar HTTPS/TLS
- [ ] Configurar certificados SSL (Let's Encrypt)
- [ ] Habilitar CORS solo para dominios permitidos
- [ ] Configurar rate limiting
- [ ] Habilitar auditoría de logs
- [ ] Configurar backups automáticos
- [ ] Implementar secrets management (Azure Key Vault, AWS Secrets Manager)
- [ ] Configurar network policies en Kubernetes
- [ ] Habilitar pod security policies

Ninguno de estos puntos está resuelto todavía en este repositorio — es una
lista de lo que faltaría antes de un despliegue productivo real, no un
checklist ya cumplido.
