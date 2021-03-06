/* contrib/lpathtree/lpathtree--1.0.sql */

-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION lpathtree" to load this file. \quit

CREATE FUNCTION lpathtree_in(cstring)
RETURNS lpathtree
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;

CREATE FUNCTION lpathtree_out(lpathtree)
RETURNS cstring
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;

CREATE TYPE lpathtree (
	INTERNALLENGTH = -1,
	INPUT = lpathtree_in,
	OUTPUT = lpathtree_out,
	STORAGE = extended
);


--Compare function for lpathtree
CREATE FUNCTION lpathtree_cmp(lpathtree,lpathtree)
RETURNS int4
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION lpathtree_lt(lpathtree,lpathtree)
RETURNS bool
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION lpathtree_le(lpathtree,lpathtree)
RETURNS bool
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION lpathtree_eq(lpathtree,lpathtree)
RETURNS bool
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION lpathtree_ge(lpathtree,lpathtree)
RETURNS bool
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION lpathtree_gt(lpathtree,lpathtree)
RETURNS bool
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION lpathtree_ne(lpathtree,lpathtree)
RETURNS bool
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;


CREATE OPERATOR < (
        LEFTARG = lpathtree,
	RIGHTARG = lpathtree,
	PROCEDURE = lpathtree_lt,
        COMMUTATOR = '>',
	NEGATOR = '>=',
        RESTRICT = contsel,
	JOIN = contjoinsel
);

CREATE OPERATOR <= (
        LEFTARG = lpathtree,
	RIGHTARG = lpathtree,
	PROCEDURE = lpathtree_le,
        COMMUTATOR = '>=',
	NEGATOR = '>',
        RESTRICT = contsel,
	JOIN = contjoinsel
);

CREATE OPERATOR >= (
        LEFTARG = lpathtree,
	RIGHTARG = lpathtree,
	PROCEDURE = lpathtree_ge,
        COMMUTATOR = '<=',
	NEGATOR = '<',
        RESTRICT = contsel,
	JOIN = contjoinsel
);

CREATE OPERATOR > (
        LEFTARG = lpathtree,
	RIGHTARG = lpathtree,
	PROCEDURE = lpathtree_gt,
        COMMUTATOR = '<',
	NEGATOR = '<=',
        RESTRICT = contsel,
	JOIN = contjoinsel
);

CREATE OPERATOR = (
        LEFTARG = lpathtree,
	RIGHTARG = lpathtree,
	PROCEDURE = lpathtree_eq,
        COMMUTATOR = '=',
	NEGATOR = '<>',
        RESTRICT = eqsel,
	JOIN = eqjoinsel,
        SORT1 = '<',
	SORT2 = '<'
);

CREATE OPERATOR <> (
        LEFTARG = lpathtree,
	RIGHTARG = lpathtree,
	PROCEDURE = lpathtree_ne,
        COMMUTATOR = '<>',
	NEGATOR = '=',
        RESTRICT = neqsel,
	JOIN = neqjoinsel
);

--util functions

CREATE FUNCTION sublpathtree(lpathtree,int4,int4)
RETURNS lpathtree
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION subpath(lpathtree,int4,int4)
RETURNS lpathtree
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION subpath(lpathtree,int4)
RETURNS lpathtree
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION index(lpathtree,lpathtree)
RETURNS int4
AS 'MODULE_PATHNAME', 'lpathtree_index'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION index(lpathtree,lpathtree,int4)
RETURNS int4
AS 'MODULE_PATHNAME', 'lpathtree_index'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION nlevel(lpathtree)
RETURNS int4
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION lpathtree2text(lpathtree)
RETURNS text
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION text2lpathtree(text)
RETURNS lpathtree
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION lca(_lpathtree)
RETURNS lpathtree
AS 'MODULE_PATHNAME','_lca'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION lca(lpathtree,lpathtree)
RETURNS lpathtree
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION lca(lpathtree,lpathtree,lpathtree)
RETURNS lpathtree
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION lca(lpathtree,lpathtree,lpathtree,lpathtree)
RETURNS lpathtree
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION lca(lpathtree,lpathtree,lpathtree,lpathtree,lpathtree)
RETURNS lpathtree
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION lca(lpathtree,lpathtree,lpathtree,lpathtree,lpathtree,lpathtree)
RETURNS lpathtree
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION lca(lpathtree,lpathtree,lpathtree,lpathtree,lpathtree,lpathtree,lpathtree)
RETURNS lpathtree
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION lca(lpathtree,lpathtree,lpathtree,lpathtree,lpathtree,lpathtree,lpathtree,lpathtree)
RETURNS lpathtree
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION lpathtree_isparent(lpathtree,lpathtree)
RETURNS bool
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION lpathtree_risparent(lpathtree,lpathtree)
RETURNS bool
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION lpathtree_addlpathtree(lpathtree,lpathtree)
RETURNS lpathtree
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION lpathtree_addtext(lpathtree,text)
RETURNS lpathtree
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION lpathtree_textadd(text,lpathtree)
RETURNS lpathtree
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION lpathtreeparentsel(internal, oid, internal, integer)
RETURNS float8
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;

CREATE OPERATOR @> (
        LEFTARG = lpathtree,
	RIGHTARG = lpathtree,
	PROCEDURE = lpathtree_isparent,
        COMMUTATOR = '<@',
        RESTRICT = lpathtreeparentsel,
	JOIN = contjoinsel
);

CREATE OPERATOR ^@> (
        LEFTARG = lpathtree,
	RIGHTARG = lpathtree,
	PROCEDURE = lpathtree_isparent,
        COMMUTATOR = '^<@',
        RESTRICT = contsel,
	JOIN = contjoinsel
);

CREATE OPERATOR <@ (
        LEFTARG = lpathtree,
	RIGHTARG = lpathtree,
	PROCEDURE = lpathtree_risparent,
        COMMUTATOR = '@>',
        RESTRICT = lpathtreeparentsel,
	JOIN = contjoinsel
);

CREATE OPERATOR ^<@ (
        LEFTARG = lpathtree,
	RIGHTARG = lpathtree,
	PROCEDURE = lpathtree_risparent,
        COMMUTATOR = '^@>',
        RESTRICT = contsel,
	JOIN = contjoinsel
);

CREATE OPERATOR || (
        LEFTARG = lpathtree,
	RIGHTARG = lpathtree,
	PROCEDURE = lpathtree_addlpathtree
);

CREATE OPERATOR || (
        LEFTARG = lpathtree,
	RIGHTARG = text,
	PROCEDURE = lpathtree_addtext
);

CREATE OPERATOR || (
        LEFTARG = text,
	RIGHTARG = lpathtree,
	PROCEDURE = lpathtree_textadd
);


-- B-tree support

CREATE OPERATOR CLASS lpathtree_ops
    DEFAULT FOR TYPE lpathtree USING btree AS
        OPERATOR        1       < ,
        OPERATOR        2       <= ,
        OPERATOR        3       = ,
        OPERATOR        4       >= ,
        OPERATOR        5       > ,
        FUNCTION        1       lpathtree_cmp(lpathtree, lpathtree);


--lpathquery type
CREATE FUNCTION lpathquery_in(cstring)
RETURNS lpathquery
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;

CREATE FUNCTION lpathquery_out(lpathquery)
RETURNS cstring
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;

CREATE TYPE lpathquery (
	INTERNALLENGTH = -1,
	INPUT = lpathquery_in,
	OUTPUT = lpathquery_out,
	STORAGE = extended
);

CREATE FUNCTION ltq_regex(lpathtree,lpathquery)
RETURNS bool
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION ltq_rregex(lpathquery,lpathtree)
RETURNS bool
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;

CREATE OPERATOR ~ (
        LEFTARG = lpathtree,
	RIGHTARG = lpathquery,
	PROCEDURE = ltq_regex,
	COMMUTATOR = '~',
	RESTRICT = contsel,
	JOIN = contjoinsel
);

CREATE OPERATOR ~ (
        LEFTARG = lpathquery,
	RIGHTARG = lpathtree,
	PROCEDURE = ltq_rregex,
	COMMUTATOR = '~',
	RESTRICT = contsel,
	JOIN = contjoinsel
);

--not-indexed
CREATE OPERATOR ^~ (
        LEFTARG = lpathtree,
	RIGHTARG = lpathquery,
	PROCEDURE = ltq_regex,
	COMMUTATOR = '^~',
	RESTRICT = contsel,
	JOIN = contjoinsel
);

CREATE OPERATOR ^~ (
        LEFTARG = lpathquery,
	RIGHTARG = lpathtree,
	PROCEDURE = ltq_rregex,
	COMMUTATOR = '^~',
	RESTRICT = contsel,
	JOIN = contjoinsel
);

CREATE FUNCTION lt_q_regex(lpathtree,_lpathquery)
RETURNS bool
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION lt_q_rregex(_lpathquery,lpathtree)
RETURNS bool
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;

CREATE OPERATOR ? (
        LEFTARG = lpathtree,
	RIGHTARG = _lpathquery,
	PROCEDURE = lt_q_regex,
	COMMUTATOR = '?',
	RESTRICT = contsel,
	JOIN = contjoinsel
);

CREATE OPERATOR ? (
        LEFTARG = _lpathquery,
	RIGHTARG = lpathtree,
	PROCEDURE = lt_q_rregex,
	COMMUTATOR = '?',
	RESTRICT = contsel,
	JOIN = contjoinsel
);

--not-indexed
CREATE OPERATOR ^? (
        LEFTARG = lpathtree,
	RIGHTARG = _lpathquery,
	PROCEDURE = lt_q_regex,
	COMMUTATOR = '^?',
	RESTRICT = contsel,
	JOIN = contjoinsel
);

CREATE OPERATOR ^? (
        LEFTARG = _lpathquery,
	RIGHTARG = lpathtree,
	PROCEDURE = lt_q_rregex,
	COMMUTATOR = '^?',
	RESTRICT = contsel,
	JOIN = contjoinsel
);


--GiST support for lpathtree
CREATE FUNCTION lpathtree_gist_in(cstring)
RETURNS lpathtree_gist
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;

CREATE FUNCTION lpathtree_gist_out(lpathtree_gist)
RETURNS cstring
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;

CREATE TYPE lpathtree_gist (
	internallength = -1,
	input = lpathtree_gist_in,
	output = lpathtree_gist_out,
	storage = plain
);


CREATE FUNCTION lpathtree_consistent(internal,internal,int2,oid,internal)
RETURNS bool as 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION lpathtree_compress(internal)
RETURNS internal as 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION lpathtree_decompress(internal)
RETURNS internal as 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION lpathtree_penalty(internal,internal,internal)
RETURNS internal as 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION lpathtree_picksplit(internal, internal)
RETURNS internal as 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION lpathtree_union(internal, internal)
RETURNS int4 as 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION lpathtree_same(internal, internal, internal)
RETURNS internal as 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR CLASS gist_lpathtree_ops
    DEFAULT FOR TYPE lpathtree USING gist AS
	OPERATOR	1	< ,
	OPERATOR	2	<= ,
	OPERATOR	3	= ,
	OPERATOR	4	>= ,
	OPERATOR	5	> ,
	OPERATOR	10	@> ,
	OPERATOR	11	<@ ,
	OPERATOR	12	~ (lpathtree, lpathquery) ,
	OPERATOR	13	~ (lpathquery, lpathtree) ,
	OPERATOR	14	? (lpathtree, _lpathquery) ,
	OPERATOR	15	? (_lpathquery, lpathtree) ,
	FUNCTION	1	lpathtree_consistent (internal, internal, int2, oid, internal),
	FUNCTION	2	lpathtree_union (internal, internal),
	FUNCTION	3	lpathtree_compress (internal),
	FUNCTION	4	lpathtree_decompress (internal),
	FUNCTION	5	lpathtree_penalty (internal, internal, internal),
	FUNCTION	6	lpathtree_picksplit (internal, internal),
	FUNCTION	7	lpathtree_same (internal, internal, internal),
	STORAGE		lpathtree_gist;


-- arrays of lpathtree

CREATE FUNCTION _lpathtree_isparent(_lpathtree,lpathtree)
RETURNS bool
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION _lpathtree_r_isparent(lpathtree,_lpathtree)
RETURNS bool
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION _lpathtree_risparent(_lpathtree,lpathtree)
RETURNS bool
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION _lpathtree_r_risparent(lpathtree,_lpathtree)
RETURNS bool
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION _ltq_regex(_lpathtree,lpathquery)
RETURNS bool
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION _ltq_rregex(lpathquery,_lpathtree)
RETURNS bool
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION _lt_q_regex(_lpathtree,_lpathquery)
RETURNS bool
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION _lt_q_rregex(_lpathquery,_lpathtree)
RETURNS bool
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;

CREATE OPERATOR @> (
        LEFTARG = _lpathtree,
	RIGHTARG = lpathtree,
	PROCEDURE = _lpathtree_isparent,
        COMMUTATOR = '<@',
        RESTRICT = contsel,
	JOIN = contjoinsel
);

CREATE OPERATOR <@ (
        LEFTARG = lpathtree,
	RIGHTARG = _lpathtree,
	PROCEDURE = _lpathtree_r_isparent,
        COMMUTATOR = '@>',
        RESTRICT = contsel,
	JOIN = contjoinsel
);

CREATE OPERATOR <@ (
        LEFTARG = _lpathtree,
	RIGHTARG = lpathtree,
	PROCEDURE = _lpathtree_risparent,
        COMMUTATOR = '@>',
        RESTRICT = contsel,
	JOIN = contjoinsel
);

CREATE OPERATOR @> (
        LEFTARG = lpathtree,
	RIGHTARG = _lpathtree,
	PROCEDURE = _lpathtree_r_risparent,
        COMMUTATOR = '<@',
        RESTRICT = contsel,
	JOIN = contjoinsel
);

CREATE OPERATOR ~ (
        LEFTARG = _lpathtree,
	RIGHTARG = lpathquery,
	PROCEDURE = _ltq_regex,
        COMMUTATOR = '~',
        RESTRICT = contsel,
	JOIN = contjoinsel
);

CREATE OPERATOR ~ (
        LEFTARG = lpathquery,
	RIGHTARG = _lpathtree,
	PROCEDURE = _ltq_rregex,
        COMMUTATOR = '~',
        RESTRICT = contsel,
	JOIN = contjoinsel
);

CREATE OPERATOR ? (
        LEFTARG = _lpathtree,
	RIGHTARG = _lpathquery,
	PROCEDURE = _lt_q_regex,
        COMMUTATOR = '?',
        RESTRICT = contsel,
	JOIN = contjoinsel
);

CREATE OPERATOR ? (
        LEFTARG = _lpathquery,
	RIGHTARG = _lpathtree,
	PROCEDURE = _lt_q_rregex,
        COMMUTATOR = '?',
        RESTRICT = contsel,
	JOIN = contjoinsel
);


--not indexed
CREATE OPERATOR ^@> (
        LEFTARG = _lpathtree,
	RIGHTARG = lpathtree,
	PROCEDURE = _lpathtree_isparent,
        COMMUTATOR = '^<@',
        RESTRICT = contsel,
	JOIN = contjoinsel
);

CREATE OPERATOR ^<@ (
        LEFTARG = lpathtree,
	RIGHTARG = _lpathtree,
	PROCEDURE = _lpathtree_r_isparent,
        COMMUTATOR = '^@>',
        RESTRICT = contsel,
	JOIN = contjoinsel
);

CREATE OPERATOR ^<@ (
        LEFTARG = _lpathtree,
	RIGHTARG = lpathtree,
	PROCEDURE = _lpathtree_risparent,
        COMMUTATOR = '^@>',
        RESTRICT = contsel,
	JOIN = contjoinsel
);

CREATE OPERATOR ^@> (
        LEFTARG = lpathtree,
	RIGHTARG = _lpathtree,
	PROCEDURE = _lpathtree_r_risparent,
        COMMUTATOR = '^<@',
        RESTRICT = contsel,
	JOIN = contjoinsel
);

CREATE OPERATOR ^~ (
        LEFTARG = _lpathtree,
	RIGHTARG = lpathquery,
	PROCEDURE = _ltq_regex,
        COMMUTATOR = '^~',
        RESTRICT = contsel,
	JOIN = contjoinsel
);

CREATE OPERATOR ^~ (
        LEFTARG = lpathquery,
	RIGHTARG = _lpathtree,
	PROCEDURE = _ltq_rregex,
        COMMUTATOR = '^~',
        RESTRICT = contsel,
	JOIN = contjoinsel
);

CREATE OPERATOR ^? (
        LEFTARG = _lpathtree,
	RIGHTARG = _lpathquery,
	PROCEDURE = _lt_q_regex,
        COMMUTATOR = '^?',
        RESTRICT = contsel,
	JOIN = contjoinsel
);

CREATE OPERATOR ^? (
        LEFTARG = _lpathquery,
	RIGHTARG = _lpathtree,
	PROCEDURE = _lt_q_rregex,
        COMMUTATOR = '^?',
        RESTRICT = contsel,
	JOIN = contjoinsel
);

--extractors
CREATE FUNCTION _lpathtree_extract_isparent(_lpathtree,lpathtree)
RETURNS lpathtree
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;

CREATE OPERATOR ?@> (
        LEFTARG = _lpathtree,
	RIGHTARG = lpathtree,
	PROCEDURE = _lpathtree_extract_isparent
);

CREATE FUNCTION _lpathtree_extract_risparent(_lpathtree,lpathtree)
RETURNS lpathtree
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;

CREATE OPERATOR ?<@ (
        LEFTARG = _lpathtree,
	RIGHTARG = lpathtree,
	PROCEDURE = _lpathtree_extract_risparent
);

CREATE FUNCTION _ltq_extract_regex(_lpathtree,lpathquery)
RETURNS lpathtree
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;

CREATE OPERATOR ?~ (
        LEFTARG = _lpathtree,
	RIGHTARG = lpathquery,
	PROCEDURE = _ltq_extract_regex
);

--GiST support for lpathtree[]
CREATE FUNCTION _lpathtree_consistent(internal,internal,int2,oid,internal)
RETURNS bool
AS 'MODULE_PATHNAME'
LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION _lpathtree_compress(internal)
RETURNS internal
AS 'MODULE_PATHNAME'
LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION _lpathtree_penalty(internal,internal,internal)
RETURNS internal
AS 'MODULE_PATHNAME'
LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION _lpathtree_picksplit(internal, internal)
RETURNS internal
AS 'MODULE_PATHNAME'
LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION _lpathtree_union(internal, internal)
RETURNS int4
AS 'MODULE_PATHNAME'
LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION _lpathtree_same(internal, internal, internal)
RETURNS internal
AS 'MODULE_PATHNAME'
LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR CLASS gist__lpathtree_ops
    DEFAULT FOR TYPE _lpathtree USING gist AS
	OPERATOR	10	<@ (_lpathtree, lpathtree),
	OPERATOR	11	@> (lpathtree, _lpathtree),
	OPERATOR	12	~ (_lpathtree, lpathquery),
	OPERATOR	13	~ (lpathquery, _lpathtree),
	OPERATOR	14	? (_lpathtree, _lpathquery),
	OPERATOR	15	? (_lpathquery, _lpathtree),
	FUNCTION	1	_lpathtree_consistent (internal, internal, int2, oid, internal),
	FUNCTION	2	_lpathtree_union (internal, internal),
	FUNCTION	3	_lpathtree_compress (internal),
	FUNCTION	4	lpathtree_decompress (internal),
	FUNCTION	5	_lpathtree_penalty (internal, internal, internal),
	FUNCTION	6	_lpathtree_picksplit (internal, internal),
	FUNCTION	7	_lpathtree_same (internal, internal, internal),
	STORAGE		lpathtree_gist;
