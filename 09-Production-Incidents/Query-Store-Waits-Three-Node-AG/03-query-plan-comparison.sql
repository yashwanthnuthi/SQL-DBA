/* DBA-024 | Query Store runtime comparison for one query_id.
   Run in SalesDB; replace the example query ID and UTC interval.
   Compare plans, durations, CPU, logical reads and execution counts.
   Query Store duration/CPU units are microseconds; output uses milliseconds.
*/
USE [SalesDB];
SET NOCOUNT ON;
DECLARE @QueryId bigint=123;
DECLARE @StartUtc datetimeoffset(7)='2026-11-04T18:00:00+00:00';
DECLARE @EndUtc datetimeoffset(7)='2026-11-04T19:00:00+00:00';
;WITH runtime_rows AS
(
 SELECT rs.plan_id,rs.runtime_stats_interval_id,rs.execution_type,
        SUM(rs.count_executions) AS executions,
        SUM(rs.avg_duration*rs.count_executions) AS weighted_duration_us,
        SUM(rs.avg_cpu_time*rs.count_executions) AS weighted_cpu_us,
        SUM(rs.avg_logical_io_reads*rs.count_executions) AS weighted_reads
 FROM sys.query_store_runtime_stats AS rs
 GROUP BY rs.plan_id,rs.runtime_stats_interval_id,rs.execution_type
)
SELECT p.query_id,p.plan_id,p.is_forced_plan,p.last_execution_time,
       SUM(r.executions) AS executions,
       CAST(SUM(r.weighted_duration_us)/NULLIF(SUM(r.executions),0)/1000.0
            AS decimal(18,2)) AS avg_duration_ms,
       CAST(SUM(r.weighted_cpu_us)/NULLIF(SUM(r.executions),0)/1000.0
            AS decimal(18,2)) AS avg_cpu_ms,
       CAST(SUM(r.weighted_reads)/NULLIF(SUM(r.executions),0)
            AS decimal(18,2)) AS avg_logical_reads,
       p.query_plan
FROM sys.query_store_plan AS p
JOIN runtime_rows AS r ON r.plan_id=p.plan_id
JOIN sys.query_store_runtime_stats_interval AS i
 ON i.runtime_stats_interval_id=r.runtime_stats_interval_id
WHERE p.query_id=@QueryId AND r.execution_type=0
 AND i.start_time<@EndUtc AND i.end_time>@StartUtc
GROUP BY p.query_id,p.plan_id,p.is_forced_plan,p.last_execution_time,p.query_plan
ORDER BY avg_duration_ms DESC;
-- For a true before/after comparison, run with a separate baseline window.
-- Query Store plans are generally estimated/compiled plans, not actual row counts.
