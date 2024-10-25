-- EXAMPLE 3.1
explain analyze select a.* from pg_class c join pg_attribute a on c.oid = a.attrelid where c.relname in ( 'pg_class', 'pg_namespace' );
