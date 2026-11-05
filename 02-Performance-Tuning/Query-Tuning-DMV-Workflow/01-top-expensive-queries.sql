/*
DBA-011 | Top cached statements by cumulative elapsed time
SQL Server 2019/2022. Read-only. Requires VIEW SERVER STATE (2019)
or VIEW SERVER PERFORMANCE STATE (2022).
Cumulative values cover cached plan lifetime, not a fixed historical window.
*/
SET NOCOUNT ON;
SELECT TOP (10)
    DB_NAME(CONVERT(int, pa.value)) AS database_name,
    qs.execution_count,
    CAST(qs.total_elapsed_time / 1000.0 AS decimal(19,2)) AS total_elapsed_ms,
    CAST(qs.total_elapsed_time / 1000.0 / NULLIF(qs.execution_count,0) AS decimal(19,2)) AS avg_elapsed_ms,
    CAST(qs.total_worker_time / 1000.0 AS decimal(19,2)) AS total_cpu_ms,
    qs.total_logical_reads,
    qs.total_logical_writes,
    qs.last_execution_time,
    qs.plan_handle,
    qs.sql_handle,
    SUBSTRING(st.text,
      (qs.statement_start_offset / 2) + 1,
      ((CASE qs.statement_end_offset WHEN -1 THEN DATALENGTH(st.text)
        ELSE qs.statement_end_offset END - qs.statement_start_offset) / 2) + 1
    ) AS statement_text,
    qp.query_plan
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
OUTER APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
OUTER APPLY (SELECT TOP (1) value FROM sys.dm_exec_plan_attributes(qs.plan_handle)
             WHERE attribute = 'dbid') AS pa
ORDER BY qs.total_elapsed_time DESC;
