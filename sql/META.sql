\pset tuples_only
\pset format unaligned

begin;

create extension pg_text_semver cascade;

select jsonb_pretty(pg_text_semver_meta_pgxn());

rollback;
