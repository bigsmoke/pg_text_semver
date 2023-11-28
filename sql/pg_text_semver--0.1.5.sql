-- Complain if script is sourced in `psql`, rather than via `CREATE EXTENSION`.
\echo Use "CREATE EXTENSION pg_text_semver" to load this file. \quit

--------------------------------------------------------------------------------------------------------------

comment on extension pg_text_semver is
$markdown$
# PostgreSQL semantic versioning extension: `pg_text_semver`

[![PGXN version](https://badge.fury.io/pg/pg_text_semver.svg)](https://badge.fury.io/pg/pg_text_semver)

The `pg_text_semver` extension offers a `semver` `DOMAIN` type based on
Postgres' built-in `text` type that implements the [Semantic Versioning 2.0.0
Specification](https://semver.org/spec/v2.0.0.html).

See the [`test__pg_text_semver()`](#procedure-test__pg_text_semver) procedure
for examples of how to use the types, operators and functions provides by this
extension.

## Alternatives to `pg_text_semver`

An excellent pre-existing alternative to `pg_text_semver` is the
[`semver`](https://github.com/theory/pg-semver) extension.  `semver` is written
in C and therefore more efficient than `pg_text_semver`.  But, as of March 2,
2023, [it treats the parts of the semantic version as 32-bit
integers](https://github.com/theory/pg-semver/issues/47), while the spec
prescribes no limitations to the size of each number.

Besides [`semver`](https://github.com/theory/pg-semver) (repo name `pg-semver`,
with a dash), there is also the older [PG
SEMVER](https://github.com/eendroroy/pg_semver) (repo name `pg_semver`, with an
underscore).  The `pg_text_semver` author only discovered PG SEMVER _after_
releasing his own extension, and hasn't tried it; something left to do…

<?pg-readme-reference?>

## Authors and contributors

* [Rowan](https://www.bigsmoke.us/) originated this extension in 2022 while
  developing the PostgreSQL backend for the [FlashMQ SaaS MQTT cloud
  broker](https://www.flashmq.com/).  Rowan does not like to see himself as a
  tech person or a tech writer, but, much to his chagrin, [he
  _is_](https://blog.bigsmoke.us/category/technology). Some of his chagrin
  about his disdain for the IT industry he poured into a book: [_Why
  Programming Still Sucks_](https://www.whyprogrammingstillsucks.com/).  Much
  more than a “tech bro”, he identifies as a garden gnome, fairy and ork rolled
  into one, and his passion is really to [regreen and reenchant his
  environment](https://sapienshabitat.com/).  One of his proudest achievements
  is to be the third generation ecological gardener to grow the wild garden
  around his beautiful [family holiday home in the forest of Norg, Drenthe,
  the Netherlands](https://www.schuilplaats-norg.nl/) (available for rent!).

<?pg-readme-colophon?>
$markdown$;

--------------------------------------------------------------------------------------------------------------

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

comment on function pg_text_semver_readme() is
$md$This function utilizes the `pg_readme` extension to generate a thorough README for this extension, based on the `pg_catalog` and the `COMMENT` objects found therein.
$md$;

--------------------------------------------------------------------------------------------------------------

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
            "test": {
                "requires": {
                    "pgtap": 0
                }
            },
            "develop": {
                "recommends": {
                    "pg_readme": 0
                }
            }
        }'::jsonb
        ,'provides'
        ,('{
            "pg_safer_settings": {
                "file": "pg_text_semver--0.1.5.sql",
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

comment on function pg_text_semver_meta_pgxn() is
$md$Returns the JSON meta data that has to go into the `META.json` file needed for PGXN—PostgreSQL Extension Network—packages.

The `Makefile` includes a recipe to allow the developer to: `make META.json` to
refresh the meta file with the function's current output, including the
`default_version`.

And indeed, `pg_safer_settings` can be found on PGXN:
https://pgxn.org/dist/pg_safer_settings/
$md$;

--------------------------------------------------------------------------------------------------------------

create function semver_regexp(with_capture_groups$ bool = false)
    returns text
    immutable
    leakproof
    parallel safe
    language sql
    return $re$(?x)
^
($re$ || case when with_capture_groups$ then '' else '?:' end || $re$0|[1-9]\d*)  # major version
\.
($re$ || case when with_capture_groups$ then '' else '?:' end || $re$0|[1-9]\d*)  # minor version
\.
($re$ || case when with_capture_groups$ then '' else '?:' end || $re$0|[1-9]\d*)  # patch version
(?:-
    # pre-release version
    ($re$ || case when with_capture_groups$ then '' else '?:' end || $re$
        (?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*
    )
)?
(?:\+
    # build metadata
    ($re$ || case when with_capture_groups$ then '' else '?:' end || $re$
        [0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*
    )
)?
$
$re$;

comment on function semver_regexp(bool) is
$md$Returns a regular expression to match or parse a semantic version string.

The regular expression is based on the official regular expression from [semver.or](https://semver.org/).
$md$;

--------------------------------------------------------------------------------------------------------------

create domain semver
    as text
    check (value ~ semver_regexp(false));

--------------------------------------------------------------------------------------------------------------

create domain semver_prerelease
    as text
    check (
        value ~ '^(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*$'
    );

/*
create domain semver_prerelease
    as text
    check (value ~ $re$
(x:)
^
(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*
$
$re$);
*/

--------------------------------------------------------------------------------------------------------------

create type semver_parsed as (
    major text
    ,minor text
    ,patch text
    ,prerelease text
    ,build text
);

--------------------------------------------------------------------------------------------------------------

create function semver_parsed(semver)
    returns semver_parsed
    immutable
    leakproof
    parallel safe
    language sql
begin atomic
    select
        row(
            (m.match_groups)[1]
            ,(m.match_groups)[2]
            ,(m.match_groups)[3]
            ,(m.match_groups)[4]
            ,(m.match_groups)[5]
        )::semver_parsed
    from (
        select
            regexp_match($1, semver_regexp(true)) as match_groups
    ) as m
    ;
end;

--------------------------------------------------------------------------------------------------------------

create function semver_eq(semver, semver)
    returns bool
    immutable
    leakproof
    parallel safe
    language sql
    return case
        when (regexp_match($1, semver_regexp(true)))[1] = (regexp_match($2, semver_regexp(true)))[1]
            and (regexp_match($1, semver_regexp(true)))[2] = (regexp_match($2, semver_regexp(true)))[2]
            and (regexp_match($1, semver_regexp(true)))[3] = (regexp_match($2, semver_regexp(true)))[3]
            and (regexp_match($1, semver_regexp(true)))[4]
                is not distinct from (regexp_match($2, semver_regexp(true)))[4]
        then true
        else false
    end;

--------------------------------------------------------------------------------------------------------------

create operator = (
    leftarg = semver
    ,rightarg = semver
    ,function = semver_eq
    ,negator = !=
);

--------------------------------------------------------------------------------------------------------------

create function semver_prerelease_cmp(semver_prerelease, semver_prerelease)
    returns int
    called on null input
    immutable
    leakproof
    parallel safe
    language sql
    return
        case
            when $1 is not distinct from $2
                then 0

            -- “When major, minor, and patch are equal, a pre-release version has lower precedence than
            -- a normal version."
            when $1 is null and $2 is not null
                then 1
            when $1 is not null and $2 is null
                then -1

            else coalesce(
                (
                    select
                        diff
                    from (
                        select
                            case
                                -- “A larger set of pre-release fields has a higher precedence than a smaller
                                -- set, if all of the preceding identifiers are equal.”
                                when a.id is not null and b.id is null
                                    then 1
                                when a.id is null and b.id is not null
                                    then -1

                                -- “Numeric identifiers always have lower precedence than non-numeric identifiers.”
                                when a.id ~ '^[0-9]+$' and b.id !~ '^[0-9]+$'
                                    then -1
                                when a.id !~ '^[0-9]+$' and b.id ~ '^[0-9]+$'
                                    then 1

                                -- “Identifiers consisting of only digits are compared numerically.”
                                when a.id ~ '^[0-9]+$' and b.id ~ '^[0-9]+$'
                                    then sign(int8(a.id) - int8(b.id))

                                -- “Identifiers with letters or hyphens are compared lexically in ASCII sort order.”
                                when a.id !~ '^[0-9]+$' and b.id !~ '^[0-9]+$' and a.id < b.id
                                    then -1
                                when a.id !~ '^[0-9]+$' and b.id !~ '^[0-9]+$' and a.id > b.id
                                    then 1

                                else null
                            end as diff
                            ,coalesce(a.pos, b.pos) as pos
                        from
                            string_to_table($1, '.') with ordinality as a(id, pos)
                        full outer join
                            string_to_table($2, '.') with ordinality as b(id, pos)
                            on a.pos = b.pos
                    ) as d
                where
                    diff is not null
                    and diff != 0
                order by
                    pos
                limit
                    1
            )
            ,0
        )
        end
    ;

--------------------------------------------------------------------------------------------------------------

create function semver_cmp(semver, semver)
    returns int
    immutable
    leakproof
    parallel safe
    language sql
    return (
        select
            case
                when length(a.major) > length(b.major)
                    then 1
                when length(a.major) < length(b.major)
                    then -1
                when a.major > b.major
                    then 1
                when a.major < b.major
                    then -1
                when length(a.minor) > length(b.minor)
                    then 1
                when length(a.minor) < length(b.minor)
                    then -1
                when a.minor > b.minor
                    then 1
                when a.minor < b.minor
                    then -1
                when length(a.patch) > length(b.patch)
                    then 1
                when length(a.patch) < length(b.patch)
                    then -1
                when a.patch > b.patch
                    then 1
                when a.patch < b.patch
                    then -1
                else semver_prerelease_cmp(a.prerelease, b.prerelease)
            end
        from
            semver_parsed($1) as a
        cross join lateral
            semver_parsed($2) as b
    );

--------------------------------------------------------------------------------------------------------------

create function semver_gt(semver, semver)
    returns bool
    immutable
    leakproof
    parallel safe
    language sql
    return case
        when semver_cmp($1, $2) = 1 then true
        else false
    end;

create operator > (
    leftarg = semver
    ,rightarg = semver
    ,function = semver_gt
    ,commutator = <
);

create function semver_lt(semver, semver)
    returns bool
    immutable
    leakproof
    parallel safe
    language sql
    return case
        when semver_cmp($1, $2) = -1 then true
        else false
    end;

create operator < (
    leftarg = semver
    ,rightarg = semver
    ,function = semver_lt
    ,commutator = >
);

--------------------------------------------------------------------------------------------------------------

/*
create function semver_eq(semver, semver)
    returns bool
    immutable
    leakproof
    parallel safe
    language sql
    return case
        when semver_cmp($1, $2) = 0 then true
        else false
    end;
*/

--------------------------------------------------------------------------------------------------------------

create procedure test__pg_text_semver()
    set search_path to pg_catalog
    set plpgsql.check_asserts to true
    set pg_readme.include_this_routine_definition to true
    language plpgsql
    as $$
begin
    -- Because this extension is relocatable, let's update the search_path to include the extensions current
    -- schema (which we couldn't have done by `SET search_path TO CURRENT` in the extension setup script.
    perform
        set_config('search_path', e.extnamespace::regnamespace::text || ', pg_catalog', true)
    from
        pg_extension as e
    where
        e.extname = 'pg_text_semver'
    ;

    -- First try some valid, isolated pre-release version.
    perform '0.1.a.a1-.99-e'::semver_prerelease;
    perform 'a1.99-e-'::semver_prerelease;

    -- Let's compare some valid pre-release versions now.
    assert semver_prerelease_cmp(null, 'beta') = 1;
    assert semver_prerelease_cmp(null, null) = 0;
    assert semver_prerelease_cmp('same', 'same') = 0;
    assert semver_prerelease_cmp('alpha', null) = -1;
    assert semver_prerelease_cmp('string.180', 'string.20') = 1;
    assert semver_prerelease_cmp('has.3.identifiers', 'has.3.identifiers.plus-1') = -1;
    assert semver_prerelease_cmp('0.1.2.3.4', '0.1.2.3.4') = 0;
    assert semver_prerelease_cmp('0.1.2.3.4.5', '0.1.2.3.4') = 1;

    assert semver_parsed('1.0.0') = row('1', '0', '0', null, null)::semver_parsed;
    assert semver_parsed('8.4.7-alpha') = row('8', '4', '7', 'alpha', null)::semver_parsed;
    assert semver_parsed('1.0.0+commit-x') = row('1', '0', '0', null, 'commit-x')::semver_parsed;
    assert semver_parsed('1.0.0-a.1+commit-y') = row('1', '0', '0', 'a.1', 'commit-y')::semver_parsed;

    assert '10.0.0'::semver > '2.9.9'::semver;
    assert '1.0.0-alpha'::semver < '1.0.0'::semver;
    assert '8.8.8+bla'::semver = '8.8.8'::semver;
    assert '8.8.8+bla'::semver = '8.8.8+bah'::semver;
end;
$$;

--------------------------------------------------------------------------------------------------------------
