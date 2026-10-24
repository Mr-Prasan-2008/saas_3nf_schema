\set ON_ERROR_STOP on
\echo 'WARNING: This script drops and recreates the saas schema. Use a disposable development/test database.'
DROP SCHEMA IF EXISTS saas CASCADE;
\ir ../migrations/001_initial_schema.sql
\ir ../fixtures/001_seed_data.sql
\ir ./verify_constraints.sql
\echo 'SUCCESS: schema, fixtures, constraint tests, and referential-action tests completed.'
