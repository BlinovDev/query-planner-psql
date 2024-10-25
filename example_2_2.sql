-- EXAMPLE 2.2
explain analyze select * from pg_class where oid > 1247 order by oid limit 10;

explain analyze select * from pg_class where oid < 1500 order by oid desc limit 10;

-- vacuum analyze test;
explain analyze select id from test order by id asc limit 10;
