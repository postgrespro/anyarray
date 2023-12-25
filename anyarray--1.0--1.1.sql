/*
 * anyarray version 1.1
 */

CREATE OR REPLACE FUNCTION ginanyarray_triconsistent(internal, internal, anyarray,internal,internal,internal,internal,internal)
	RETURNS internal
	AS 'MODULE_PATHNAME'
	LANGUAGE C IMMUTABLE;

ALTER OPERATOR FAMILY _bit_aa_ops USING gin ADD
        FUNCTION    6   (bit[],bit[]) ginanyarray_triconsistent(internal, internal, anyarray,internal,internal,internal,internal,internal);

ALTER OPERATOR FAMILY _bytea_aa_ops USING gin ADD
        FUNCTION    6   (bytea[],bytea[]) ginanyarray_triconsistent(internal, internal, anyarray,internal,internal,internal,internal,internal);

ALTER OPERATOR FAMILY _char_aa_ops USING gin ADD
        FUNCTION    6   (char[],char[]) ginanyarray_triconsistent(internal, internal, anyarray,internal,internal,internal,internal,internal);

ALTER OPERATOR FAMILY _cidr_aa_ops USING gin ADD
        FUNCTION    6   (cidr[],cidr[]) ginanyarray_triconsistent(internal, internal, anyarray,internal,internal,internal,internal,internal);

ALTER OPERATOR FAMILY _date_aa_ops USING gin ADD
        FUNCTION    6   (date[],date[]) ginanyarray_triconsistent(internal, internal, anyarray,internal,internal,internal,internal,internal);

ALTER OPERATOR FAMILY _float4_aa_ops USING gin ADD
        FUNCTION    6   (float4[],float4[]) ginanyarray_triconsistent(internal, internal, anyarray,internal,internal,internal,internal,internal);

ALTER OPERATOR FAMILY _float8_aa_ops USING gin ADD
        FUNCTION    6   (float8[],float8[]) ginanyarray_triconsistent(internal, internal, anyarray,internal,internal,internal,internal,internal);

ALTER OPERATOR FAMILY _inet_aa_ops USING gin ADD
        FUNCTION    6   (inet[],inet[]) ginanyarray_triconsistent(internal, internal, anyarray,internal,internal,internal,internal,internal);

ALTER OPERATOR FAMILY _int2_aa_ops USING gin ADD
        FUNCTION    6   (int2[],int2[]) ginanyarray_triconsistent(internal, internal, anyarray,internal,internal,internal,internal,internal);

ALTER OPERATOR FAMILY _int4_aa_ops USING gin ADD
        FUNCTION    6   (int4[],int4[]) ginanyarray_triconsistent(internal, internal, anyarray,internal,internal,internal,internal,internal);

ALTER OPERATOR FAMILY _int8_aa_ops USING gin ADD
        FUNCTION    6   (int8[],int8[]) ginanyarray_triconsistent(internal, internal, anyarray,internal,internal,internal,internal,internal);

ALTER OPERATOR FAMILY _interval_aa_ops USING gin ADD
        FUNCTION    6   (interval[],interval[]) ginanyarray_triconsistent(internal, internal, anyarray,internal,internal,internal,internal,internal);

ALTER OPERATOR FAMILY _macaddr_aa_ops USING gin ADD
        FUNCTION    6   (macaddr[],macaddr[]) ginanyarray_triconsistent(internal, internal, anyarray,internal,internal,internal,internal,internal);

ALTER OPERATOR FAMILY _money_aa_ops USING gin ADD
        FUNCTION    6   (money[],money[]) ginanyarray_triconsistent(internal, internal, anyarray,internal,internal,internal,internal,internal);

ALTER OPERATOR FAMILY _numeric_aa_ops USING gin ADD
        FUNCTION    6   (numeric[],numeric[]) ginanyarray_triconsistent(internal, internal, anyarray,internal,internal,internal,internal,internal);

ALTER OPERATOR FAMILY _oid_aa_ops USING gin ADD
        FUNCTION    6   (oid[],oid[]) ginanyarray_triconsistent(internal, internal, anyarray,internal,internal,internal,internal,internal);

ALTER OPERATOR FAMILY _text_aa_ops USING gin ADD
        FUNCTION    6   (text[],text[]) ginanyarray_triconsistent(internal, internal, anyarray,internal,internal,internal,internal,internal);

ALTER OPERATOR FAMILY _time_aa_ops USING gin ADD
        FUNCTION    6   (time[],time[]) ginanyarray_triconsistent(internal, internal, anyarray,internal,internal,internal,internal,internal);

ALTER OPERATOR FAMILY _timestamp_aa_ops USING gin ADD
        FUNCTION    6   (timestamp[],timestamp[]) ginanyarray_triconsistent(internal, internal, anyarray,internal,internal,internal,internal,internal);

ALTER OPERATOR FAMILY _timestamptz_aa_ops USING gin ADD
        FUNCTION    6   (timestamptz[],timestamptz[]) ginanyarray_triconsistent(internal, internal, anyarray,internal,internal,internal,internal,internal);

ALTER OPERATOR FAMILY _timetz_aa_ops USING gin ADD
        FUNCTION    6   (timetz[],timetz[]) ginanyarray_triconsistent(internal, internal, anyarray,internal,internal,internal,internal,internal);

ALTER OPERATOR FAMILY _varbit_aa_ops USING gin ADD
        FUNCTION    6   (varbit[],varbit[]) ginanyarray_triconsistent(internal, internal, anyarray,internal,internal,internal,internal,internal);

ALTER OPERATOR FAMILY _varchar_aa_ops USING gin ADD
        FUNCTION    6   (varchar[],varchar[]) ginanyarray_triconsistent(internal, internal, anyarray,internal,internal,internal,internal,internal);
