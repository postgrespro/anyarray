set enable_seqscan=off;
set enable_sort=off;
SET anyarray.similarity_type=cosine;
SET anyarray.similarity_threshold = 0.5;
/*
 * Complete checks for int2[].
 */

CREATE TABLE test_array (
	i int2[]
);
INSERT INTO test_array VALUES ('{}'), ('{0}'), ('{1,2,3,4}'), ('{1,2,3}'), ('{1,2}'), ('{1}');

CREATE INDEX idx_array ON test_array USING rum (i aa_rum_anyarray_ops);


SELECT NULL::int[] = '{1}';
SELECT NULL::int[] && '{1}';
SELECT NULL::int[] @> '{1}';
SELECT NULL::int[] <@ '{1}';
SELECT NULL::int[] % '{1}';
SELECT NULL::int[] <=> '{1}';

INSERT INTO test_array VALUES (NULL);
SELECT * FROM test_array WHERE i = '{1}';
DELETE FROM test_array WHERE i IS NULL;

SELECT * FROM test_array WHERE i = '{NULL}';
SELECT * FROM test_array WHERE i = '{1,2,3,NULL}';
SELECT * FROM test_array WHERE i = '{{1,2},{3,4}}';

EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i = '{}';
SELECT * FROM test_array WHERE i = '{}';
SELECT * FROM test_array WHERE i = '{0}';
SELECT * FROM test_array WHERE i = '{1}';
SELECT * FROM test_array WHERE i = '{1,2}';
SELECT * FROM test_array WHERE i = '{2,1}';
SELECT * FROM test_array WHERE i = '{1,2,3,3}';
SELECT * FROM test_array WHERE i = '{0,0}';
SELECT * FROM test_array WHERE i = '{100}';

EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i && '{}';
SELECT * FROM test_array WHERE i && '{}';
SELECT * FROM test_array WHERE i && '{1}';
SELECT * FROM test_array WHERE i && '{2}';
SELECT * FROM test_array WHERE i && '{3}';
SELECT * FROM test_array WHERE i && '{4}';
SELECT * FROM test_array WHERE i && '{1,2}';
SELECT * FROM test_array WHERE i && '{1,2,3}';
SELECT * FROM test_array WHERE i && '{1,2,3,4}';
SELECT * FROM test_array WHERE i && '{4,3,2,1}';
SELECT * FROM test_array WHERE i && '{0,0}';
SELECT * FROM test_array WHERE i && '{100}';

EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i @> '{}';
SELECT * FROM test_array WHERE i @> '{}';
SELECT * FROM test_array WHERE i @> '{1}';
SELECT * FROM test_array WHERE i @> '{2}';
SELECT * FROM test_array WHERE i @> '{3}';
SELECT * FROM test_array WHERE i @> '{4}';
SELECT * FROM test_array WHERE i @> '{1,2,4}';
SELECT * FROM test_array WHERE i @> '{1,2,3,4}';
SELECT * FROM test_array WHERE i @> '{4,3,2,1}';
SELECT * FROM test_array WHERE i @> '{0,0}';
SELECT * FROM test_array WHERE i @> '{100}';

EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i <@ '{}';
SELECT * FROM test_array WHERE i <@ '{}';
SELECT * FROM test_array WHERE i <@ '{1}';
SELECT * FROM test_array WHERE i <@ '{2}';
SELECT * FROM test_array WHERE i <@ '{1,2,4}';
SELECT * FROM test_array WHERE i <@ '{1,2,3,4}';
SELECT * FROM test_array WHERE i <@ '{4,3,2,1}';
SELECT * FROM test_array WHERE i <@ '{0,0}';
SELECT * FROM test_array WHERE i <@ '{100}';

EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i % '{}';
SELECT * FROM test_array WHERE i % '{}';
SELECT * FROM test_array WHERE i % '{1}';
SELECT * FROM test_array WHERE i % '{2}';
SELECT * FROM test_array WHERE i % '{1,2}';
SELECT * FROM test_array WHERE i % '{1,2,4}';
SELECT * FROM test_array WHERE i % '{1,2,3,4}';
SELECT * FROM test_array WHERE i % '{4,3,2,1}';
SELECT * FROM test_array WHERE i % '{1,2,3,4,5}';
SELECT * FROM test_array WHERE i % '{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}';
SELECT * FROM test_array WHERE i % '{1,10,20,30,40,50}';
SELECT * FROM test_array WHERE i % '{1,10,20,30}';
SELECT * FROM test_array WHERE i % '{1,1,1,1,1}';
SELECT * FROM test_array WHERE i % '{0,0}';
SELECT * FROM test_array WHERE i % '{100}';

EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i && '{1}' ORDER BY i <=> '{1}' ASC;
SELECT * FROM test_array WHERE i && '{1}' ORDER BY i <=> '{1}' ASC;

DROP INDEX idx_array;


ALTER TABLE test_array ADD COLUMN add_info timestamp;

CREATE INDEX idx_array ON test_array
USING rum (i aa_rum_anyarray_addon_ops, add_info)
WITH (attach = 'add_info', to = 'i');

WITH q as (
     SELECT row_number() OVER (ORDER BY i) idx, ctid FROM test_array
)
UPDATE test_array SET add_info = '2016-05-16 14:21:25'::timestamp +
								 format('%s days', q.idx)::interval
FROM q WHERE test_array.ctid = q.ctid;

EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i = '{}';
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i && '{}';
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i @> '{}';
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i <@ '{}';
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i % '{}';

EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i && '{1}' ORDER BY add_info <=> '2016-05-16 14:21:25' LIMIT 10;
SELECT * FROM test_array WHERE i && '{1}' ORDER BY add_info <=> '2016-05-16 14:21:25' LIMIT 10;

DROP INDEX idx_array;


/*
 * Sanity checks for popular array types.
 */

ALTER TABLE test_array ALTER COLUMN i TYPE int4[];
CREATE INDEX idx_array ON test_array USING rum (i aa_rum_anyarray_ops);
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i = '{}';
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i && '{}';
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i @> '{}';
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i <@ '{}';
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i % '{}';
DROP INDEX idx_array;

ALTER TABLE test_array ALTER COLUMN i TYPE int8[];
CREATE INDEX idx_array ON test_array USING rum (i aa_rum_anyarray_ops);
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i = '{}';
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i && '{}';
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i @> '{}';
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i <@ '{}';
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i % '{}';
DROP INDEX idx_array;

ALTER TABLE test_array ALTER COLUMN i TYPE text[];
CREATE INDEX idx_array ON test_array USING rum (i aa_rum_anyarray_ops);
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i = '{}';
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i && '{}';
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i @> '{}';
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i <@ '{}';
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i % '{}';
DROP INDEX idx_array;

ALTER TABLE test_array ALTER COLUMN i TYPE varchar[];
CREATE INDEX idx_array ON test_array USING rum (i aa_rum_anyarray_ops);
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i = '{}';
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i && '{}';
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i @> '{}';
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i <@ '{}';
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i % '{}';
DROP INDEX idx_array;

ALTER TABLE test_array ALTER COLUMN i TYPE char[];
CREATE INDEX idx_array ON test_array USING rum (i aa_rum_anyarray_ops);
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i = '{}';
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i && '{}';
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i @> '{}';
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i <@ '{}';
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i % '{}';
DROP INDEX idx_array;

ALTER TABLE test_array ALTER COLUMN i TYPE numeric[] USING i::numeric[];
CREATE INDEX idx_array ON test_array USING rum (i aa_rum_anyarray_ops);
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i = '{}';
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i && '{}';
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i @> '{}';
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i <@ '{}';
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i % '{}';
DROP INDEX idx_array;

ALTER TABLE test_array ALTER COLUMN i TYPE float4[] USING i::float4[];
CREATE INDEX idx_array ON test_array USING rum (i aa_rum_anyarray_ops);
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i = '{}';
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i && '{}';
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i @> '{}';
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i <@ '{}';
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i % '{}';
DROP INDEX idx_array;

ALTER TABLE test_array ALTER COLUMN i TYPE float8[] USING i::float8[];
CREATE INDEX idx_array ON test_array USING rum (i aa_rum_anyarray_ops);
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i = '{}';
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i && '{}';
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i @> '{}';
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i <@ '{}';
EXPLAIN (COSTS OFF) SELECT * FROM test_array WHERE i % '{}';
DROP INDEX idx_array;

/*
 * Check ordering using distance operator
 */

CREATE TABLE test_array_order (
    i int2[]
);
\copy test_array_order(i) from 'data/rum_array.data';

CREATE INDEX idx_array_order ON test_array_order USING rum (i aa_rum_anyarray_ops);

EXPLAIN (COSTS OFF)
SELECT *, i <=> '{51}' from test_array_order WHERE i @> '{23,20}' order by i <=> '{51}';
SELECT i,
	CASE WHEN distance = 'Infinity' THEN -1
		ELSE distance::numeric(18,14)
	END distance
	FROM
		(SELECT *, (i <=> '{51}') AS distance
		FROM test_array_order WHERE i @> '{23,20}' ORDER BY i <=> '{51}') t;
