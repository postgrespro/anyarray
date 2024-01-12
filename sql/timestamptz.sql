SELECT
    t,
	ARRAY(
		SELECT
			epoch2timestamp(v)::timestamptz
		FROM
			generate_series(max(0, t - 10),  t) as v
	) AS v
	INTO test_timestamptz
FROM
	generate_series(1, 200) as t;


SET anyarray.similarity_type=cosine;
SELECT  t, similarity(v, to_tsp_array('{10,9,8,7,6,5,4,3,2,1}')::timestamptz[]) AS s FROM test_timestamptz 
	WHERE v % to_tsp_array('{10,9,8,7,6,5,4,3,2,1}')::timestamptz[] ORDER BY s DESC, t;
SELECT  t, similarity(v, to_tsp_array('{50,49,8,7,6,5,4,3,2,1}')::timestamptz[]) AS s FROM test_timestamptz 
	WHERE v % to_tsp_array('{50,49,8,7,6,5,4,3,2,1}')::timestamptz[] ORDER BY s DESC, t;

SET anyarray.similarity_type=jaccard;
SELECT  t, similarity(v, to_tsp_array('{10,9,8,7,6,5,4,3,2,1}')::timestamptz[]) AS s FROM test_timestamptz 
	WHERE v % to_tsp_array('{10,9,8,7,6,5,4,3,2,1}')::timestamptz[] ORDER BY s DESC, t;
SELECT  t, similarity(v, to_tsp_array('{50,49,8,7,6,5,4,3,2,1}')::timestamptz[]) AS s FROM test_timestamptz 
	WHERE v % to_tsp_array('{50,49,8,7,6,5,4,3,2,1}')::timestamptz[] ORDER BY s DESC, t;

SELECT t, v FROM test_timestamptz WHERE v && to_tsp_array('{43,50}')::timestamptz[] ORDER BY t;
SELECT t, v FROM test_timestamptz WHERE v @> to_tsp_array('{43,50}')::timestamptz[] ORDER BY t;
SELECT t, v FROM test_timestamptz WHERE v <@ to_tsp_array('{0,1,2,3,4,5,6,7,8,9,10}')::timestamptz[] ORDER BY t;
SELECT t, v FROM test_timestamptz WHERE v =  to_tsp_array('{0,1,2,3,4,5,6,7,8,9,10}')::timestamptz[] ORDER BY t;
SET anyarray.similarity_type=cosine;
SELECT t, v FROM test_timestamptz WHERE v %  to_tsp_array('{0,1,2,3,4,5,6,7,8,9,10}')::timestamptz[] ORDER BY t;
SET anyarray.similarity_type=jaccard;
SELECT t, v FROM test_timestamptz WHERE v %  to_tsp_array('{0,1,2,3,4,5,6,7,8,9,10}')::timestamptz[] ORDER BY t;
SET anyarray.similarity_type=overlap;
SET anyarray.similarity_threshold = 3;
SELECT t, v FROM test_timestamptz WHERE v %  to_tsp_array('{0,1,2,3,4,5,6,7,8,9,10}')::timestamptz[] ORDER BY t;
RESET anyarray.similarity_threshold;

CREATE INDEX idx_test_timestamptz ON test_timestamptz USING gist (v _timestamptz_aa_ops);

SET enable_seqscan=off;

EXPLAIN (COSTS OFF) SELECT t, v FROM test_timestamptz WHERE v && to_tsp_array('{43,50}')::timestamptz[] ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_timestamptz WHERE v @> to_tsp_array('{43,50}')::timestamptz[] ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_timestamptz WHERE v <@ to_tsp_array('{0,1,2,3,4,5,6,7,8,9,10}')::timestamptz[] ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_timestamptz WHERE v =  to_tsp_array('{0,1,2,3,4,5,6,7,8,9,10}')::timestamptz[] ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_timestamptz WHERE v %  to_tsp_array('{0,1,2,3,4,5,6,7,8,9,10}')::timestamptz[] ORDER BY t;

SELECT t, v FROM test_timestamptz WHERE v && to_tsp_array('{43,50}')::timestamptz[] ORDER BY t;
SELECT t, v FROM test_timestamptz WHERE v @> to_tsp_array('{43,50}')::timestamptz[] ORDER BY t;
SELECT t, v FROM test_timestamptz WHERE v <@ to_tsp_array('{0,1,2,3,4,5,6,7,8,9,10}')::timestamptz[] ORDER BY t;
SELECT t, v FROM test_timestamptz WHERE v =  to_tsp_array('{0,1,2,3,4,5,6,7,8,9,10}')::timestamptz[] ORDER BY t;
SET anyarray.similarity_type=cosine;
SELECT t, v FROM test_timestamptz WHERE v %  to_tsp_array('{0,1,2,3,4,5,6,7,8,9,10}')::timestamptz[] ORDER BY t;
SET anyarray.similarity_type=jaccard;
SELECT t, v FROM test_timestamptz WHERE v %  to_tsp_array('{0,1,2,3,4,5,6,7,8,9,10}')::timestamptz[] ORDER BY t;
SET anyarray.similarity_type=overlap;
SET anyarray.similarity_threshold = 3;
SELECT t, v FROM test_timestamptz WHERE v %  to_tsp_array('{0,1,2,3,4,5,6,7,8,9,10}')::timestamptz[] ORDER BY t;
RESET anyarray.similarity_threshold;

DROP INDEX idx_test_timestamptz;
CREATE INDEX idx_test_timestamptz ON test_timestamptz USING gin (v _timestamptz_aa_ops);

SET enable_seqscan=off;

EXPLAIN (COSTS OFF) SELECT t, v FROM test_timestamptz WHERE v && to_tsp_array('{43,50}')::timestamptz[] ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_timestamptz WHERE v @> to_tsp_array('{43,50}')::timestamptz[] ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_timestamptz WHERE v <@ to_tsp_array('{0,1,2,3,4,5,6,7,8,9,10}')::timestamptz[] ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_timestamptz WHERE v =  to_tsp_array('{0,1,2,3,4,5,6,7,8,9,10}')::timestamptz[] ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_timestamptz WHERE v %  to_tsp_array('{0,1,2,3,4,5,6,7,8,9,10}')::timestamptz[] ORDER BY t;

SELECT t, v FROM test_timestamptz WHERE v && to_tsp_array('{43,50}')::timestamptz[] ORDER BY t;
SELECT t, v FROM test_timestamptz WHERE v @> to_tsp_array('{43,50}')::timestamptz[] ORDER BY t;
SELECT t, v FROM test_timestamptz WHERE v <@ to_tsp_array('{0,1,2,3,4,5,6,7,8,9,10}')::timestamptz[] ORDER BY t;
SELECT t, v FROM test_timestamptz WHERE v =  to_tsp_array('{0,1,2,3,4,5,6,7,8,9,10}')::timestamptz[] ORDER BY t;
SET anyarray.similarity_type=cosine;
SELECT t, v FROM test_timestamptz WHERE v %  to_tsp_array('{0,1,2,3,4,5,6,7,8,9,10}')::timestamptz[] ORDER BY t;
SET anyarray.similarity_type=jaccard;
SELECT t, v FROM test_timestamptz WHERE v %  to_tsp_array('{0,1,2,3,4,5,6,7,8,9,10}')::timestamptz[] ORDER BY t;
SET anyarray.similarity_type=overlap;
SET anyarray.similarity_threshold = 3;
SELECT t, v FROM test_timestamptz WHERE v %  to_tsp_array('{0,1,2,3,4,5,6,7,8,9,10}')::timestamptz[] ORDER BY t;
RESET anyarray.similarity_threshold;

DROP INDEX idx_test_timestamptz;
CREATE INDEX idx_test_timestamptz ON test_timestamptz USING rum (v _timestamptz_aa_ops);

SET enable_seqscan=off;

EXPLAIN (COSTS OFF) SELECT t, v FROM test_timestamptz WHERE v && to_tsp_array('{43,50}')::timestamptz[] ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_timestamptz WHERE v @> to_tsp_array('{43,50}')::timestamptz[] ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_timestamptz WHERE v <@ to_tsp_array('{0,1,2,3,4,5,6,7,8,9,10}')::timestamptz[] ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_timestamptz WHERE v =  to_tsp_array('{0,1,2,3,4,5,6,7,8,9,10}')::timestamptz[] ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_timestamptz WHERE v %  to_tsp_array('{0,1,2,3,4,5,6,7,8,9,10}')::timestamptz[] ORDER BY t;

SELECT t, v FROM test_timestamptz WHERE v && to_tsp_array('{43,50}')::timestamptz[] ORDER BY t;
SELECT t, v FROM test_timestamptz WHERE v @> to_tsp_array('{43,50}')::timestamptz[] ORDER BY t;
SELECT t, v FROM test_timestamptz WHERE v <@ to_tsp_array('{0,1,2,3,4,5,6,7,8,9,10}')::timestamptz[] ORDER BY t;
SELECT t, v FROM test_timestamptz WHERE v =  to_tsp_array('{0,1,2,3,4,5,6,7,8,9,10}')::timestamptz[] ORDER BY t;
SET anyarray.similarity_type=cosine;
SELECT t, v FROM test_timestamptz WHERE v %  to_tsp_array('{0,1,2,3,4,5,6,7,8,9,10}')::timestamptz[] ORDER BY t;
SET anyarray.similarity_type=jaccard;
SELECT t, v FROM test_timestamptz WHERE v %  to_tsp_array('{0,1,2,3,4,5,6,7,8,9,10}')::timestamptz[] ORDER BY t;
SET anyarray.similarity_type=overlap;
SET anyarray.similarity_threshold = 3;
SELECT t, v FROM test_timestamptz WHERE v %  to_tsp_array('{0,1,2,3,4,5,6,7,8,9,10}')::timestamptz[] ORDER BY t;
RESET anyarray.similarity_threshold;

