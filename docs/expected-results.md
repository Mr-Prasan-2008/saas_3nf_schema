# Expected Results and Local Verification

These are the expected baseline counts from `fixtures/001_seed_data.sql`. They are provided as a verification target, not as a claim that this package has already been run on your computer.

| Table | Expected row count |
|---|---:|
| `saas.tenants` | 2 |
| `saas.tenant_settings` | 2 |
| `saas.users` | 4 |
| `saas.tenant_memberships` | 5 |
| `saas.projects` | 3 |
| `saas.tasks` | 5 |
| `saas.tags` | 4 |
| `saas.project_tags` | 4 |

`tests/verify_constraints.sql` emits `PASS` notices for these test cases:

1. Duplicate tenant membership rejected (`23505`).
2. Cross-tenant project/tag association rejected (`23503`).
3. Assigning a task to a non-member of that tenant rejected (`23503`).
4. Invalid task status rejected (`23514`).
5. Orphan membership rejected (`23503`).
6. Project primary-key update cascades to its tasks and project-tag links.
7. Project deletion cascades to its tasks and project-tag links.

The two referential-action tests run inside transactions and roll back so the baseline seed data remains available for the final row-count summary.

## Verify locally

Run from the repository root in PowerShell:

```powershell
psql -U postgres -h localhost -p 5432 -d saas_3nf_demo -v ON_ERROR_STOP=1 -f ".\tests\run_all.sql"
$LASTEXITCODE
```

The psql exit code should be `0` if the script completes successfully. Capture your actual terminal output after running the script and add it to the repository if your mentor requests execution evidence.
