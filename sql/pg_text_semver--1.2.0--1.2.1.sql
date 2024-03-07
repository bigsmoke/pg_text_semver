-- Complain if script is sourced in `psql`, rather than via `CREATE EXTENSION`.
\echo Use "CREATE EXTENSION pg_text_semver" to load this file. \quit

--------------------------------------------------------------------------------------------------------------

-- Fix key in `provides` object.
create or replace function pg_text_semver_meta_pgxn()
    returns jsonb
    stable
    language sql
    return jsonb_build_object(
        'name'
        ,'pg_text_semver'
        ,'abstract'
        ,'PostgreSQL semantic versioning extension, with comparison functions and operators.'
        ,'description'
        ,'The pg_text_semver extension offers a "semver" DOMAIN type based on Postgres'' built-in "text" type.'
        ,'version'
        ,(select extversion from pg_extension where extname = 'pg_text_semver')
        ,'maintainer'
        ,array[
            'Rowan Rodrik van der Molen <rowan@bigsmoke.us>'
        ]
        ,'license'
        ,'postgresql'
        ,'prereqs'
        ,'{
            "develop": {
                "recommends": {
                    "pg_readme": 0
                }
            }
        }'::jsonb
        ,'provides'
        ,('{
            "pg_text_semver": {
                "file": "pg_text_semver--1.2.0.sql",
                "version": "' || (select extversion from pg_extension where extname = 'pg_text_semver') || '",
                "docfile": "README.md"
            }
        }')::jsonb
        ,'resources'
        ,'{
            "homepage": "https://blog.bigsmoke.us/tag/pg_text_semver",
            "bugtracker": {
                "web": "https://github.com/bigsmoke/pg_text_semver/issues"
            },
            "repository": {
                "url": "https://github.com/bigsmoke/pg_text_semver.git",
                "web": "https://github.com/bigsmoke/pg_text_semver",
                "type": "git"
            }
        }'::jsonb
        ,'meta-spec'
        ,'{
            "version": "1.0.0",
            "url": "https://pgxn.org/spec/"
        }'::jsonb
        ,'generated_by'
        ,'`select pg_text_semver_meta_pgxn()`'
        ,'tags'
        ,array[
            'domain',
            'function',
            'functions',
            'plpgsql',
            'semver',
            'settings',
            'type'
        ]
    );

-- `pg_safer_setting` → `pg_text_semver`
comment on function pg_text_semver_meta_pgxn() is
$md$Returns the JSON meta data that has to go into the `META.json` file needed for PGXN—PostgreSQL Extension Network—packages.

The `Makefile` includes a recipe to allow the developer to: `make META.json` to
refresh the meta file with the function's current output, including the
`default_version`.

And indeed, `pg_text_semver` can be found on PGXN:
https://pgxn.org/dist/pg_text_semver/
$md$;

--------------------------------------------------------------------------------------------------------------
