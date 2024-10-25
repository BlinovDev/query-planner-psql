-- EXAMPLE 3.3
explain analyze select * from
    ( select * from pg_class order by oid) as c
        join
    ( select * from pg_attribute a order by attrelid) as a
    on c.oid = a.attrelid;
