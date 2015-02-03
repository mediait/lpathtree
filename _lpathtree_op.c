/*
 * contrib/lpathtree/_lpathtree_op.c
 *
 *
 * op function for lpathtree[]
 * Teodor Sigaev <teodor@stack.net>
 */
#include "postgres.h"

#include <ctype.h>

#include "lpathtree.h"

PG_FUNCTION_INFO_V1(_lpathtree_isparent);
PG_FUNCTION_INFO_V1(_lpathtree_r_isparent);
PG_FUNCTION_INFO_V1(_lpathtree_risparent);
PG_FUNCTION_INFO_V1(_lpathtree_r_risparent);
PG_FUNCTION_INFO_V1(_ltq_regex);
PG_FUNCTION_INFO_V1(_ltq_rregex);
PG_FUNCTION_INFO_V1(_lt_q_regex);
PG_FUNCTION_INFO_V1(_lt_q_rregex);

Datum		_lpathtree_r_isparent(PG_FUNCTION_ARGS);
Datum		_lpathtree_r_risparent(PG_FUNCTION_ARGS);

PG_FUNCTION_INFO_V1(_lpathtree_extract_isparent);
PG_FUNCTION_INFO_V1(_lpathtree_extract_risparent);
PG_FUNCTION_INFO_V1(_ltq_extract_regex);
Datum		_lpathtree_extract_isparent(PG_FUNCTION_ARGS);
Datum		_lpathtree_extract_risparent(PG_FUNCTION_ARGS);
Datum		_ltq_extract_regex(PG_FUNCTION_ARGS);

PG_FUNCTION_INFO_V1(_lca);
Datum		_lca(PG_FUNCTION_ARGS);

typedef Datum (*PGCALL2) (PG_FUNCTION_ARGS);

#define NEXTVAL(x) ( (lpathtree*)( (char*)(x) + INTALIGN( VARSIZE(x) ) ) )

static bool
array_iterator(ArrayType *la, PGCALL2 callback, void *param, lpathtree **found)
{
	int			num = ArrayGetNItems(ARR_NDIM(la), ARR_DIMS(la));
	lpathtree	   *item = (lpathtree *) ARR_DATA_PTR(la);

	if (ARR_NDIM(la) > 1)
		ereport(ERROR,
				(errcode(ERRCODE_ARRAY_SUBSCRIPT_ERROR),
				 errmsg("array must be one-dimensional")));
	if (array_contains_nulls(la))
		ereport(ERROR,
				(errcode(ERRCODE_NULL_VALUE_NOT_ALLOWED),
				 errmsg("array must not contain nulls")));

	if (found)
		*found = NULL;
	while (num > 0)
	{
		if (DatumGetBool(DirectFunctionCall2(callback,
							 PointerGetDatum(item), PointerGetDatum(param))))
		{

			if (found)
				*found = item;
			return true;
		}
		num--;
		item = NEXTVAL(item);
	}

	return false;
}

Datum
_lpathtree_isparent(PG_FUNCTION_ARGS)
{
	ArrayType  *la = PG_GETARG_ARRAYTYPE_P(0);
	lpathtree	   *query = PG_GETARG_LPATHTREE(1);
	bool		res = array_iterator(la, lpathtree_isparent, (void *) query, NULL);

	PG_FREE_IF_COPY(la, 0);
	PG_FREE_IF_COPY(query, 1);
	PG_RETURN_BOOL(res);
}

Datum
_lpathtree_r_isparent(PG_FUNCTION_ARGS)
{
	PG_RETURN_DATUM(DirectFunctionCall2(_lpathtree_isparent,
										PG_GETARG_DATUM(1),
										PG_GETARG_DATUM(0)
										));
}

Datum
_lpathtree_risparent(PG_FUNCTION_ARGS)
{
	ArrayType  *la = PG_GETARG_ARRAYTYPE_P(0);
	lpathtree	   *query = PG_GETARG_LPATHTREE(1);
	bool		res = array_iterator(la, lpathtree_risparent, (void *) query, NULL);

	PG_FREE_IF_COPY(la, 0);
	PG_FREE_IF_COPY(query, 1);
	PG_RETURN_BOOL(res);
}

Datum
_lpathtree_r_risparent(PG_FUNCTION_ARGS)
{
	PG_RETURN_DATUM(DirectFunctionCall2(_lpathtree_risparent,
										PG_GETARG_DATUM(1),
										PG_GETARG_DATUM(0)
										));
}

Datum
_ltq_regex(PG_FUNCTION_ARGS)
{
	ArrayType  *la = PG_GETARG_ARRAYTYPE_P(0);
	lpathquery	*query = PG_GETARG_LPATHQUERY(1);
	bool		res = array_iterator(la, ltq_regex, (void *) query, NULL);

	PG_FREE_IF_COPY(la, 0);
	PG_FREE_IF_COPY(query, 1);
	PG_RETURN_BOOL(res);
}

Datum
_ltq_rregex(PG_FUNCTION_ARGS)
{
	PG_RETURN_DATUM(DirectFunctionCall2(_ltq_regex,
										PG_GETARG_DATUM(1),
										PG_GETARG_DATUM(0)
										));
}

Datum
_lt_q_regex(PG_FUNCTION_ARGS)
{
	ArrayType  *_tree = PG_GETARG_ARRAYTYPE_P(0);
	ArrayType  *_query = PG_GETARG_ARRAYTYPE_P(1);
	lpathquery *query = (lpathquery *) ARR_DATA_PTR(_query);
	bool		res = false;
	int			num = ArrayGetNItems(ARR_NDIM(_query), ARR_DIMS(_query));

	if (ARR_NDIM(_query) > 1)
		ereport(ERROR,
				(errcode(ERRCODE_ARRAY_SUBSCRIPT_ERROR),
				 errmsg("array must be one-dimensional")));
	if (array_contains_nulls(_query))
		ereport(ERROR,
				(errcode(ERRCODE_NULL_VALUE_NOT_ALLOWED),
				 errmsg("array must not contain nulls")));

	while (num > 0)
	{
		if (array_iterator(_tree, ltq_regex, (void *) query, NULL))
		{
			res = true;
			break;
		}
		num--;
		query = (lpathquery *) NEXTVAL(query);
	}

	PG_FREE_IF_COPY(_tree, 0);
	PG_FREE_IF_COPY(_query, 1);
	PG_RETURN_BOOL(res);
}

Datum
_lt_q_rregex(PG_FUNCTION_ARGS)
{
	PG_RETURN_DATUM(DirectFunctionCall2(_lt_q_regex,
										PG_GETARG_DATUM(1),
										PG_GETARG_DATUM(0)
										));
}

Datum
_lpathtree_extract_isparent(PG_FUNCTION_ARGS)
{
	ArrayType  *la = PG_GETARG_ARRAYTYPE_P(0);
	lpathtree	   *query = PG_GETARG_LPATHTREE(1);
	lpathtree	   *found,
			   *item;

	if (!array_iterator(la, lpathtree_isparent, (void *) query, &found))
	{
		PG_FREE_IF_COPY(la, 0);
		PG_FREE_IF_COPY(query, 1);
		PG_RETURN_NULL();
	}

	item = (lpathtree *) palloc(VARSIZE(found));
	memcpy(item, found, VARSIZE(found));

	PG_FREE_IF_COPY(la, 0);
	PG_FREE_IF_COPY(query, 1);
	PG_RETURN_POINTER(item);
}

Datum
_lpathtree_extract_risparent(PG_FUNCTION_ARGS)
{
	ArrayType  *la = PG_GETARG_ARRAYTYPE_P(0);
	lpathtree	   *query = PG_GETARG_LPATHTREE(1);
	lpathtree	   *found,
			   *item;

	if (!array_iterator(la, lpathtree_risparent, (void *) query, &found))
	{
		PG_FREE_IF_COPY(la, 0);
		PG_FREE_IF_COPY(query, 1);
		PG_RETURN_NULL();
	}

	item = (lpathtree *) palloc(VARSIZE(found));
	memcpy(item, found, VARSIZE(found));

	PG_FREE_IF_COPY(la, 0);
	PG_FREE_IF_COPY(query, 1);
	PG_RETURN_POINTER(item);
}

Datum
_ltq_extract_regex(PG_FUNCTION_ARGS)
{
	ArrayType  *la = PG_GETARG_ARRAYTYPE_P(0);
	lpathquery *query = PG_GETARG_LPATHQUERY(1);
	lpathtree	   *found,
			   *item;

	if (!array_iterator(la, ltq_regex, (void *) query, &found))
	{
		PG_FREE_IF_COPY(la, 0);
		PG_FREE_IF_COPY(query, 1);
		PG_RETURN_NULL();
	}

	item = (lpathtree *) palloc(VARSIZE(found));
	memcpy(item, found, VARSIZE(found));

	PG_FREE_IF_COPY(la, 0);
	PG_FREE_IF_COPY(query, 1);
	PG_RETURN_POINTER(item);
}

Datum
_lca(PG_FUNCTION_ARGS)
{
	ArrayType  *la = PG_GETARG_ARRAYTYPE_P(0);
	int			num = ArrayGetNItems(ARR_NDIM(la), ARR_DIMS(la));
	lpathtree	   *item = (lpathtree *) ARR_DATA_PTR(la);
	lpathtree	  **a,
			   *res;

	if (ARR_NDIM(la) > 1)
		ereport(ERROR,
				(errcode(ERRCODE_ARRAY_SUBSCRIPT_ERROR),
				 errmsg("array must be one-dimensional")));
	if (array_contains_nulls(la))
		ereport(ERROR,
				(errcode(ERRCODE_NULL_VALUE_NOT_ALLOWED),
				 errmsg("array must not contain nulls")));

	a = (lpathtree **) palloc(sizeof(lpathtree *) * num);
	while (num > 0)
	{
		num--;
		a[num] = item;
		item = NEXTVAL(item);
	}
	res = lca_inner(a, ArrayGetNItems(ARR_NDIM(la), ARR_DIMS(la)));
	pfree(a);

	PG_FREE_IF_COPY(la, 0);

	if (res)
		PG_RETURN_POINTER(res);
	else
		PG_RETURN_NULL();
}
