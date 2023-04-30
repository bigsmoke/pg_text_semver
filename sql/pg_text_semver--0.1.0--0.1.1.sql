-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
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

<?pg-readme-reference?>

<?pg-readme-colophon?>
$markdown$;

--------------------------------------------------------------------------------------------------------------
