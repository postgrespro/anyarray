/* contrib/anyarray/anyarray--1.0--2.0.sql */

-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION anyarray" to load this file. \quit

/* 
 anyarray 2.0 
*/

CREATE FUNCTION ginanyarray_triconsistent(internal, internal, anyarray,internal,internal,internal,internal,internal)
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

CREATE FUNCTION rumanyarray_config(internal)
RETURNS void
AS 'MODULE_PATHNAME'
LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION rumanyarray_distance(anyarray,anyarray)
RETURNS float8
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT STABLE;

CREATE OPERATOR <=> (
	PROCEDURE = rumanyarray_distance,
	LEFTARG = anyarray,
	RIGHTARG = anyarray,
	COMMUTATOR = '<=>'
);


CREATE FUNCTION rumextract_anyarray(anyarray,internal,internal,internal,internal)
RETURNS internal
AS 'MODULE_PATHNAME'
LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION rumextract_anyarray_query(anyarray,internal,smallint,internal,internal,internal,internal)
RETURNS internal
AS 'MODULE_PATHNAME'
LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION rumanyarray_consistent(internal, smallint, anyarray, integer, internal, internal, internal, internal)
RETURNS bool
AS 'MODULE_PATHNAME'
LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION rumanyarray_preconsistent(internal, smallint, anyarray, integer, internal, internal, internal, internal)
RETURNS bool
AS 'MODULE_PATHNAME'
LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION rumanyarray_ordering(internal,smallint,anyarray,int,internal,internal,internal,internal,internal)
RETURNS float8
AS 'MODULE_PATHNAME'
LANGUAGE C IMMUTABLE STRICT;


CREATE OPERATOR CLASS aa_rum_anyarray_ops
FOR TYPE anyarray USING rum
AS
	OPERATOR	1	&&  (anyarray, anyarray),
	OPERATOR	2	@>  (anyarray, anyarray),
	OPERATOR	3	<@  (anyarray, anyarray),
	OPERATOR	4	=   (anyarray, anyarray),
	OPERATOR	5	%   (anyarray, anyarray),
	OPERATOR	20	<=> (anyarray, anyarray) FOR ORDER BY pg_catalog.float_ops,
	--dispatch function 1 for concrete type
	FUNCTION	2	rumextract_anyarray(anyarray,internal,internal,internal,internal),
	FUNCTION	3	rumextract_anyarray_query(anyarray,internal,smallint,internal,internal,internal,internal),
	FUNCTION	4	rumanyarray_consistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
	FUNCTION	6	rumanyarray_config(internal),
	FUNCTION	8	rumanyarray_ordering(internal,smallint,anyarray,int,internal,internal,internal,internal,internal),
	STORAGE anyelement;

CREATE OPERATOR CLASS aa_rum_anyarray_addon_ops
FOR TYPE anyarray USING rum
AS
	OPERATOR	1	&& (anyarray, anyarray),
	OPERATOR	2	@> (anyarray, anyarray),
	OPERATOR	3	<@ (anyarray, anyarray),
	OPERATOR	4	=  (anyarray, anyarray),
	--dispatch function 1 for concrete type
	FUNCTION	2	ginarrayextract(anyarray,internal,internal),
	FUNCTION	3	ginqueryarrayextract(anyarray,internal,smallint,internal,internal,internal,internal),
	FUNCTION	4	ginarrayconsistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
	STORAGE anyelement;

CREATE OPERATOR CLASS _bit_aa_ops
FOR TYPE _bit  USING rum
AS
        OPERATOR        1       &&  (anyarray, anyarray),
        OPERATOR        2       @>  (anyarray, anyarray),
        OPERATOR        3       <@  (anyarray, anyarray),
        OPERATOR        4       =   (anyarray, anyarray),
        OPERATOR        5       %   (anyarray, anyarray),
        OPERATOR        20      <=> (anyarray, anyarray) FOR ORDER BY pg_catalog.float_ops,
        --dispatch function 1 for concrete type
        FUNCTION   		1   bitcmp(bit,bit),
        FUNCTION        2       rumextract_anyarray(anyarray,internal,internal,internal,internal),
        FUNCTION        3       rumextract_anyarray_query(anyarray,internal,smallint,internal,internal,internal,internal),
        FUNCTION        4       rumanyarray_consistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        6       rumanyarray_config(internal),
        FUNCTION        7       rumanyarray_preconsistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        8       rumanyarray_ordering(internal,smallint,anyarray,int,internal,internal,internal,internal,internal),
        STORAGE bit;
    
CREATE OPERATOR CLASS _bytea_aa_ops
FOR TYPE _bytea  USING rum
AS
        OPERATOR        1       &&  (anyarray, anyarray),
        OPERATOR        2       @>  (anyarray, anyarray),
        OPERATOR        3       <@  (anyarray, anyarray),
        OPERATOR        4       =   (anyarray, anyarray),
        OPERATOR        5       %   (anyarray, anyarray),
        OPERATOR        20      <=> (anyarray, anyarray) FOR ORDER BY pg_catalog.float_ops,
        --dispatch function 1 for concrete type
        FUNCTION    	1   byteacmp(bytea,bytea),
        FUNCTION        2       rumextract_anyarray(anyarray,internal,internal,internal,internal),
        FUNCTION        3       rumextract_anyarray_query(anyarray,internal,smallint,internal,internal,internal,internal),
        FUNCTION        4       rumanyarray_consistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        6       rumanyarray_config(internal),
        FUNCTION        7       rumanyarray_preconsistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        8       rumanyarray_ordering(internal,smallint,anyarray,int,internal,internal,internal,internal,internal),
        STORAGE bytea;
    
CREATE OPERATOR CLASS _char_aa_ops
FOR TYPE "_char"  USING rum
AS
        OPERATOR        1       &&  (anyarray, anyarray),
        OPERATOR        2       @>  (anyarray, anyarray),
        OPERATOR        3       <@  (anyarray, anyarray),
        OPERATOR        4       =   (anyarray, anyarray),
        OPERATOR        5       %   (anyarray, anyarray),
        OPERATOR        20      <=> (anyarray, anyarray) FOR ORDER BY pg_catalog.float_ops,
        --dispatch function 1 for concrete type
        FUNCTION    1   btcharcmp("char","char"),
        FUNCTION        2       rumextract_anyarray(anyarray,internal,internal,internal,internal),
        FUNCTION        3       rumextract_anyarray_query(anyarray,internal,smallint,internal,internal,internal,internal),
        FUNCTION        4       rumanyarray_consistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        6       rumanyarray_config(internal),
        FUNCTION        7       rumanyarray_preconsistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        8       rumanyarray_ordering(internal,smallint,anyarray,int,internal,internal,internal,internal,internal),
        STORAGE "char";
    
CREATE OPERATOR CLASS _cidr_aa_ops
FOR TYPE _cidr  USING rum
AS
        OPERATOR        1       &&  (anyarray, anyarray),
        OPERATOR        2       @>  (anyarray, anyarray),
        OPERATOR        3       <@  (anyarray, anyarray),
        OPERATOR        4       =   (anyarray, anyarray),
        OPERATOR        5       %   (anyarray, anyarray),
        OPERATOR        20      <=> (anyarray, anyarray) FOR ORDER BY pg_catalog.float_ops,
        --dispatch function 1 for concrete type
        FUNCTION    1   network_cmp(inet,inet),
        FUNCTION        2       rumextract_anyarray(anyarray,internal,internal,internal,internal),
        FUNCTION        3       rumextract_anyarray_query(anyarray,internal,smallint,internal,internal,internal,internal),
        FUNCTION        4       rumanyarray_consistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        6       rumanyarray_config(internal),
        FUNCTION        7       rumanyarray_preconsistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        8       rumanyarray_ordering(internal,smallint,anyarray,int,internal,internal,internal,internal,internal),
        STORAGE cidr;
    
CREATE OPERATOR CLASS _date_aa_ops
FOR TYPE _date  USING rum
AS
        OPERATOR        1       &&  (anyarray, anyarray),
        OPERATOR        2       @>  (anyarray, anyarray),
        OPERATOR        3       <@  (anyarray, anyarray),
        OPERATOR        4       =   (anyarray, anyarray),
        OPERATOR        5       %   (anyarray, anyarray),
        OPERATOR        20      <=> (anyarray, anyarray) FOR ORDER BY pg_catalog.float_ops,
        --dispatch function 1 for concrete type
        FUNCTION    1   date_cmp(date,date),
        FUNCTION        2       rumextract_anyarray(anyarray,internal,internal,internal,internal),
        FUNCTION        3       rumextract_anyarray_query(anyarray,internal,smallint,internal,internal,internal,internal),
        FUNCTION        4       rumanyarray_consistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        6       rumanyarray_config(internal),
        FUNCTION        7       rumanyarray_preconsistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        8       rumanyarray_ordering(internal,smallint,anyarray,int,internal,internal,internal,internal,internal),
        STORAGE date;
    
CREATE OPERATOR CLASS _float4_aa_ops
FOR TYPE _float4  USING rum
AS
        OPERATOR        1       &&  (anyarray, anyarray),
        OPERATOR        2       @>  (anyarray, anyarray),
        OPERATOR        3       <@  (anyarray, anyarray),
        OPERATOR        4       =   (anyarray, anyarray),
        OPERATOR        5       %   (anyarray, anyarray),
        OPERATOR        20      <=> (anyarray, anyarray) FOR ORDER BY pg_catalog.float_ops,
        --dispatch function 1 for concrete type
        FUNCTION    1   btfloat4cmp(float4,float4),
        FUNCTION        2       rumextract_anyarray(anyarray,internal,internal,internal,internal),
        FUNCTION        3       rumextract_anyarray_query(anyarray,internal,smallint,internal,internal,internal,internal),
        FUNCTION        4       rumanyarray_consistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        6       rumanyarray_config(internal),
        FUNCTION        7       rumanyarray_preconsistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        8       rumanyarray_ordering(internal,smallint,anyarray,int,internal,internal,internal,internal,internal),
        STORAGE float4;
    
CREATE OPERATOR CLASS _float8_aa_ops
FOR TYPE _float8  USING rum
AS
        OPERATOR        1       &&  (anyarray, anyarray),
        OPERATOR        2       @>  (anyarray, anyarray),
        OPERATOR        3       <@  (anyarray, anyarray),
        OPERATOR        4       =   (anyarray, anyarray),
        OPERATOR        5       %   (anyarray, anyarray),
        OPERATOR        20      <=> (anyarray, anyarray) FOR ORDER BY pg_catalog.float_ops,
        --dispatch function 1 for concrete type
        FUNCTION    1   btfloat8cmp(float8,float8),
        FUNCTION        2       rumextract_anyarray(anyarray,internal,internal,internal,internal),
        FUNCTION        3       rumextract_anyarray_query(anyarray,internal,smallint,internal,internal,internal,internal),
        FUNCTION        4       rumanyarray_consistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        6       rumanyarray_config(internal),
        FUNCTION        7       rumanyarray_preconsistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        8       rumanyarray_ordering(internal,smallint,anyarray,int,internal,internal,internal,internal,internal),
        STORAGE float8;
    
CREATE OPERATOR CLASS _inet_aa_ops
FOR TYPE _inet  USING rum
AS
        OPERATOR        1       &&  (anyarray, anyarray),
        OPERATOR        2       @>  (anyarray, anyarray),
        OPERATOR        3       <@  (anyarray, anyarray),
        OPERATOR        4       =   (anyarray, anyarray),
        OPERATOR        5       %   (anyarray, anyarray),
        OPERATOR        20      <=> (anyarray, anyarray) FOR ORDER BY pg_catalog.float_ops,
        --dispatch function 1 for concrete type
        FUNCTION    1   network_cmp(inet,inet),
        FUNCTION        2       rumextract_anyarray(anyarray,internal,internal,internal,internal),
        FUNCTION        3       rumextract_anyarray_query(anyarray,internal,smallint,internal,internal,internal,internal),
        FUNCTION        4       rumanyarray_consistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        6       rumanyarray_config(internal),
        FUNCTION        7       rumanyarray_preconsistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        8       rumanyarray_ordering(internal,smallint,anyarray,int,internal,internal,internal,internal,internal),
        STORAGE inet;
    
CREATE OPERATOR CLASS _int2_aa_ops
FOR TYPE _int2  USING rum
AS
        OPERATOR        1       &&  (anyarray, anyarray),
        OPERATOR        2       @>  (anyarray, anyarray),
        OPERATOR        3       <@  (anyarray, anyarray),
        OPERATOR        4       =   (anyarray, anyarray),
        OPERATOR        5       %   (anyarray, anyarray),
        OPERATOR        20      <=> (anyarray, anyarray) FOR ORDER BY pg_catalog.float_ops,
        --dispatch function 1 for concrete type
        FUNCTION    1   btint2cmp(int2,int2),
        FUNCTION        2       rumextract_anyarray(anyarray,internal,internal,internal,internal),
        FUNCTION        3       rumextract_anyarray_query(anyarray,internal,smallint,internal,internal,internal,internal),
        FUNCTION        4       rumanyarray_consistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        6       rumanyarray_config(internal),
        FUNCTION        7       rumanyarray_preconsistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        8       rumanyarray_ordering(internal,smallint,anyarray,int,internal,internal,internal,internal,internal),
        STORAGE int2;
    
CREATE OPERATOR CLASS _int4_aa_ops
FOR TYPE _int4  USING rum
AS
        OPERATOR        1       &&  (anyarray, anyarray),
        OPERATOR        2       @>  (anyarray, anyarray),
        OPERATOR        3       <@  (anyarray, anyarray),
        OPERATOR        4       =   (anyarray, anyarray),
        OPERATOR        5       %   (anyarray, anyarray),
        OPERATOR        20      <=> (anyarray, anyarray) FOR ORDER BY pg_catalog.float_ops,
        --dispatch function 1 for concrete type
        FUNCTION    1   btint4cmp(int4,int4),
        FUNCTION        2       rumextract_anyarray(anyarray,internal,internal,internal,internal),
        FUNCTION        3       rumextract_anyarray_query(anyarray,internal,smallint,internal,internal,internal,internal),
        FUNCTION        4       rumanyarray_consistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        6       rumanyarray_config(internal),
        FUNCTION        7       rumanyarray_preconsistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        8       rumanyarray_ordering(internal,smallint,anyarray,int,internal,internal,internal,internal,internal),
        STORAGE int4;
    
CREATE OPERATOR CLASS _int8_aa_ops
FOR TYPE _int8  USING rum
AS
        OPERATOR        1       &&  (anyarray, anyarray),
        OPERATOR        2       @>  (anyarray, anyarray),
        OPERATOR        3       <@  (anyarray, anyarray),
        OPERATOR        4       =   (anyarray, anyarray),
        OPERATOR        5       %   (anyarray, anyarray),
        OPERATOR        20      <=> (anyarray, anyarray) FOR ORDER BY pg_catalog.float_ops,
        --dispatch function 1 for concrete type
        FUNCTION    1   btint8cmp(int8,int8),
        FUNCTION        2       rumextract_anyarray(anyarray,internal,internal,internal,internal),
        FUNCTION        3       rumextract_anyarray_query(anyarray,internal,smallint,internal,internal,internal,internal),
        FUNCTION        4       rumanyarray_consistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        6       rumanyarray_config(internal),
        FUNCTION        7       rumanyarray_preconsistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        8       rumanyarray_ordering(internal,smallint,anyarray,int,internal,internal,internal,internal,internal),
        STORAGE int8;
    
CREATE OPERATOR CLASS _interval_aa_ops
FOR TYPE _interval  USING rum
AS
        OPERATOR        1       &&  (anyarray, anyarray),
        OPERATOR        2       @>  (anyarray, anyarray),
        OPERATOR        3       <@  (anyarray, anyarray),
        OPERATOR        4       =   (anyarray, anyarray),
        OPERATOR        5       %   (anyarray, anyarray),
        OPERATOR        20      <=> (anyarray, anyarray) FOR ORDER BY pg_catalog.float_ops,
        --dispatch function 1 for concrete type
        FUNCTION    1   interval_cmp(interval,interval),
        FUNCTION        2       rumextract_anyarray(anyarray,internal,internal,internal,internal),
        FUNCTION        3       rumextract_anyarray_query(anyarray,internal,smallint,internal,internal,internal,internal),
        FUNCTION        4       rumanyarray_consistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        6       rumanyarray_config(internal),
        FUNCTION        7       rumanyarray_preconsistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        8       rumanyarray_ordering(internal,smallint,anyarray,int,internal,internal,internal,internal,internal),
        STORAGE interval;
    
CREATE OPERATOR CLASS _macaddr_aa_ops
FOR TYPE _macaddr  USING rum
AS
        OPERATOR        1       &&  (anyarray, anyarray),
        OPERATOR        2       @>  (anyarray, anyarray),
        OPERATOR        3       <@  (anyarray, anyarray),
        OPERATOR        4       =   (anyarray, anyarray),
        OPERATOR        5       %   (anyarray, anyarray),
        OPERATOR        20      <=> (anyarray, anyarray) FOR ORDER BY pg_catalog.float_ops,
        --dispatch function 1 for concrete type
        FUNCTION    1   macaddr_cmp(macaddr,macaddr),
        FUNCTION        2       rumextract_anyarray(anyarray,internal,internal,internal,internal),
        FUNCTION        3       rumextract_anyarray_query(anyarray,internal,smallint,internal,internal,internal,internal),
        FUNCTION        4       rumanyarray_consistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        6       rumanyarray_config(internal),
        FUNCTION        7       rumanyarray_preconsistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        8       rumanyarray_ordering(internal,smallint,anyarray,int,internal,internal,internal,internal,internal),
        STORAGE macaddr;
    
CREATE OPERATOR CLASS _money_aa_ops
FOR TYPE _money  USING rum
AS
        OPERATOR        1       &&  (anyarray, anyarray),
        OPERATOR        2       @>  (anyarray, anyarray),
        OPERATOR        3       <@  (anyarray, anyarray),
        OPERATOR        4       =   (anyarray, anyarray),
        OPERATOR        5       %   (anyarray, anyarray),
        OPERATOR        20      <=> (anyarray, anyarray) FOR ORDER BY pg_catalog.float_ops,
        --dispatch function 1 for concrete type
        FUNCTION    1   cash_cmp(money,money),
        FUNCTION        2       rumextract_anyarray(anyarray,internal,internal,internal,internal),
        FUNCTION        3       rumextract_anyarray_query(anyarray,internal,smallint,internal,internal,internal,internal),
        FUNCTION        4       rumanyarray_consistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        6       rumanyarray_config(internal),
        FUNCTION        7       rumanyarray_preconsistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        8       rumanyarray_ordering(internal,smallint,anyarray,int,internal,internal,internal,internal,internal),
        STORAGE money;
    
CREATE OPERATOR CLASS _numeric_aa_ops
FOR TYPE _numeric  USING rum
AS
        OPERATOR        1       &&  (anyarray, anyarray),
        OPERATOR        2       @>  (anyarray, anyarray),
        OPERATOR        3       <@  (anyarray, anyarray),
        OPERATOR        4       =   (anyarray, anyarray),
        OPERATOR        5       %   (anyarray, anyarray),
        OPERATOR        20      <=> (anyarray, anyarray) FOR ORDER BY pg_catalog.float_ops,
        --dispatch function 1 for concrete type
        FUNCTION    1   numeric_cmp(numeric,numeric),
        FUNCTION        2       rumextract_anyarray(anyarray,internal,internal,internal,internal),
        FUNCTION        3       rumextract_anyarray_query(anyarray,internal,smallint,internal,internal,internal,internal),
        FUNCTION        4       rumanyarray_consistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        6       rumanyarray_config(internal),
        FUNCTION        7       rumanyarray_preconsistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        8       rumanyarray_ordering(internal,smallint,anyarray,int,internal,internal,internal,internal,internal),
        STORAGE numeric;
    
CREATE OPERATOR CLASS _oid_aa_ops
FOR TYPE _oid  USING rum
AS
        OPERATOR        1       &&  (anyarray, anyarray),
        OPERATOR        2       @>  (anyarray, anyarray),
        OPERATOR        3       <@  (anyarray, anyarray),
        OPERATOR        4       =   (anyarray, anyarray),
        OPERATOR        5       %   (anyarray, anyarray),
        OPERATOR        20      <=> (anyarray, anyarray) FOR ORDER BY pg_catalog.float_ops,
        --dispatch function 1 for concrete type
        FUNCTION    1   btoidcmp(oid,oid),
        FUNCTION        2       rumextract_anyarray(anyarray,internal,internal,internal,internal),
        FUNCTION        3       rumextract_anyarray_query(anyarray,internal,smallint,internal,internal,internal,internal),
        FUNCTION        4       rumanyarray_consistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        6       rumanyarray_config(internal),
        FUNCTION        7       rumanyarray_preconsistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        8       rumanyarray_ordering(internal,smallint,anyarray,int,internal,internal,internal,internal,internal),
        STORAGE oid;
    
CREATE OPERATOR CLASS _text_aa_ops
FOR TYPE _text  USING rum
AS
        OPERATOR        1       &&  (anyarray, anyarray),
        OPERATOR        2       @>  (anyarray, anyarray),
        OPERATOR        3       <@  (anyarray, anyarray),
        OPERATOR        4       =   (anyarray, anyarray),
        OPERATOR        5       %   (anyarray, anyarray),
        OPERATOR        20      <=> (anyarray, anyarray) FOR ORDER BY pg_catalog.float_ops,
        --dispatch function 1 for concrete type
        FUNCTION    1   bttextcmp(text,text),
        FUNCTION        2       rumextract_anyarray(anyarray,internal,internal,internal,internal),
        FUNCTION        3       rumextract_anyarray_query(anyarray,internal,smallint,internal,internal,internal,internal),
        FUNCTION        4       rumanyarray_consistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        6       rumanyarray_config(internal),
        FUNCTION        7       rumanyarray_preconsistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        8       rumanyarray_ordering(internal,smallint,anyarray,int,internal,internal,internal,internal,internal),
        STORAGE text;
    
CREATE OPERATOR CLASS _time_aa_ops
FOR TYPE _time  USING rum
AS
        OPERATOR        1       &&  (anyarray, anyarray),
        OPERATOR        2       @>  (anyarray, anyarray),
        OPERATOR        3       <@  (anyarray, anyarray),
        OPERATOR        4       =   (anyarray, anyarray),
        OPERATOR        5       %   (anyarray, anyarray),
        OPERATOR        20      <=> (anyarray, anyarray) FOR ORDER BY pg_catalog.float_ops,
        --dispatch function 1 for concrete type
        FUNCTION    	1   	time_cmp(time,time),
        FUNCTION        2       rumextract_anyarray(anyarray,internal,internal,internal,internal),
        FUNCTION        3       rumextract_anyarray_query(anyarray,internal,smallint,internal,internal,internal,internal),
        FUNCTION        4       rumanyarray_consistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        6       rumanyarray_config(internal),
        FUNCTION        7       rumanyarray_preconsistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        8       rumanyarray_ordering(internal,smallint,anyarray,int,internal,internal,internal,internal,internal),
        STORAGE time;
    
CREATE OPERATOR CLASS _timestamp_aa_ops
FOR TYPE _timestamp  USING rum
AS
        OPERATOR        1       &&  (anyarray, anyarray),
        OPERATOR        2       @>  (anyarray, anyarray),
        OPERATOR        3       <@  (anyarray, anyarray),
        OPERATOR        4       =   (anyarray, anyarray),
        OPERATOR        5       %   (anyarray, anyarray),
        OPERATOR        20      <=> (anyarray, anyarray) FOR ORDER BY pg_catalog.float_ops,
        --dispatch function 1 for concrete type
        FUNCTION    	1   	timestamp_cmp(timestamp,timestamp),
        FUNCTION        2       rumextract_anyarray(anyarray,internal,internal,internal,internal),
        FUNCTION        3       rumextract_anyarray_query(anyarray,internal,smallint,internal,internal,internal,internal),
        FUNCTION        4       rumanyarray_consistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        6       rumanyarray_config(internal),
        FUNCTION        7       rumanyarray_preconsistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        8       rumanyarray_ordering(internal,smallint,anyarray,int,internal,internal,internal,internal,internal),
        STORAGE timestamp;
    
CREATE OPERATOR CLASS _timestamptz_aa_ops
FOR TYPE _timestamptz  USING rum
AS
        OPERATOR        1       &&  (anyarray, anyarray),
        OPERATOR        2       @>  (anyarray, anyarray),
        OPERATOR        3       <@  (anyarray, anyarray),
        OPERATOR        4       =   (anyarray, anyarray),
        OPERATOR        5       %   (anyarray, anyarray),
        OPERATOR        20      <=> (anyarray, anyarray) FOR ORDER BY pg_catalog.float_ops,
        --dispatch function 1 for concrete type
        FUNCTION    	1  		timestamptz_cmp(timestamptz,timestamptz),
        FUNCTION        2       rumextract_anyarray(anyarray,internal,internal,internal,internal),
        FUNCTION        3       rumextract_anyarray_query(anyarray,internal,smallint,internal,internal,internal,internal),
        FUNCTION        4       rumanyarray_consistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        6       rumanyarray_config(internal),
        FUNCTION        7       rumanyarray_preconsistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        8       rumanyarray_ordering(internal,smallint,anyarray,int,internal,internal,internal,internal,internal),
        STORAGE timestamptz;
    
CREATE OPERATOR CLASS _timetz_aa_ops
FOR TYPE _timetz  USING rum
AS
        OPERATOR        1       &&  (anyarray, anyarray),
        OPERATOR        2       @>  (anyarray, anyarray),
        OPERATOR        3       <@  (anyarray, anyarray),
        OPERATOR        4       =   (anyarray, anyarray),
        OPERATOR        5       %   (anyarray, anyarray),
        OPERATOR        20      <=> (anyarray, anyarray) FOR ORDER BY pg_catalog.float_ops,
        --dispatch function 1 for concrete type
        FUNCTION    	1   	timetz_cmp(timetz,timetz),
        FUNCTION        2       rumextract_anyarray(anyarray,internal,internal,internal,internal),
        FUNCTION        3       rumextract_anyarray_query(anyarray,internal,smallint,internal,internal,internal,internal),
        FUNCTION        4       rumanyarray_consistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        6       rumanyarray_config(internal),
        FUNCTION        7       rumanyarray_preconsistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        8       rumanyarray_ordering(internal,smallint,anyarray,int,internal,internal,internal,internal,internal),
        STORAGE timetz;
    
CREATE OPERATOR CLASS _varbit_aa_ops
FOR TYPE _varbit  USING rum
AS
        OPERATOR        1       &&  (anyarray, anyarray),
        OPERATOR        2       @>  (anyarray, anyarray),
        OPERATOR        3       <@  (anyarray, anyarray),
        OPERATOR        4       =   (anyarray, anyarray),
        OPERATOR        5       %   (anyarray, anyarray),
        OPERATOR        20      <=> (anyarray, anyarray) FOR ORDER BY pg_catalog.float_ops,
        --dispatch function 1 for concrete type
        FUNCTION    	1  		varbitcmp(varbit,varbit),
        FUNCTION        2       rumextract_anyarray(anyarray,internal,internal,internal,internal),
        FUNCTION        3       rumextract_anyarray_query(anyarray,internal,smallint,internal,internal,internal,internal),
        FUNCTION        4       rumanyarray_consistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        6       rumanyarray_config(internal),
        FUNCTION        7       rumanyarray_preconsistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        8       rumanyarray_ordering(internal,smallint,anyarray,int,internal,internal,internal,internal,internal),
        STORAGE varbit;
    
CREATE OPERATOR CLASS _varchar_aa_ops
FOR TYPE _varchar  USING rum
AS
        OPERATOR        1       &&  (anyarray, anyarray),
        OPERATOR        2       @>  (anyarray, anyarray),
        OPERATOR        3       <@  (anyarray, anyarray),
        OPERATOR        4       =   (anyarray, anyarray),
        OPERATOR        5       %   (anyarray, anyarray),
        OPERATOR        20      <=> (anyarray, anyarray) FOR ORDER BY pg_catalog.float_ops,
        --dispatch function 1 for concrete type
        FUNCTION    	1   	bttextcmp(text,text),
        FUNCTION        2       rumextract_anyarray(anyarray,internal,internal,internal,internal),
        FUNCTION        3       rumextract_anyarray_query(anyarray,internal,smallint,internal,internal,internal,internal),
        FUNCTION        4       rumanyarray_consistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        6       rumanyarray_config(internal),
        FUNCTION        7       rumanyarray_preconsistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        8       rumanyarray_ordering(internal,smallint,anyarray,int,internal,internal,internal,internal,internal),
        STORAGE varchar;

/* 
 *  anyarray support for uuid type in GIST, GIN, RUM
 */

CREATE OPERATOR CLASS _uuid_aa_ops
FOR TYPE _uuid USING gist
AS
	OPERATOR	3	&&	(anyarray, anyarray),
	OPERATOR	6	=	(anyarray, anyarray),
	OPERATOR	7	@>	(anyarray, anyarray),
	OPERATOR	8	<@	(anyarray, anyarray),
	OPERATOR	16	%	(anyarray, anyarray),
	FUNCTION	1	ganyarray_consistent(internal,internal,int,oid,internal),
	FUNCTION	2	ganyarray_union (bytea, internal),
	FUNCTION	3	ganyarray_compress (internal),
	FUNCTION	4	ganyarray_decompress (internal),
	FUNCTION	5	ganyarray_penalty (internal, internal, internal),
	FUNCTION	6	ganyarray_picksplit (internal, internal),
	FUNCTION	7	ganyarray_same (ganyarray, ganyarray, internal),
STORAGE         ganyarray;

CREATE OPERATOR CLASS _uuid_aa_ops
FOR TYPE _uuid  USING gin
AS
    OPERATOR	3	&&	(anyarray, anyarray),
	OPERATOR	6	=	(anyarray, anyarray),
	OPERATOR	7	@>	(anyarray, anyarray),
	OPERATOR	8	<@	(anyarray, anyarray),
	OPERATOR	16	%	(anyarray, anyarray),
	FUNCTION    1   uuid_cmp(uuid,uuid),
	FUNCTION    2   ginanyarray_extract(anyarray, internal),
	FUNCTION    3   ginanyarray_queryextract(anyarray, internal, internal),
	FUNCTION    4   ginanyarray_consistent(internal, internal, anyarray),
	FUNCTION    6   ginanyarray_triconsistent(internal, internal, anyarray,internal,internal,internal,internal,internal),
	STORAGE     uuid;

CREATE OPERATOR CLASS _uuid_aa_ops
FOR TYPE _uuid  USING rum
AS
        OPERATOR        1       &&  (anyarray, anyarray),
        OPERATOR        2       @>  (anyarray, anyarray),
        OPERATOR        3       <@  (anyarray, anyarray),
        OPERATOR        4       =   (anyarray, anyarray),
        OPERATOR        5       %   (anyarray, anyarray),
        OPERATOR        20      <=> (anyarray, anyarray) FOR ORDER BY pg_catalog.float_ops,
        --dispatch function 1 for concrete type
        FUNCTION    	1   	uuid_cmp(uuid,uuid),
        FUNCTION        2       rumextract_anyarray(anyarray,internal,internal,internal,internal),
        FUNCTION        3       rumextract_anyarray_query(anyarray,internal,smallint,internal,internal,internal,internal),
        FUNCTION        4       rumanyarray_consistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        6       rumanyarray_config(internal),
        FUNCTION        7       rumanyarray_preconsistent(internal,smallint,anyarray,integer,internal,internal,internal,internal),
        FUNCTION        8       rumanyarray_ordering(internal,smallint,anyarray,int,internal,internal,internal,internal,internal),
        STORAGE uuid;
