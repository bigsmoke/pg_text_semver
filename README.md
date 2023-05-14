---
pg_extension_name: pg_text_semver
pg_extension_version: 0.1.4
pg_readme_generated_at: 2023-05-14 22:46:23.639191+01
pg_readme_version: 0.6.3
---

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

## Object reference

### Routines

#### Function: `pg_text_semver_meta_pgxn()`

Returns the JSON meta data that has to go into the `META.json` file needed for PGXN—PostgreSQL Extension Network—packages.

The `Makefile` includes a recipe to allow the developer to: `make META.json` to
refresh the meta file with the function's current output, including the
`default_version`.

And indeed, `pg_safer_settings` can be found on PGXN:
https://pgxn.org/dist/pg_safer_settings/

Function return type: `jsonb`

Function attributes: `STABLE`

#### Function: `pg_text_semver_readme()`

This function utilizes the `pg_readme` extension to generate a thorough README for this extension, based on the `pg_catalog` and the `COMMENT` objects found therein.

Function return type: `text`

Function-local settings:

  *  `SET search_path TO public, pg_temp`
  *  `SET pg_readme.include_view_definitions TO true`
  *  `SET pg_readme.include_routine_definitions_like TO {test__%}`

#### Function: `semver_cmp (semver, semver)`

Function arguments:

| Arg. # | Arg. mode  | Argument name                                                     | Argument type                                                        | Default expression  |
| ------ | ---------- | ----------------------------------------------------------------- | -------------------------------------------------------------------- | ------------------- |
|   `$1` |       `IN` |                                                                   | `semver`                                                             |  |
|   `$2` |       `IN` |                                                                   | `semver`                                                             |  |

Function return type: `integer`

Function attributes: `IMMUTABLE`, `LEAKPROOF`, `PARALLEL SAFE`

#### Function: `semver_eq (semver, semver)`

Function arguments:

| Arg. # | Arg. mode  | Argument name                                                     | Argument type                                                        | Default expression  |
| ------ | ---------- | ----------------------------------------------------------------- | -------------------------------------------------------------------- | ------------------- |
|   `$1` |       `IN` |                                                                   | `semver`                                                             |  |
|   `$2` |       `IN` |                                                                   | `semver`                                                             |  |

Function return type: `boolean`

Function attributes: `IMMUTABLE`, `LEAKPROOF`, `PARALLEL SAFE`

#### Function: `semver_gt (semver, semver)`

Function arguments:

| Arg. # | Arg. mode  | Argument name                                                     | Argument type                                                        | Default expression  |
| ------ | ---------- | ----------------------------------------------------------------- | -------------------------------------------------------------------- | ------------------- |
|   `$1` |       `IN` |                                                                   | `semver`                                                             |  |
|   `$2` |       `IN` |                                                                   | `semver`                                                             |  |

Function return type: `boolean`

Function attributes: `IMMUTABLE`, `LEAKPROOF`, `PARALLEL SAFE`

#### Function: `semver_lt (semver, semver)`

Function arguments:

| Arg. # | Arg. mode  | Argument name                                                     | Argument type                                                        | Default expression  |
| ------ | ---------- | ----------------------------------------------------------------- | -------------------------------------------------------------------- | ------------------- |
|   `$1` |       `IN` |                                                                   | `semver`                                                             |  |
|   `$2` |       `IN` |                                                                   | `semver`                                                             |  |

Function return type: `boolean`

Function attributes: `IMMUTABLE`, `LEAKPROOF`, `PARALLEL SAFE`

#### Function: `semver_parsed (semver)`

Function arguments:

| Arg. # | Arg. mode  | Argument name                                                     | Argument type                                                        | Default expression  |
| ------ | ---------- | ----------------------------------------------------------------- | -------------------------------------------------------------------- | ------------------- |
|   `$1` |       `IN` |                                                                   | `semver`                                                             |  |

Function return type: `semver_parsed`

Function attributes: `IMMUTABLE`, `LEAKPROOF`, `PARALLEL SAFE`

#### Function: `semver_prerelease_cmp (semver_prerelease, semver_prerelease)`

Function arguments:

| Arg. # | Arg. mode  | Argument name                                                     | Argument type                                                        | Default expression  |
| ------ | ---------- | ----------------------------------------------------------------- | -------------------------------------------------------------------- | ------------------- |
|   `$1` |       `IN` |                                                                   | `semver_prerelease`                                                  |  |
|   `$2` |       `IN` |                                                                   | `semver_prerelease`                                                  |  |

Function return type: `integer`

Function attributes: `IMMUTABLE`, `LEAKPROOF`, `PARALLEL SAFE`

#### Function: `semver_regexp (boolean)`

Returns a regular expression to match or parse a semantic version string.

The regular expression is based on the official regular expression from [semver.or](https://semver.org/).

Function arguments:

| Arg. # | Arg. mode  | Argument name                                                     | Argument type                                                        | Default expression  |
| ------ | ---------- | ----------------------------------------------------------------- | -------------------------------------------------------------------- | ------------------- |
|   `$1` |       `IN` | `with_capture_groups$`                                            | `boolean`                                                            | `false` |

Function return type: `text`

Function attributes: `IMMUTABLE`, `LEAKPROOF`, `PARALLEL SAFE`

#### Procedure: `test__pg_text_semver()`

Procedure-local settings:

  *  `SET search_path TO pg_catalog`
  *  `SET plpgsql.check_asserts TO true`
  *  `SET pg_readme.include_this_routine_definition TO true`

```sql
CREATE OR REPLACE PROCEDURE public.test__pg_text_semver()
 LANGUAGE plpgsql
 SET search_path TO 'pg_catalog'
 SET "plpgsql.check_asserts" TO 'true'
 SET "pg_readme.include_this_routine_definition" TO 'true'
AS $procedure$
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
$procedure$
```

### Types

The following extra types have been defined _besides_ the implicit composite types of the [tables](#tables) and [views](#views) in this extension.

#### Domain: `semver`

```sql
CREATE DOMAIN semver AS text
  CHECK ((VALUE ~ semver_regexp(false)));
```

#### Domain: `semver_prerelease`

```sql
CREATE DOMAIN semver_prerelease AS text
  CHECK ((VALUE ~ '^(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*$'::text));
```

#### Composite type: `semver_parsed`

```sql
CREATE TYPE semver_parsed AS (
  major text,
  minor text,
  patch text,
  prerelease text,
  build text
);
```

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

## Colophon

This `README.md` for the `pg_text_semver` extension was automatically generated using the [`pg_readme`](https://github.com/bigsmoke/pg_readme) PostgreSQL extension.
