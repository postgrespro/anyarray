-- Check security CVE-2020-14350
CREATE FUNCTION rumanyarray_distance(anyarray,anyarray) RETURNS bool AS $$ SELECT false $$ LANGUAGE SQL;
CREATE EXTENSION anyarray CASCADE;
DROP FUNCTION rumanyarray_distance(anyarray,anyarray);

