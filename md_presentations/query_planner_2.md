Second part of talk about query planner in [[PostgreSQL]]. 
### Explain flags
`EXPLAIN` command has its own specific flags that allow user to customise query plan build according to his aims.
##### ANALYSE
The most popular flag for `EXPLAIN` command. `ANALYSE` does real request to DB and shows time of querying and planning.
##### VERBOSE
`VERBOSE` prints additional row for each DB request done(for example each request to partitions) with information about names of columns returned by that exact query.
##### BUFFERS

### Specifics of plans for partitioned tables
For partitioned tables query plan looks really similar to the plan for `SELECT * FROM table;`, but there are some differences that we should take into account.
Depending on size each partition can use its own scan method(for **small** ones **seq_scan** can be the choice, for **huge** ones you as a Dev must care that **index** been used).
Also you can with simple `EXPLAIN` check the amount of partitions. Be very careful with `EXPLAIN ANALISE` for such queries!
![[partitions_explain_analyse.png.png]]
### Specifics of plans for complex indexes

```PostgreSQL
EXPLAIN SELECT provider, variation FROM a8r_games WHERE variation = 'AllLuckyClover100' AND provider = 'bgaming';  
  
EXPLAIN SELECT provider, variation FROM a8r_games WHERE provider = 'bgaming' AND variation = 'AllLuckyClover100';

EXPLAIN SELECT provider, variation FROM a8r_games WHERE provider = 'bgaming';
```
**Query plan:**
For first two queries:
![[complex_index_a8r_games_two_cond.png]]
For third query: 
![[complex_index_a8r_games_one_cond.png]]
### Prepared statements

**Parse statement** -> **Rewrite query** -> **Generate paths** -> **Generate plan** -> **Execute plan**
