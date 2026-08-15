# Arquitectura

Este documento explica cómo está organizado el código de ARME-ERP y por qué se
tomaron las decisiones de diseño principales. Es un complemento técnico al
[README](../README.md).

## Capas (Clean Architecture)

El backend está dividido en cuatro proyectos con dependencias en una sola
dirección (hacia adentro):

```
ArmeErp.WebApi  ──depende de──>  ArmeErp.Application  ──depende de──>  ArmeErp.Domain
      │                                   │
      └──────────depende de───────────────┴──> ArmeErp.Infrastructure ──depende de──> ArmeErp.Domain
```

- **`ArmeErp.Domain`** — entidades (`Client`, `Project`, `Budget`, `Invoice`, etc.),
  enums y la clase base `BaseEntity` (Id, auditoría, soft delete). No depende
  de ningún otro proyecto ni de EF Core: es POCO puro. Esto es lo que hace que
  las reglas de negocio sean testeables sin base de datos.
- **`ArmeErp.Application`** — casos de uso, expresados como comandos/queries de
  CQRS (ver abajo), DTOs, interfaces (`IUnitOfWork`, `IRepository<T>`) y
  validadores de FluentValidation. Depende solo de `Domain`. No sabe que existe
  PostgreSQL, HTTP o EF Core.
- **`ArmeErp.Infrastructure`** — implementación concreta: `ApplicationDbContext`
  (EF Core + Npgsql), `Repository<T>`/`UnitOfWork`, configuraciones Fluent API
  por entidad, y el seeder de datos de desarrollo. Implementa las interfaces
  que `Application` define.
- **`ArmeErp.WebApi`** — el host HTTP: controllers, autenticación/autorización,
  Swagger, health checks, CORS. Es el único proyecto que sabe que existe
  ASP.NET Core.
- **`ArmeErp.AuthServer`** — servidor OpenIddict independiente, separado de la
  API de negocio a propósito (ver sección de autenticación).

La regla práctica: si al leer un archivo en `Domain` o `Application` aparece un
`using Microsoft.EntityFrameworkCore` o `using Microsoft.AspNetCore...`, algo
está mal ubicado.

## CQRS + MediatR

Cada caso de uso vive en su propia carpeta bajo
`Application/Features/<Módulo>/{Commands|Queries}/<Acción>/`, con tres
archivos: el `record` del comando/query, su `Handler` (`IRequestHandler<TRequest,TResponse>`)
y, para comandos, un `Validator` de FluentValidation.

```
Features/Clients/Commands/CreateClient/
  CreateClientCommand.cs
  CreateClientCommandHandler.cs
  CreateClientCommandValidator.cs
```

Los controllers no contienen lógica: reciben la petición HTTP, arman un
comando o query, lo despachan con `IMediator.Send(...)` y devuelven el
resultado. Esto se eligió sobre un enfoque de "service layer" tradicional
porque:

1. **Cada caso de uso es una unidad independiente** — se puede leer, testear y
   modificar `CreateClientCommandHandler` sin tocar `UpdateClientCommandHandler`,
   en vez de tener un `ClientService` gigante con todos los métodos.
2. **Separación de lecturas y escrituras** — las queries (`GetAllClientsQuery`)
   no pasan por el mismo camino que los commands, lo que deja la puerta abierta
   a optimizar lecturas de forma distinta en el futuro (proyecciones, caché)
   sin afectar el modelo de escritura.
3. **Los validadores se ejecutan de forma desacoplada** del handler — FluentValidation
   valida el comando antes de que el handler lo toque.

El costo real de este patrón es más archivos por operación (tres en vez de un
método en un service). En un proyecto de este tamaño se aceptó ese costo a
cambio de que cada operación sea trivial de ubicar y de testear en aislamiento
(ver `backend/tests/ArmeErp.Application.Tests`).

## Persistencia: Repository + Unit of Work sobre EF Core

`IUnitOfWork` expone un `IRepository<T>` por agregado (`Clients`, `Projects`,
`Budgets`, `BudgetItems`, `Invoices`) más `SaveChangesAsync` y control
transaccional explícito (`BeginTransaction`/`Commit`/`Rollback`). Los handlers
de `Application` dependen únicamente de `IUnitOfWork`, nunca de
`ApplicationDbContext` directamente — así los tests unitarios de handlers
mockean `IUnitOfWork` sin necesitar una base de datos real (ver los tests en
`backend/tests/ArmeErp.Application.Tests/Clients` y `.../Projects`).

El esquema real de la base de datos se genera a partir de las entidades de
`Domain` vía **EF Core Migrations** (`backend/src/ArmeErp.Infrastructure/Persistence/Migrations`),
aplicadas automáticamente al arrancar la API en desarrollo
(`Database.MigrateAsync()` en `Program.cs`). Esto es intencional: la fuente de
verdad del esquema es el código C#, no SQL escrito a mano.

> **Nota sobre `database/schema/*.sql`**: el repositorio también incluye un
> conjunto de scripts SQL con un diseño modular más amplio (usuarios/roles,
> proveedores, inventario, auditoría — 33 tablas). Ese diseño **no está
> conectado a la aplicación que corre hoy**; es un ejercicio de diseño de base
> de datos para los módulos planeados a futuro. Ver
> [`docs/database-design.md`](./database-design.md) para el detalle de qué
> tablas están realmente implementadas vía EF Core y cuáles son solo el diseño
> objetivo.

## Autenticación: por qué OpenIddict y por qué un servidor separado

La autenticación se resolvió con **OpenIddict** en un proyecto propio
(`ArmeErp.AuthServer`), separado de la API de negocio (`ArmeErp.WebApi`), en
vez de meter la emisión de tokens dentro de la misma API:

- El servidor de autorización y el recurso protegido son responsabilidades
  distintas en OAuth2/OIDC. Separarlos en dos procesos hace explícito ese
  límite y permite, a futuro, tener varias APIs de recurso validando contra el
  mismo emisor sin duplicar lógica de emisión de tokens.
- `ArmeErp.WebApi` solo hace **validación** de tokens (`OpenIddict.Validation.AspNetCore`),
  descubriendo la configuración del emisor vía el endpoint
  `.well-known/openid-configuration` de `ArmeErp.AuthServer`. La API de negocio
  nunca ve contraseñas ni emite tokens.
- `ArmeErp.AuthServer` usa una base de datos **en memoria** (no PostgreSQL)
  para las entidades de OpenIddict (clients, scopes), porque en este estado
  del proyecto no hay una tabla de usuarios real — ver la limitación abajo.

**Limitación conocida y documentada, no oculta**: el flujo implementado es
`Resource Owner Password Credentials` (grant `password`) con **un único
usuario hardcodeado** (`admin@arme.com` / `Admin123!`) en
`AuthorizationController.Exchange()`. No hay tabla de usuarios, ni hash de
contraseñas, ni registro. Esto fue una decisión consciente para tener un flujo
de auth **real y funcional de punta a punta** (login → JWT firmado por
OpenIddict → validación en la API → autorización por rol) sin construir todavía
un módulo de gestión de usuarios completo. El paquete `angular-auth-oidc-client`
está instalado en el frontend y configurado para `authorization_code` (`auth.config.ts`),
pero **no se usa en el login actual**: el componente de login hace el POST de
password grant directamente contra `/connect/token` y guarda el token en
`localStorage` (ver `frontend/src/app/pages/login/login.ts`). Migrar a
`authorization_code` + PKCE contra un store de usuarios real es el primer ítem
del roadmap de seguridad (ver [README](../README.md#roadmap)).

Un problema adicional del estado actual: `web-client` está dado de alta en
OpenIddict como cliente **confidencial** (con `client_secret`), pero ese
secreto vive hardcodeado en `frontend/src/environments/environment.ts` — un
archivo que termina compilado dentro del bundle de JavaScript que llega al
navegador. Un `client_secret` en una SPA nunca es realmente secreto,
independientemente de si viene de una variable de entorno o está hardcodeado:
cualquiera puede extraerlo del bundle. El diseño correcto para un cliente
público es no usar `client_secret` en absoluto y depender de PKCE. Se dejó así
para tener el flujo funcionando de punta a punta rápido; se corrige junto con
la migración a `authorization_code` + PKCE del punto anterior.

## Esquema modular de base de datos

El dominio actualmente implementado (`ArmeErp.Domain/Entities`) cubre:
`Client`, `Project`, `ProjectStage`, `ProjectTask`, `Budget`, `BudgetItem`,
`Invoice`, `Contract`, `Expense`, `Payment`. De estas, solo **Clientes** y
**Proyectos** tienen CQRS handlers y controllers HTTP completos (CRUD real).
Las demás entidades existen en el modelo de datos (se crean vía migraciones y
algunas se usan para sembrar datos de ejemplo del dashboard) pero no tienen
todavía casos de uso ni endpoints propios.

Ver [`docs/database-design.md`](./database-design.md) para el detalle completo
tabla por tabla y qué corresponde a cada estado.
