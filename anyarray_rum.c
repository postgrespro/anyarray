/*-------------------------------------------------------------------------
 *
 * anyarray_rum.c
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
 *    contrib/anyarray/anyarray_rum.c
 *
 *-------------------------------------------------------------------------
 */

#include "postgres.h"
#include "catalog/pg_collation.h"

#include <float.h>
#include <math.h>
#if PG_VERSION_NUM >= 120000
#include "utils/float.h"
#else
static inline float8
get_float8_infinity(void)
{
#ifdef INFINITY
	/* C99 standard way */
	return (float8) INFINITY;
#else

	/*
	 * On some platforms, HUGE_VAL is an infinity, elsewhere it's just the
	 * largest normal float8.  We assume forcing an overflow will get us a
	 * true infinity.
	 */
	return (float8) (HUGE_VAL * HUGE_VAL);
#endif
}
#endif
#if PG_VERSION_NUM < 130000
/* definition of INT4OID in early PG versions */
#include "catalog/pg_type.h"
#endif

#include "anyarray.h"
#include "rum.h"

/*


*/


#define RUM_OVERLAP_STRATEGY	1
#define RUM_CONTAINS_STRATEGY	2
#define RUM_CONTAINED_STRATEGY	3
#define RUM_EQUAL_STRATEGY		4
#define RUM_SIMILAR_STRATEGY	5


#define NDIM			1

#define ARR_NELEMS(x)	ArrayGetNItems(ARR_NDIM(x), ARR_DIMS(x))
#define ARR_ISVOID(x)	( (x) == NULL || ARR_NELEMS(x) == 0 )


#define INIT_DUMMY_SIMPLE_ARRAY(s, len) \
	do { \
		(s)->elems = NULL; \
		(s)->hashedElems = NULL; \
		(s)->nelems = (len); \
		(s)->nHashedElems = -1; \
		(s)->info = NULL; \
	} while (0)

#define DIST_FROM_SML(sml) \
	( (sml == 0.0) ? get_float8_infinity() : ((float8) 1) / ((float8) (sml)) )

#if PG_VERSION_NUM < 110000
#define HASHSTANDARD_PROC HASHPROC
#endif

/*
 * Specifies additional information type for operator class.
 */
PG_FUNCTION_INFO_V1(rumanyarray_config);

Datum
rumanyarray_config(PG_FUNCTION_ARGS)
{
	RumConfig  *config = (RumConfig *) PG_GETARG_POINTER(0);

	config->addInfoTypeOid = INT4OID;
	config->strategyInfo[0].strategy = InvalidStrategy;

	PG_RETURN_VOID();
}


PG_FUNCTION_INFO_V1(rumextract_anyarray);
/*
 * Extract entries and queries
 */

/* Enhanced version of ginarrayextract() */
Datum
rumextract_anyarray(PG_FUNCTION_ARGS)
{
	/* Make copy of array input to ensure it doesn't disappear while in use */
	ArrayType		   *array = PG_GETARG_ARRAYTYPE_P_COPY(0);
	SimpleArray		   *sa;
	AnyArrayTypeInfo   *info;

	int32			   *nentries = (int32 *) PG_GETARG_POINTER(1);

	Datum			  **addInfo = (Datum **) PG_GETARG_POINTER(3);
	bool			  **addInfoIsNull = (bool **) PG_GETARG_POINTER(4);

	int					i;

	CHECKARRVALID(array);

	info = getAnyArrayTypeInfoCached(fcinfo, ARR_ELEMTYPE(array));

	sa = Array2SimpleArray(info, array);
	sortSimpleArray(sa, 1);
	uniqSimpleArray(sa, false);

	*nentries = sa->nelems;
	*addInfo = (Datum *) palloc(*nentries * sizeof(Datum));
	*addInfoIsNull = (bool *) palloc(*nentries * sizeof(bool));

	for (i = 0; i < *nentries; i++)
	{
		/* Use array's size as additional info */
		(*addInfo)[i] = Int32GetDatum(*nentries);
		(*addInfoIsNull)[i] = BoolGetDatum(false);
	}

	/* we should not free array, entries[i] points into it */
	PG_RETURN_POINTER(sa->elems);
}

PG_FUNCTION_INFO_V1(rumextract_anyarray_query);
/* Enhanced version of ginqueryarrayextract() */
Datum
rumextract_anyarray_query(PG_FUNCTION_ARGS)
{
	/* Make copy of array input to ensure it doesn't disappear while in use */
	ArrayType		   *array = PG_GETARG_ARRAYTYPE_P_COPY(0);
	SimpleArray		   *sa;
	AnyArrayTypeInfo   *info;

	int32			   *nentries = (int32 *) PG_GETARG_POINTER(1);

	StrategyNumber		strategy = PG_GETARG_UINT16(2);
	int32			   *searchMode = (int32 *) PG_GETARG_POINTER(6);

	CHECKARRVALID(array);

	info = getAnyArrayTypeInfoCached(fcinfo, ARR_ELEMTYPE(array));

	sa = Array2SimpleArray(info, array);
	sortSimpleArray(sa, 1);
	uniqSimpleArray(sa, false);

	*nentries = sa->nelems;

	switch (strategy)
	{
		case RUM_OVERLAP_STRATEGY:
			*searchMode = GIN_SEARCH_MODE_DEFAULT;
			break;
		case RUM_CONTAINS_STRATEGY:
			if (*nentries > 0)
				*searchMode = GIN_SEARCH_MODE_DEFAULT;
			else	/* everything contains the empty set */
				*searchMode = GIN_SEARCH_MODE_ALL;
			break;
		case RUM_CONTAINED_STRATEGY:
			/* empty set is contained in everything */
			*searchMode = GIN_SEARCH_MODE_INCLUDE_EMPTY;
			break;
		case RUM_EQUAL_STRATEGY:
			if (*nentries > 0)
				*searchMode = GIN_SEARCH_MODE_DEFAULT;
			else
				*searchMode = GIN_SEARCH_MODE_INCLUDE_EMPTY;
			break;
		case RUM_SIMILAR_STRATEGY:
			*searchMode = GIN_SEARCH_MODE_DEFAULT;
			break;
		/* Special case for distance */
		case RUM_DISTANCE:
			*searchMode = GIN_SEARCH_MODE_DEFAULT;
			break;
		default:
			elog(ERROR, "rum_extract_anyarray_query: unknown strategy number: %d",
				 strategy);
	}

	/* we should not free array, elems[i] points into it */
	PG_RETURN_POINTER(sa->elems);
}



PG_FUNCTION_INFO_V1(rumanyarray_consistent);
/*
 * Consistency check
 */

/* Enhanced version of ginarrayconsistent() */
Datum
rumanyarray_consistent(PG_FUNCTION_ARGS)
{
	bool	   *check = (bool *) PG_GETARG_POINTER(0);

	StrategyNumber strategy = PG_GETARG_UINT16(1);

	/* ArrayType  *query = PG_GETARG_ARRAYTYPE_P(2); */
	int32		nkeys = PG_GETARG_INT32(3);

	/* Pointer	   *extra_data = (Pointer *) PG_GETARG_POINTER(4); */
	bool	   *recheck = (bool *) PG_GETARG_POINTER(5);

	/* Datum	   *queryKeys = (Datum *) PG_GETARG_POINTER(6); */

    /* rumextract_anyarray_query does not return nullFlags, so RUM initializes all them by false */
	/* bool	   *nullFlags = (bool *) PG_GETARG_POINTER(7); */

/* 
*  RUM initializes addInfo and addInfoIsNull :
*  if check[i]==false, then addInfo[i] equals to (Datum)0, addInfoIsNull[i] equals to true 
*  if check[i]==true,  then addInfo[i] equals to AddInfo value stored in index, addInfoIsNull[i] equals to false 
*/
	Datum	   *addInfo = (Datum *) PG_GETARG_POINTER(8);
    bool	   *addInfoIsNull = (bool *) PG_GETARG_POINTER(9); 

	bool		res;
	int32		i;

	switch (strategy)
	{
		case RUM_OVERLAP_STRATEGY:
            /* at least one element in check[] is true, so result = true */
            *recheck = false;
            res = true;
			break;
		case RUM_CONTAINS_STRATEGY:
            /* result is not lossy */
			*recheck = false;

			/* must have all elements in check[] true, and no nulls */
			res = true;
			for (i = 0; i < nkeys; i++)
			{
				if (!check[i] /* || nullFlags[i] */)
				{
					res = false;
					break;
				}
			}
			break;
		case RUM_CONTAINED_STRATEGY:
			/* we will not need recheck, use addInfo to decide if tuple contains all elements from query */
            {
                int32		intersection = 0,
                                nentries = 0;
                *recheck = false;
                res = true;
                
                for (i = 0; i < nkeys; i++)
                {
                    if (check[i])
                    {
                        if (!nentries && !addInfoIsNull[i]) 
                        {
                            nentries = DatumGetInt32(addInfo[i]);
                            if(nentries > nkeys)
                            {
                                res = false;
                                break;
                            }
                        }
                        intersection++;
                    }            
                }
                /* if elements quantity in key equals to total quantity of elements in array ,we do not need to recheck */
                if(res)
                {
                    if(nentries != intersection)
                    {
                        res = false;
                    }
                }
            } 
			break;
		case RUM_EQUAL_STRATEGY:
			/* we will need recheck */
			*recheck = true; 

			/*
			 * Must have all elements in check[] true; no discrimination
			 * against nulls here.  This is because array_contain_compare and
			 * array_eq handle nulls differently ...
			 *
			 * Also, query and array must have equal amount of elements.
			 */
            res = true;
			for (i = 0; i < nkeys; i++)
			{
				if (!check[i])
				{
					res = false;
					break;
				}

				if (!addInfoIsNull[i] && DatumGetInt32(addInfo[i]) != nkeys)
				{
					res = false;
					break;
				}
			}
			break;
		case RUM_SIMILAR_STRATEGY:
			/* we won't need recheck */
			*recheck = false;

			{
				int32		intersection = 0,
							nentries = -1;
				float8 sml;

				for (i = 0; i < nkeys; i++)
					if (check[i])
						intersection++;
                if(intersection > 0 )
                {
                    /* extract array's length from addInfo */
                    for (i = 0; i < nkeys; i++)
                    {
                        if (!addInfoIsNull[i])
                        {
                            nentries = DatumGetInt32(addInfo[i]);
                            break;
                        }
                    } 

                    /* there must be addInfo */
                    Assert(nentries >= 0);
                    if(nentries == 0)
                    {
                        sml = 0.0; /* empty key */
                    }
                    else {
                        sml = getSimilarityValue(nentries, nkeys, intersection);
                    }
                } 
                else 
                {
                    sml = 0.0 ;
                }
                res = (sml >= SmlLimit);
			}
			break;
		default:
			elog(ERROR, "rum_anyarray_consistent: unknown strategy number: %d",
				 strategy);
			res = false;
	}

	PG_RETURN_BOOL(res);
}

PG_FUNCTION_INFO_V1(rumanyarray_preconsistent);
Datum
rumanyarray_preconsistent(PG_FUNCTION_ARGS)
{
	bool	   *check = (bool *) PG_GETARG_POINTER(0);
	StrategyNumber strategy = PG_GETARG_UINT16(1);
	/* ArrayType  *query = PG_GETARG_ARRAYTYPE_P(2); */
	int32		nkeys = PG_GETARG_INT32(3);
	/* Pointer	   *extra_data = (Pointer *) PG_GETARG_POINTER(4); */ 
	/* bool	   *recheck = (bool *) PG_GETARG_POINTER(5); */
	/* Datum	   *queryKeys = (Datum *) PG_GETARG_POINTER(6); */ 
	/* bool	   *nullFlags = (bool *) PG_GETARG_POINTER(7); */

	bool		res;
	int32		i;

	switch (strategy)
	{
		case RUM_OVERLAP_STRATEGY:
			/* 
            * at least one check[i]==true
            * preConsistent function is not called, if all check[i]==false
            */
			res = true;
			break;
		case RUM_CONTAINS_STRATEGY:
			/* 
            * at least one check[i]==false
            * preConsistent function is not called, if all check[i]==true
            */
            res = false;
			break;
		case RUM_CONTAINED_STRATEGY:
			/* we will need recheck */
			res = true;
			break;
		case RUM_EQUAL_STRATEGY:
			/* 
            * at least one check[i]==false
            * preConsistent function is not called, if all check[i]==true
            */
            res = false;
			break;
		case RUM_SIMILAR_STRATEGY:
		    {
				int32		intersection = 0;
				
                for (i = 0; i < nkeys; i++)
					if (check[i])
						intersection++;

				switch(SmlType)
				{
					case AA_Cosine:
						/* intersection / sqrt(nkeys * intersection) */
						res = (sqrt(((double)intersection) / (double)nkeys) >= SmlLimit);
						break;
					case AA_Jaccard:
						res = ((((double)intersection) / (double)nkeys) >= SmlLimit);
						break;
					case AA_Overlap:
						/*  
						*  if intersection >= SmlLimit, so result = true
						*  if intersection < SmlLimit, so result = false
						*/
						res = (((double)intersection) >= SmlLimit);
						break;
					default:
						elog(ERROR, "unknown similarity type");
				}
			}
			break;
		default:
			elog(ERROR, "rum_anyarray_preconsistent: unknown strategy number: %d", strategy);
			res = false;
	}

	PG_RETURN_BOOL(res);
}



PG_FUNCTION_INFO_V1(rumanyarray_ordering);
/*
 * Similarity and distance
 */

Datum
rumanyarray_ordering(PG_FUNCTION_ARGS)
{
	bool	   *check = (bool *) PG_GETARG_POINTER(0);
	int			nkeys = PG_GETARG_INT32(3);
	Datum	   *addInfo = (Datum *) PG_GETARG_POINTER(8);
	bool	   *addInfoIsNull = (bool *) PG_GETARG_POINTER(9);

	float8		sml;
	int32		intersection = 0,
				nentries = -1;
	int			i;

	for (i = 0; i < nkeys; i++)
		if (check[i])
			intersection++;

	if (intersection > 0)
	{
		/* extract array's length from addInfo */
		for (i = 0; i < nkeys; i++)
		{
			if (!addInfoIsNull[i])
			{
				nentries = DatumGetInt32(addInfo[i]);
				break;
			}
		}

		/* there must be addInfo */
		Assert(nentries >= 0);
        sml = getSimilarityValue(nkeys, nentries, intersection);
        PG_RETURN_FLOAT8(DIST_FROM_SML(sml));
	}

	PG_RETURN_FLOAT8(DIST_FROM_SML(0.0));
}


PG_FUNCTION_INFO_V1(rumanyarray_distance);
Datum
rumanyarray_distance(PG_FUNCTION_ARGS)
{
	ArrayType		   *a = PG_GETARG_ARRAYTYPE_P(0);
	ArrayType		   *b = PG_GETARG_ARRAYTYPE_P(1);
	AnyArrayTypeInfo   *info;
	SimpleArray		   *sa,
					   *sb;
	float8				sml = 0.0;

	CHECKARRVALID(a);
	CHECKARRVALID(b);

	if (ARR_ELEMTYPE(a) != ARR_ELEMTYPE(b))
		ereport(ERROR,
				(errcode(ERRCODE_INVALID_PARAMETER_VALUE),
				 errmsg("array types do not match")));

	if (ARR_ISVOID(a) || ARR_ISVOID(b))
		PG_RETURN_FLOAT8(0.0);

	if (fcinfo->flinfo->fn_extra == NULL)
		fcinfo->flinfo->fn_extra = getAnyArrayTypeInfo(fcinfo->flinfo->fn_mcxt,
													   ARR_ELEMTYPE(a));
	info = (AnyArrayTypeInfo *) fcinfo->flinfo->fn_extra;

	sa = Array2SimpleArray(info, a);
	sb = Array2SimpleArray(info, b);

	sml = getSimilarityValue(sa->nelems, sb->nelems, numOfIntersect(sa, sb));

	freeSimpleArray(sb);
	freeSimpleArray(sa);

	PG_FREE_IF_COPY(b, 1);
	PG_FREE_IF_COPY(a, 0);

	PG_RETURN_FLOAT8(DIST_FROM_SML(sml));
}
