-- EXAMPLE 2.1
explain analyze select * from pg_class limit 2;

explain analyze select * from pg_class where relname ~ 'a';
-- Rows Removed by Filter: 80

explain analyze select * from pg_class where oid = 1247;
