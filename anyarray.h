/*-------------------------------------------------------------------------
 * 
 * anyarray.h
 *        anyarray common declarations
 *
 * Portions Copyright (c) 1996-2023, PostgreSQL Global Development Group
 *
 * Copyright (c) 2023, Postgres Professional
 *
 * Author: Teodor Sigaev <teodor@sigaev.ru>,
 *         Oleg Bartunov <o.bartunov@postgrespro.ru>
 *
 * IDENTIFICATION
 *        contrib/anyarray/anyarray.c
 *
 *-------------------------------------------------------------------------
 */

#ifndef _ANYARRAY_H_
#define _ANYARRAY_H_
#include "postgres.h"
#include "fmgr.h"
#include "nodes/memnodes.h"
#include "utils/array.h"

typedef struct AnyArrayTypeInfo
{
	Oid				typid;
	int16			typlen;
	bool			typbyval;
	char			typalign;
	MemoryContext	funcCtx;
	Oid				cmpFuncOid;
	bool			cmpFuncInited;
	FmgrInfo		cmpFunc;
	bool			hashFuncInited;
	Oid				hashFuncOid;
	FmgrInfo		hashFunc;
} AnyArrayTypeInfo;

typedef struct SimpleArray
{
	Datum				*elems;
	int32				*hashedElems;
	int32				nelems;
	int32				nHashedElems;
	AnyArrayTypeInfo	*info;
} SimpleArray;

#define LINEAR_LIMIT	(5)

#define NDIM 1
#define ARRISVOID(x)  ((x) == NULL || ARRNELEMS(x) == 0)
#define ARRNELEMS(x)  ArrayGetNItems(ARR_NDIM(x), ARR_DIMS(x))

/* reject arrays we can't handle; but allow a NULL or empty array */
#define CHECKARRVALID(x) \
	do { \
		if (x) { \
			if (ARR_NDIM(x) != NDIM && ARR_NDIM(x) != 0) \
				ereport(ERROR, \
						(errcode(ERRCODE_ARRAY_SUBSCRIPT_ERROR), \
						 errmsg("array must be one-dimensional"))); \
			if (ARR_HASNULL(x) && array_contains_nulls(x)) \
				ereport(ERROR, \
						(errcode(ERRCODE_NULL_VALUE_NOT_ALLOWED), \
						 errmsg("array must not contain nulls"))); \
		} \
	} while(0)


typedef enum SimilarityKind {
	AA_Cosine,
	AA_Jaccard,
	AA_Overlap
} SimilarityKind;

extern SimilarityKind SmlType;
extern double SmlLimit;

#define AnyAarraySimilarityStrategy	(16)

/*
 * Various support functions
 */
extern AnyArrayTypeInfo* getAnyArrayTypeInfo(MemoryContext ctx, Oid typid);
extern void freeAnyArrayTypeInfo(AnyArrayTypeInfo *info);
extern AnyArrayTypeInfo* getAnyArrayTypeInfoCached(FunctionCallInfo fcinfo, Oid typid);
extern void cmpFuncInit(AnyArrayTypeInfo* info);
extern void hashFuncInit(AnyArrayTypeInfo* info);
extern SimpleArray* Array2SimpleArray(AnyArrayTypeInfo  *info, ArrayType *a);
extern void	freeSimpleArray(SimpleArray* s);
extern ArrayType* SimpleArray2Array(SimpleArray *s);
extern void sortSimpleArray(SimpleArray *s, int32 direction);
extern void uniqSimpleArray(SimpleArray *s, bool onlyDuplicate);
extern void hashSimpleArray(SimpleArray *s);
extern double getSimilarity(SimpleArray *sa, SimpleArray *sb);
extern double getSimilarityValue(int32 nelemsa, int32 nelemsb, int32 intersection);
extern int numOfIntersect(SimpleArray *a, SimpleArray *b);
#endif

