# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

ARME-ERP: a management system for industrial-warehouse construction
companies (naves industriales). Backend in .NET 8 (Clean Architecture,
CQRS+MediatR, EF Core/PostgreSQL, OpenIddict), frontend in Angular 20 +
Tailwind. It is a personal/portfolio project, not a commercial product —
`README.md#roadmap` is the authoritative, honest list of what's implemented
end-to-end vs. UI-only mockup vs. aspirational design. Read it before
assuming a module is real.

## Commands

### Full stack (Docker Compose)

```bash
cp .env.example .env
docker compose up --build          # postgres:5432, auth:5080, api:5070, web:8080
docker compose down -v             # tear down AND wipe the postgres volume (true clean slate)
```

The API applies EF Core migrations automatically on startup in Development
(`Database.MigrateAsync()` in `ArmeErp.WebApi/Program.cs`) and seeds
fictional demo data if the `Clients` table is empty (`DatabaseSeeder`).

### Backend

```bash
cd backend
dotnet restore ArmeErp.sln
dotnet build ArmeErp.sln
dotnet run --project src/ArmeErp.AuthServer   # separate terminal
dotnet run --project src/ArmeErp.WebApi

dotnet test ArmeErp.sln                                          # all tests
dotnet test tests/ArmeErp.Application.Tests/*.csproj             # unit tests only
dotnet test --filter "FullyQualifiedName~CreateClientCommandHandlerTests"  # single test class
```

`ArmeErp.IntegrationTests` hits the real running stack over HTTP (login →
JWT → protected endpoint) — it needs `docker compose up` first, and
no-ops gracefully (not a failure) if the stack isn't reachable.

**If `dotnet test`/`dotnet ef` fails locally with `You must install or
update .NET to run this application`**: this machine only has newer .NET
SDKs installed, no .NET 8 runtime. Run the same command inside the
`mcr.microsoft.com/dotnet/sdk:8.0` image instead — same image the
Dockerfiles build with:
```bash
docker run --rm -v "$(pwd)/backend:/src" -w /src mcr.microsoft.com/dotnet/sdk:8.0 \
  dotnet test ArmeErp.sln
```

### EF Core migrations

Use the `ef-migration` skill (`.claude/skills/ef-migration/SKILL.md`) — it
runs `dotnet ef` inside Docker to sidestep the local runtime issue above,
and includes the mandatory step of verifying the migration against a truly
clean database (`docker compose down -v && up`), not a stale volume.

### Frontend

```bash
cd frontend
npm install
npm start           # ng serve, http://localhost:4200
npm run build
npm test             # Karma/Jasmine
```

## Architecture

Full writeup: `docs/architecture.md` (layers, CQRS rationale, why OpenIddict
with a separate auth server, and its documented limitations). Summary:

### Backend: 5 projects, dependencies point inward

```
ArmeErp.WebApi ──> ArmeErp.Application ──> ArmeErp.Domain
      │                                          ^
      └──────────> ArmeErp.Infrastructure ───────┘
ArmeErp.AuthServer (standalone OpenIddict server, no dependency on the above)
```

- **`Domain`** — entities (`Client`, `Project`, `ProjectStage`, `ProjectTask`,
  `Budget`, `BudgetItem`, `Invoice`, `Contract`, `Expense`, `Payment`) and
  enums only. No EF Core, no ASP.NET Core references. `BaseEntity` gives
  every entity `Id`, `CreatedAt`/`UpdatedAt`/`CreatedBy`/`UpdatedBy`,
  `IsDeleted` (soft delete, enforced via a global EF query filter in
  `ApplicationDbContext.OnModelCreating`).
- **`Application`** — CQRS. Every use case lives in its own folder:
  `Features/<Module>/{Commands|Queries}/<Action>/` with a command/query
  record, an `IRequestHandler` and (for commands) a FluentValidation
  validator. Handlers depend only on `IUnitOfWork`/`IRepository<T>`
  (interfaces defined here), never on `ApplicationDbContext` directly — this
  is what makes handlers testable with Moq and no real database (see
  `backend/tests/ArmeErp.Application.Tests`). Controllers are thin: build a
  command/query, call `mediator.Send()`, return the result.
- **`Infrastructure`** — `ApplicationDbContext`, Fluent API configs under
  `Persistence/Configurations/`, `Repository<T>`/`UnitOfWork`, EF Core
  migrations (`Persistence/Migrations/` — the real source of truth for the
  DB schema, not the SQL under `database/schema/`), and `DatabaseSeeder`.
- **`WebApi`** — controllers, OpenIddict token *validation* (not issuance),
  CORS restricted via `Cors:AllowedOrigins` config, Swagger, health checks.
- **`AuthServer`** — separate OpenIddict token-*issuance* server (in-memory
  DB for OpenIddict's own client/scope entities). `AuthorizationController`
  validates credentials against a single hardcoded demo user — there's no
  user table yet; this is a known, documented limitation, not a bug.

**Only Clients and Projects have full CQRS+controller CRUD.** `Budget`,
`BudgetItem`, `Invoice`, `Contract`, `Expense`, `Payment` have entities,
DbSets and migrations (so their tables exist) but no `Features/` folder and
no controller yet — see the `new-cqrs-feature` skill when adding one.

### Database: two schemas, only one is real

`database/schema/*.sql` (33 tables, snake_case, applied by nothing) is an
**aspirational** design for future modules — never treat it as the current
schema. The actual schema is generated by EF Core Migrations from `Domain`
entities (PascalCase tables). Full breakdown: `docs/database-design.md`.

### Frontend

Angular 20 standalone components. `frontend/src/app/pages/{clients,projects,dashboard}`
consume the real API via `HttpClient` services
(`frontend/src/app/services/`). Login (`pages/login/login.ts`) does a
direct OpenIddict `password`-grant POST to `/connect/token` and stores the
JWT in `localStorage` — `auth.interceptor.ts` attaches it to `/api` calls,
`auth.guard.ts` checks it for route access. The `angular-auth-oidc-client`
config in `auth/auth.config.ts` is present but **not used** by the actual
login flow (see `docs/architecture.md` for why).

The remaining sidebar pages (Contratos, Empleados, Maquinaria, Materiales,
Pagos, Proveedores, Reportes, Etapas, Configuración) are UI-only — no
backend, no HTTP calls, and for several (Empleados, Maquinaria, Materiales,
Proveedores) no domain entity exists at all.

## Claude Code config in this repo

- `.claude/skills/new-cqrs-feature/` — scaffold a full CQRS slice
  (Create/Update/Delete/GetAll/GetById) for one of the entity-only modules
  above, following the Clients/Projects pattern exactly.
- `.claude/skills/ef-migration/` — add + verify an EF Core migration.
- `.claude/agents/security-reviewer.md` — review auth/CORS/secrets changes
  against the documented known limitations, flag only new regressions.
- `.claude/agents/db-schema-reviewer.md` — catch drift between
  entities/migrations and `docs/database-design.md`.
- `.claude/settings.json` — `PostToolUse` hooks: `dotnet build` the nearest
  project after editing a `.cs` file under `backend/`; Prettier-format
  `.ts`/`.html`/`.scss` after editing under `frontend/`. Both best-effort,
  never blocking.
