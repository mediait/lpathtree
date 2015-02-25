/*
 * op function for lpathtree
 * Teodor Sigaev <teodor@stack.net>
 * contrib/lpathtree/lpathtree_op.c
 */
#include "postgres.h"

#include <ctype.h>

#include "access/htup_details.h"
#include "catalog/pg_statistic.h"
#include "utils/builtins.h"
#include "utils/lsyscache.h"
#include "utils/selfuncs.h"
#include "lpathtree.h"

PG_MODULE_MAGIC;

/* compare functions */
PG_FUNCTION_INFO_V1(lpathtree_cmp);
PG_FUNCTION_INFO_V1(lpathtree_lt);
PG_FUNCTION_INFO_V1(lpathtree_le);
PG_FUNCTION_INFO_V1(lpathtree_eq);
PG_FUNCTION_INFO_V1(lpathtree_ne);
PG_FUNCTION_INFO_V1(lpathtree_ge);
PG_FUNCTION_INFO_V1(lpathtree_gt);
PG_FUNCTION_INFO_V1(nlevel);
PG_FUNCTION_INFO_V1(lpathtree_isparent);
PG_FUNCTION_INFO_V1(lpathtree_risparent);
PG_FUNCTION_INFO_V1(sublpathtree);
PG_FUNCTION_INFO_V1(subpath);
PG_FUNCTION_INFO_V1(lpathtree_index);
PG_FUNCTION_INFO_V1(lpathtree_addlpathtree);
PG_FUNCTION_INFO_V1(lpathtree_addtext);
PG_FUNCTION_INFO_V1(lpathtree_textadd);
PG_FUNCTION_INFO_V1(lca);
PG_FUNCTION_INFO_V1(lpathtree2text);
PG_FUNCTION_INFO_V1(text2lpathtree);
PG_FUNCTION_INFO_V1(lpathtreeparentsel);

Datum		lpathtree_cmp(PG_FUNCTION_ARGS);
Datum		lpathtree_lt(PG_FUNCTION_ARGS);
Datum		lpathtree_le(PG_FUNCTION_ARGS);
Datum		lpathtree_eq(PG_FUNCTION_ARGS);
Datum		lpathtree_ne(PG_FUNCTION_ARGS);
Datum		lpathtree_ge(PG_FUNCTION_ARGS);
Datum		lpathtree_gt(PG_FUNCTION_ARGS);
Datum		nlevel(PG_FUNCTION_ARGS);
Datum		sublpathtree(PG_FUNCTION_ARGS);
Datum		subpath(PG_FUNCTION_ARGS);
Datum		lpathtree_index(PG_FUNCTION_ARGS);
Datum		lpathtree_addlpathtree(PG_FUNCTION_ARGS);
Datum		lpathtree_addtext(PG_FUNCTION_ARGS);
Datum		lpathtree_textadd(PG_FUNCTION_ARGS);
Datum		lca(PG_FUNCTION_ARGS);
Datum		lpathtree2text(PG_FUNCTION_ARGS);
Datum		text2lpathtree(PG_FUNCTION_ARGS);
Datum		lpathtreeparentsel(PG_FUNCTION_ARGS);

int
lpathtree_compare(const lpathtree *a, const lpathtree *b)
{
	lpathtree_level *al = LPATHTREE_FIRST(a);
	lpathtree_level *bl = LPATHTREE_FIRST(b);
	int			an = a->numlevel;
	int			bn = b->numlevel;
	int			res = 0;

	while (an > 0 && bn > 0)
	{
		if ((res = memcmp(al->name, bl->name, Min(al->len, bl->len))) == 0)
		{
			if (al->len != bl->len)
				return (al->len - bl->len) * 10 * (an + 1);
		}
		else
			return res * 10 * (an + 1);

		an--;
		bn--;
		al = LEVEL_NEXT(al);
		bl = LEVEL_NEXT(bl);
	}

	return (a->numlevel - b->numlevel) * 10 * (an + 1);
}

#define RUNCMP						\
lpathtree *a	= PG_GETARG_LPATHTREE(0);			\
lpathtree *b	= PG_GETARG_LPATHTREE(1);			\
int res = lpathtree_compare(a,b);				\
PG_FREE_IF_COPY(a,0);					\
PG_FREE_IF_COPY(b,1);					\

Datum
lpathtree_cmp(PG_FUNCTION_ARGS)
{
	RUNCMP
		PG_RETURN_INT32(res);
}

Datum
lpathtree_lt(PG_FUNCTION_ARGS)
{
	RUNCMP
		PG_RETURN_BOOL((res < 0) ? true : false);
}

Datum
lpathtree_le(PG_FUNCTION_ARGS)
{
	RUNCMP
		PG_RETURN_BOOL((res <= 0) ? true : false);
}

Datum
lpathtree_eq(PG_FUNCTION_ARGS)
{
	RUNCMP
		PG_RETURN_BOOL((res == 0) ? true : false);
}

Datum
lpathtree_ge(PG_FUNCTION_ARGS)
{
	RUNCMP
		PG_RETURN_BOOL((res >= 0) ? true : false);
}

Datum
lpathtree_gt(PG_FUNCTION_ARGS)
{
	RUNCMP
		PG_RETURN_BOOL((res > 0) ? true : false);
}

Datum
lpathtree_ne(PG_FUNCTION_ARGS)
{
	RUNCMP
		PG_RETURN_BOOL((res != 0) ? true : false);
}

Datum
nlevel(PG_FUNCTION_ARGS)
{
	lpathtree	   *a = PG_GETARG_LPATHTREE(0);
	int			res = a->numlevel;

	PG_FREE_IF_COPY(a, 0);
	PG_RETURN_INT32(res);
}

bool
inner_isparent(const lpathtree *c, const lpathtree *p)
{
	lpathtree_level *cl = LPATHTREE_FIRST(c);
	lpathtree_level *pl = LPATHTREE_FIRST(p);
	int			pn = p->numlevel;

	if (pn > c->numlevel)
		return false;

	while (pn > 0)
	{
		if (cl->len != pl->len)
			return false;
		if (memcmp(cl->name, pl->name, cl->len))
			return false;

		pn--;
		cl = LEVEL_NEXT(cl);
		pl = LEVEL_NEXT(pl);
	}
	return true;
}

Datum
lpathtree_isparent(PG_FUNCTION_ARGS)
{
	lpathtree	   *c = PG_GETARG_LPATHTREE(1);
	lpathtree	   *p = PG_GETARG_LPATHTREE(0);
	bool		res = inner_isparent(c, p);

	PG_FREE_IF_COPY(c, 1);
	PG_FREE_IF_COPY(p, 0);
	PG_RETURN_BOOL(res);
}

Datum
lpathtree_risparent(PG_FUNCTION_ARGS)
{
	lpathtree	   *c = PG_GETARG_LPATHTREE(0);
	lpathtree	   *p = PG_GETARG_LPATHTREE(1);
	bool		res = inner_isparent(c, p);

	PG_FREE_IF_COPY(c, 0);
	PG_FREE_IF_COPY(p, 1);
	PG_RETURN_BOOL(res);
}


static lpathtree *
inner_sublpathtree(lpathtree *t, int32 startpos, int32 endpos)
{
	char	   *start = NULL,
			   *end = NULL;
	lpathtree_level *ptr = LPATHTREE_FIRST(t);
	lpathtree	   *res;
	int			i;
	if (startpos > endpos) startpos = endpos;
	// if (startpos < 0 || endpos < 0 || startpos >= t->numlevel || startpos > endpos)
	if (startpos < 0 || endpos < 0 )
		ereport(ERROR,
				(errcode(ERRCODE_INVALID_PARAMETER_VALUE),
				 errmsg("invalid positions")));

	if (endpos > t->numlevel)
		endpos = t->numlevel;

	start = end = (char *) ptr;
	for (i = 0; i < endpos; i++)
	{
		if (i == startpos)
			start = (char *) ptr;
		if (i == endpos - 1)
		{
			end = (char *) LEVEL_NEXT(ptr);
			break;
		}
		ptr = LEVEL_NEXT(ptr);
	}

	res = (lpathtree *) palloc(lpathtree_HDRSIZE + (end - start));
	SET_VARSIZE(res, lpathtree_HDRSIZE + (end - start));
	res->numlevel = endpos - startpos;

	memcpy(LPATHTREE_FIRST(res), start, end - start);

	return res;
}

Datum
sublpathtree(PG_FUNCTION_ARGS)
{
	lpathtree	   *t = PG_GETARG_LPATHTREE(0);
	lpathtree	   *res = inner_sublpathtree(t, PG_GETARG_INT32(1), PG_GETARG_INT32(2));

	PG_FREE_IF_COPY(t, 0);
	PG_RETURN_POINTER(res);
}

Datum
subpath(PG_FUNCTION_ARGS)
{
	lpathtree	   *t = PG_GETARG_LPATHTREE(0);
	int32		start = PG_GETARG_INT32(1);
	int32		len = (fcinfo->nargs == 3) ? PG_GETARG_INT32(2) : 0;
	int32		end;
	lpathtree	   *res;

	end = start + len;

	if (start < 0)
	{
		start = t->numlevel + start;
		end = start + len;
	}
	if (start < 0)
	{							/* start > t->numlevel */
		start = t->numlevel + start;
		end = start + len;
	}

	if (len < 0)
		end = t->numlevel + len;
	else if (len == 0)
		end = (fcinfo->nargs == 3) ? start : 0xffff;

	res = inner_sublpathtree(t, start, end);

	PG_FREE_IF_COPY(t, 0);
	PG_RETURN_POINTER(res);
}

static lpathtree *
lpathtree_concat(lpathtree *a, lpathtree *b)
{
	lpathtree	   *r;

	r = (lpathtree *) palloc(VARSIZE(a) + VARSIZE(b) - lpathtree_HDRSIZE);
	SET_VARSIZE(r, VARSIZE(a) + VARSIZE(b) - lpathtree_HDRSIZE);
	r->numlevel = a->numlevel + b->numlevel;

	memcpy(LPATHTREE_FIRST(r), LPATHTREE_FIRST(a), VARSIZE(a) - lpathtree_HDRSIZE);
	memcpy(((char *) LPATHTREE_FIRST(r)) + VARSIZE(a) - lpathtree_HDRSIZE,
		   LPATHTREE_FIRST(b),
		   VARSIZE(b) - lpathtree_HDRSIZE);
	return r;
}

Datum
lpathtree_addlpathtree(PG_FUNCTION_ARGS)
{
	lpathtree	   *a = PG_GETARG_LPATHTREE(0);
	lpathtree	   *b = PG_GETARG_LPATHTREE(1);
	lpathtree	   *r;

	r = lpathtree_concat(a, b);
	PG_FREE_IF_COPY(a, 0);
	PG_FREE_IF_COPY(b, 1);
	PG_RETURN_POINTER(r);
}

Datum
lpathtree_addtext(PG_FUNCTION_ARGS)
{
	lpathtree	   *a = PG_GETARG_LPATHTREE(0);
	text	   *b = PG_GETARG_TEXT_PP(1);
	char	   *s;
	lpathtree	   *r,
			   *tmp;

	s = text_to_cstring(b);

	tmp = (lpathtree *) DatumGetPointer(DirectFunctionCall1(lpathtree_in,
														PointerGetDatum(s)));

	pfree(s);

	r = lpathtree_concat(a, tmp);

	pfree(tmp);

	PG_FREE_IF_COPY(a, 0);
	PG_FREE_IF_COPY(b, 1);
	PG_RETURN_POINTER(r);
}

Datum
lpathtree_index(PG_FUNCTION_ARGS)
{
	lpathtree	   *a = PG_GETARG_LPATHTREE(0);
	lpathtree	   *b = PG_GETARG_LPATHTREE(1);
	int			start = (fcinfo->nargs == 3) ? PG_GETARG_INT32(2) : 0;
	int			i,
				j;
	lpathtree_level *startptr,
			   *aptr,
			   *bptr;
	bool		found = false;

	if (start < 0)
	{
		if (-start >= a->numlevel)
			start = 0;
		else
			start = (int) (a->numlevel) + start;
	}

	if (a->numlevel - start < b->numlevel || a->numlevel == 0 || b->numlevel == 0)
	{
		PG_FREE_IF_COPY(a, 0);
		PG_FREE_IF_COPY(b, 1);
		PG_RETURN_INT32(-1);
	}

	startptr = LPATHTREE_FIRST(a);
	for (i = 0; i <= a->numlevel - b->numlevel; i++)
	{
		if (i >= start)
		{
			aptr = startptr;
			bptr = LPATHTREE_FIRST(b);
			for (j = 0; j < b->numlevel; j++)
			{
				if (!(aptr->len == bptr->len && memcmp(aptr->name, bptr->name, aptr->len) == 0))
					break;
				aptr = LEVEL_NEXT(aptr);
				bptr = LEVEL_NEXT(bptr);
			}

			if (j == b->numlevel)
			{
				found = true;
				break;
			}
		}
		startptr = LEVEL_NEXT(startptr);
	}

	if (!found)
		i = -1;

	PG_FREE_IF_COPY(a, 0);
	PG_FREE_IF_COPY(b, 1);
	PG_RETURN_INT32(i);
}

Datum
lpathtree_textadd(PG_FUNCTION_ARGS)
{
	lpathtree	   *a = PG_GETARG_LPATHTREE(1);
	text	   *b = PG_GETARG_TEXT_PP(0);
	char	   *s;
	lpathtree	   *r,
			   *tmp;

	s = text_to_cstring(b);

	tmp = (lpathtree *) DatumGetPointer(DirectFunctionCall1(lpathtree_in,
														PointerGetDatum(s)));

	pfree(s);

	r = lpathtree_concat(tmp, a);

	pfree(tmp);

	PG_FREE_IF_COPY(a, 1);
	PG_FREE_IF_COPY(b, 0);
	PG_RETURN_POINTER(r);
}

lpathtree *
lca_inner(lpathtree **a, int len)
{
	int			tmp,
				num = ((*a)->numlevel) ? (*a)->numlevel - 1 : 0;
	lpathtree	  **ptr = a + 1;
	int			i,
				reslen = lpathtree_HDRSIZE;
	lpathtree_level *l1,
			   *l2;
	lpathtree	   *res;


	if ((*a)->numlevel == 0)
		return NULL;

	while (ptr - a < len)
	{
		if ((*ptr)->numlevel == 0)
			return NULL;
		else if ((*ptr)->numlevel == 1)
			num = 0;
		else
		{
			l1 = LPATHTREE_FIRST(*a);
			l2 = LPATHTREE_FIRST(*ptr);
			tmp = num;
			num = 0;
			for (i = 0; i < Min(tmp, (*ptr)->numlevel - 1); i++)
			{
				if (l1->len == l2->len && memcmp(l1->name, l2->name, l1->len) == 0)
					num = i + 1;
				else
					break;
				l1 = LEVEL_NEXT(l1);
				l2 = LEVEL_NEXT(l2);
			}
		}
		ptr++;
	}

	l1 = LPATHTREE_FIRST(*a);
	for (i = 0; i < num; i++)
	{
		reslen += MAXALIGN(l1->len + LEVEL_HDRSIZE);
		l1 = LEVEL_NEXT(l1);
	}

	res = (lpathtree *) palloc(reslen);
	SET_VARSIZE(res, reslen);
	res->numlevel = num;

	l1 = LPATHTREE_FIRST(*a);
	l2 = LPATHTREE_FIRST(res);

	for (i = 0; i < num; i++)
	{
		memcpy(l2, l1, MAXALIGN(l1->len + LEVEL_HDRSIZE));
		l1 = LEVEL_NEXT(l1);
		l2 = LEVEL_NEXT(l2);
	}

	return res;
}

Datum
lca(PG_FUNCTION_ARGS)
{
	int			i;
	lpathtree	  **a,
			   *res;

	a = (lpathtree **) palloc(sizeof(lpathtree *) * fcinfo->nargs);
	for (i = 0; i < fcinfo->nargs; i++)
		a[i] = PG_GETARG_LPATHTREE(i);
	res = lca_inner(a, (int) fcinfo->nargs);
	for (i = 0; i < fcinfo->nargs; i++)
		PG_FREE_IF_COPY(a[i], i);
	pfree(a);

	if (res)
		PG_RETURN_POINTER(res);
	else
		PG_RETURN_NULL();
}

Datum
text2lpathtree(PG_FUNCTION_ARGS)
{
	text	   *in = PG_GETARG_TEXT_PP(0);
	char	   *s;
	lpathtree	   *out;

	s = text_to_cstring(in);

	out = (lpathtree *) DatumGetPointer(DirectFunctionCall1(lpathtree_in,
														PointerGetDatum(s)));
	pfree(s);
	PG_FREE_IF_COPY(in, 0);
	PG_RETURN_POINTER(out);
}


Datum
lpathtree2text(PG_FUNCTION_ARGS)
{
	lpathtree	   *in = PG_GETARG_LPATHTREE(0);
	char	   *ptr;
	int			i;
	lpathtree_level *curlevel;
	text	   *out;

	out = (text *) palloc(1 + VARSIZE(in) + VARHDRSZ);
	ptr = VARDATA(out);
	curlevel = LPATHTREE_FIRST(in);
	for (i = 0; i < in->numlevel; i++)
	{
		*ptr = NODE_DELIMITER_CHAR;
		ptr++;
		memcpy(ptr, curlevel->name, curlevel->len);
		ptr += curlevel->len;
		curlevel = LEVEL_NEXT(curlevel);
	}

	SET_VARSIZE(out, ptr - ((char *) out));
	PG_FREE_IF_COPY(in, 0);

	PG_RETURN_POINTER(out);
}


#define DEFAULT_PARENT_SEL 0.001

/*
 *	lpathtreeparentsel - Selectivity of parent relationship for lpathtree data types.
 */
Datum
lpathtreeparentsel(PG_FUNCTION_ARGS)
{
	PlannerInfo *root = (PlannerInfo *) PG_GETARG_POINTER(0);
	Oid			operator = PG_GETARG_OID(1);
	List	   *args = (List *) PG_GETARG_POINTER(2);
	int			varRelid = PG_GETARG_INT32(3);
	VariableStatData vardata;
	Node	   *other;
	bool		varonleft;
	double		selec;

	/*
	 * If expression is not variable <@ something or something <@ variable,
	 * then punt and return a default estimate.
	 */
	if (!get_restriction_variable(root, args, varRelid,
								  &vardata, &other, &varonleft))
		PG_RETURN_FLOAT8(DEFAULT_PARENT_SEL);

	/*
	 * If the something is a NULL constant, assume operator is strict and
	 * return zero, ie, operator will never return TRUE.
	 */
	if (IsA(other, Const) &&
		((Const *) other)->constisnull)
	{
		ReleaseVariableStats(vardata);
		PG_RETURN_FLOAT8(0.0);
	}

	if (IsA(other, Const))
	{
		/* Variable is being compared to a known non-null constant */
		Datum		constval = ((Const *) other)->constvalue;
		FmgrInfo	contproc;
		double		mcvsum;
		double		mcvsel;
		double		nullfrac;
		int			hist_size;

		fmgr_info(get_opcode(operator), &contproc);

		/*
		 * Is the constant "<@" to any of the column's most common values?
		 */
		mcvsel = mcv_selectivity(&vardata, &contproc, constval, varonleft,
								 &mcvsum);

		/*
		 * If the histogram is large enough, see what fraction of it the
		 * constant is "<@" to, and assume that's representative of the
		 * non-MCV population.  Otherwise use the default selectivity for the
		 * non-MCV population.
		 */
		selec = histogram_selectivity(&vardata, &contproc,
									  constval, varonleft,
									  10, 1, &hist_size);
		if (selec < 0)
		{
			/* Nope, fall back on default */
			selec = DEFAULT_PARENT_SEL;
		}
		else if (hist_size < 100)
		{
			/*
			 * For histogram sizes from 10 to 100, we combine the histogram
			 * and default selectivities, putting increasingly more trust in
			 * the histogram for larger sizes.
			 */
			double		hist_weight = hist_size / 100.0;

			selec = selec * hist_weight +
				DEFAULT_PARENT_SEL * (1.0 - hist_weight);
		}

		/* In any case, don't believe extremely small or large estimates. */
		if (selec < 0.0001)
			selec = 0.0001;
		else if (selec > 0.9999)
			selec = 0.9999;

		if (HeapTupleIsValid(vardata.statsTuple))
			nullfrac = ((Form_pg_statistic) GETSTRUCT(vardata.statsTuple))->stanullfrac;
		else
			nullfrac = 0.0;

		/*
		 * Now merge the results from the MCV and histogram calculations,
		 * realizing that the histogram covers only the non-null values that
		 * are not listed in MCV.
		 */
		selec *= 1.0 - nullfrac - mcvsum;
		selec += mcvsel;
	}
	else
		selec = DEFAULT_PARENT_SEL;

	ReleaseVariableStats(vardata);

	/* result should be in range, but make sure... */
	CLAMP_PROBABILITY(selec);

	PG_RETURN_FLOAT8((float8) selec);
}
