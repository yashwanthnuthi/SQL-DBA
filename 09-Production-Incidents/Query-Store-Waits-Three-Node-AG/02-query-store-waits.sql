/* DBA-023 | Run in SalesDB on the PRIMARY first.
   Set the UTC investigation window. Read only.
   Requires VIEW DATABASE PERFORMANCE STATE on SQL Server 2022.
   Query Store must be enabled and wait stats captured.
   Active intervals can have duplicate in-memory/disk rows:
   aggregate by plan, interval, execution type, wait category, replica group.
*/
USE [SalesDB];
SET NOCOUNT ON;
DECLARE @StartUtc datetimeoffset(7)='2026-11-04T18:00:00+00:00';
DECLARE @EndUtc   datetimeoffset(7)='2026-11-04T19:00:00+00:00';

SELECT actual_state_desc, desired_state_desc,
       wait_stats_capture_mode_desc, readonly_reason
FROM sys.database_query_store_options;

;WITH grouped_waits AS
(
 SELECT ws.plan_id,ws.runtime_stats_interval_id,ws.execution_type,
        ws.wait_category,ws.wait_category_desc,ws.replica_group_id,
        SUM(ws.total_query_wait_time_ms) AS wait_ms
 FROM sys.query_store_wait_stats AS ws
 GROUP BY ws.plan_id,ws.runtime_stats_interval_id,ws.execution_type,
          ws.wait_category,ws.wait_category_desc,ws.replica_group_id
)
SELECT TOP (25) q.query_id,w.plan_id,w.replica_group_id,
       w.wait_category_desc,
       SUM(w.wait_ms) AS total_wait_ms,
       COUNT(DISTINCT w.runtime_stats_interval_id) AS intervals_seen,
       LEFT(qt.query_sql_text,2000) AS query_text_excerpt
FROM grouped_waits AS w
JOIN sys.query_store_runtime_stats_interval AS i
 ON i.runtime_stats_interval_id=w.runtime_stats_interval_id
JOIN sys.query_store_plan AS p ON p.plan_id=w.plan_id
JOIN sys.query_store_query AS q ON q.query_id=p.query_id
JOIN sys.query_store_query_text AS qt ON qt.query_text_id=q.query_text_id
WHERE i.start_time < @EndUtc AND i.end_time > @StartUtc
  AND w.execution_type=0
GROUP BY q.query_id,w.plan_id,w.replica_group_id,
         w.wait_category_desc,qt.query_sql_text
ORDER BY total_wait_ms DESC;
-- Intervals overlapping the boundary are included in full.
-- Do not treat results as exact-to-the-second incident totals.
-- Wait categories are not individual wait types.
