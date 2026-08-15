# Diseño de base de datos

Este documento distingue **lo que la aplicación realmente crea y usa hoy**
(vía EF Core Migrations) de **lo que es un diseño objetivo para módulos
futuros** (los scripts en `database/schema/`). Mezclar ambos sin aclararlo
sería engañoso, así que se listan por separado.

## Esquema implementado (EF Core Migrations)

Fuente de verdad: `backend/src/ArmeErp.Infrastructure/Persistence/Migrations/`,
generada a partir de las entidades en `ArmeErp.Domain/Entities` y las
configuraciones Fluent API en `ArmeErp.Infrastructure/Persistence/Configurations`.
Se aplica automáticamente al arrancar la API (`Database.MigrateAsync()`).

| Tabla | Entidad | CRUD vía API |
|---|---|---|
| `Clients` | `Client` | ✅ Sí (`ClientsController`) |
| `Projects` | `Project` | ✅ Sí (`ProjectsController`) |
| `ProjectStages` | `ProjectStage` | ❌ No (modelo de datos listo, sin endpoints) |
| `ProjectTasks` | `ProjectTask` | ❌ No |
| `Budgets` | `Budget` | ❌ No |
| `BudgetItems` | `BudgetItem` | ❌ No |
| `Invoices` | `Invoice` | ❌ No |
| `Contracts` | `Contract` | ❌ No |
| `Expenses` | `Expense` | ❌ No |
| `Payments` | `Payment` | ❌ No |

Todas heredan de `BaseEntity` (`Id`, `CreatedAt`, `UpdatedAt`, `CreatedBy`,
`UpdatedBy`, `IsDeleted`) y tienen un filtro global de soft delete
(`HasQueryFilter` en `ApplicationDbContext`).

El `DatabaseSeeder` (`ArmeErp.Infrastructure/Persistence/DatabaseSeeder.cs`)
inserta datos ficticios de ejemplo en desarrollo — 2 clientes, 2 proyectos con
sus etapas, contratos, gastos y pagos — usados por el dashboard para calcular
KPIs (`GetDashboardSummaryQueryHandler`). Esos datos son claramente de
demostración (nombres y RFC ficticios), nunca información real.

## Diseño objetivo — `database/schema/*.sql` (no conectado a la aplicación)

El repositorio incluye además un conjunto de scripts SQL (`database/schema/01`
a `09`, aplicados por `database/install.sql`) con un diseño mucho más amplio:
33 tablas cubriendo seguridad (usuarios/roles/permisos), proveedores,
inventario/materiales, flujo de caja y auditoría, en `snake_case` (a
diferencia del esquema PascalCase que genera EF Core).

**Esto es un ejercicio de diseño, no código en uso.** Ningún proceso de la
aplicación ejecuta estos scripts; `docker-compose.yml` no los monta ni el
contenedor de PostgreSQL los aplica en el arranque. Se conservan en el repo
como referencia de hacia dónde apunta el modelo de datos si los módulos de
Proveedores, Inventario y Seguridad/Usuarios se implementan (ver roadmap en el
[README](../README.md#roadmap)). Si se retoman, la implementación real debería
migrarse a entidades de `ArmeErp.Domain` + migraciones de EF Core, siguiendo el
mismo patrón que `Client`/`Project`, no ejecutando estos `.sql` directamente.

### Módulos cubiertos por el diseño objetivo

- **Seguridad**: `users`, `roles`, `permissions`, `user_roles`, `role_permissions`
  — reemplazaría el usuario hardcodeado actual en `ArmeErp.AuthServer`.
- **Clientes**: `clients`, `client_contacts`, `client_documents` — el módulo
  de Clientes actual es un subconjunto de esto.
- **Proveedores**: `suppliers`, `project_suppliers`, `supplier_evaluations`.
- **Financiero**: `contracts`, `budgets`, `budget_items`, `invoices`,
  `invoice_items`, `payments`, `expenses`, `cash_flow`.
- **Proyectos**: `projects`, `project_stages`, `project_tasks`, `project_team`,
  `project_documents`, `project_photos`.
- **Inventario**: `material_categories`, `materials`, `warehouses`,
  `inventory_movements`, `project_materials`.
- **Auditoría**: `audit_logs`, `system_logs`, `change_history`.
