/*
 * contrib/lpathtree/_lpathtree_gist.c
 *
 *
 * GiST support for lpathtree[]
 * Teodor Sigaev <teodor@stack.net>
 */
#include "postgres.h"

#include "access/gist.h"
#include "access/skey.h"
#include "crc32.h"
#include "lpathtree.h"


PG_FUNCTION_INFO_V1(_lpathtree_compress);
Datum		_lpathtree_compress(PG_FUNCTION_ARGS);

PG_FUNCTION_INFO_V1(_lpathtree_same);
Datum		_lpathtree_same(PG_FUNCTION_ARGS);

PG_FUNCTION_INFO_V1(_lpathtree_union);
Datum		_lpathtree_union(PG_FUNCTION_ARGS);

PG_FUNCTION_INFO_V1(_lpathtree_penalty);
Datum		_lpathtree_penalty(PG_FUNCTION_ARGS);

PG_FUNCTION_INFO_V1(_lpathtree_picksplit);
Datum		_lpathtree_picksplit(PG_FUNCTION_ARGS);

PG_FUNCTION_INFO_V1(_lpathtree_consistent);
Datum		_lpathtree_consistent(PG_FUNCTION_ARGS);

#define GETENTRY(vec,pos) ((lpathtree_gist *) DatumGetPointer((vec)->vector[(pos)].key))
#define NEXTVAL(x) ( (lpathtree*)( (char*)(x) + INTALIGN( VARSIZE(x) ) ) )

/* Number of one-bits in an unsigned byte */
static const uint8 number_of_ones[256] = {
	0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4,
	1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5,
	1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5,
	2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
	1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5,
	2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
	2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
	3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7,
	1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5,
	2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
	2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
	3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7,
	2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
	3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7,
	3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7,
	4, 5, 5, 6, 5, 6, 6, 7, 5, 6, 6, 7, 6, 7, 7, 8
};

#define WISH_F(a,b,c) (double)( -(double)(((a)-(b))*((a)-(b))*((a)-(b)))*(c) )


static void
hashing(BITVECP sign, lpathtree *t)
{
	int			tlen = t->numlevel;
	lpathtree_level *cur = LPATHTREE_FIRST(t);
	int			hash;

	while (tlen > 0)
	{
		hash = lpathtree_crc32_sz(cur->name, cur->len);
		AHASH(sign, hash);
		cur = LEVEL_NEXT(cur);
		tlen--;
	}
}

Datum
_lpathtree_compress(PG_FUNCTION_ARGS)
{
	GISTENTRY  *entry = (GISTENTRY *) PG_GETARG_POINTER(0);
	GISTENTRY  *retval = entry;

	if (entry->leafkey)
	{							/* lpathtree */
		lpathtree_gist *key;
		ArrayType  *val = DatumGetArrayTypeP(entry->key);
		int32		len = LTG_HDRSIZE + ASIGLEN;
		int			num = ArrayGetNItems(ARR_NDIM(val), ARR_DIMS(val));
		lpathtree	   *item = (lpathtree *) ARR_DATA_PTR(val);

		if (ARR_NDIM(val) > 1)
			ereport(ERROR,
					(errcode(ERRCODE_ARRAY_SUBSCRIPT_ERROR),
					 errmsg("array must be one-dimensional")));
		if (array_contains_nulls(val))
			ereport(ERROR,
					(errcode(ERRCODE_NULL_VALUE_NOT_ALLOWED),
					 errmsg("array must not contain nulls")));

		key = (lpathtree_gist *) palloc(len);
		SET_VARSIZE(key, len);
		key->flag = 0;

		MemSet(LTG_SIGN(key), 0, ASIGLEN);
		while (num > 0)
		{
			hashing(LTG_SIGN(key), item);
			num--;
			item = NEXTVAL(item);
		}

		retval = (GISTENTRY *) palloc(sizeof(GISTENTRY));
		gistentryinit(*retval, PointerGetDatum(key),
					  entry->rel, entry->page,
					  entry->offset, FALSE);
	}
	else if (!LTG_ISALLTRUE(entry->key))
	{
		int32		i,
					len;
		lpathtree_gist *key;

		BITVECP		sign = LTG_SIGN(DatumGetPointer(entry->key));

		ALOOPBYTE
		{
			if ((sign[i] & 0xff) != 0xff)
				PG_RETURN_POINTER(retval);
		}
		len = LTG_HDRSIZE;
		key = (lpathtree_gist *) palloc(len);
		SET_VARSIZE(key, len);
		key->flag = LTG_ALLTRUE;

		retval = (GISTENTRY *) palloc(sizeof(GISTENTRY));
		gistentryinit(*retval, PointerGetDatum(key),
					  entry->rel, entry->page,
					  entry->offset, FALSE);
	}
	PG_RETURN_POINTER(retval);
}

Datum
_lpathtree_same(PG_FUNCTION_ARGS)
{
	lpathtree_gist *a = (lpathtree_gist *) PG_GETARG_POINTER(0);
	lpathtree_gist *b = (lpathtree_gist *) PG_GETARG_POINTER(1);
	bool	   *result = (bool *) PG_GETARG_POINTER(2);

	if (LTG_ISALLTRUE(a) && LTG_ISALLTRUE(b))
		*result = true;
	else if (LTG_ISALLTRUE(a))
		*result = false;
	else if (LTG_ISALLTRUE(b))
		*result = false;
	else
	{
		int32		i;
		BITVECP		sa = LTG_SIGN(a),
					sb = LTG_SIGN(b);

		*result = true;
		ALOOPBYTE
		{
			if (sa[i] != sb[i])
			{
				*result = false;
				break;
			}
		}
	}
	PG_RETURN_POINTER(result);
}

static int32
unionkey(BITVECP sbase, lpathtree_gist *add)
{
	int32		i;
	BITVECP		sadd = LTG_SIGN(add);

	if (LTG_ISALLTRUE(add))
		return 1;

	ALOOPBYTE
		sbase[i] |= sadd[i];
	return 0;
}

Datum
_lpathtree_union(PG_FUNCTION_ARGS)
{
	GistEntryVector *entryvec = (GistEntryVector *) PG_GETARG_POINTER(0);
	int		   *size = (int *) PG_GETARG_POINTER(1);
	ABITVEC		base;
	int32		i,
				len;
	int32		flag = 0;
	lpathtree_gist *result;

	MemSet((void *) base, 0, sizeof(ABITVEC));
	for (i = 0; i < entryvec->n; i++)
	{
		if (unionkey(base, GETENTRY(entryvec, i)))
		{
			flag = LTG_ALLTRUE;
			break;
		}
	}

	len = LTG_HDRSIZE + ((flag & LTG_ALLTRUE) ? 0 : ASIGLEN);
	result = (lpathtree_gist *) palloc(len);
	SET_VARSIZE(result, len);
	result->flag = flag;
	if (!LTG_ISALLTRUE(result))
		memcpy((void *) LTG_SIGN(result), (void *) base, sizeof(ABITVEC));
	*size = len;

	PG_RETURN_POINTER(result);
}

static int32
sizebitvec(BITVECP sign)
{
	int32		size = 0,
				i;

	ALOOPBYTE
		size += number_of_ones[(unsigned char) sign[i]];
	return size;
}

static int
hemdistsign(BITVECP a, BITVECP b)
{
	int			i,
				diff,
				dist = 0;

	ALOOPBYTE
	{
		diff = (unsigned char) (a[i] ^ b[i]);
		dist += number_of_ones[diff];
	}
	return dist;
}

static int
hemdist(lpathtree_gist *a, lpathtree_gist *b)
{
	if (LTG_ISALLTRUE(a))
	{
		if (LTG_ISALLTRUE(b))
			return 0;
		else
			return ASIGLENBIT - sizebitvec(LTG_SIGN(b));
	}
	else if (LTG_ISALLTRUE(b))
		return ASIGLENBIT - sizebitvec(LTG_SIGN(a));

	return hemdistsign(LTG_SIGN(a), LTG_SIGN(b));
}


Datum
_lpathtree_penalty(PG_FUNCTION_ARGS)
{
	lpathtree_gist *origval = (lpathtree_gist *) DatumGetPointer(((GISTENTRY *) PG_GETARG_POINTER(0))->key);
	lpathtree_gist *newval = (lpathtree_gist *) DatumGetPointer(((GISTENTRY *) PG_GETARG_POINTER(1))->key);
	float	   *penalty = (float *) PG_GETARG_POINTER(2);

	*penalty = hemdist(origval, newval);
	PG_RETURN_POINTER(penalty);
}

typedef struct
{
	OffsetNumber pos;
	int32		cost;
} SPLITCOST;

static int
comparecost(const void *a, const void *b)
{
	return ((const SPLITCOST *) a)->cost - ((const SPLITCOST *) b)->cost;
}

Datum
_lpathtree_picksplit(PG_FUNCTION_ARGS)
{
	GistEntryVector *entryvec = (GistEntryVector *) PG_GETARG_POINTER(0);
	GIST_SPLITVEC *v = (GIST_SPLITVEC *) PG_GETARG_POINTER(1);
	OffsetNumber k,
				j;
	lpathtree_gist *datum_l,
			   *datum_r;
	BITVECP		union_l,
				union_r;
	int32		size_alpha,
				size_beta;
	int32		size_waste,
				waste = -1;
	int32		nbytes;
	OffsetNumber seed_1 = 0,
				seed_2 = 0;
	OffsetNumber *left,
			   *right;
	OffsetNumber maxoff;
	BITVECP		ptr;
	int			i;
	SPLITCOST  *costvector;
	lpathtree_gist *_k,
			   *_j;

	maxoff = entryvec->n - 2;
	nbytes = (maxoff + 2) * sizeof(OffsetNumber);
	v->spl_left = (OffsetNumber *) palloc(nbytes);
	v->spl_right = (OffsetNumber *) palloc(nbytes);

	for (k = FirstOffsetNumber; k < maxoff; k = OffsetNumberNext(k))
	{
		_k = GETENTRY(entryvec, k);
		for (j = OffsetNumberNext(k); j <= maxoff; j = OffsetNumberNext(j))
		{
			size_waste = hemdist(_k, GETENTRY(entryvec, j));
			if (size_waste > waste)
			{
				waste = size_waste;
				seed_1 = k;
				seed_2 = j;
			}
		}
	}

	left = v->spl_left;
	v->spl_nleft = 0;
	right = v->spl_right;
	v->spl_nright = 0;

	if (seed_1 == 0 || seed_2 == 0)
	{
		seed_1 = 1;
		seed_2 = 2;
	}

	/* form initial .. */
	if (LTG_ISALLTRUE(GETENTRY(entryvec, seed_1)))
	{
		datum_l = (lpathtree_gist *) palloc(LTG_HDRSIZE);
		SET_VARSIZE(datum_l, LTG_HDRSIZE);
		datum_l->flag = LTG_ALLTRUE;
	}
	else
	{
		datum_l = (lpathtree_gist *) palloc(LTG_HDRSIZE + ASIGLEN);
		SET_VARSIZE(datum_l, LTG_HDRSIZE + ASIGLEN);
		datum_l->flag = 0;
		memcpy((void *) LTG_SIGN(datum_l), (void *) LTG_SIGN(GETENTRY(entryvec, seed_1)), sizeof(ABITVEC));
	}
	if (LTG_ISALLTRUE(GETENTRY(entryvec, seed_2)))
	{
		datum_r = (lpathtree_gist *) palloc(LTG_HDRSIZE);
		SET_VARSIZE(datum_r, LTG_HDRSIZE);
		datum_r->flag = LTG_ALLTRUE;
	}
	else
	{
		datum_r = (lpathtree_gist *) palloc(LTG_HDRSIZE + ASIGLEN);
		SET_VARSIZE(datum_r, LTG_HDRSIZE + ASIGLEN);
		datum_r->flag = 0;
		memcpy((void *) LTG_SIGN(datum_r), (void *) LTG_SIGN(GETENTRY(entryvec, seed_2)), sizeof(ABITVEC));
	}

	maxoff = OffsetNumberNext(maxoff);
	/* sort before ... */
	costvector = (SPLITCOST *) palloc(sizeof(SPLITCOST) * maxoff);
	for (j = FirstOffsetNumber; j <= maxoff; j = OffsetNumberNext(j))
	{
		costvector[j - 1].pos = j;
		_j = GETENTRY(entryvec, j);
		size_alpha = hemdist(datum_l, _j);
		size_beta = hemdist(datum_r, _j);
		costvector[j - 1].cost = Abs(size_alpha - size_beta);
	}
	qsort((void *) costvector, maxoff, sizeof(SPLITCOST), comparecost);

	union_l = LTG_SIGN(datum_l);
	union_r = LTG_SIGN(datum_r);

	for (k = 0; k < maxoff; k++)
	{
		j = costvector[k].pos;
		if (j == seed_1)
		{
			*left++ = j;
			v->spl_nleft++;
			continue;
		}
		else if (j == seed_2)
		{
			*right++ = j;
			v->spl_nright++;
			continue;
		}
		_j = GETENTRY(entryvec, j);
		size_alpha = hemdist(datum_l, _j);
		size_beta = hemdist(datum_r, _j);

		if (size_alpha < size_beta + WISH_F(v->spl_nleft, v->spl_nright, 0.00001))
		{
			if (LTG_ISALLTRUE(datum_l) || LTG_ISALLTRUE(_j))
			{
				if (!LTG_ISALLTRUE(datum_l))
					MemSet((void *) union_l, 0xff, sizeof(ABITVEC));
			}
			else
			{
				ptr = LTG_SIGN(_j);
				ALOOPBYTE
					union_l[i] |= ptr[i];
			}
			*left++ = j;
			v->spl_nleft++;
		}
		else
		{
			if (LTG_ISALLTRUE(datum_r) || LTG_ISALLTRUE(_j))
			{
				if (!LTG_ISALLTRUE(datum_r))
					MemSet((void *) union_r, 0xff, sizeof(ABITVEC));
			}
			else
			{
				ptr = LTG_SIGN(_j);
				ALOOPBYTE
					union_r[i] |= ptr[i];
			}
			*right++ = j;
			v->spl_nright++;
		}
	}

	*right = *left = FirstOffsetNumber;

	v->spl_ldatum = PointerGetDatum(datum_l);
	v->spl_rdatum = PointerGetDatum(datum_r);

	PG_RETURN_POINTER(v);
}

static bool
gist_te(lpathtree_gist *key, lpathtree *query)
{
	lpathtree_level *curq = LPATHTREE_FIRST(query);
	BITVECP		sign = LTG_SIGN(key);
	int			qlen = query->numlevel;
	unsigned int hv;

	if (LTG_ISALLTRUE(key))
		return true;

	while (qlen > 0)
	{
		hv = lpathtree_crc32_sz(curq->name, curq->len);
		if (!GETBIT(sign, AHASHVAL(hv)))
			return false;
		curq = LEVEL_NEXT(curq);
		qlen--;
	}

	return true;
}

static bool
checkcondition_bit(void *checkval, ITEM *val)
{
	return (FLG_CANLOOKSIGN(val->flag)) ? GETBIT(checkval, AHASHVAL(val->val)) : true;
}

static bool
gist_qe(lpathtree_gist *key, lpathquery *query)
{
	lpathquery_level *curq = LPATHQUERY_FIRST(query);
	BITVECP		sign = LTG_SIGN(key);
	int			qlen = query->numlevel;

	if (LTG_ISALLTRUE(key))
		return true;

	while (qlen > 0)
	{
		if (curq->numvar && LQL_CANLOOKSIGN(curq))
		{
			bool		isexist = false;
			int			vlen = curq->numvar;
			lpathquery_variant *curv = LQL_FIRST(curq);

			while (vlen > 0)
			{
				if (GETBIT(sign, AHASHVAL(curv->val)))
				{
					isexist = true;
					break;
				}
				curv = LVAR_NEXT(curv);
				vlen--;
			}
			if (!isexist)
				return false;
		}

		curq = LQL_NEXT(curq);
		qlen--;
	}

	return true;
}

static bool
_arrq_cons(lpathtree_gist *key, ArrayType *_query)
{
	lpathquery  *query = (lpathquery *) ARR_DATA_PTR(_query);
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
		if (gist_qe(key, query))
			return true;
		num--;
		query = (lpathquery *) NEXTVAL(query);
	}
	return false;
}

Datum
_lpathtree_consistent(PG_FUNCTION_ARGS)
{
	GISTENTRY  *entry = (GISTENTRY *) PG_GETARG_POINTER(0);
	char	   *query = (char *) DatumGetPointer(PG_DETOAST_DATUM(PG_GETARG_DATUM(1)));
	StrategyNumber strategy = (StrategyNumber) PG_GETARG_UINT16(2);

	/* Oid		subtype = PG_GETARG_OID(3); */
	bool	   *recheck = (bool *) PG_GETARG_POINTER(4);
	lpathtree_gist *key = (lpathtree_gist *) DatumGetPointer(entry->key);
	bool		res = false;

	/* All cases served by this function are inexact */
	*recheck = true;

	switch (strategy)
	{
		case 10:
		case 11:
			res = gist_te(key, (lpathtree *) query);
			break;
		case 12:
		case 13:
			res = gist_qe(key, (lpathquery *) query);
			break;
		case 14:
		case 15:
			res = _arrq_cons(key, (ArrayType *) query);
			break;
		default:
			/* internal error */
			elog(ERROR, "unrecognized StrategyNumber: %d", strategy);
	}
	PG_FREE_IF_COPY(query, 1);
	PG_RETURN_BOOL(res);
}
