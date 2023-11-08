SELECT
    t,
	ARRAY(
		SELECT
			v::text::bytea
		FROM
			generate_series(max(0, t - 10),  t) as v
	) AS v
	INTO test_bytea
FROM
	generate_series(1, 200) as t;

SET bytea_output = escape;

SET anyarray.similarity_type=cosine;
SELECT  t, similarity(v, '{10,9,8,7,6,5,4,3,2,1}') AS s FROM test_bytea 
	WHERE v % '{10,9,8,7,6,5,4,3,2,1}' ORDER BY s DESC, t;
SELECT  t, similarity(v, '{50,49,8,7,6,5,4,3,2,1}') AS s FROM test_bytea 
	WHERE v % '{50,49,8,7,6,5,4,3,2,1}' ORDER BY s DESC, t;

SET anyarray.similarity_type=jaccard;
SELECT  t, similarity(v, '{10,9,8,7,6,5,4,3,2,1}') AS s FROM test_bytea 
	WHERE v % '{10,9,8,7,6,5,4,3,2,1}' ORDER BY s DESC, t;
SELECT  t, similarity(v, '{50,49,8,7,6,5,4,3,2,1}') AS s FROM test_bytea 
	WHERE v % '{50,49,8,7,6,5,4,3,2,1}' ORDER BY s DESC, t;

SELECT t, v FROM test_bytea WHERE v && '{43,50}' ORDER BY t;
SELECT t, v FROM test_bytea WHERE v @> '{43,50}' ORDER BY t;
SELECT t, v FROM test_bytea WHERE v <@ '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
SELECT t, v FROM test_bytea WHERE v =  '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
SET anyarray.similarity_type=cosine;
SELECT t, v FROM test_bytea WHERE v %  '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
SET anyarray.similarity_type=jaccard;
SELECT t, v FROM test_bytea WHERE v %  '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
SET anyarray.similarity_type=overlap;
SET anyarray.similarity_threshold = 3;
SELECT t, v FROM test_bytea WHERE v %  '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
RESET anyarray.similarity_threshold;

CREATE INDEX idx_test_bytea ON test_bytea USING gist (v _bytea_aa_ops);

SET enable_seqscan=off;

EXPLAIN (COSTS OFF) SELECT t, v FROM test_bytea WHERE v && '{43,50}' ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_bytea WHERE v @> '{43,50}' ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_bytea WHERE v <@ '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_bytea WHERE v =  '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_bytea WHERE v %  '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;

SELECT t, v FROM test_bytea WHERE v && '{43,50}' ORDER BY t;
SELECT t, v FROM test_bytea WHERE v @> '{43,50}' ORDER BY t;
SELECT t, v FROM test_bytea WHERE v <@ '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
SELECT t, v FROM test_bytea WHERE v =  '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
SET anyarray.similarity_type=cosine;
SELECT t, v FROM test_bytea WHERE v %  '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
SET anyarray.similarity_type=jaccard;
SELECT t, v FROM test_bytea WHERE v %  '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
SET anyarray.similarity_type=overlap;
SET anyarray.similarity_threshold = 3;
SELECT t, v FROM test_bytea WHERE v %  '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
RESET anyarray.similarity_threshold;

DROP INDEX idx_test_bytea;
CREATE INDEX idx_test_bytea ON test_bytea USING gin (v _bytea_aa_ops);

SET enable_seqscan=off;

EXPLAIN (COSTS OFF) SELECT t, v FROM test_bytea WHERE v && '{43,50}' ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_bytea WHERE v @> '{43,50}' ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_bytea WHERE v <@ '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_bytea WHERE v =  '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_bytea WHERE v %  '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;

SELECT t, v FROM test_bytea WHERE v && '{43,50}' ORDER BY t;
SELECT t, v FROM test_bytea WHERE v @> '{43,50}' ORDER BY t;
SELECT t, v FROM test_bytea WHERE v <@ '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
SELECT t, v FROM test_bytea WHERE v =  '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
SET anyarray.similarity_type=cosine;
SELECT t, v FROM test_bytea WHERE v %  '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
SET anyarray.similarity_type=jaccard;
SELECT t, v FROM test_bytea WHERE v %  '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
SET anyarray.similarity_type=overlap;
SET anyarray.similarity_threshold = 3;
SELECT t, v FROM test_bytea WHERE v %  '{0,1,2,3,4,5,6,7,8,9,10}' ORDER BY t;
RESET anyarray.similarity_threshold;

RESET bytea_output;
