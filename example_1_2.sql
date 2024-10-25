-- EXAMPLE 1.2
create table test (id serial primary key, some_text text);
insert into test (some_text) select 'whatever' from generate_series(1,1000);

DROP TABLE test;

explain select * from test where id = 50;

SET enable_indexscan = false;

SET enable_bitmapscan = false;

-- Index Scan using test_pkey on test  (cost=0.28..8.29 rows=1 width=13)
-- Bitmap Heap Scan on test  (cost=4.28..8.30 rows=1 width=13)
-- Seq Scan on test  (cost=0.00..18.50 rows=1 width=13)

SET enable_indexscan = true;
SET enable_bitmapscan = true;
