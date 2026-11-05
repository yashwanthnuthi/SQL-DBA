# Production Case Study: Query Store Waits Across a Three-Node Always On AG

**Status: Draft scenario and scripts. No production incident is claimed.**
Reference: [Microsoft Learn — sys.query_store_wait_stats](https://learn.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-query-store-wait-stats-transact-sql?view=sql-server-ver17).

## Example environment (invented for learning)

- AG: `AG_SALES_PROD`; database: `SalesDB`
- `SQLPROD01`: primary, read/write, synchronous
- `SQLPROD02`: readable secondary, synchronous
- `SQLDR01`: optional readable DR, asynchronous
- SQL Server 2022 Enterprise, Query Store enabled and wait capture ON.
- Application order search increases from **1–2 seconds** to **12–18 seconds** at 10:15 AM. These are hypothetical numbers.

**Important:** Query Store's secondary-replica capture and replica attribution depend on SQL Server version, build, configuration, and readable-secondary support. SQL Server 2022 adds `replica_group_id`; check `sys.query_store_replicas` and your actual build/feature availability. Do not assume data for all three replicas is present. Queries executed on a readable secondary may require direct investigation on that replica. Confirm Query Store state before interpreting missing rows.

## How to investigate safely

1. **Verify the AG first.** Run [01-check-ag-health.sql](01-check-ag-health.sql) on each replica. Confirm role, connected state, synchronization, redo and log send queues. Don't assume a slow application is caused by AG replication.
2. **Find which queries waited.** On the primary, in SalesDB, run [02-query-store-waits.sql](02-query-store-waits.sql). Replace the sample UTC timestamps with the actual incident window. Review wait categories and query IDs.
3. **Inspect query plans.** Run [03-query-plan-comparison.sql](03-query-plan-comparison.sql) for the identified query ID, once for baseline and once for incident. Compare execution count, average duration, CPU, reads and plan ID. Inspect plan XML in SSMS.
4. **Check live blocking.** Run [04-live-blocking.sql](04-live-blocking.sql) on the node serving the slow workload. Lock waits point toward transactions/blockers; Buffer IO toward reads; Memory toward grants; CPU toward scheduling pressure. A category alone is not proof of cause.
5. **Validate replica routing.** Check whether the application uses the AG listener with read-only intent and whether readable secondary routing is configured. Identify the actual node handling the request.
6. **Propose a controlled fix.** If a plan regression is confirmed, evaluate targeted statistics, indexing, a query rewrite or plan remediation in nonproduction. Any DDL or Query Store plan forcing needs change approval, rollback steps, and monitoring. No change script is included here.
7. **Prove the result.** Compare equal-length baseline/incident/post-fix windows with similar traffic and parameters; document p50/p95 application latency, executions, CPU, logical reads, Query Store waits, blocking, and AG queues. Check all replicas after change.

## Wait categories: quick guide

| Category | Child-friendly explanation | DBA follow-up |
|---|---|---|
| Lock | A query waits for another to unlock data | Identify blocking session, open transaction, isolation |
| Buffer IO | SQL Server waits to read a page | Compare file latency and physical reads |
| CPU | Query needs processor time | Compare CPU, runnable tasks and expensive plans |
| Memory | Query waits for working space | Review grants, concurrency and spills |
| Tran Log IO | Changes wait for log writes | Check log write latency and commit frequency |
| Parallelism | Workers coordinate work | Review skew, row estimates and plan shape |
| Replication | AG/replication-related waits | Inspect AG queues, health and replica-specific waits |

## Technical notes

- Query Store wait categories are **per plan and interval**, not the same as instance-level `sys.dm_os_wait_stats`.
- The current Query Store interval can contain multiple rows for the same plan, interval, execution type and wait category, so aggregate before ranking.
- The SQL Server 2022 view includes `replica_group_id` to identify the replica group.
- SQL Server 2022 requires **VIEW DATABASE PERFORMANCE STATE** for this view; AG server DMVs generally require **VIEW SERVER PERFORMANCE STATE**.
- The window scripts include complete Query Store intervals that overlap the requested UTC period, so totals are not exact at the boundaries.
- Runtime CPU and duration values are in microseconds; the script converts them to milliseconds.
- Query Store is database-scoped. Never treat one database's wait data as server-wide.
- Query Store does not track compilation waits in the same way as execution waits.
- Never paste unredacted SQL text, credentials, customer values, or server identifiers into a public portfolio.

## Portfolio interview story (fictional example)

**Symptom:** Order search takes 12–18 seconds instead of 1–2 seconds.
**Investigation:** Verify AG health; identify top Query Store wait category and query ID; compare plans; check live blocking and I/O.
**Possible root cause:** A plan regression after a statistics change leads to many extra logical reads and Buffer IO waits.
**Proposed resolution:** Test a suitable covering index or targeted statistics update, subject to plan review.
**Validation:** Capture before/after metrics and ensure no adverse replica or write impact.
**Honesty note:** This is a practice scenario. Do not report the proposed fix or improvement as an actual production outcome.

## Test checklist

- [ ] Run scripts on SQL Server 2022 lab with Query Store ON
- [ ] Confirm required permissions
- [ ] Confirm AG replica roles and visibility
- [ ] Confirm Query Store wait category and replica grouping
- [ ] Validate query text and plan access
- [ ] Save sanitized before/after evidence
