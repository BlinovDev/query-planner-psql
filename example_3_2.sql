-- EXAMPLE 3.2
explain analyze select * from pg_class c join pg_namespace n on c.relnamespace = n.oid;
