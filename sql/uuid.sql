SELECT
    t,
	ARRAY(
		SELECT
			('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a' || RIGHT('00' || to_hex(v % 256),2))::uuid
		FROM
			generate_series(max(0, t - 10),  t) as v
	) AS v
	INTO test_uuid
FROM
	generate_series(1, 200) as t;


SET anyarray.similarity_type=cosine;
SELECT  t, similarity(v, to_uuid_array('{10,9,8,7,6,5,4,3,2,1}')::uuid[]) AS s FROM test_uuid 
	WHERE v % to_uuid_array('{10,9,8,7,6,5,4,3,2,1}')::uuid[] ORDER BY s DESC, t;
SELECT  t, similarity(v, to_uuid_array('{50,49,8,7,6,5,4,3,2,1}')::uuid[]) AS s FROM test_uuid 
	WHERE v % to_uuid_array('{50,49,8,7,6,5,4,3,2,1}')::uuid[] ORDER BY s DESC, t;

SET anyarray.similarity_type=jaccard;
SELECT  t, similarity(v, to_uuid_array('{10,9,8,7,6,5,4,3,2,1}')::uuid[]) AS s FROM test_uuid 
	WHERE v % to_uuid_array('{10,9,8,7,6,5,4,3,2,1}')::uuid[] ORDER BY s DESC, t;
SELECT  t, similarity(v, to_uuid_array('{50,49,8,7,6,5,4,3,2,1}')::uuid[]) AS s FROM test_uuid 
	WHERE v % to_uuid_array('{50,49,8,7,6,5,4,3,2,1}')::uuid[] ORDER BY s DESC, t;

SELECT t, v FROM test_uuid WHERE v && to_uuid_array('{43,50}')::uuid[] ORDER BY t;
SELECT t, v FROM test_uuid WHERE v @> to_uuid_array('{43,50}')::uuid[] ORDER BY t;
SELECT t, v FROM test_uuid WHERE v <@ to_uuid_array('{0,1,2,3,4,5,6,7,8,9,10}')::uuid[] ORDER BY t;
SELECT t, v FROM test_uuid WHERE v =  to_uuid_array('{0,1,2,3,4,5,6,7,8,9,10}')::uuid[] ORDER BY t;
SET anyarray.similarity_type=cosine;
SELECT t, v FROM test_uuid WHERE v %  to_uuid_array('{0,1,2,3,4,5,6,7,8,9,10}')::uuid[] ORDER BY t;
SET anyarray.similarity_type=jaccard;
SELECT t, v FROM test_uuid WHERE v %  to_uuid_array('{0,1,2,3,4,5,6,7,8,9,10}')::uuid[] ORDER BY t;
SET anyarray.similarity_type=overlap;
SET anyarray.similarity_threshold = 3;
SELECT t, v FROM test_uuid WHERE v %  to_uuid_array('{0,1,2,3,4,5,6,7,8,9,10}')::uuid[] ORDER BY t;
RESET anyarray.similarity_threshold;

CREATE INDEX idx_test_uuid ON test_uuid USING gist (v _uuid_aa_ops);

SET enable_seqscan=off;

EXPLAIN (COSTS OFF) SELECT t, v FROM test_uuid WHERE v && to_uuid_array('{43,50}')::uuid[] ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_uuid WHERE v @> to_uuid_array('{43,50}')::uuid[] ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_uuid WHERE v <@ to_uuid_array('{0,1,2,3,4,5,6,7,8,9,10}')::uuid[] ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_uuid WHERE v =  to_uuid_array('{0,1,2,3,4,5,6,7,8,9,10}')::uuid[] ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_uuid WHERE v %  to_uuid_array('{0,1,2,3,4,5,6,7,8,9,10}')::uuid[] ORDER BY t;

SELECT t, v FROM test_uuid WHERE v && to_uuid_array('{43,50}')::uuid[] ORDER BY t;
SELECT t, v FROM test_uuid WHERE v @> to_uuid_array('{43,50}')::uuid[] ORDER BY t;
SELECT t, v FROM test_uuid WHERE v <@ to_uuid_array('{0,1,2,3,4,5,6,7,8,9,10}')::uuid[] ORDER BY t;
SELECT t, v FROM test_uuid WHERE v =  to_uuid_array('{0,1,2,3,4,5,6,7,8,9,10}')::uuid[] ORDER BY t;
SET anyarray.similarity_type=cosine;
SELECT t, v FROM test_uuid WHERE v %  to_uuid_array('{0,1,2,3,4,5,6,7,8,9,10}')::uuid[] ORDER BY t;
SET anyarray.similarity_type=jaccard;
SELECT t, v FROM test_uuid WHERE v %  to_uuid_array('{0,1,2,3,4,5,6,7,8,9,10}')::uuid[] ORDER BY t;
SET anyarray.similarity_type=overlap;
SET anyarray.similarity_threshold = 3;
SELECT t, v FROM test_uuid WHERE v %  to_uuid_array('{0,1,2,3,4,5,6,7,8,9,10}')::uuid[] ORDER BY t;
RESET anyarray.similarity_threshold;

DROP INDEX idx_test_uuid;
CREATE INDEX idx_test_uuid ON test_uuid USING gin (v _uuid_aa_ops);

SET enable_seqscan=off;

EXPLAIN (COSTS OFF) SELECT t, v FROM test_uuid WHERE v && to_uuid_array('{43,50}')::uuid[] ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_uuid WHERE v @> to_uuid_array('{43,50}')::uuid[] ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_uuid WHERE v <@ to_uuid_array('{0,1,2,3,4,5,6,7,8,9,10}')::uuid[] ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_uuid WHERE v =  to_uuid_array('{0,1,2,3,4,5,6,7,8,9,10}')::uuid[] ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_uuid WHERE v %  to_uuid_array('{0,1,2,3,4,5,6,7,8,9,10}')::uuid[] ORDER BY t;

SELECT t, v FROM test_uuid WHERE v && to_uuid_array('{43,50}')::uuid[] ORDER BY t;
SELECT t, v FROM test_uuid WHERE v @> to_uuid_array('{43,50}')::uuid[] ORDER BY t;
SELECT t, v FROM test_uuid WHERE v <@ to_uuid_array('{0,1,2,3,4,5,6,7,8,9,10}')::uuid[] ORDER BY t;
SELECT t, v FROM test_uuid WHERE v =  to_uuid_array('{0,1,2,3,4,5,6,7,8,9,10}')::uuid[] ORDER BY t;
SET anyarray.similarity_type=cosine;
SELECT t, v FROM test_uuid WHERE v %  to_uuid_array('{0,1,2,3,4,5,6,7,8,9,10}')::uuid[] ORDER BY t;
SET anyarray.similarity_type=jaccard;
SELECT t, v FROM test_uuid WHERE v %  to_uuid_array('{0,1,2,3,4,5,6,7,8,9,10}')::uuid[] ORDER BY t;
SET anyarray.similarity_type=overlap;
SET anyarray.similarity_threshold = 3;
SELECT t, v FROM test_uuid WHERE v %  to_uuid_array('{0,1,2,3,4,5,6,7,8,9,10}')::uuid[] ORDER BY t;
RESET anyarray.similarity_threshold;

DROP INDEX idx_test_uuid;
CREATE INDEX idx_test_uuid ON test_uuid USING rum (v _uuid_aa_ops);

SET enable_seqscan=off;

EXPLAIN (COSTS OFF) SELECT t, v FROM test_uuid WHERE v && to_uuid_array('{43,50}')::uuid[] ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_uuid WHERE v @> to_uuid_array('{43,50}')::uuid[] ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_uuid WHERE v <@ to_uuid_array('{0,1,2,3,4,5,6,7,8,9,10}')::uuid[] ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_uuid WHERE v =  to_uuid_array('{0,1,2,3,4,5,6,7,8,9,10}')::uuid[] ORDER BY t;
EXPLAIN (COSTS OFF) SELECT t, v FROM test_uuid WHERE v %  to_uuid_array('{0,1,2,3,4,5,6,7,8,9,10}')::uuid[] ORDER BY t;

SELECT t, v FROM test_uuid WHERE v && to_uuid_array('{43,50}')::uuid[] ORDER BY t;
SELECT t, v FROM test_uuid WHERE v @> to_uuid_array('{43,50}')::uuid[] ORDER BY t;
SELECT t, v FROM test_uuid WHERE v <@ to_uuid_array('{0,1,2,3,4,5,6,7,8,9,10}')::uuid[] ORDER BY t;
SELECT t, v FROM test_uuid WHERE v =  to_uuid_array('{0,1,2,3,4,5,6,7,8,9,10}')::uuid[] ORDER BY t;
SET anyarray.similarity_type=cosine;
SELECT t, v FROM test_uuid WHERE v %  to_uuid_array('{0,1,2,3,4,5,6,7,8,9,10}')::uuid[] ORDER BY t;
SET anyarray.similarity_type=jaccard;
SELECT t, v FROM test_uuid WHERE v %  to_uuid_array('{0,1,2,3,4,5,6,7,8,9,10}')::uuid[] ORDER BY t;
SET anyarray.similarity_type=overlap;
SET anyarray.similarity_threshold = 3;
SELECT t, v FROM test_uuid WHERE v %  to_uuid_array('{0,1,2,3,4,5,6,7,8,9,10}')::uuid[] ORDER BY t;
RESET anyarray.similarity_threshold;

