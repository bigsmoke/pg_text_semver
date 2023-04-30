-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION pg_text_semver" to load this file. \quit

--------------------------------------------------------------------------------------------------------------

-- Add `CASCADE` option to `CREATE EXTENSION` statement.
create or replace function pg_text_semver_readme()
    returns text
    volatile
    set search_path from current
    set pg_readme.include_view_definitions to 'true'
    set pg_readme.include_routine_definitions_like to '{test__%}'
    language plpgsql
    as $plpgsql$
declare
    _readme text;
begin
    create extension if not exists pg_readme cascade;

    _readme := pg_extension_readme('pg_text_semver'::name);

    raise transaction_rollback;  -- to `DROP EXTENSION` if we happened to `CREATE EXTENSION` for just this.
exception
    when transaction_rollback then
        return _readme;
end;
$plpgsql$;

--------------------------------------------------------------------------------------------------------------
