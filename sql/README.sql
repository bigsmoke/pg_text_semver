\pset tuples_only
\pset format unaligned

begin;

create extension pg_text_semver cascade;

select pg_text_semver_readme();

rollback;
