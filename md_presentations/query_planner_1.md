First part of talk about query planner in [[PostgreSQL]].
# Plan
1. What is it?
2. Which problem will be solved?
3. Few words about definitions and limitations
4. Query execution plan
5. How to generate execution plan?
6. Scan methods
7. Join methods
8. How to read it?(examples for clear SQL and ORM)
9. pg_indexes table
10. Analyse and vacuum
11. Q&A
#### 1. What is it?
[[PostgreSQL]] query planner is one of more important parts of any DBMS(Database Management System).
Query planner is responsible for way chosen to execute SQL queries(use seq-scan or which index should be used).
#### 2. Which problem will be solved?
- Pass DBA review quicker;
- Estimate request and optimise the query;
- Make decisions based on query plan;
- Do not broke prod DB(optional);
#### 3. Definitions and limitations
Speaking about **PostgreSQL** .
**Selectivity** - relation of chosen records to amount of all records in the table.
**Cardinality** - amount of different values in one column of table. 
For **bool** columns **cardinality = 2**, for **id** column **cardinality = amount of rows**.
#### 4. Query execution
**Parse statement** -> **Rewrite query** -> **Generate paths** -> **Generate plan** -> **Execute plan**
#### 5. How to generate execution plan?
Use `EXPLAIN` command to see query execution plan. To get more info about query plan you can use additional flags as `ANALYSE` and `VERBOSE`.
```PostgreSQL
EXPLAIN SELECT * FROM users WHERE created_at BETWEEN '2022-01-01' AND '2024-01-01';
```
For ORM query you can generate explain for it just using `.explain` method as shown:
```Ruby
User.where(created_at: '2022-01-01'..'2024-01-01').explain
```
**Example**
#### 6. Plan metrics
**@Example 1.1**
**cost** - characteristic of query complicity relational to SeqScan of one data sheet.
**rows** - approximate amount of rows returned by query.
**width** - average size of string of your table in bytes.
**@Example 1.2**
Remember that some operations can return rows ASAP or one by one and some operations require all data to be red. ???
**@Example 1.3**
##### work_mem
**work_mem** is a setting in PostgreSQL that stands for fast memory can be used by operation(pay attention: by operation, not by query).
##### More key words
In this section we will take a look on couple of other words and phrases you can probably find in you query plan:
- Function Scan — initiates function and returns data set;
- Sort — sorts records by condition;
- Limit — limits amount of returned rows;
- HashAggregate — generates hash with key(GROUP BY key) and values — associated values with that key. Scans the hash and returns one result row for each key;
- Unique — deletes duplicates;
- Append — summarises results of sub-queries;
- Result — prints some constants;
- Values Scan — when **values** used;
- GroupAggregate — similar to HashAggregate, but requires data to be sorted;
- HashSetOp — uses Append and after that checks condition and sorts result set of rows returned by append;
- InitPlan — executes part of query that should be pre-counted;
- SubPlan — executes part of query that depends of current row;
- Materialize — save result set in memory, allows forward/backward data access;
- Memoize — cashing of caching results from parameterised scans inside nested-loop joins.
**@Example 1.4**
#### 7. Scan methods
- Sequential scan;
- Index scan/Index scan Backward/Index only scan;
- Bitmap index scan;
###### Seq scan:
Seq-scan means that we don't use index and going sequentially throw the table data. Planner uses it when:
- you select almost all data from the table;
- you use `like` method;
- you don't have index that matches search condition.
**@Example 2.1**
###### Index scan:
1. **Direct Access**: An Index Scan directly accesses the index to find the rows that satisfy the query conditions. It looks up index entries in sorted order.
2. **Efficiency in Certain Conditions**: This method is efficient for queries that return a small percentage of rows, where the cost of directly looking up each row in the index is lower than scanning the whole table.
3. **Ordered Results**: Since Index Scans follow the order of the index, they are useful when the query needs results in a specific order, potentially avoiding the need for an additional sort step.
4. **Row-by-Row Processing**: Index Scans process one row at a time, which can be beneficial for certain types of queries, especially those involving limit clauses or when only a few rows are retrieved.
**@Example 2.2**
###### Bitmap index scan:
1. **Bitmap Creation**: A Bitmap Index Scan first creates a bitmap (a compact in-memory representation) where each bit corresponds to a data sheet. It sets bits for sheets that can match the index conditions.
2. **Efficient for Larger Result Sets**: This method is typically used when the query is expected to return a larger portion of rows but not so large that a sequential scan would be more efficient. It’s more efficient in such cases because it reduces random disk input/output by reading the table rows in physical order.
3. **No Ordering**: The Bitmap Index Scan does not inherently maintain the order of the index, as it focuses on efficiently retrieving all matching rows.
4. **Two-Step Process**: It consists of two phases – first, the bitmap creation using the index, and second, the retrieval of rows based on this bitmap. This can be more efficient for I/O as it groups disk reads, which is beneficial when dealing with a larger number of rows.
**@Example 2.3**
#### 8. Join methods
##### Nested Loop
Just nested loop as it is. We go throw records on first table and check all rows of second table on each step(for each record in first table). Not recommended for joins of huge tables.
With index works much faster cause Postgres doesn't scan all raws.
**@Example 3.1**
##### Hash Join
Using specific hash to minimise amount of table scans by storing already used keys and values.
Indexes don't influence choice of Hash join but can improve its speed same way as with nested loop, planner don't have a need to scan all the table and can access records stored in the index.
**@Example 3.2**
##### Merge Join
While merge join we sort records in both tables and with such approach saves us some time, cause planner knows when to go to the next record.
For merge join B-tree index causes skip of sorting step, cause values are already sorted in the index(required for both tables).
Merge join requires data to be readable forward and backward(last example in **1.4**).
**@Example 3.3**

**Alternative joins:**
- Hash Left Join,
- Hash Right Join,
- Merge Left Join,
- Merge Right Join,
- Nested Loop Left Join.

**Anti-joins:**
- Hash Anti Join,
- Merge Anti Join,
- Nested Loop Anti Join.
**@Example 3.4**
#### 9. Row caching
Just couple more words about Materialize and Memoized we saw in the end of example **1.4**.

If you repeatedly scan the inner set rows with the same parameter and (consequently) get the same result every time, it might be a good idea to cache the rows for faster access.

This became possible in PostgreSQL 14 with the introduction of the Memoize node. The Memoize node resembles the Materialize node in some ways, but it is tailored specifically for parameterised joins and is much more complicated under the hood:
- While Materialize simply materializes every row of its child node, Memoize stores separate row instances for each parameter value.
- When reaching its maximum storage capacity, Materialize offloads any additional data on disk, but Memoize does not (because that would void any benefit of caching).
#### 9. Stats and its value
##### pg_indexes
In **pg_indexes** table you can find all indexes of your DB and sort them by table name for example:
```PostgreSQL
SELECT * FROM pg_indexes WHERE tablename LIKE ('%users%');
```
This feature can help you to understand how you should write your query.
##### pg_statistics
Statistic data about all tables and their columns. Available only for DB admin.
##### pg_stats
Views of **pg_statistics** with more human readable data.
**@Example 4.1**
- **null_frac** — percentage of null rows in the column.
- **avg_width** — average size of data in the column, more useful for variable size data types.
- **n_distinct** — if >1, its amount of different(unique) values. If <0, then its a percentage of rows with unique value in the column.
- **most_common_vals** — array of most popular values in the column.
- **most_common_freqs** — how often values from most_common_vals appear in responses, also a percentage.
- **histogram_bounds** — array of values that separates all data to equal parts.
**@Example 4.2**
- **correlation** — difference between sorting of rows on disc and their values. As value became closer to -1/1 as less difference you have.
**@Example 4.3**
- **most_common_elems**, **most_common_elem_freqs**,  **elem_count_histogram** same as **most_common_vals**, **most_common_freqs** и **histogram_bounds**, but for arrays, tsvectors and alike data types.
##### statistics tuning
```PostgreSQL
SHOW data_directory;
```

```bash
cat /opt/homebrew/var/postgresql@14/postgresql.conf

# default_statistics_target
```

```PostgreSQL
SET enable_bitmapscan = on;
SET enable_hashagg = on;
SET enable_hashjoin = on;  
SET enable_indexscan = on;  
SET enable_indexonlyscan = on;  
SET enable_material = on;
SET enable_mergejoin = on;  
SET enable_nestloop = on;
SET enable_seqscan = on;
SET enable_sort = on;
SET enable_tidscan = on;
```
##### random sample
**@Example 4.4**
In reality PostgreSQL cannot read all data from tables to build and renew statistic, that is why it only does it for 
`300 * statistics_target` rows from actual table column.
Of course that fact make us doubt, but as practice shows it works in most of cases(basic value of **statistics_target** = 100).
Because of that, sometimes ANALYSE can broke your queries, cause incorrect data will be taken. In such cases you can just raise value of **statistics_target**, but be careful with such modifications.
All in all, PostgreSQL tuning isn't the main part here and we can move forward.
#### 10. Analyse and vacuum
`ANALYSE` command helps you to keep Postgres statistic tables up to date. `VACCUM` command cleans up empty space on disc that arises after data deletion.
Don't use these on production DB-s without deep understanding of how it actually works and DBA approve.
#### 11. Q&A
Thanks!
