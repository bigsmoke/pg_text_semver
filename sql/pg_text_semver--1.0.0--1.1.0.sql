-- Complain if script is sourced in `psql`, rather than via `CREATE EXTENSION`.
\echo Use "CREATE EXTENSION pg_text_semver" to load this file. \quit

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

-- Test `min(semver)` and `max(semver)`.
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

    raise transaction_rollback;
exception
    when transaction_rollback then
end;
$$;

--------------------------------------------------------------------------------------------------------------
