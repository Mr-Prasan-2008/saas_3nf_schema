# Relational Design and 3NF Notes

## Objective

Design a relational database for a multi-tenant SaaS work-management application. Each tenant owns its projects, tasks, tenant-specific tags, settings, and membership/role assignments. A global user identity can belong to more than one tenant.

## Assumptions

1. `tenant_id` identifies a customer workspace (tenant).
2. Users are global identities, while their role is specific to a tenant membership.
3. A tenant has at most one settings row; the settings row is optional until configured.
4. Each project belongs to exactly one tenant and has a key unique within that tenant.
5. A task belongs to one project; an optional assignee must be a member of the same tenant.
6. Tags are tenant-scoped. A project may have many tags and a tag may be linked to many projects.
7. Deleting a project deletes its tasks and tag links. Deleting a tenant cascades to its tenant-owned rows. A membership referenced as a project creator or task assignee cannot be deleted until those references have been dealt with; the default `NO ACTION` behavior rejects a delete that would leave references behind.

## Relational schema

- `tenants(tenant_id PK, tenant_slug UNIQUE, display_name, created_at)`
- `tenant_settings(tenant_id PK/FK, time_zone, retention_days, support_email)`
- `users(user_id PK, email UNIQUE, display_name, created_at)`
- `tenant_memberships(tenant_id PK/FK, user_id PK/FK, role, joined_at)`
- `projects(project_id PK, tenant_id FK, project_key, project_name, status, created_by_user_id)` with `UNIQUE(tenant_id, project_id)` and `UNIQUE(tenant_id, project_key)`
- `tasks(task_id PK, tenant_id, project_id, assignee_user_id nullable, title, description, status, priority, due_date, created_at)`
- `tags(tag_id PK, tenant_id, tag_name, color)` with `UNIQUE(tenant_id, tag_id)` and `UNIQUE(tenant_id, tag_name)`
- `project_tags(tenant_id PK/FK, project_id PK/FK, tag_id PK/FK, created_at)`

## Business-rule to database mapping

| Rule | Enforcement |
|---|---|
| Every tenant has a unique slug | `UNIQUE(tenant_slug)` and `NOT NULL` |
| A tenant has no more than one settings row | `tenant_settings.tenant_id` is its primary key |
| A user can be a member of a given tenant only once | Composite primary key `(tenant_id, user_id)` |
| Membership roles use an allowed vocabulary | `CHECK(role IN (...))` |
| A project creator belongs to the same tenant | Composite FK `(tenant_id, created_by_user_id)` to membership |
| A task's project belongs to the same tenant | Composite FK `(tenant_id, project_id)` to project |
| An assigned task user belongs to the same tenant | Composite FK `(tenant_id, assignee_user_id)` to membership |
| A project cannot use a tag from another tenant | Two composite FKs on `project_tags` share `tenant_id` |
| Task status and priority values are valid | `CHECK` constraints |
| Dependent rows are not orphaned | Foreign keys plus appropriate `ON DELETE` / `ON UPDATE` actions |

## 3NF normalization explanation

### First Normal Form (1NF)

Each column stores a single value. There are no comma-separated lists of users or tags in a project row. User membership and project-tag associations are represented as rows in junction tables.

### Second Normal Form (2NF)

Tables with single-column primary keys have no partial dependency on a composite key. In `tenant_memberships`, the membership-specific attributes (`role`, `joined_at`) depend on the full `(tenant_id, user_id)` key. In `project_tags`, the row represents the combination of tenant, project, and tag, and there are no non-key attributes that depend on only part of that key (the `created_at` records when that association was created).

### Third Normal Form (3NF)

Non-key attributes describe the key, the whole key, and nothing but the key. Tenant display details are stored in `tenants`, global user details in `users`, tenant-specific roles in `tenant_memberships`, and settings in `tenant_settings`. Project rows do not repeat tenant names or creator email addresses; they store keys to those facts. Tag names are stored once per tenant in `tags`, rather than repeated in projects. No derived counts or redundant copies of non-key attributes are stored.

The schema is designed to satisfy 3NF under these stated functional dependencies. A formal normalization review should be revisited if more attributes or business rules are added.

## Referential actions

- `ON UPDATE CASCADE` lets a changed parent key propagate to matching child keys. The test script demonstrates updating a tenant key inside a transaction and then rolling back.
- `ON DELETE CASCADE` is used for tenant settings, memberships, tenant-owned projects and tags, tasks under projects, and project-tag junction rows where deletion represents removal of the parent entity.
- `ON DELETE NO ACTION` protects project creator and assignee membership references from being removed while dependent operational rows still rely on them. It also allows a tenant-level delete to finish its cascades as one statement when all dependent rows are removed together.

## Tenant-isolation strategy

Tenant-owned child rows carry `tenant_id` in the foreign key, not just in a separate unrelated column. For example, `tasks(tenant_id, project_id)` references `projects(tenant_id, project_id)`. The database therefore rejects a task or tag association that combines rows across tenants even when both referenced IDs exist independently.
