# SQL Server System Catalog: Easy DBA Guide

**Status: Draft.** These are original, beginner-friendly adaptations inspired by the [Microsoft system catalog FAQ](https://learn.microsoft.com/en-us/sql/relational-databases/system-catalog-views/querying-the-sql-server-system-catalog-faq?view=sql-server-ver17). They are not copies of Microsoft's scripts, and have **not** been tested against a live SQL Server instance.

## Imagine SQL Server is a school library

- **Database:** the whole library.
- **Table:** a shelf of records.
- **Column:** one type of information on each record, such as a student's name.
- **Index:** the book index that helps find a page quickly.
- **Primary key:** a unique student ID, so two students are not confused.
- **Foreign key:** a link between two records.
- **View:** a saved way of looking at data.
- **Stored procedure:** a saved set of instructions.
- **Statistics:** a rough count/map SQL Server uses to choose a quick route.
- **Permissions:** who is allowed to see or change things.
- **System catalog:** SQL Server's own directory describing the database.

## Scripts

| ID | File | Simple question it answers |
|---|---|---|
| DBA-017 | [Tables and columns](01-tables-and-columns.sql) | What tables and columns exist? Which tables have no key or index? |
| DBA-018 | [Indexes, keys, statistics](02-indexes-keys-statistics.sql) | How are tables organized and connected? |
| DBA-019 | [Views, procedures, functions](03-views-procedures-functions.sql) | What saved SQL programs exist, and when did definitions change? |
| DBA-020 | [Constraints and dependencies](04-constraints-dependencies.sql) | What rules protect data and which objects refer to others? |
| DBA-021 | [Security and custom types](05-security-and-types.sql) | Which users, roles, permissions and special types exist? |

## How to run

1. Open SQL Server Management Studio (SSMS).
2. Connect to a **test** SQL Server instance.
3. Select the database you want to inspect from the SSMS database dropdown.
4. Open one `.sql` file and read the comments above each SELECT.
5. Replace example names like `dbo.Orders` and `dbo.usp_GetOrders` with real names in that database.
6. Run one SELECT at a time (highlight a statement, then Execute) and look at the Results tab.
7. If you see no rows, the object might not exist or your login may not have permission to see it.

## Why the scripts were rewritten

- More descriptive output column names and simpler comments.
- Schema-qualified names where needed to avoid confusing two tables with the same name.
- `NOT EXISTS` used to find missing keys/indexes clearly.
- Modern `sys.sql_expression_dependencies` used rather than deprecated `sys.sql_dependencies`.
- The Microsoft FAQ's example that creates/drops a helper function was replaced with read-only permission queries.
- Examples grouped by DBA job, instead of one very long file.

## Important limits

- These scripts only read system metadata; none creates, drops or changes database objects.
- **Read-only doesn't mean zero impact:** large metadata scans can consume resources.
- Catalog visibility is permission-dependent; an empty result doesn't prove an object is absent.
- `modify_date` means the object's definition changed, **not** its data changed.
- Missing a primary key, clustered index or index is a clue to investigate, not automatically a defect.
- Some objects and metadata differ by SQL Server version and platform. Start with SQL Server 2019/2022 in a lab.
- The original FAQ includes additional niche CLR and schema-ownership examples that are not fully reproduced in this beginner collection.

## Validation

Draft only. Run on a lab database, check output against SSMS Object Explorer, and record results before marking these scripts validated.
