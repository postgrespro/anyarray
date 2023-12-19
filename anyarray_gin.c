/*-------------------------------------------------------------------------
 *
 * anyarray_gin.c
 *    GIN support functions for anyarray
 *
 * Portions Copyright (c) 1996-2023, PostgreSQL Global Development Group
 *
 * Copyright (c) 2023, Postgres Professional
 *
 * Author: Teodor Sigaev <teodor@sigaev.ru>,
 *         Oleg Bartunov <o.bartunov@postgrespro.ru>
 *
 * IDENTIFICATION
 *    contrib/anyarray/anyarray_gin.c
 *
 *-------------------------------------------------------------------------
 */


#include "postgres.h"

#include "access/gin.h"
#include "access/gist.h"
#include "access/skey.h"

#include "anyarray.h"

PG_FUNCTION_INFO_V1(ginanyarray_extract);
Datum
ginanyarray_extract(PG_FUNCTION_ARGS)
{
	ArrayType			*array;
	int32				*nentries = (int32 *) PG_GETARG_POINTER(1);
	SimpleArray			*sa;
	AnyArrayTypeInfo	*info;

	array = PG_GETARG_ARRAYTYPE_P_COPY(0);

	CHECKARRVALID(array);

	info = getAnyArrayTypeInfoCached(fcinfo, ARR_ELEMTYPE(array));

	sa = Array2SimpleArray(info, array);
	sortSimpleArray(sa, 1);
	uniqSimpleArray(sa, false);

	*nentries = sa->nelems;

	 PG_RETURN_POINTER(sa->elems);
}


PG_FUNCTION_INFO_V1(ginanyarray_queryextract);
Datum
ginanyarray_queryextract(PG_FUNCTION_ARGS)
{
	int32	   			*searchMode = (int32 *) PG_GETARG_POINTER(6);
	int32				*nentries = (int32 *) PG_GETARG_POINTER(1);
	StrategyNumber 		strategy = PG_GETARG_UINT16(2);
	SimpleArray			*sa;
	AnyArrayTypeInfo	*info;
	ArrayType			*array;

	array = PG_GETARG_ARRAYTYPE_P_COPY(0);

	CHECKARRVALID(array);

	info = getAnyArrayTypeInfoCached(fcinfo, ARR_ELEMTYPE(array));

	sa = Array2SimpleArray(info, array);
	sortSimpleArray(sa, 1);
	uniqSimpleArray(sa, false);

	*nentries = sa->nelems;

	switch (strategy)
	{
		case AnyAarraySimilarityStrategy:
		case RTOverlapStrategyNumber:
			*searchMode = GIN_SEARCH_MODE_DEFAULT;
			break;
		case RTContainedByStrategyNumber:
			/* empty set is contained in everything */
			*searchMode = GIN_SEARCH_MODE_INCLUDE_EMPTY;
			break;
		case RTSameStrategyNumber:
			if (*nentries > 0)
				*searchMode = GIN_SEARCH_MODE_DEFAULT;
			else
				*searchMode = GIN_SEARCH_MODE_INCLUDE_EMPTY;
			break;
		case RTContainsStrategyNumber:
			if (*nentries > 0)
				*searchMode = GIN_SEARCH_MODE_DEFAULT;
			else	/* everything contains the empty set */
				*searchMode = GIN_SEARCH_MODE_ALL;
			break;
		default:
			elog(ERROR, "ginanyarray_queryextract: unknown strategy number: %d",
				 strategy);
	}

	PG_RETURN_POINTER(sa->elems);
}

PG_FUNCTION_INFO_V1(ginanyarray_consistent);
Datum
ginanyarray_consistent(PG_FUNCTION_ARGS)
{
	bool	   		*check = (bool *) PG_GETARG_POINTER(0);
	StrategyNumber 	strategy = PG_GETARG_UINT16(1);
	int32			nkeys = PG_GETARG_INT32(3);
	/* Pointer	   	*extra_data = (Pointer *) PG_GETARG_POINTER(4); */
	bool	   		*recheck = (bool *) PG_GETARG_POINTER(5);
	bool			res = true;
	int32			i;

	switch (strategy)
	{
		case RTOverlapStrategyNumber:
			/* result is not lossy */
			*recheck = false;
			/* at least one element in check[] is true, so result = true */
			res = true;
			break;
		case RTContainedByStrategyNumber:
			/* we will need recheck */
			*recheck = true;
			/* at least one element in check[] is true, so result = true */
			res = true;
			break;
		case RTSameStrategyNumber:
			/* we will need recheck */
			*recheck = true;
			/* Must have all elements in check[] true */
			res = true;
			for (i = 0; i < nkeys; i++)
			{
				if (!check[i])
				{
					res = false;
					break;
				}
			}
			break;
		case RTContainsStrategyNumber:
			/* result is not lossy */
			*recheck = false;
			/* Must have all elements in check[] true */
			res = true;
			for (i = 0; i < nkeys; i++)
			{
				if (!check[i])
				{
					res = false;
					break;
				}
			}
			break;
		case AnyAarraySimilarityStrategy:
			{
				int32	nIntersection = 0;

				for (i = 0; i < nkeys; i++)
				{
					if (check[i])
						nIntersection++;
				}

				switch(SmlType)
				{
					case AA_Cosine:
						*recheck = true;
						/* nIntersection / sqrt(nkeys * nIntersection) */
						res = (sqrt(((double)nIntersection) / (double)nkeys) >= SmlLimit);
						break;
					case AA_Jaccard:
						*recheck = true;
						res = ((((double)nIntersection) / (double)nkeys) >= SmlLimit);
						break;
					case AA_Overlap:
						*recheck = false;
						res = (((double)nIntersection) >= SmlLimit);
						break;
					default:
						elog(ERROR, "unknown similarity type");
				}
			}
			break;
		default:
			elog(ERROR, "ginanyarray_consistent: unknown strategy number: %d",
				 strategy);
	}

	PG_RETURN_BOOL(res);
}

PG_FUNCTION_INFO_V1(ginanyarray_triconsistent);
Datum
ginanyarray_triconsistent(PG_FUNCTION_ARGS)
{
	GinTernaryValue *check = (GinTernaryValue *)PG_GETARG_POINTER(0);
	StrategyNumber 	strategy = PG_GETARG_UINT16(1);
	int32			nkeys = PG_GETARG_INT32(3);
	/* Pointer	   	*extra_data = (Pointer *) PG_GETARG_POINTER(4); */
	GinTernaryValue res = GIN_MAYBE;
	int32			i;

	switch (strategy)
	{
		case RTOverlapStrategyNumber:
			/* if at least one element in check[] is GIN_TRUE, so result = GIN_TRUE
			*  otherwise if at least one element in check[] is GIN_MAYBE, so result = GIN_MAYBE
			*  otherwise result = GIN_FALSE
			*/
			res = GIN_FALSE;
			for (i = 0; i < nkeys; i++)
			{
				if (check[i] == GIN_TRUE)
				{
					res = GIN_TRUE;
					break;
				} else if (check[i] == GIN_MAYBE)
				{
					res = GIN_MAYBE;
				} 
			}
			break;
		case RTContainedByStrategyNumber:
			/* at least one element in check[] is GIN_TRUE or GIN_MAYBE, so result = GIN_MAYBE (we will need recheck in any case) */
			res = GIN_MAYBE;
			break;
		case RTSameStrategyNumber:
			/* if at least one element in check[] is GIN_FALSE, so result = GIN_FALSE
			*  otherwise result = GIN_MAYBE
			*/
			res = GIN_MAYBE;
			for (i = 0; i < nkeys; i++)
			{
				if (check[i] == GIN_FALSE)
				{
					res = GIN_FALSE;
					break;
				} 
			}
			break;
		case RTContainsStrategyNumber:
			/* if at least one element in check[] is GIN_FALSE, so result = GIN_FALSE
			*  otherwise if at least one element in check[] is GIN_MAYBE, so result = GIN_MAYBE
			*  otherwise result = GIN_TRUE
			*/
			res = GIN_TRUE;
			for (i = 0; i < nkeys; i++)
			{
				if (check[i] == GIN_FALSE)
				{
					res = GIN_FALSE;
					break;
				} else if (check[i] == GIN_MAYBE)
				{
					res = GIN_MAYBE;
				} 
			}
			break;
		case AnyAarraySimilarityStrategy:
			{
				int32	nIntersectionMin = 0;
				int32	nIntersectionMax = 0;

				res = GIN_FALSE;
				for (i = 0; i < nkeys; i++)
				{
					if (check[i] == GIN_TRUE)
					{
						nIntersectionMin++;
						nIntersectionMax++;
					} else if (check[i] == GIN_MAYBE)
					{
						nIntersectionMax++;
						res = GIN_MAYBE;
					}
				}

				switch(SmlType)
				{
					case AA_Cosine:
						/* nIntersection / sqrt(nkeys * nIntersection) */
						if(sqrt(((double)nIntersectionMax) / (double)nkeys) < SmlLimit){
							res = GIN_FALSE;	
						} else {
							res = GIN_MAYBE;
						}
						break;
					case AA_Jaccard:
						if((((double)nIntersectionMax) / (double)nkeys) < SmlLimit){
							res = GIN_FALSE;	
						} else {
							res = GIN_MAYBE;
						}
						break;
					case AA_Overlap:
						/* if nIntersection >= SmlLimit, so result = GIN_TRUE
						*  otherwise if at least one element in check[] is GIN_MAYBE, so result = GIN_MAYBE
						*  otherwise result = GIN_FALSE
						*/
						if(((double)nIntersectionMin) >= SmlLimit)
						{
							res = GIN_TRUE;
						}
						break;
					default:
						elog(ERROR, "unknown similarity type");
				}
			}
			break;
		default:
			elog(ERROR, "ginanyarray_consistent: unknown strategy number: %d",
				 strategy);
	}
	PG_RETURN_GIN_TERNARY_VALUE(res);
}
