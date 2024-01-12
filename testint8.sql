SELECT
    t,
	ARRAY(
		SELECT
			v::int8
		FROM
			generate_series(GREATEST(0, t - 10),  t) as v
	) AS v
	INTO test_int8
FROM
	generate_series(1, 200) as t;

CREATE INDEX idx_test_int8 ON test_int8 USING rum (v _int8_aa_ops);
# _int8_aa_ops aa_rum_int8_ops
SET enable_seqscan=off;