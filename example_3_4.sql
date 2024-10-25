-- EXAMPLE 3.4
explain analyze select * from pg_class c where not exists (select * from pg_attribute a where a.attrelid = c.oid and a.attnum = 10);
