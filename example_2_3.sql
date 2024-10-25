-- EXAMPLE 2.3
create table test_bitmap (id serial primary key, i int4);
insert into test_bitmap (i) select random() * 1000000000 from generate_series(1,100000);

select count(*) from test_bitmap;
select * from test_bitmap;

create index i1 on test_bitmap (i);

explain analyze select * from test_bitmap where i < 100000;

-- one index twice
explain analyze select * from test_bitmap where i < 5000000 or i > 950000000;
-- two indexes
explain analyze select * from test_bitmap where i < 5000000 or id > 95000;


alter table test_bitmap add column j int4 default random() * 1000000000;
create index i2 on test_bitmap (j);
alter table test_bitmap add column h int4 default random() * 1000000000;
create index i3 on test_bitmap (h);

explain analyze select * from test_bitmap where j < 50000000 and i < 50000000 and h > 950000000;

DROP TABLE test_bitmap;
