-- Complain if script is sourced in `psql`, rather than via `CREATE EXTENSION`.
\echo Use "CREATE EXTENSION pg_text_semver" to load this file. \quit

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

-- Test new PGXN `META.json` Version Ranges parsing and comparison functions.
create or replace procedure test__pg_text_semver()
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
