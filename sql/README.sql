\pset tuples_only
\pset format unaligned

begin;

create schema if not exists ext;
set search_path to ext;

create extension pg_text_semver cascade;

select pg_text_semver_readme();

rollback;
