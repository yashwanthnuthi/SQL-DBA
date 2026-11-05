/*
DBA-012 | Instance cumulative wait statistics, highest wait_ms first.
Read-only. Counters reset on restart or DBCC SQLPERF(..., CLEAR).
Compare snapshots over a known interval for meaningful rates.
*/
SET NOCOUNT ON;
WITH waits AS
(
    SELECT wait_type, waiting_tasks_count, wait_time_ms,
           signal_wait_time_ms,
           wait_time_ms - signal_wait_time_ms AS resource_wait_ms
    FROM sys.dm_os_wait_stats
    WHERE wait_time_ms > 0
      AND wait_type NOT IN
      ('SLEEP_TASK','SLEEP_SYSTEMTASK','LAZYWRITER_SLEEP',
       'SQLTRACE_BUFFER_FLUSH','XE_TIMER_EVENT','XE_DISPATCHER_WAIT',
       'REQUEST_FOR_DEADLOCK_SEARCH','BROKER_TASK_STOP',
       'BROKER_TO_FLUSH','BROKER_EVENTHANDLER',
       'CLR_AUTO_EVENT','CLR_MANUAL_EVENT','LOGMGR_QUEUE',
       'CHECKPOINT_QUEUE','FT_IFTS_SCHEDULER_IDLE_WAIT',
       'DIRTY_PAGE_POLL','HADR_FILESTREAM_IOMGR_IOCOMPLETION')
)
SELECT wait_type, waiting_tasks_count,
       wait_time_ms,
       CAST(100.0 * wait_time_ms / NULLIF(SUM(wait_time_ms) OVER (),0)
            AS decimal(6,2)) AS pct_of_filtered_waits,
       CAST(wait_time_ms * 1.0 / NULLIF(waiting_tasks_count,0)
            AS decimal(18,2)) AS avg_wait_ms,
       signal_wait_time_ms, resource_wait_ms
FROM waits
ORDER BY wait_time_ms DESC;
