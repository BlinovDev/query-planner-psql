-- EXAMPLE 4.1
drop table test;
create table test (all_the_same int4, almost_unique int4);

insert into test (all_the_same, almost_unique)
select 123, random() * 1000000 from generate_series(1,100000);

create index i1_t on test (all_the_same);

create index i2_t on test (almost_unique);

explain select * from test where all_the_same = 123;

explain select * from test where almost_unique = 123;

select * from pg_statistic where starelid = 'test'::regclass;

select * from pg_stats where tablename = 'test';
