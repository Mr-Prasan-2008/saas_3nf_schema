# ER Diagram

Render the Mermaid block below in GitHub Markdown or paste it into the [Mermaid Live Editor](https://mermaid.live/) to export an image.

```mermaid
erDiagram
    TENANTS ||--o| TENANT_SETTINGS : configures
    TENANTS ||--o{ PROJECTS : owns
    TENANTS ||--o{ TENANT_MEMBERSHIPS : has
    USERS ||--o{ TENANT_MEMBERSHIPS : joins
    TENANTS ||--o{ TAGS : defines
    PROJECTS ||--o{ TASKS : contains
    TENANT_MEMBERSHIPS ||--o{ TASKS : may_be_assigned
    PROJECTS ||--o{ PROJECT_TAGS : has
    TAGS ||--o{ PROJECT_TAGS : labels

    TENANTS {
        bigint tenant_id PK
        text tenant_slug UK
        text display_name
        timestamptz created_at
    }
    TENANT_SETTINGS {
        bigint tenant_id PK, FK
        text time_zone
        int retention_days
        text support_email
    }
    USERS {
        bigint user_id PK
        text email UK
        text display_name
        timestamptz created_at
    }
    TENANT_MEMBERSHIPS {
        bigint tenant_id PK, FK
        bigint user_id PK, FK
        text role
        timestamptz joined_at
    }
    PROJECTS {
        bigint project_id PK
        bigint tenant_id FK
        text project_key
        text project_name
        text status
        bigint created_by_user_id
    }
    TASKS {
        bigint task_id PK
        bigint tenant_id FK
        bigint project_id FK
        bigint assignee_user_id FK
        text title
        text status
        text priority
        date due_date
    }
    TAGS {
        bigint tag_id PK
        bigint tenant_id FK
        text tag_name
        text color
    }
    PROJECT_TAGS {
        bigint tenant_id PK, FK
        bigint project_id PK, FK
        bigint tag_id PK, FK
        timestamptz created_at
    }
```

## Relationship summary

- **1:1:** each tenant can have zero or one settings row; `tenant_settings.tenant_id` is both primary key and foreign key, so duplicate settings for a tenant are impossible.
- **1:N:** one tenant owns many projects; one project contains many tasks; one tenant defines many tags.
- **N:M:** users can join multiple tenants, and tenants can have multiple users through `tenant_memberships`. Projects can use multiple tags, and tags can be applied to multiple projects through `project_tags`.
- **Tenant-safe references:** composite foreign keys include `tenant_id`, so a project cannot be linked to a tag or assignee from another tenant.
