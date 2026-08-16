---
name: new-cqrs-feature
description: Scaffolds a full CQRS feature slice (Create/Update/Delete commands + GetAll/GetById queries, handlers, validators, DTO, controller) for a domain entity, following the exact conventions used by Clients and Projects in ArmeErp.Application.
---

# Scaffold a CQRS feature slice

Use this when adding CRUD for an entity that already exists in
`backend/src/ArmeErp.Domain/Entities/` but has no `Features/` folder yet in
`ArmeErp.Application` — this is exactly the situation for `Budget`,
`BudgetItem`, `Invoice`, `Contract`, `Expense` and `Payment` per the roadmap
in the root `README.md`.

Ask the user which entity to scaffold if it isn't obvious from the request
(e.g. "add CRUD for Invoices" → entity is `Invoice`).

## Before generating anything

Read these three files in full — they are the literal template. Do not
invent a different shape; mirror them field-for-field, adjusting only names
and the entity's own properties:

- `backend/src/ArmeErp.Application/Features/Clients/**/*.cs` (simple case —
  flat command records)
- `backend/src/ArmeErp.Application/Features/Projects/**/*.cs` (the DTO-based
  case — commands wrap a `CreateXDto`/`UpdateXDto` instead of flat fields;
  use this shape when the entity has many fields, like `Invoice` or `Budget`)
- `backend/src/ArmeErp.Domain/Entities/<Entity>.cs` for the actual entity
  being scaffolded, so field names and types match exactly.

Also read `backend/src/ArmeErp.Application/Interfaces/IUnitOfWork.cs` —
if the entity doesn't already have an `IRepository<T>` property there
(`Budgets`, `BudgetItems` and `Invoices` already do; `Contract`, `Expense`,
`Payment` do not yet), add it there and in
`backend/src/ArmeErp.Infrastructure/Repositories/UnitOfWork.cs` first.

## What to generate

For entity `X` (e.g. `Invoice`), create under
`backend/src/ArmeErp.Application/Features/<X-plural>/`:

```
Commands/Create<X>/Create<X>Command.cs
Commands/Create<X>/Create<X>CommandHandler.cs
Commands/Create<X>/Create<X>CommandValidator.cs
Commands/Update<X>/Update<X>Command.cs
Commands/Update<X>/Update<X>CommandHandler.cs
Commands/Delete<X>/Delete<X>Command.cs
Commands/Delete<X>/Delete<X>CommandHandler.cs
Queries/GetAll<X-plural>/GetAll<X-plural>Query.cs
Queries/GetAll<X-plural>/GetAll<X-plural>QueryHandler.cs
Queries/Get<X>ById/Get<X>ByIdQuery.cs
Queries/Get<X>ById/Get<X>ByIdQueryHandler.cs
```

Rules, matching the existing code exactly:

- Handlers depend only on `IUnitOfWork` (constructor injection), never on
  `ApplicationDbContext` directly.
- `Delete` handlers return `bool` (`false` if not found, no exception).
- `Update` handlers throw `KeyNotFoundException` (Clients-style, flat
  commands) or return `null` (Projects-style, DTO commands) when the entity
  doesn't exist — pick whichever matches the shape you're mirroring, stay
  consistent within the feature.
- Every `Create`/`Update` command gets a `FluentValidation` validator:
  `NotEmpty()` for required strings, `MaximumLength()` matching the column
  length in the corresponding EF configuration under
  `ArmeErp.Infrastructure/Persistence/Configurations/`, and any numeric
  fields (amounts, percentages) get a sane range check
  (`GreaterThanOrEqualTo(0)` at minimum).
- Add or extend the DTO in `ArmeErp.Application/DTOs/<X>Dto.cs` if it
  doesn't already exist (several already do: `ExpenseDto.cs`,
  `PaymentDto.cs`, `ProjectStageDto.cs` — check first).

Then add a thin `<X-plural>Controller` under
`backend/src/ArmeErp.WebApi/Controllers/`, copying `ClientsController.cs`:
`[Authorize]`, injects `IMediator`, one action per command/query, no
business logic in the controller.

## After generating

1. `dotnet build backend/ArmeErp.sln` — must compile clean.
2. Write unit tests under `backend/tests/ArmeErp.Application.Tests/<X-plural>/`
   mirroring `Clients/` or `Projects/` (one test class per handler, mock
   `IUnitOfWork`/`IRepository<T>` with Moq, cover the found/not-found and
   success paths). This project already has `Moq` referenced.
3. Update `docs/database-design.md`'s "CRUD vía API" column for this table
   from ❌ to ✅, and remove the entity from the "Con modelo de datos pero
   sin API ni UI conectada" section of the root `README.md#roadmap`. Don't
   leave the docs claiming something is unimplemented once it isn't.
