-- EXAMPLE 1.4
-- Function Scan
explain analyze select * from generate_Series(1,10) i;
-- Sort
explain analyze select * from pg_class order by relname;
-- other Sort method
explain analyze select * from pg_class order by relfilenode limit 5;
-- Limit
explain analyze select * from pg_class limit 2;
-- HashAggregate
explain analyze select relkind, count(*) from pg_Class group by relkind;
-- Unique
explain select distinct relkind from (select relkind from pg_class order by relkind) as x;
-- Append
explain select oid from pg_class union all select oid from pg_proc union all select oid from pg_database;
-- Result
explain select 1, 2;
-- Values Scan
explain select * from ( values (1, 'hubert'), (2, 'depesz'), (3, 'lubaczewski') ) as t (a,b);
-- GroupAggregate
explain select relkind, count(*) from (select relkind from pg_class order by relkind) x group by relkind;
-- HashSetOp
explain select * from (select oid from pg_Class order by oid) x intersect all select * from (select oid from pg_proc order by oid) y;
explain select * from (select oid from pg_Class order by oid) x intersect all select * from (select oid from pg_proc order by oid) y intersect all select * from (Select oid from pg_database order by oid) as w;
-- CTE Scan
explain analyze with x as (select relname, relkind from pg_class) select relkind, count(*), (select count(*) from x) from x group by relkind;
-- InitPlan
explain select * from pg_class where relkind = (select relkind from pg_class order by random() limit 1);
explain select *, (select length('depesz')) from pg_class;
-- SubPlan
explain analyze select c.relname, c.relkind, (Select count(*) from pg_Class x where c.relkind = x.relkind) from pg_Class c;
-- Memoize/Materialize
EXPLAIN ANALYSE SELECT n.nspname as "Schema",
       pg_catalog.format_type(t.oid, NULL) AS "Name",
       pg_catalog.obj_description(t.oid, 'pg_type') as "Description"
FROM pg_catalog.pg_type t
         LEFT JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
WHERE (t.typrelid = 0 OR (SELECT c.relkind = 'c' FROM pg_catalog.pg_class c WHERE c.oid = t.typrelid))
  AND NOT EXISTS(SELECT 1 FROM pg_catalog.pg_type el WHERE el.oid = t.typelem AND el.typarray = t.oid)
  AND pg_catalog.pg_type_is_visible(t.oid)
ORDER BY 1, 2;

explain analyze select * from
    ( select * from pg_class order by oid) as c
        join
    ( select * from pg_attribute a order by attrelid) as a
    on c.oid = a.attrelid;
    