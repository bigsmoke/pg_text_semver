-- Complain if script is sourced in `psql`, rather than via `CREATE EXTENSION`.
\echo Use "CREATE EXTENSION pg_text_semver" to load this file. \quit

--------------------------------------------------------------------------------------------------------------

-- Mention PG SEMVER alternative as well.
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
