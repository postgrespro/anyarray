AnyArray – 1-D anyarray functionality for PostgreSQL
==============================================

Introduction
------------

AnyArray is a PostgreSQL extension which implements 1-D anyarray
functionality.


Authors
-------

 * Teodor Sigaev <teodor@sigaev.ru> , Postgres Professional, Moscow, Russia
 * Oleg Bartunov <o.bartunov@postgrespro.ru> , Postgres Professional, Moscow, Russia

Availability
------------

AnyArray is released as an extension and not available in default PostgreSQL
installation. It is available from
[github](https://github.com/postgrespro/anyarray)
under the same license as
[PostgreSQL](http://www.postgresql.org/about/licence/)
and supports PostgreSQL 9.1+.

Installation
------------

Before build and install AnyArray you should ensure following:
    
 * PostgreSQL version is 9.1 or higher.
 * You have development package of PostgreSQL installed or you built
   PostgreSQL from source.
 * Your PATH variable is configured so that pg\_config command available.
    
Typical installation procedure may look like this:
    
    $ git clone https://github.com/postgrespro/anyarray.git
    $ cd anyarray
    $ make USE_PGXS=1
    $ sudo make USE_PGXS=1 install
    $ make USE_PGXS=1 installcheck
    $ psql DB -c "CREATE EXTENSION anyarray;"

Usage
-----

### Anyarray functions

|Function|Description|Examples|
|--------|-----------|--------|
|`anyset(int)` → `int[1]`||`anyset(1234)`  → `ARRAY[1234]`|
|`icount(anyarray)`→`int`|Returns the length of anyarray. icount() returns 0 for empty arrays.|`icount( '{1234234, 0234234}'::int[] )` → `2`|
|`sort(anyarray [, 'asc'\|'desc'])`→ `anyarray`|Returns the anyarray sorted in an ascending (default) or descending order. |`sort( '{1234234, -30, 0234234}'::int[],'desc')` → `{1234234, 234234, -30}`|
|`sort_asc(anyarray)`→ `anyarray`|Returns the anyarray sorted in an ascending order.  |`sort_asc( '{1234234,-30, 0234234}'::int[])` → `{-30,234234,1234234}`|
|`sort_desc(anyarray)`→ `anyarray`|Returns the anyarray sorted in a descending order.  |`sort( '{1234234, -30, 0234234}'::int[],'desc' )` → `{1234234,234234,-30}`|
|`uniq(anyarray)`→ `anyarray`|Returns anyarray where consequent repeating elements replaced by one element. If you need to remove all repeating elements in array, you can sort array and apply uniq() function. |`uniq( '{1234234, -30, -30, 0234234, -30}'::int[])` → `{1234234, -30, 234234, -30}` , `uniq( sort_asc( '{1234234, -30, -30, 0234234, -30}'::int[] ) )` → `{-30,234234,1234234}`|
|`uniq_d(anyarray)`→ `anyarray`|Returns only consequent repeating elements. If you need to return all repeating elements, you can sort array and apply uniq_d() function  |`uniq_d( '{1234234, -30, -30, 0234234, -30, 0234234}'::int[] )` → `{-30}`, `uniq_d( sort_asc('{1234234, -30,-30, 0234234, -30, 0234234}'::int[] ) )` → `{-30,234234}` |
|`idx(anyarray, searchelement)`→ `int`|Returns the position of the searchelement first occurance in the array |`idx( '{1234234,-30,-30,0234234,-30}'::int[], -30 )` → `2`|
|`subarray(anyarray, start int, length int)`→ `anyarray`|Returns the subarray from original array. If the start position value is negative, it is counted from the end of the original array (-1 means last element, -2 means element before last etc.)|`subarray( '{1234234, -30, -30, 0234234, -30}'::int[],2,3 )` → `{-30, -30, 234234}` , `subarray( '{1234234, -30, -30, 0234234, -30}'::int[], -1, 1 )` → `{-30}`, `subarray( '{1234234, -30, -30, 0234234, -30}'::int[], 0, -1 )` → `{1234234, -30, -30, 234234}`|


### Anyarray operators

|Operator|Description|Examples|
|--------|-----------|--------|
|`#anyarray` → `int`|Returns the length of anyarray. |`#'{1234234,0234234}'::int[]` → `2`|
|`anyarray + anyarray`→ `anyarray`|Returns the union of arrays |`'{123,623,445}'::int[] + 1245` → `{123,623,445,1245}` , `'{123,623,445}'::int[] + '{1245,87,445}'` → `{123,623,445,1245,87,445}` |
|`anyarray - anyarray`→ `anyarray`|Returns the substraction of left array and right array |`'{123,623,445}'::int[] - 623` → `{123,445}`, `'{123,623,445}'::int[] - '{1623,623}'::int[]` `{123,445}`|
|`anyarray \| anyarray`→ `anyarray`|Returns the union of array, repeating elements are excluded from resulting array.|`'{123,623,445}'::int[]` \| `{1623,623}'::int[]` → `{123,445,623,1623}`|
|`anyarray & anyarray`→ `anyarray`|Returns arrays intersection.|`'{1,3,1}'::int[] & '{1,2}'` → `{1}`|


### Anyarray operator class strategies


|Operator|GIST and GIN Strategy num|RUM Strategy num|Description|
|--------|-------------------------|----------------|-----------|
|`anyarray` && `anyarray`|RTOverlapStrategyNumber 3|RUM_OVERLAP_STRATEGY 1|Overlapped|
|`anyarray` = `anyarray`|RTSameStrategyNumber 6|RUM_EQUAL_STRATEGY 4|Same|
|`anyarray` @> `anyarray`|RTContainsStrategyNumber 7|RUM_CONTAINS_STRATEGY 2|Contains|
|`anyarray` <@ `anyarray`|RTContainedByStrategyNumber 8|RUM_CONTAINED_STRATEGY 3|Contained|
|`anyarray` % `anyarray`|AnyAarraySimilarityStrategy 16 |RUM_SIMILAR_STRATEGY 5|Similarity|


### Similarity search options

Set distance type for similarity search.
```
SET anyarray.similarity_type=cosine;
SET anyarray.similarity_type=jaccard;
SET anyarray.similarity_type=overlap;
```

Set threshold for similarity search.
```
SET anyarray.similarity_threshold = 3;
RESET anyarray.similarity_threshold;
```

Examples
-------

Examples for INTEGER[] .

### Create a table with sample data.
```
SELECT t, ARRAY(
		SELECT v::int4
		FROM generate_series(max(0, t - 10),  t) as v
	) AS v
	INTO test_int4
FROM generate_series(1, 200) as t;
```

### Similarity calculation.

```
SET anyarray.similarity_type=cosine;
SELECT  t, similarity(v, '{10,9,8,7,6,5,4,3,2,1}') AS s FROM test_int4 
	WHERE v % '{10,9,8,7,6,5,4,3,2,1}' ORDER BY s DESC, t;
SELECT  t, similarity(v, '{50,49,8,7,6,5,4,3,2,1}') AS s FROM test_int4 
	WHERE v % '{50,49,8,7,6,5,4,3,2,1}' ORDER BY s DESC, t;

SET anyarray.similarity_type=jaccard;
SELECT  t, similarity(v, '{10,9,8,7,6,5,4,3,2,1}') AS s FROM test_int4 
	WHERE v % '{10,9,8,7,6,5,4,3,2,1}' ORDER BY s DESC, t;
SELECT  t, similarity(v, '{50,49,8,7,6,5,4,3,2,1}') AS s FROM test_int4 
	WHERE v % '{50,49,8,7,6,5,4,3,2,1}' ORDER BY s DESC, t;

SELECT t, v FROM test_int4 WHERE v && '{43,50}' ORDER BY t;
SELECT t, v FROM test_int4 WHERE v @> '{43,50}' ORDER BY t;
SELECT t, v FROM test_int4 WHERE v <@ '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
SELECT t, v FROM test_int4 WHERE v =  '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
SET anyarray.similarity_type=cosine;
SELECT t, v FROM test_int4 WHERE v %  '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
SET anyarray.similarity_type=jaccard;
SELECT t, v FROM test_int4 WHERE v %  '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
SET anyarray.similarity_type=overlap;
SET anyarray.similarity_threshold = 3;
SELECT t, v FROM test_int4 WHERE v %  '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
RESET anyarray.similarity_threshold;
```

### Create GIST index.

```
CREATE INDEX idx_test_int4 ON test_int4 USING gist (v _int4_aa_ops);

SET enable_seqscan=off;

EXPLAIN (COSTS OFF) SELECT t, v FROM test_int4 WHERE v && '{43,50}' ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_int4 WHERE v @> '{43,50}' ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_int4 WHERE v <@ '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_int4 WHERE v =  '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_int4 WHERE v %  '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;

SELECT t, v FROM test_int4 WHERE v && '{43,50}' ORDER BY t;
SELECT t, v FROM test_int4 WHERE v @> '{43,50}' ORDER BY t;
SELECT t, v FROM test_int4 WHERE v <@ '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
SELECT t, v FROM test_int4 WHERE v =  '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
SET anyarray.similarity_type=cosine;
SELECT t, v FROM test_int4 WHERE v %  '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
SET anyarray.similarity_type=jaccard;
SELECT t, v FROM test_int4 WHERE v %  '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
SET anyarray.similarity_type=overlap;
SET anyarray.similarity_threshold = 3;
SELECT t, v FROM test_int4 WHERE v %  '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
RESET anyarray.similarity_threshold;

DROP INDEX idx_test_int4;
```

### Create GIN index.

```
CREATE INDEX idx_test_int4 ON test_int4 USING gin (v _int4_aa_ops);

SET enable_seqscan=off;

EXPLAIN (COSTS OFF) SELECT t, v FROM test_int4 WHERE v && '{43,50}' ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_int4 WHERE v @> '{43,50}' ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_int4 WHERE v <@ '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_int4 WHERE v =  '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_int4 WHERE v %  '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;

SELECT t, v FROM test_int4 WHERE v && '{43,50}' ORDER BY t;
SELECT t, v FROM test_int4 WHERE v @> '{43,50}' ORDER BY t;
SELECT t, v FROM test_int4 WHERE v <@ '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
SELECT t, v FROM test_int4 WHERE v =  '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
SET anyarray.similarity_type=cosine;
SELECT t, v FROM test_int4 WHERE v %  '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
SET anyarray.similarity_type=jaccard;
SELECT t, v FROM test_int4 WHERE v %  '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
SET anyarray.similarity_type=overlap;
SET anyarray.similarity_threshold = 3;
SELECT t, v FROM test_int4 WHERE v %  '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
RESET anyarray.similarity_threshold;
```

### Create RUM index.

```
CREATE INDEX idx_test_int4 ON test_int4 USING rum (v _int4_aa_ops);

SET enable_seqscan=off;

EXPLAIN (COSTS OFF) SELECT t, v FROM test_int4 WHERE v && '{43,50}' ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_int4 WHERE v @> '{43,50}' ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_int4 WHERE v <@ '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_int4 WHERE v =  '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_int4 WHERE v %  '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;

SELECT t, v FROM test_int4 WHERE v && '{43,50}' ORDER BY t;
SELECT t, v FROM test_int4 WHERE v @> '{43,50}' ORDER BY t;
SELECT t, v FROM test_int4 WHERE v <@ '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
SELECT t, v FROM test_int4 WHERE v =  '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
SET anyarray.similarity_type=cosine;
SELECT t, v FROM test_int4 WHERE v %  '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
SET anyarray.similarity_type=jaccard;
SELECT t, v FROM test_int4 WHERE v %  '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
SET anyarray.similarity_type=overlap;
SET anyarray.similarity_threshold = 3;
SELECT t, v FROM test_int4 WHERE v %  '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
RESET anyarray.similarity_threshold;
```

Operator class names for all types implemented in anyarray.
-----------------------------------------------------------

|Anyarray type|GIST|GIN|RUM|
|----|----|---|---|
|bit|_bit_aa_ops|_bit_aa_ops|_bit_aa_ops|
|bytea|_bytea_aa_ops|_bytea_aa_ops|_bytea_aa_ops|
|char|_char_aa_ops|_char_aa_ops|_char_aa_ops|
|cidr|_cidr_aa_ops|_cidr_aa_ops|_cidr_aa_ops|
|date|_date_aa_ops|_date_aa_ops|_date_aa_ops|
|float4|_float4_aa_ops|_float4_aa_ops|_float4_aa_ops|
|float8|_float8_aa_ops|_float8_aa_ops|_float8_aa_ops|
|inet|_inet_aa_ops|_inet_aa_ops|_inet_aa_ops|
|int2|_int2_aa_ops|_int2_aa_ops|_int2_aa_ops|
|int4|_int4_aa_ops|_int4_aa_ops|_int4_aa_ops|
|int8|_int8_aa_ops|_int8_aa_ops|_int8_aa_ops|
|interval|_interval_aa_ops|_interval_aa_ops|_interval_aa_ops|
|macaddr|_macaddr_aa_ops|_macaddr_aa_ops|_macaddr_aa_ops|
|money| - |_money_aa_ops|_money_aa_ops|
|numeric|_numeric_aa_ops|_numeric_aa_ops|_numeric_aa_ops|
|oid|_oid_aa_ops|_oid_aa_ops|_oid_aa_ops|
|text|_text_aa_ops|_text_aa_ops|_text_aa_ops|
|time|_time_aa_ops|_time_aa_ops|_time_aa_ops|
|timestamp|_timestamp_aa_ops|_timestamp_aa_ops|_timestamp_aa_ops|
|timestamptz|_timestamptz_aa_ops|_timestamptz_aa_ops|_timestamptz_aa_ops|
|timetz|_timetz_aa_ops|_timetz_aa_ops|_timetz_aa_ops|
|uuid|_uuid_aa_ops|_uuid_aa_ops|_uuid_aa_ops|
|varbit|_varbit_aa_ops|_varbit_aa_ops|_varbit_aa_ops|
|varchar|_varchar_aa_ops|_varchar_aa_ops|_varchar_aa_ops|

## Upgrading

Install the latest version and run in every database you want to upgrade:

```
ALTER EXTENSION anyarray UPDATE;
```
You need to close this database server connection to apply changes.

You can check the version in the current database with psql command:

```
\dx
```

## Version Notes

### 2.0

The support of RUM index is added. RUM extension 1.4 of upper is required.
Anyarray supports GIST, GIN, RUM indexes for uuid type.
Anyarray supports GIN, RUM indexes for money type.

### 1.1

Query time of anyarray using GIN indexes decreased.
