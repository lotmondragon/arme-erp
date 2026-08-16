---
name: ef-migration
description: Adds and verifies a new EF Core migration for ArmeErp.Infrastructure against a clean PostgreSQL database, using the dotnet/sdk:8.0 Docker image so it works regardless of which local .NET SDKs are installed.
disable-model-invocation: true
---

# Add and verify an EF Core migration

This repo's local dev machine may only have newer .NET SDKs installed
(no .NET 8 runtime), which makes `dotnet ef` fail locally with
`You must install or update .NET to run this application`. Running the
exact same command inside the `mcr.microsoft.com/dotnet/sdk:8.0` container —
the same image the Dockerfiles build with — sidesteps that entirely and is
what this skill does by default.

## 1. Ask for the migration name if not given

Use PascalCase, describing the schema change (e.g. `AddInvoicePaidAmount`,
not `Update2`).

## 2. Generate the migration

Run from the repo root:

```bash
docker run --rm -v "$(pwd)/backend:/src" -w /src mcr.microsoft.com/dotnet/sdk:8.0 \
  bash -c "dotnet tool install --global dotnet-ef --version 8.* 2>/dev/null; \
  export PATH=\"\$PATH:/root/.dotnet/tools\"; \
  dotnet ef migrations add <MigrationName> \
    --project src/ArmeErp.Infrastructure \
    --startup-project src/ArmeErp.WebApi \
    --output-dir Persistence/Migrations"
```

This writes the migration files under
`backend/src/ArmeErp.Infrastructure/Persistence/Migrations/` on the host
(bind mount), same as running it natively.

## 3. Verify against a truly clean database — this is the step people skip

A migration that "looks right" can still fail against a database that
already has tables from a previous `EnsureCreated`-style run, or succeed
locally against a stale volume while failing on a genuinely empty one. Don't
skip this:

```bash
docker compose down -v      # removes the postgres volume — a real clean slate
docker compose up -d --build
```

Then confirm all four services report healthy and the API applied the
migration without errors:

```bash
docker compose ps
docker compose logs api --tail=50
```

If `docker compose logs api` shows a Postgres exception (e.g.
`relation "X" already exists`, `column "Y" does not exist`), the migration
or the volume state is wrong — fix and regenerate rather than patching
around it with `EnsureCreated` or manual SQL.

## 4. Local (non-Docker) alternative, only if Docker isn't available

Requires the .NET 8 runtime installed locally (not just a newer SDK) and
`dotnet-ef` on PATH:

```bash
cd backend
dotnet tool install --global dotnet-ef --version 8.*
dotnet ef migrations add <MigrationName> \
  --project src/ArmeErp.Infrastructure \
  --startup-project src/ArmeErp.WebApi \
  --output-dir Persistence/Migrations
```

If this fails with a framework-resolution error even though the command
looks right, that's the dual-SDK/runtime mismatch — fall back to the Docker
path above instead of fighting `DOTNET_ROOT`.
