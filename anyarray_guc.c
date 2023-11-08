/*-------------------------------------------------------------------------
 * 
 * anyarray_guc.c
 *		GUC management
 *
 * Portions Copyright (c) 1996-2023, PostgreSQL Global Development Group
 *
 * Copyright (c) 2023, Postgres Professional
 *
 * Author: Teodor Sigaev <teodor@sigaev.ru>,
 *         Oleg Bartunov <o.bartunov@postgrespro.ru>
 *
 * IDENTIFICATION
 *		contrib/anyarray/anyarray_gud.c
 *
 *-------------------------------------------------------------------------
 */

#include "anyarray.h"

#include <utils/guc.h>

SimilarityType	SmlType = AA_Cosine;
double			SmlLimit = 0.6;

static bool AnyArrayInited = false;

static const struct config_enum_entry SmlTypeOptions[] = {
	{"cosine", AA_Cosine, false},
	{"jaccard", AA_Jaccard, false},
	{"overlap", AA_Overlap, false},
	{NULL, 0, false}
};

static void
initAnyArray()
{
	if (AnyArrayInited)
		return;

	DefineCustomRealVariable(
		"anyarray.similarity_threshold",
		"Lower threshold of array's similarity",
		"Array's with similarity lower than threshold are not similar by % operation",
		&SmlLimit,
		SmlLimit,
		0.0,
		1e10,
		PGC_USERSET,
		0,
		NULL,
		NULL,
		NULL
	);
	DefineCustomEnumVariable(
		"anyarray.similarity_type",
		"Type of similarity formula",
		"Type of similarity formula: cosine(default), jaccard, overlap",
		(int*)&SmlType,
		SmlType,
		SmlTypeOptions,
		PGC_SUSET,
		0,
		NULL,
		NULL,
		NULL
	);
}

void _PG_init(void);
void
_PG_init(void)
{
	initAnyArray();
}

void _PG_fini(void);
void
_PG_fini(void)
{
	return;
}


