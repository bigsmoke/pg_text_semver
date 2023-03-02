\set ON_ERROR_STOP

begin;

create extension pg_text_semver cascade;

call test__pg_text_semver();

rollback;
