# Multi-Tenant SaaS Relational Schema — 3NF

A PostgreSQL project demonstrating a normalized relational model for a multi-tenant SaaS work-management application. It includes an ER diagram, DDL, realistic seed data, tenant-isolation constraints, referential actions, and repeatable verification scripts.

## Project deliverables

- `docs/er-diagram.md` — Mermaid ER diagram source.
- `docs/er-diagram.png` / `docs/er-diagram.svg` — exported ER diagram for reports and previews.
- `docs/er-diagram.dot` — Graphviz source for the exported diagram.
- `docs/design-and-3nf.md` — assumptions, relational schema, business rules, and 1NF/2NF/3NF rationale.
- `migrations/001_initial_schema.sql` — PostgreSQL DDL with PK, FK, UNIQUE, CHECK, NOT NULL, indexes, and referential actions.
- `fixtures/001_seed_data.sql` — multi-row sample data for every table.
- `tests/verify_constraints.sql` — negative tests and cascade-update/delete tests.
- `tests/run_all.sql` — single entry point that resets only the `saas` schema, rebuilds it, seeds the data, and runs verification.
- `docs/expected-results.md` — expected row counts and test messages to compare against your local run.

## Requirements

- PostgreSQL 14 or later (tested syntax targets PostgreSQL 14+; PostgreSQL 16 is suitable).
- `psql` command-line client.

## Run on Windows PowerShell

Extract the project. In PowerShell, move into the folder containing this `README.md`:

```powershell
Set-Location -LiteralPath "C:\path\to\saas_3nf_schema"
psql -U postgres -h localhost -p 5432 -d postgres -c "SELECT version();"
```

Create a dedicated development database if you do not have one already:

```powershell
createdb -U postgres -h localhost -p 5432 saas_3nf_demo
```

Then run the complete build and test suite:

```powershell
psql -U postgres -h localhost -p 5432 -d saas_3nf_demo -v ON_ERROR_STOP=1 -f ".\tests\run_all.sql"
```

The script drops and recreates **only the `saas` schema** in the database you choose. Use a dedicated development/test database; do not run it against a production database or a database containing work you need to preserve.

To save console output as a local evidence file:

```powershell
psql -U postgres -h localhost -p 5432 -d saas_3nf_demo -v ON_ERROR_STOP=1 -f ".\tests\run_all.sql" 2>&1 | Tee-Object ".\docs\local-test-output.txt"
```

PowerShell may format PostgreSQL `NOTICE` messages as `NativeCommandError` records, depending on the PowerShell version. Check the `PASS` notices and `$LASTEXITCODE` after the command; an exit code of `0` indicates `psql` completed successfully.

## Inspect data after running

```powershell
psql -U postgres -h localhost -p 5432 -d saas_3nf_demo -c "SELECT tenant_slug, display_name FROM saas.tenants ORDER BY tenant_slug;"
psql -U postgres -h localhost -p 5432 -d saas_3nf_demo -c "SELECT t.tenant_slug, p.project_key, p.project_name FROM saas.projects p JOIN saas.tenants t USING (tenant_id) ORDER BY t.tenant_slug, p.project_key;"
psql -U postgres -h localhost -p 5432 -d saas_3nf_demo -c "SELECT t.tenant_slug, p.project_key, task.title, task.status FROM saas.tasks task JOIN saas.projects p ON p.tenant_id = task.tenant_id AND p.project_id = task.project_id JOIN saas.tenants t ON t.tenant_id = task.tenant_id ORDER BY t.tenant_slug, p.project_key, task.task_id;"
```

## Design highlights

- **1:1:** `tenants` to `tenant_settings` (`tenant_settings.tenant_id` is also its PK).
- **1:N:** tenant to projects; project to tasks; tenant to tags.
- **N:M:** users to tenants through `tenant_memberships`; projects to tags through `project_tags`.
- **Tenant isolation:** composite foreign keys require a task's project, assignee membership, and project tags to belong to the same tenant.
- **3NF:** repeating groups and many-to-many values are separated into their own tables; non-key attributes describe their table's key rather than other non-key attributes.
- **Referential integrity:** cascading key updates and cascading deletes are configured on dependent tables where appropriate; assigned-member deletion is blocked while projects or tasks still refer to that membership.

## Before publishing

Review `docs/design-and-3nf.md` and adjust terminology to match the exact brief from your instructor or internship mentor. Commit the SQL and documentation, and add `docs/local-test-output.txt` only after you execute the scripts locally. Do not commit database passwords or `.env` secrets.
