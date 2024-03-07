-- Complain if script is sourced in `psql`, rather than via `CREATE EXTENSION`.
\echo Use "CREATE EXTENSION pg_text_semver" to load this file. \quit

--------------------------------------------------------------------------------------------------------------

comment on extension pg_text_semver is
$markdown$
# PostgreSQL semantic versioning extension: `pg_text_semver`

[![PGXN version](https://badge.fury.io/pg/pg_text_semver.svg)](https://badge.fury.io/pg/pg_text_semver)

This is [not the only](#alternatives-to-pg_text_semver) Postgres extension that
implements the [Semantic Versioning 2.0.0
Specification](https://semver.org/spec/v2.0.0.html); what sets this one apart
is that offers a simple `semver` `DOMAIN` based on Postgres'
built-in `text` type.

## `pg_text_semver` features

* Values of the [`semver`](#domain-semver) domain type can be compared:
  - using the usual comparison operators—`<`, '>`, `<=`, `>=`, `<>`, `!=`, and
    `=`—; or
  - using the [`semver_cmp(semver, semver)`](#function-semver_cmp-semver-semver)
    function directly.
* The [`semver`](#domain-semver) domain is constrained using the
  [`semver_regexp()`](#function-semver_regexp-boolean) function.  This means
  that you can also access this regular expression directly, either with
  capturing groups or without, by passing `true` or `false` to the function,
  respectively.
* Parsed `semver` values can be obtained by casting to the `semver_parsed`
  composite type.
* All the same comparison operators and functions exist for `semver_parsed` as
  do for plain `semver` values.
* In addition, `semver_parsed` values can be used for sorting and indexing.
* `semver_parsed` values can be serialized to a properly formatted semantic
  version by casting (back) to `semver` or `text`.
* There's a separate [`semver_prerelease`](#domain-semver_prerelease) domain
  type, so that the prerelease portions of semantic versions can be validated
  or compared (using the
  [`semver_prerelease_cmp()`](#function-semver_prerelease_cmp-semver_prerelease-semver_prerelease)
  function.

## Installation

Basically:

```
sudo make install
```

Like most Postgres extensions, `pg_text_semver` requires [Postgres' PGXS build
infrastructure](https://www.postgresql.org/docs/current/extend-pgxs.html) for
`make install` to work.  Depending on your OS, this may or may not require
you to install anything in addition to the package you need to install to get
the `postgres` daemon up and running.

## `pg_text_semver` usage

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
            "develop": {
                "recommends": {
                    "pg_readme": 0
                }
            }
        }'::jsonb
        ,'provides'
        ,('{
            "pg_safer_settings": {
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

create function semver_prerelease_regexp()
    returns text
    immutable
    leakproof
    parallel safe
    return '^(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*$';

--------------------------------------------------------------------------------------------------------------

create domain semver_prerelease
    as text
    check (value ~ semver_prerelease_regexp());

--------------------------------------------------------------------------------------------------------------

create type semver_parsed as (
    major text
    ,minor text
    ,patch text
    ,prerelease text
    ,build text
);

comment on type semver_parsed is
$md$This composite type can be used to access the individual parts of a `semver`.

A semantic version can take 4 forms.  Depending on the form, the `prerelease` and/or `build` fields may be
`NLL`.  `major`, `minor` and `patch` can never be `NULL` for a valid semantic version.

| #  | Form                                           | Example           | `prerelease` | `build`    |
| -- | ---------------------------------------------- | ----------------- | ------------ | ---------- |
| 1. | `<major>.<minor>.<patch>`                      | 1.0.22            | `NULL`       | `NULL`     |
| 2. | `<major>.<minor>.<patch>-<prerelease>`         | 1.0.22-alpha2     | `NOT NULL`   | `NULL`     |
| 3. | `<major>.<minor>.<patch>-<prerelease>+<build>` | 1.0.22-alpha2+arm | `NOT NULL`   | `NOT NULL` |
| 4. | `<major>.<minor>.<patch>+<build>`              | 1.0.22+arm        | `NULL`       | `NOT NULL` |

To unparse/serialize a `semver_parsed` composite values, cast it to `semver` or `text`.
$md$;

--------------------------------------------------------------------------------------------------------------

create function semver_parsed(text)
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

create function semver_parsed(semver)
    returns semver_parsed
    immutable
    leakproof
    parallel safe
    language sql
    return semver_parsed($1::text);

--------------------------------------------------------------------------------------------------------------

create cast (text as semver_parsed)
    with function semver_parsed(text)
    as assignment;

--------------------------------------------------------------------------------------------------------------

create function semver(semver_parsed)
    returns semver
    immutable
    leakproof
    parallel safe
    language sql
    return ($1).major || '.' || ($1).minor || '.' || ($1).patch
        || coalesce('-' || ($1).prerelease,  '')
        || coalesce('+' || ($1).build,  '');

--------------------------------------------------------------------------------------------------------------

create cast (semver_parsed as text)
    with function semver(semver_parsed)
    as assignment;

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

comment on function semver_eq(semver, semver) is
$md$This functions returns true if two semantic versions are _semantically_ identical to each other, false otherwise.

This is the only function in the `semver_<op>(semver, semver)` family that does
not utilize `semver_cmp(semver, semver)`.  Whether that one extra level of
indirection would indeed hinder performance remains to be tested, as of March
2, 2024.
$md$;

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

create function semver_prerelease_eq(semver_prerelease, semver_prerelease)
    returns bool
    immutable
    leakproof
    parallel safe
    language sql
    return case
        when semver_prerelease_cmp($1, $2) = 0 then true
        else false
    end;

create operator = (
    leftarg = semver_prerelease
    ,rightarg = semver_prerelease
    ,function = semver_prerelease_eq
    ,negator = !=
);

create function semver_prerelease_gt(semver_prerelease, semver_prerelease)
    returns bool
    immutable
    leakproof
    parallel safe
    language sql
    return case
        when semver_prerelease_cmp($1, $2) = 1 then true
        else false
    end;

create operator > (
    leftarg = semver_prerelease
    ,rightarg = semver_prerelease
    ,function = semver_prerelease_gt
    ,commutator = <
    ,negator = <=
);

create function semver_prerelease_ge(semver_prerelease, semver_prerelease)
    returns bool
    immutable
    leakproof
    parallel safe
    language sql
    return case
        when semver_prerelease_cmp($1, $2) >= 0 then true
        else false
    end;

create operator >= (
    leftarg = semver_prerelease
    ,rightarg = semver_prerelease
    ,function = semver_prerelease_ge
    ,commutator = <=
    ,negator = <
);

create function semver_prerelease_lt(semver_prerelease, semver_prerelease)
    returns bool
    immutable
    leakproof
    parallel safe
    language sql
    return case
        when semver_prerelease_cmp($1, $2) = -1 then true
        else false
    end;

create operator < (
    leftarg = semver_prerelease
    ,rightarg = semver_prerelease
    ,function = semver_prerelease_lt
    ,commutator = >
    ,negator = >=
);

create function semver_prerelease_le(semver_prerelease, semver_prerelease)
    returns bool
    immutable
    leakproof
    parallel safe
    language sql
    return case
        when semver_prerelease_cmp($1, $2) <= 0 then true
        else false
    end;

create operator <= (
    leftarg = semver_prerelease
    ,rightarg = semver_prerelease
    ,function = semver_prerelease_le
    ,commutator = >=
    ,negator = >
);

--------------------------------------------------------------------------------------------------------------

create function semver_cmp(semver_parsed, semver_parsed)
    returns int
    immutable
    leakproof
    parallel safe
    language sql
    return (
        select
            case
                when length(($1).major) > length(($2).major)
                    then 1
                when length(($1).major) < length(($2).major)
                    then -1
                when ($1).major > ($2).major
                    then 1
                when ($1).major < ($2).major
                    then -1
                when length(($1).minor) > length(($2).minor)
                    then 1
                when length(($1).minor) < length(($2).minor)
                    then -1
                when ($1).minor > ($2).minor
                    then 1
                when ($1).minor < ($2).minor
                    then -1
                when length(($1).patch) > length(($2).patch)
                    then 1
                when length(($1).patch) < length(($2).patch)
                    then -1
                when ($1).patch > ($2).patch
                    then 1
                when ($1).patch < ($2).patch
                    then -1
                else semver_prerelease_cmp(($1).prerelease, ($2).prerelease)
            end
    );

--------------------------------------------------------------------------------------------------------------

create function semver_eq(semver_parsed, semver_parsed)
    returns bool
    immutable
    leakproof
    parallel safe
    language sql
    return case
        when semver_cmp($1, $2) = 0 then true
        else false
    end;

create operator = (
    leftarg = semver_parsed
    ,rightarg = semver_parsed
    ,function = semver_eq
    ,negator = !=
);

create function semver_gt(semver_parsed, semver_parsed)
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
    leftarg = semver_parsed
    ,rightarg = semver_parsed
    ,function = semver_gt
    ,commutator = <
    ,negator = <=
);

create function semver_ge(semver_parsed, semver_parsed)
    returns bool
    immutable
    leakproof
    parallel safe
    language sql
    return case
        when semver_cmp($1, $2) >= 0 then true
        else false
    end;

create operator >= (
    leftarg = semver_parsed
    ,rightarg = semver_parsed
    ,function = semver_ge
    ,commutator = <=
    ,negator = <
);

create function semver_lt(semver_parsed, semver_parsed)
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
    leftarg = semver_parsed
    ,rightarg = semver_parsed
    ,function = semver_lt
    ,commutator = >
    ,negator = >=
);

create function semver_le(semver_parsed, semver_parsed)
    returns bool
    immutable
    leakproof
    parallel safe
    language sql
    return case
        when semver_cmp($1, $2) <= 0 then true
        else false
    end;

create operator <= (
    leftarg = semver_parsed
    ,rightarg = semver_parsed
    ,function = semver_le
    ,commutator = >=
    ,negator = >
);

create operator class text_semver_parsed_ops
    default for type semver_parsed using btree as
        operator 1 < ,
        operator 2 <= ,
        operator 3 = ,
        operator 4 >= ,
        operator 5 > ,
        function 1 semver_cmp(semver_parsed, semver_parsed);

--------------------------------------------------------------------------------------------------------------

create function semver_cmp(semver, semver)
    returns int
    immutable
    leakproof
    parallel safe
    language sql
    return semver_cmp(semver_parsed($1), semver_parsed($2));

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
    ,negator = <=
);

create function semver_ge(semver, semver)
    returns bool
    immutable
    leakproof
    parallel safe
    language sql
    return case
        when semver_cmp($1, $2) >= 0 then true
        else false
    end;

create operator >= (
    leftarg = semver
    ,rightarg = semver
    ,function = semver_ge
    ,commutator = <=
    ,negator = <
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
    ,negator = >=
);

create function semver_le(semver, semver)
    returns bool
    immutable
    leakproof
    parallel safe
    language sql
    return case
        when semver_cmp($1, $2) <= 0 then true
        else false
    end;

create operator <= (
    leftarg = semver
    ,rightarg = semver
    ,function = semver_le
    ,commutator = >=
    ,negator = >
);

/*
create operator class text_semver_ops
    default for type semver using btree as
        operator 1 < ,
        operator 2 <= ,
        operator 3 = ,
        operator 4 >= ,
        operator 5 > ,
        function 1 semver_cmp(semver, semver);
*/

--------------------------------------------------------------------------------------------------------------

create function semver_greatest(semver, semver)
    returns semver
    --returns null on null input
    immutable
    leakproof
    parallel safe
    language sql
    return case
        when $1 is not null and $2 is null then
            $1
        when $1 is null and $2 is not null then
            $2
        when $1 > $2 then
            $1
        else
            $2
    end;

--------------------------------------------------------------------------------------------------------------

create aggregate max(semver)
(
    sfunc = semver_greatest,
    stype = semver
);

--------------------------------------------------------------------------------------------------------------

create function semver_least(semver, semver)
    returns semver
    --returns null on null input
    immutable
    leakproof
    parallel safe
    language sql
    return case
        when $1 is not null and $2 is null then
            $1
        when $1 is null and $2 is not null then
            $2
        when $1 < $2 then
            $1
        else
            $2
    end;

--------------------------------------------------------------------------------------------------------------

create aggregate min(semver)
(
    sfunc = semver_least,
    stype = semver
);

--------------------------------------------------------------------------------------------------------------

create function semver_cmp(semver, semver, text)
    returns bool
    immutable
    leakproof
    parallel safe
begin atomic
    with cmp_op_value (cmp_op, cmp_val) as (
        values
            ('>',    1)
            ,('>=',  0)
            ,('>=',  1)
            ,('==',  0)
            ,('=',   0)
            ,('!=', -1)
            ,('!=',  1)
            ,('<>', -1)
            ,('<>',  1)
            ,('<=',  0)
            ,('<=', -1)
            ,('<',  -1)
    )
    select exists (
        select from
            cmp_op_value
        where
            cmp_val = semver_cmp($1, $2)
            and cmp_op = $3
    );
end;

comment on function semver_cmp(semver, semver, text) is
$md$This function is convenient if you want to compare two versions, and want to dynamically give the comparison operator as a third argument rather than hardcoding the call to a specific comparison operator (function).

Both the SQL notation and non-SQL notation of some operators are supported, to
be at least flexible enough to, for instance, support testing [version
range](https://pgxn.org/spec/#Version.Ranges) constraints according to the PGXN
spec.
$md$;

--------------------------------------------------------------------------------------------------------------

create function nonsemver_cmp(text, text, text)
    returns bool
    returns null on null input
    immutable
    leakproof
    parallel safe
    return case
        when $3 in ('=', '==') then
            $1 = $2
        when $3 in ('!=', '<>') then
            $1 != $2
        else
            null
    end;

comment on function nonsemver_cmp(text, text, text) is
$md$When we don't know the semantics of two version strings, it's hard to compare them for anything else than equality.  But, in case you do want to do that, there's this function.

The first two function arguments are the versions to compare.  The third
argument must be an unequality operator (`'='` or `'=='`) or an unequality
operator (`'!='` or `'<>'`).
$md$;

--------------------------------------------------------------------------------------------------------------

create function meta_pgxn_version_range(text)
    returns table (version_range_op text, version_no text, any_version bool)
    immutable
    leakproof
    parallel safe
begin atomic
    select
        case
            when re_groups[1] is not null then
                re_groups[1]
            when any_version then
                null
            else
                '>='  -- The default in the absense of an operator is `>=`.
        end
        ,nullif(re_groups[2], '0')
        ,any_version
    from
        regexp_split_to_table($1, ',\s*') as version_range
    cross join lateral (
            select
                case
                    when version_range = '0' then true
                    else false
                end as any_version
        ) as a
    cross join lateral (
            select
                regexp_match(version_range, '^(>|>=|==|!=|<=|<)? *([0-9].*)$') as re_groups
        ) as r
    ;
end;

comment on function meta_pgxn_version_range(text) is
$md$Returns a row for each element from a _Version Ranges_ value that adheres to the PGXN `META.json` spec.

When dealing with [version ranges](https://pgxn.org/spec/#Version.Ranges) from
a PGXN `META.json` file, it may be convenient to parse these out so that the
constraints can then, for example be fed into [`semver_cmp(semver, semver,
text)`](#function-semver_cmp-semver-semver-text).
$md$;

--------------------------------------------------------------------------------------------------------------

create function meta_pgxn_version_range_cmp(text, text)
    returns bool
    returns null on null input
    immutable
    leakproof
    parallel safe
    language plpgsql
    as $$
declare
    _version_range_op text;
    _version_no text;
    _nonsemver bool := $1 !~ semver_regexp();
begin
    if $2 = '0' then
        return true;
    end if;

    _nonsemver := (
        select
            _nonsemver or bool_or(r.version_no !~ semver_regexp())
        from
            meta_pgxn_version_range($2) as r
    );

    if _nonsemver then
        return (
            select
                case
                    when bool_or(nonsemver_cmp($1, r.version_no, r.version_range_op) is null) then
                        null
                    else
                        bool_and(nonsemver_cmp($1, r.version_no, r.version_range_op) is true)
                end
            from
            meta_pgxn_version_range($2) as r
        );
    end if;

    return (
        select
            case
                when bool_or(semver_cmp($1, r.version_no, r.version_range_op) is null) then
                    null
                else
                    bool_and(semver_cmp($1, r.version_no, r.version_range_op) is true)
            end
        from
            meta_pgxn_version_range($2) as r
    );
end;
$$;

comment on function meta_pgxn_version_range_cmp(text, text) is
$md$Use this function if you want to check a version (semantic or otherwise) against a PGXN `META.json` Version Ranges.

This function takes 2 arguments:

1. a [Version Ranges](https://pgxn.org/spec/#Version.Ranges) string confirmed to
   PGXN's `META.json` spec; and
2. a version string to tests against the Version Ranges;
$md$;

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

    -- Remember the buildup of a semver: <major>.<minor>.<patch>-<prerelease>+<build>

    -- We can validate the prerelease portion of a semantic version separately:
    assert 'alpha-1' ~ semver_prerelease_regexp();
    assert '0123' !~ semver_prerelease_regexp(), '0 may NOT lead in a numeric prerelease identifer.';
    assert '0something' ~ semver_prerelease_regexp(), '0 MAY lead in an ALPHAnumeric prerelease identifer.';

    -- Or we can use the domain that uses that regexp in its check constraint:
    perform 'alpha-1'::semver_prerelease;
    perform 'alpha28743'::semver_prerelease;
    perform '0.1.a.a1-.99-e'::semver_prerelease;
    perform 'a1.99-e-'::semver_prerelease;
    perform null::semver_prerelease, 'A prerelease tag is not a mandatory part of a semantic version.';

    --
    -- The prerelease parts of semantic versions can be separately compared:

    assert semver_prerelease_cmp(null, 'beta') = 1;
    assert null::semver_prerelease > 'beta'::semver_prerelease;

    assert semver_prerelease_cmp(null, null) = 0;
    assert null::semver_prerelease = null::semver_prerelease, 'Missing prerelease tags should count equally.';

    assert semver_prerelease_cmp('same', 'same') = 0;
    assert 'same'::semver_prerelease = 'same'::semver_prerelease;
    assert 's.4.m.e'::semver_prerelease = 's.4.m.e'::semver_prerelease;

    assert semver_prerelease_cmp('alpha', null) = -1;
    assert 'alpha'::semver_prerelease < null::semver_prerelease;

    assert semver_prerelease_cmp('string.180', 'string.20') = 1;
    assert 'string.180'::semver_prerelease > 'string.20'::semver_prerelease;

    assert semver_prerelease_cmp('has.3.identifiers', 'has.3.identifiers.plus-1') = -1;
    assert 'has.3.identifiers'::semver_prerelease < 'has.3.identifiers.plus-1'::semver_prerelease;

    assert semver_prerelease_cmp('0.1.2.3.4', '0.1.2.3.4') = 0;
    assert '0.1.2.3.4'::semver_prerelease = '0.1.2.3.4'::semver_prerelease;

    assert semver_prerelease_cmp('0.1.2.3.4.5', '0.1.2.3.4') = 1;
    assert '0.1.2.3.4.5'::semver_prerelease > '0.1.2.3.4'::semver_prerelease;

    --
    -- The `semvver_parsed` type and accompanying functions are used by the `semver` comparison functions,
    -- so we test the former first because we want to test from the deepest dependency up, which is also
    -- why we _started_ by testing the `semver_prerelease` domain and its associated functions.
    --

    -- We cast to `jsonb` here to bypass `semver_parsed` its very own equality operator.
    assert to_jsonb(semver_parsed('1.0.0')) = to_jsonb(row('1', '0', '0', null, null)::semver_parsed);
    assert to_jsonb(semver_parsed('8.4.7-alpha')) = to_jsonb(row('8', '4', '7', 'alpha', null)::semver_parsed);
    assert to_jsonb(semver_parsed('1.0.0+commit-x')) = to_jsonb(row('1', '0', '0', null, 'commit-x')::semver_parsed);
    assert to_jsonb(semver_parsed('1.0.0-a.1+commit-y')) = to_jsonb(row('1', '0', '0', 'a.1', 'commit-y')::semver_parsed);

    -- Semantic versions can be constructed from a composite by casting to `text`.
    assert row('1', '0', '0', null, null)::semver_parsed::text = '1.0.0';
    -- Or by casting to `semver` (a `text` `DOMAIN`):
    assert row('1', '0', '0', null, null)::semver_parsed::semver = '1.0.0';
    -- When we cast to `semver`, validation is implicit:
    begin
        perform row('l', '0', 'l', null, null)::semver_parsed::semver;
        raise assert_failure using message = 'l.0.l should not be accepted as a valid semver.';
    exception when check_violation then
    end;

    -- `semver_parsed` can be ordered semantically.
    declare
        _presorted text[] = array[
            '0.0.9'
            ,'0.0.88-alpha-2-a'
            ,'0.0.88+stuff'
            ,'0.0.88'
            ,'1.0.0-a'
            ,'1.0.0-a.123'
            ,'1.0.0'
        ];
        _shuffled text[] = array[
            '0.0.88-alpha-2-a'
            ,'0.0.88'
            ,'0.0.9'
            ,'1.0.0'
            ,'1.0.0-a.123'
            ,'1.0.0-a'
            ,'0.0.88+stuff'
        ];
        _resorted text[] = (select array_agg(v order by v::semver_parsed) from unnest(_shuffled) as v);
    begin
        assert _resorted = _presorted, format('%s ≠ %s', _resorted, _presorted);
    end;

    assert '0.9.3'::semver < '0.11.2'::semver;
    assert '10.0.0'::semver > '2.9.9'::semver;

    assert '1.0.0-alpha'::semver < '1.0.0'::semver;
    assert '1.0.0-alpha'::semver < '1.0.0-alpha.2'::semver;
    assert '1.0.0-alpha.1'::semver < '1.0.0-alpha.2'::semver;
    assert '1.0.0-alpha.1'::semver < '1.0.0-alpha.a'::semver;
    assert '1.0.0-alpha'::semver < '1.0.0-beta'::semver;

    assert '8.8.8+bla'::semver = '8.8.8'::semver,
        '“Build metadata MUST be ignored when determining version precedence.”';
    assert '8.8.8+bla'::semver = '8.8.8+bah'::semver,
        '“Build metadata MUST be ignored when determining version precedence.”';
    assert '8.8.8-alpha+build12'::semver = '8.8.8-alpha+build13'::semver,
        '“Build metadata MUST be ignored when determining version precedence.”';
    assert '8.8.8-alpha+build12'::semver = '8.8.8-alpha'::semver;

    -- Unlike `semver_parsed`, plain `semver` cannot be ordered semantically; because `semver` is a `text`
    -- domain, it will be sorted lexically as such.  _But_, we can always cast to `semver_parsed` for
    -- ordering and indexing.  Do remember to index on that cast expression then, or your queries will be
    -- slow!
    declare
        _presorted text[] := array[
            '0.0.9'
            ,'0.0.88-alpha-2-a'
            ,'0.0.88+stuff'
            ,'0.0.88'
            ,'1.0.0-a'
            ,'1.0.0-a.123'
            ,'1.0.0'
        ];
        _shuffled text[] := array[
            '0.0.88-alpha-2-a'
            ,'0.0.88'
            ,'0.0.9'
            ,'1.0.0'
            ,'1.0.0-a.123'
            ,'1.0.0-a'
            ,'0.0.88+stuff'
        ];
        _resorted text[];
    begin
        create temporary table shuffled (v semver);
        insert into shuffled select v from unnest(_shuffled) as v;
        --create index on shuffled (v text_semver_ops);  -- Operator classes for domains are ignored.
        create index on shuffled ((v::semver_parsed));
        _resorted := (select array_agg(v order by v::semver_parsed) from shuffled);
        assert _resorted = _presorted, format('%s ≠ %s', _resorted, _presorted);
    end;

    declare
        _shuffled text[] := array[
            '0.0.88'
            ,'1.0.0+stuff'
            ,'1.0.0'
            ,'1.0.0-a'
            ,'0.0.88+stuff'
            ,'0.0.88-alpha-2-a'
            ,'1.0.0-a.123'
        ];
    begin
        -- `min(semver)` and `max(semver)` are also possible:
        assert (select min(v::semver) from unnest(_shuffled) as v)::text = '0.0.88-alpha-2-a';
        assert (select max(v::semver) from unnest(_shuffled) as v)::text in ('1.0.0', '1.0.0+stuff');
    end;

    perform null::semver;

    -- There are some circumstances (like when parsing PGXN Version Ranges) where you may want to specify the
    -- operator dynamically rather that hardcode it in an expression; meet `semver_cmp(semver, semver, text)`:
    assert semver_cmp('0.4.1', '0.4.2', '<');
    assert semver_cmp('0.4.1', '0.4.2', '<=');
    assert semver_cmp('0.4.2', '0.4.2', '<=');
    assert semver_cmp('0.4.2', '0.4.2', '==');
    assert semver_cmp('0.4.2', '0.4.2', '=');
    assert semver_cmp('0.4.2', '0.4.2', '>=');
    assert semver_cmp('0.4.3', '0.4.2', '>=');
    assert semver_cmp('0.4.3', '0.4.2', '>');
    assert semver_cmp('0.4.3', '0.4.2', '<>');
    assert semver_cmp('0.4.2', '0.4.3', '<>');
    assert semver_cmp('0.4.3', '0.4.2', '!=');
    assert semver_cmp('0.4.2', '0.4.3', '!=');

    -- Speaking of PGXN `META.json` Version Ranges, you might want some help parsing them:
    assert (select array_agg(r.*) from meta_pgxn_version_range('1.9.8') r)
        = array[row('>='::text, '1.9.8'::text, false)];
    assert (select array_agg(r.*) from meta_pgxn_version_range('0') r)
        = array[row(null::text, null::text, true)];
    assert (select array_agg(r.*) from meta_pgxn_version_range('> 1.8.0, != 1.8.4-alpha, < 2.0.0') r)
        = array[
            row('>'::text,   '1.8.0'::text,       false)
            ,row('!='::text, '1.8.4-alpha'::text, false)
            ,row('<'::text,  '2.0.0'::text,       false)
        ];

    -- You can even check a PGXN `META.json` Version Ranges specification directly against a given version:
    assert meta_pgxn_version_range_cmp('6.7.200-alpha-2+build.3', '0');
    assert meta_pgxn_version_range_cmp('not-a-semver', '>= 1.0.0') is null;
    assert meta_pgxn_version_range_cmp('1.8.4', '> 1.8.0, != 1.8.4-alpha, < 2.0.0');
    assert not meta_pgxn_version_range_cmp('1.7.0', '> 1.8.0, != 1.8.4-alpha, < 2.0.0');
    assert not meta_pgxn_version_range_cmp('1.8.0', '> 1.8.0, != 1.8.4-alpha, < 2.0.0');
    assert not meta_pgxn_version_range_cmp('1.8.4-alpha', '> 1.8.0, != 1.8.4-alpha, < 2.0.0');
    assert not meta_pgxn_version_range_cmp('2.0.0', '> 1.8.0, != 1.8.4-alpha, < 2.0.0');

    raise transaction_rollback;
exception
    when transaction_rollback then
end;
$$;

--------------------------------------------------------------------------------------------------------------
