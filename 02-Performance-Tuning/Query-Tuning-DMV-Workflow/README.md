# Query Tuning Process Using SQL Server DMVs

**Status:** Draft — authored for portfolio, not executed or validated against a SQL Server instance.

**Supported:** SQL Server 2019 and 2022 (on-premises); some DMV permissions and output vary by environment. For most server-wide performance DMVs, SQL Server 2019 requires `VIEW SERVER STATE`; SQL Server 2022 requires `VIEW SERVER PERFORMANCE STATE`. Access to SQL text, plans, and input buffers may require additional permissions depending on context.

## Workflow

1. [DBA-011: Top 10 expensive cached statements](01-top-expensive-queries.sql) — rank by `total_elapsed_time`. Inspect execution count, average duration, CPU, reads and plan. Cache eviction/recompilation loses history; Query Store is preferable for durable history.
2. [DBA-012: Wait statistics](02-wait-statistics.sql) — rank by total `wait_time_ms` and percentage of filtered waits. These are cumulative instance counters; take two snapshots and subtract to identify waits during the incident. Filtering idle waits is heuristic, not exhaustive.
3. **Execution plan review** — see checklist below.
4. [DBA-013: Blocking and locks](03-current-blocking.sql) — identify blocked sessions, head blockers, lock waits and session SQL. A point-in-time sample may miss intermittent blocking; use Extended Events for history.
5. [DBA-014: Database file I/O](04-file-io-latency.sql) — per-file read/write counts and average latency. Compare intervals, workload and storage telemetry; cumulative averages alone cannot prove a storage fault.
6. [DBA-015: Index optimization example](05-example-index-optimization.sql) — hypothetical covering index, commented out for safety. Review existing indexes and plan evidence before implementation.
7. [DBA-016: Baseline and verify](06-baseline-and-verify.sql) — `SET STATISTICS IO/TIME` and actual plan. Record per-table logical reads, CPU, duration, row counts and plan shape before/after.

## What to inspect in an actual execution plan, and why

| Plan feature | Why it matters | What to validate |
|---|---|---|
| Estimated vs actual row counts | Large discrepancies can lead to poor join choices and memory grants | Statistics freshness, predicates, parameter sensitivity |
| Table/index scans | May read many rows, but scans can be optimal | Selectivity, table size, predicate coverage; don't assume scans are bad |
| Key/RID lookups | Repeated lookups can dominate high-row-count plans | Lookup count, potential covering index, write overhead |
| Sorts and hash operators | May need substantial memory and spill to tempdb | Actual spills, memory grant, row estimates |
| Join algorithms | Nested loops/hash/merge suit different data shapes | Row counts, indexes, spills, residual predicates |
| Warnings | Flag conversion, spill, missing stats, etc. | Implicit conversions on indexed columns, cardinality issues |
| Parallelism and skew | Unbalanced threads can slow a query | Per-thread rows, DOP, CPU, waits |
| Predicates and residuals | Non-SARGable expressions can prevent efficient seeks | Functions on filtered columns, type mismatches, wildcard patterns |
| Missing-index suggestions | Potential clues, not guaranteed fixes | Compare existing indexes and overall write/read workload |
| Memory grants and actual runtime | Over/under grants hurt concurrency or cause spills | Granted vs used memory, concurrency effects |

## Interpreting common waits

- `PAGEIOLATCH_*`: pages waiting on physical reads; correlate with file I/O and query reads.
- `WRITELOG`: log flush latency; correlate with log throughput, commits and storage.
- `LCK_M_*`: lock contention; inspect blocking chains and transaction duration.
- `RESOURCE_SEMAPHORE`: memory grant waits; inspect concurrent grants and plan estimates.
- `SOS_SCHEDULER_YIELD`: CPU scheduler pressure candidate; corroborate with CPU utilization and runnable tasks.
- `CXPACKET` / `CXCONSUMER`: parallel execution context; not automatically a problem.
- `HADR_*`: availability group activity; interpret by replica role and specific wait type.

## Tuning choices

- **Indexes:** design keys around equality/range predicates and joins; use INCLUDE selectively. Avoid duplicate or excessive indexes.
- **Rewrite queries:** make predicates SARGable, avoid unnecessary row expansion, and compare alternative joins/subqueries using actual plans.
- **Statistics:** inspect stale or poorly sampled statistics; update targeted statistics when evidence warrants. Don't blindly update everything.
- **Partitioning:** consider for manageability and partition elimination on very large tables with suitable predicates; it is **not** a general-purpose performance fix.
- **Test:** use representative parameters and row volumes, compare multiple runs and plan stability, and measure regression risk for other queries.

## Operational safeguards

All DMV scripts are read-only. They can still consume CPU or expose sensitive SQL text and file paths. Do not publish unredacted production output. The example index is intentionally commented out. Never clear wait stats, flush caches, kill sessions, or change indexes in production as part of an unapproved diagnostic run.

## Validation status

Scripts have been drafted and reviewed conceptually, but **have not been executed** against a SQL Server 2019/2022 instance. No performance improvement is claimed. Add sanitized before/after evidence after testing.
