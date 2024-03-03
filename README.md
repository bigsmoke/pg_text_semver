---
pg_extension_name: pg_text_semver
pg_extension_version: 1.1.0
pg_readme_generated_at: 2024-03-03 17:19:04.658815+00
pg_readme_version: 0.6.6
---

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

## Object reference

### Routines

#### Function: `max (semver)`

Function arguments:

| Arg. # | Arg. mode  | Argument name                                                     | Argument type                                                        | Default expression  |
| ------ | ---------- | ----------------------------------------------------------------- | -------------------------------------------------------------------- | ------------------- |
|   `$1` |       `IN` |                                                                   | `semver`                                                             |  |

Function return type: `semver`

Function attributes: `IMMUTABLE`, COST 1

#### Function: `min (semver)`

Function arguments:

| Arg. # | Arg. mode  | Argument name                                                     | Argument type                                                        | Default expression  |
| ------ | ---------- | ----------------------------------------------------------------- | -------------------------------------------------------------------- | ------------------- |
|   `$1` |       `IN` |                                                                   | `semver`                                                             |  |

Function return type: `semver`

Function attributes: `IMMUTABLE`, COST 1

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

  *  `SET search_path TO ext, pg_temp`
  *  `SET pg_readme.include_view_definitions TO true`
  *  `SET pg_readme.include_routine_definitions_like TO {test__%}`

#### Function: `semver_cmp (semver_parsed, semver_parsed)`

Function arguments:

| Arg. # | Arg. mode  | Argument name                                                     | Argument type                                                        | Default expression  |
| ------ | ---------- | ----------------------------------------------------------------- | -------------------------------------------------------------------- | ------------------- |
|   `$1` |       `IN` |                                                                   | `semver_parsed`                                                      |  |
|   `$2` |       `IN` |                                                                   | `semver_parsed`                                                      |  |

Function return type: `integer`

Function attributes: `IMMUTABLE`, `LEAKPROOF`, `PARALLEL SAFE`

#### Function: `semver_cmp (semver, semver)`

Function arguments:

| Arg. # | Arg. mode  | Argument name                                                     | Argument type                                                        | Default expression  |
| ------ | ---------- | ----------------------------------------------------------------- | -------------------------------------------------------------------- | ------------------- |
|   `$1` |       `IN` |                                                                   | `semver`                                                             |  |
|   `$2` |       `IN` |                                                                   | `semver`                                                             |  |

Function return type: `integer`

Function attributes: `IMMUTABLE`, `LEAKPROOF`, `PARALLEL SAFE`

#### Function: `semver_eq (semver_parsed, semver_parsed)`

Function arguments:

| Arg. # | Arg. mode  | Argument name                                                     | Argument type                                                        | Default expression  |
| ------ | ---------- | ----------------------------------------------------------------- | -------------------------------------------------------------------- | ------------------- |
|   `$1` |       `IN` |                                                                   | `semver_parsed`                                                      |  |
|   `$2` |       `IN` |                                                                   | `semver_parsed`                                                      |  |

Function return type: `boolean`

Function attributes: `IMMUTABLE`, `LEAKPROOF`, `PARALLEL SAFE`

#### Function: `semver_eq (semver, semver)`

This functions returns true if two semantic versions are _semantically_ identical to each other, false otherwise.

This is the only function in the `semver_<op>(semver, semver)` family that does
not utilize `semver_cmp(semver, semver)`.  Whether that one extra level of
indirection would indeed hinder performance remains to be tested, as of March
2, 2024.

Function arguments:

| Arg. # | Arg. mode  | Argument name                                                     | Argument type                                                        | Default expression  |
| ------ | ---------- | ----------------------------------------------------------------- | -------------------------------------------------------------------- | ------------------- |
|   `$1` |       `IN` |                                                                   | `semver`                                                             |  |
|   `$2` |       `IN` |                                                                   | `semver`                                                             |  |

Function return type: `boolean`

Function attributes: `IMMUTABLE`, `LEAKPROOF`, `PARALLEL SAFE`

#### Function: `semver_ge (semver_parsed, semver_parsed)`

Function arguments:

| Arg. # | Arg. mode  | Argument name                                                     | Argument type                                                        | Default expression  |
| ------ | ---------- | ----------------------------------------------------------------- | -------------------------------------------------------------------- | ------------------- |
|   `$1` |       `IN` |                                                                   | `semver_parsed`                                                      |  |
|   `$2` |       `IN` |                                                                   | `semver_parsed`                                                      |  |

Function return type: `boolean`

Function attributes: `IMMUTABLE`, `LEAKPROOF`, `PARALLEL SAFE`

#### Function: `semver_ge (semver, semver)`

Function arguments:

| Arg. # | Arg. mode  | Argument name                                                     | Argument type                                                        | Default expression  |
| ------ | ---------- | ----------------------------------------------------------------- | -------------------------------------------------------------------- | ------------------- |
|   `$1` |       `IN` |                                                                   | `semver`                                                             |  |
|   `$2` |       `IN` |                                                                   | `semver`                                                             |  |

Function return type: `boolean`

Function attributes: `IMMUTABLE`, `LEAKPROOF`, `PARALLEL SAFE`

#### Function: `semver_greatest (semver, semver)`

Function arguments:

| Arg. # | Arg. mode  | Argument name                                                     | Argument type                                                        | Default expression  |
| ------ | ---------- | ----------------------------------------------------------------- | -------------------------------------------------------------------- | ------------------- |
|   `$1` |       `IN` |                                                                   | `semver`                                                             |  |
|   `$2` |       `IN` |                                                                   | `semver`                                                             |  |

Function return type: `semver`

Function attributes: `IMMUTABLE`, `LEAKPROOF`, `PARALLEL SAFE`

#### Function: `semver_gt (semver_parsed, semver_parsed)`

Function arguments:

| Arg. # | Arg. mode  | Argument name                                                     | Argument type                                                        | Default expression  |
| ------ | ---------- | ----------------------------------------------------------------- | -------------------------------------------------------------------- | ------------------- |
|   `$1` |       `IN` |                                                                   | `semver_parsed`                                                      |  |
|   `$2` |       `IN` |                                                                   | `semver_parsed`                                                      |  |

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

#### Function: `semver_least (semver, semver)`

Function arguments:

| Arg. # | Arg. mode  | Argument name                                                     | Argument type                                                        | Default expression  |
| ------ | ---------- | ----------------------------------------------------------------- | -------------------------------------------------------------------- | ------------------- |
|   `$1` |       `IN` |                                                                   | `semver`                                                             |  |
|   `$2` |       `IN` |                                                                   | `semver`                                                             |  |

Function return type: `semver`

Function attributes: `IMMUTABLE`, `LEAKPROOF`, `PARALLEL SAFE`

#### Function: `semver_le (semver_parsed, semver_parsed)`

Function arguments:

| Arg. # | Arg. mode  | Argument name                                                     | Argument type                                                        | Default expression  |
| ------ | ---------- | ----------------------------------------------------------------- | -------------------------------------------------------------------- | ------------------- |
|   `$1` |       `IN` |                                                                   | `semver_parsed`                                                      |  |
|   `$2` |       `IN` |                                                                   | `semver_parsed`                                                      |  |

Function return type: `boolean`

Function attributes: `IMMUTABLE`, `LEAKPROOF`, `PARALLEL SAFE`

#### Function: `semver_le (semver, semver)`

Function arguments:

| Arg. # | Arg. mode  | Argument name                                                     | Argument type                                                        | Default expression  |
| ------ | ---------- | ----------------------------------------------------------------- | -------------------------------------------------------------------- | ------------------- |
|   `$1` |       `IN` |                                                                   | `semver`                                                             |  |
|   `$2` |       `IN` |                                                                   | `semver`                                                             |  |

Function return type: `boolean`

Function attributes: `IMMUTABLE`, `LEAKPROOF`, `PARALLEL SAFE`

#### Function: `semver_lt (semver_parsed, semver_parsed)`

Function arguments:

| Arg. # | Arg. mode  | Argument name                                                     | Argument type                                                        | Default expression  |
| ------ | ---------- | ----------------------------------------------------------------- | -------------------------------------------------------------------- | ------------------- |
|   `$1` |       `IN` |                                                                   | `semver_parsed`                                                      |  |
|   `$2` |       `IN` |                                                                   | `semver_parsed`                                                      |  |

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

#### Function: `semver_parsed (text)`

Function arguments:

| Arg. # | Arg. mode  | Argument name                                                     | Argument type                                                        | Default expression  |
| ------ | ---------- | ----------------------------------------------------------------- | -------------------------------------------------------------------- | ------------------- |
|   `$1` |       `IN` |                                                                   | `text`                                                               |  |

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

#### Function: `semver_prerelease_eq (semver_prerelease, semver_prerelease)`

Function arguments:

| Arg. # | Arg. mode  | Argument name                                                     | Argument type                                                        | Default expression  |
| ------ | ---------- | ----------------------------------------------------------------- | -------------------------------------------------------------------- | ------------------- |
|   `$1` |       `IN` |                                                                   | `semver_prerelease`                                                  |  |
|   `$2` |       `IN` |                                                                   | `semver_prerelease`                                                  |  |

Function return type: `boolean`

Function attributes: `IMMUTABLE`, `LEAKPROOF`, `PARALLEL SAFE`

#### Function: `semver_prerelease_ge (semver_prerelease, semver_prerelease)`

Function arguments:

| Arg. # | Arg. mode  | Argument name                                                     | Argument type                                                        | Default expression  |
| ------ | ---------- | ----------------------------------------------------------------- | -------------------------------------------------------------------- | ------------------- |
|   `$1` |       `IN` |                                                                   | `semver_prerelease`                                                  |  |
|   `$2` |       `IN` |                                                                   | `semver_prerelease`                                                  |  |

Function return type: `boolean`

Function attributes: `IMMUTABLE`, `LEAKPROOF`, `PARALLEL SAFE`

#### Function: `semver_prerelease_gt (semver_prerelease, semver_prerelease)`

Function arguments:

| Arg. # | Arg. mode  | Argument name                                                     | Argument type                                                        | Default expression  |
| ------ | ---------- | ----------------------------------------------------------------- | -------------------------------------------------------------------- | ------------------- |
|   `$1` |       `IN` |                                                                   | `semver_prerelease`                                                  |  |
|   `$2` |       `IN` |                                                                   | `semver_prerelease`                                                  |  |

Function return type: `boolean`

Function attributes: `IMMUTABLE`, `LEAKPROOF`, `PARALLEL SAFE`

#### Function: `semver_prerelease_le (semver_prerelease, semver_prerelease)`

Function arguments:

| Arg. # | Arg. mode  | Argument name                                                     | Argument type                                                        | Default expression  |
| ------ | ---------- | ----------------------------------------------------------------- | -------------------------------------------------------------------- | ------------------- |
|   `$1` |       `IN` |                                                                   | `semver_prerelease`                                                  |  |
|   `$2` |       `IN` |                                                                   | `semver_prerelease`                                                  |  |

Function return type: `boolean`

Function attributes: `IMMUTABLE`, `LEAKPROOF`, `PARALLEL SAFE`

#### Function: `semver_prerelease_lt (semver_prerelease, semver_prerelease)`

Function arguments:

| Arg. # | Arg. mode  | Argument name                                                     | Argument type                                                        | Default expression  |
| ------ | ---------- | ----------------------------------------------------------------- | -------------------------------------------------------------------- | ------------------- |
|   `$1` |       `IN` |                                                                   | `semver_prerelease`                                                  |  |
|   `$2` |       `IN` |                                                                   | `semver_prerelease`                                                  |  |

Function return type: `boolean`

Function attributes: `IMMUTABLE`, `LEAKPROOF`, `PARALLEL SAFE`

#### Function: `semver_prerelease_regexp()`

Function return type: `text`

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

#### Function: `semver (semver_parsed)`

Function arguments:

| Arg. # | Arg. mode  | Argument name                                                     | Argument type                                                        | Default expression  |
| ------ | ---------- | ----------------------------------------------------------------- | -------------------------------------------------------------------- | ------------------- |
|   `$1` |       `IN` |                                                                   | `semver_parsed`                                                      |  |

Function return type: `semver`

Function attributes: `IMMUTABLE`, `LEAKPROOF`, `PARALLEL SAFE`

#### Procedure: `test__pg_text_semver()`

Procedure-local settings:

  *  `SET search_path TO pg_catalog`
  *  `SET plpgsql.check_asserts TO true`
  *  `SET pg_readme.include_this_routine_definition TO true`

```sql
CREATE OR REPLACE PROCEDURE ext.test__pg_text_semver()
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

    raise transaction_rollback;
exception
    when transaction_rollback then
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
  CHECK ((VALUE ~ semver_prerelease_regexp()));
```

#### Composite type: `semver_parsed`

This composite type can be used to access the individual parts of a `semver`.

A semantic version can take 4 forms.  Depending on the form, the `prerelease` and/or `build` fields may be
`NLL`.  `major`, `minor` and `patch` can never be `NULL` for a valid semantic version.

| #  | Form                                           | Example           | `prerelease` | `build`    |
| -- | ---------------------------------------------- | ----------------- | ------------ | ---------- |
| 1. | `<major>.<minor>.<patch>`                      | 1.0.22            | `NULL`       | `NULL`     |
| 2. | `<major>.<minor>.<patch>-<prerelease>`         | 1.0.22-alpha2     | `NOT NULL`   | `NULL`     |
| 3. | `<major>.<minor>.<patch>-<prerelease>+<build>` | 1.0.22-alpha2+arm | `NOT NULL`   | `NOT NULL` |
| 4. | `<major>.<minor>.<patch>+<build>`              | 1.0.22+arm        | `NULL`       | `NOT NULL` |

To unparse/serialize a `semver_parsed` composite values, cast it to `semver` or `text`.

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
