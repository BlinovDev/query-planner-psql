-- EXAMPLE 4.4
select * from pg_stats where tablename = 'test';

alter table test alter column almost_unique set statistics 5;
VACUUM ANALYSE test;

alter table test alter column almost_unique set statistics -1;

analyze verbose test;

alter table test alter column almost_unique set statistics 10;

alter table test alter column all_the_same set statistics 10;

-- "rows in sample" is our "random sample"
