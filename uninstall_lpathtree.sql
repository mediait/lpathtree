/* $PostgreSQL: pgsql/contrib/lpathtree/uninstall_lpathtree.sql,v 1.6 2008/04/14 17:05:32 tgl Exp $ */

-- Adjust this setting to control where the objects get dropped.
SET search_path = public;

DROP OPERATOR CLASS gist__lpathtree_ops USING gist;

DROP FUNCTION _lpathtree_same(internal, internal, internal);

DROP FUNCTION _lpathtree_union(internal, internal);

DROP FUNCTION _lpathtree_picksplit(internal, internal);

DROP FUNCTION _lpathtree_penalty(internal,internal,internal);

DROP FUNCTION _lpathtree_compress(internal);

DROP FUNCTION _lpathtree_consistent(internal,internal,int2,oid,internal);

DROP OPERATOR ?~ (_lpathtree, lpathquery);

DROP FUNCTION _ltq_extract_regex(_lpathtree,lpathquery);

DROP OPERATOR ?<@ (_lpathtree, lpathtree);

DROP FUNCTION _lpathtree_extract_risparent(_lpathtree,lpathtree);

DROP OPERATOR ?@> (_lpathtree, lpathtree);

DROP FUNCTION _lpathtree_extract_isparent(_lpathtree,lpathtree);

DROP OPERATOR ^? (_lpathquery, _lpathtree);

DROP OPERATOR ^? (_lpathtree, _lpathquery);

DROP OPERATOR ^~ (lpathquery, _lpathtree);

DROP OPERATOR ^~ (_lpathtree, lpathquery);

DROP OPERATOR ^@> (lpathtree, _lpathtree);

DROP OPERATOR ^<@ (_lpathtree, lpathtree);

DROP OPERATOR ^<@ (lpathtree, _lpathtree);

DROP OPERATOR ^@> (_lpathtree, lpathtree);

DROP OPERATOR ? (_lpathquery, _lpathtree);

DROP OPERATOR ? (_lpathtree, _lpathquery);

DROP OPERATOR ~ (lpathquery, _lpathtree);

DROP OPERATOR ~ (_lpathtree, lpathquery);

DROP OPERATOR @> (lpathtree, _lpathtree);

DROP OPERATOR <@ (_lpathtree, lpathtree);

DROP OPERATOR <@ (lpathtree, _lpathtree);

DROP OPERATOR @> (_lpathtree, lpathtree);

DROP FUNCTION _lt_q_rregex(_lpathquery,_lpathtree);

DROP FUNCTION _lt_q_regex(_lpathtree,_lpathquery);

DROP FUNCTION _ltq_rregex(lpathquery,_lpathtree);

DROP FUNCTION _ltq_regex(_lpathtree,lpathquery);

DROP FUNCTION _lpathtree_r_risparent(lpathtree,_lpathtree);

DROP FUNCTION _lpathtree_risparent(_lpathtree,lpathtree);

DROP FUNCTION _lpathtree_r_isparent(lpathtree,_lpathtree);


DROP FUNCTION _lpathtree_isparent(_lpathtree,lpathtree);

DROP OPERATOR CLASS gist_lpathtree_ops USING gist;

DROP FUNCTION lpathtree_same(internal, internal, internal);

DROP FUNCTION lpathtree_union(internal, internal);

DROP FUNCTION lpathtree_picksplit(internal, internal);

DROP FUNCTION lpathtree_penalty(internal,internal,internal);

DROP FUNCTION lpathtree_decompress(internal);

DROP FUNCTION lpathtree_compress(internal);

DROP FUNCTION lpathtree_consistent(internal,internal,int2,oid,internal);

DROP TYPE lpathtree_gist CASCADE;
  
DROP OPERATOR ^? (_lpathquery, lpathtree);

DROP OPERATOR ^? (lpathtree, _lpathquery);

DROP OPERATOR ? (_lpathquery, lpathtree);

DROP OPERATOR ? (lpathtree, _lpathquery);

DROP FUNCTION lt_q_rregex(_lpathquery,lpathtree);

DROP FUNCTION lt_q_regex(lpathtree,_lpathquery);

DROP OPERATOR ^~ (lpathquery, lpathtree);

DROP OPERATOR ^~ (lpathtree, lpathquery);

DROP OPERATOR ~ (lpathquery, lpathtree);

DROP OPERATOR ~ (lpathtree, lpathquery);

DROP FUNCTION ltq_rregex(lpathquery,lpathtree);

DROP FUNCTION ltq_regex(lpathtree,lpathquery);

DROP TYPE lpathquery CASCADE;

DROP OPERATOR CLASS lpathtree_ops USING btree;

DROP OPERATOR || (text, lpathtree);

DROP OPERATOR || (lpathtree, text);

DROP OPERATOR || (lpathtree, lpathtree);

DROP OPERATOR ^<@ (lpathtree, lpathtree);

DROP OPERATOR <@ (lpathtree, lpathtree);

DROP OPERATOR ^@> (lpathtree, lpathtree);

DROP OPERATOR @> (lpathtree, lpathtree);

DROP FUNCTION lpathtreeparentsel(internal, oid, internal, integer);

DROP FUNCTION lpathtree_textadd(text,lpathtree);

DROP FUNCTION lpathtree_addtext(lpathtree,text);

DROP FUNCTION lpathtree_addlpathtree(lpathtree,lpathtree);

DROP FUNCTION lpathtree_risparent(lpathtree,lpathtree);

DROP FUNCTION lpathtree_isparent(lpathtree,lpathtree);

DROP FUNCTION lca(lpathtree,lpathtree,lpathtree,lpathtree,lpathtree,lpathtree,lpathtree,lpathtree);

DROP FUNCTION lca(lpathtree,lpathtree,lpathtree,lpathtree,lpathtree,lpathtree,lpathtree);

DROP FUNCTION lca(lpathtree,lpathtree,lpathtree,lpathtree,lpathtree,lpathtree);

DROP FUNCTION lca(lpathtree,lpathtree,lpathtree,lpathtree,lpathtree);

DROP FUNCTION lca(lpathtree,lpathtree,lpathtree,lpathtree);

DROP FUNCTION lca(lpathtree,lpathtree,lpathtree);

DROP FUNCTION lca(lpathtree,lpathtree);

DROP FUNCTION lca(_lpathtree);

DROP FUNCTION text2lpathtree(text);

DROP FUNCTION lpathtree2text(lpathtree);

DROP FUNCTION nlevel(lpathtree);

DROP FUNCTION index(lpathtree,lpathtree,int4);

DROP FUNCTION index(lpathtree,lpathtree);

DROP FUNCTION subpath(lpathtree,int4);

DROP FUNCTION subpath(lpathtree,int4,int4);

DROP FUNCTION sublpathtree(lpathtree,int4,int4);

DROP OPERATOR <> (lpathtree, lpathtree);

DROP OPERATOR = (lpathtree, lpathtree);

DROP OPERATOR > (lpathtree, lpathtree);

DROP OPERATOR >= (lpathtree, lpathtree);

DROP OPERATOR <= (lpathtree, lpathtree);

DROP OPERATOR < (lpathtree, lpathtree);

DROP FUNCTION lpathtree_ne(lpathtree,lpathtree);

DROP FUNCTION lpathtree_gt(lpathtree,lpathtree);

DROP FUNCTION lpathtree_ge(lpathtree,lpathtree);

DROP FUNCTION lpathtree_eq(lpathtree,lpathtree);

DROP FUNCTION lpathtree_le(lpathtree,lpathtree);

DROP FUNCTION lpathtree_lt(lpathtree,lpathtree);

DROP FUNCTION lpathtree_cmp(lpathtree,lpathtree);

DROP TYPE lpathtree CASCADE;
