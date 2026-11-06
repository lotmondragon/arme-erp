# ARME-ERP

Sistema de gestión empresarial para constructoras especializadas en **naves
industriales** (bodegas, plantas y centros de distribución): control de
clientes, proyectos, etapas de obra y su seguimiento financiero básico.

Es un proyecto personal construido para practicar y demostrar un stack
backend en .NET con Clean Architecture, CQRS y autenticación OAuth2/OIDC real,
consumido por un frontend en Angular — no un ERP comercial ni un producto en
producción. La sección [Roadmap](#roadmap) es explícita sobre qué está
implementado de punta a punta y qué es maqueta o diseño pendiente.

## Stack

**Backend**
- .NET 8 / ASP.NET Core Web API
- Clean Architecture (Domain / Application / Infrastructure / WebApi)
- CQRS + [MediatR](https://github.com/jbogard/MediatR)
- Entity Framework Core 8 + Npgsql (PostgreSQL), con migraciones reales
- [OpenIddict](https://github.com/openiddict/openiddict-core) para OAuth2/OIDC
- FluentValidation, Serilog, Health Checks, Swagger

**Frontend**
- Angular 20 (standalone components)
- Tailwind CSS

**Infraestructura**
- PostgreSQL 16
- Docker Compose para desarrollo local
- Manifiestos de Kubernetes (`infra/k8s/`) para un despliegue de referencia
- GitHub Actions (`.github/workflows/ci.yml`): build + test en cada push/PR

Ver [`docs/architecture.md`](docs/architecture.md) para el detalle de las
capas, el patrón CQRS y por qué se eligió OpenIddict con un servidor de auth
separado.

## Cómo correrlo local (Docker Compose)

Requisitos: Docker y Docker Compose.

```bash
git clone https://github.com/lotmondragon/arme-erp.git
cd arme-erp

cp .env.example .env   # revisa/edita los valores si quieres

docker compose up --build
```

Servicios expuestos:

| Servicio | URL |
|---|---|
| Frontend | http://localhost:8080 |
| API (Swagger) | http://localhost:5070/swagger |
| Auth Server | http://localhost:5080/health |
| PostgreSQL | localhost:5432 |

Al arrancar, la API aplica automáticamente las migraciones de EF Core sobre
una base de datos vacía y siembra datos de ejemplo **ficticios** (2 clientes,
2 proyectos) para poder navegar la aplicación de inmediato.

Credenciales de prueba (ver limitación de autenticación más abajo):

```
Usuario:     admin@arme.com
Contraseña:  Admin123!
```

Para bajar el stack y borrar los datos (volver a un estado limpio):

```bash
docker compose down -v
```

## Desarrollo local sin Docker

**Backend** (requiere .NET 8 SDK y una instancia de PostgreSQL local; ajusta
`backend/src/ArmeErp.WebApi/appsettings.Development.json` si tu conexión es
distinta):

```bash
cd backend
dotnet restore ArmeErp.sln

# Terminal 1: servidor de autenticación
dotnet run --project src/ArmeErp.AuthServer

# Terminal 2: API
dotnet run --project src/ArmeErp.WebApi
```

**Migraciones de EF Core** (requiere la herramienta `dotnet-ef`):

```bash
cd backend
dotnet tool install --global dotnet-ef   # si no la tienes

dotnet ef migrations add NombreDeLaMigracion \
  --project src/ArmeErp.Infrastructure \
  --startup-project src/ArmeErp.WebApi \
  --output-dir Persistence/Migrations

dotnet ef database update \
  --project src/ArmeErp.Infrastructure \
  --startup-project src/ArmeErp.WebApi
```

**Frontend**:

```bash
cd frontend
npm install
npm start   # http://localhost:4200
```

## Tests

```bash
cd backend
dotnet test ArmeErp.sln
```

Cubre los handlers CQRS de Clientes y Proyectos (create/update/delete/get,
casos de éxito y de "no encontrado") y el validador de FluentValidation de
creación de clientes, mockeando `IUnitOfWork` — sin necesitar base de datos.

Además, `ArmeErp.IntegrationTests` incluye pruebas de integración contra el
stack real levantado con `docker compose up` (API + Auth Server + PostgreSQL,
sin mocks): obtienen un JWT real vía OpenIddict y llaman a un endpoint
protegido. Si el stack no está corriendo, se saltan en vez de fallar, por lo
que el CI de GitHub Actions solo ejecuta los tests unitarios. No hay todavía
tests en el frontend ni tests de integración con Testcontainers en CI (ver
[Roadmap](#roadmap)).

## Roadmap

### Implementado de punta a punta

- **Clientes**: CRUD completo — entidad de dominio, comandos/queries CQRS,
  validación, controller REST, y consumo real desde el frontend Angular
  (listado, alta, edición, baja).
- **Proyectos**: igual que Clientes — CRUD completo de extremo a extremo.
- **Dashboard**: agregados reales (proyectos activos, ingresos/gastos,
  utilidad) calculados a partir de los datos de Clientes y Proyectos.
- **Autenticación**: OpenIddict emite JWTs reales; la API los valida vía
  `OpenIddict.Validation`; el login del frontend obtiene un token real y lo
  usa en cada llamada a la API (interceptor HTTP + guard de rutas).
- **Migraciones de EF Core**: el esquema se genera desde las entidades de
  dominio y se aplica automáticamente al arrancar (no `EnsureCreated`).

### Limitaciones conocidas (documentadas, no ocultas)

- **Autenticación de un solo usuario hardcodeado**: no hay tabla de usuarios
  real ni hash de contraseñas; ver el detalle en
  [`docs/architecture.md`](docs/architecture.md#autenticación-por-qué-openiddict-y-por-qué-un-servidor-separado).
  El flujo es `password` grant (ROPC), no `authorization_code` + PKCE, aunque
  el paquete `angular-auth-oidc-client` está instalado y parcialmente
  configurado para ese flujo.
- **CI/CD**: los jobs de build y test corren de verdad en cada push. Los jobs
  de build de imágenes Docker y despliegue a Kubernetes están definidos y
  son funcionales, pero requieren secrets de un registry/cluster reales que
  este repositorio no tiene configurados.

### Con modelo de datos pero sin API ni UI conectada

Las entidades `Budget`, `BudgetItem`, `Invoice`, `Contract`, `Expense` y
`Payment` existen en el dominio, tienen tabla propia (vía migraciones) y se
usan para sembrar datos de ejemplo del dashboard, pero **no tienen** comandos/queries
CQRS ni controllers — no son operables vía API todavía.

### Solo interfaz (sin backend)

Las páginas del sidebar **Contratos, Empleados, Maquinaria, Materiales,
Pagos, Proveedores, Reportes, Etapas y Configuración** son componentes de
Angular ya maquetados, pero no hacen llamadas HTTP: no hay controllers,
handlers ni entidades de dominio para Empleados, Maquinaria, Materiales ni
Proveedores. Son la referencia visual de hacia dónde va el proyecto, no
funcionalidad real.

### Diseño a futuro, no implementado

`database/schema/*.sql` contiene un diseño de base de datos modular más amplio
(usuarios/roles, proveedores, inventario, auditoría — 33 tablas) que **no está
conectado a la aplicación**. Es la referencia de diseño para si esos módulos
se construyen más adelante. Detalle completo en
[`docs/database-design.md`](docs/database-design.md).

### Próximos pasos, en orden de prioridad

1. Reemplazar el usuario hardcodeado por una tabla de usuarios real y migrar
   el login a `authorization_code` + PKCE.
2. CRUD completo de Presupuestos y Facturas (ya tienen entidad y tabla).
3. Tests de integración contra una base de datos real (Testcontainers).
4. Conectar alguna de las páginas de solo-UI (empezando por Etapas de
   proyecto, que ya tiene entidad `ProjectStage`) a un backend real.

## Estructura del repositorio

```
backend/
  src/
    ArmeErp.Domain/          # Entidades, enums — sin dependencias externas
    ArmeErp.Application/     # CQRS (comandos/queries), DTOs, validadores
    ArmeErp.Infrastructure/  # EF Core, repositorios, migraciones, seeder
    ArmeErp.WebApi/          # Controllers, auth, Swagger, health checks
    ArmeErp.AuthServer/      # Servidor OpenIddict independiente
  tests/
    ArmeErp.Application.Tests/   # Unitarios: handlers CQRS y validadores (xUnit + Moq)
    ArmeErp.IntegrationTests/    # Integración contra el stack de Docker Compose
frontend/                    # Angular 20 + Tailwind
database/schema/             # Diseño de base de datos objetivo (no conectado)
docs/                        # architecture.md, database-design.md, DEPLOYMENT.md
infra/k8s/                   # Manifiestos de Kubernetes de referencia
```

## Documentación adicional

- [`docs/architecture.md`](docs/architecture.md) — capas, CQRS+MediatR, por
  qué OpenIddict con servidor separado.
- [`docs/database-design.md`](docs/database-design.md) — esquema implementado
  vs. diseño objetivo.
- [`docs/DEPLOYMENT.md`](docs/DEPLOYMENT.md) — guía de despliegue con Docker
  Compose, Kubernetes y CI/CD.
