/*
DBA-013 | Current requests and blocking chains.
Read-only, point-in-time snapshot; rerun to observe persistence.
A sleeping head blocker may not have an active request.
*/
SET NOCOUNT ON;
SELECT
    s.session_id, s.login_name, s.host_name, s.program_name,
    s.status AS session_status,
    r.status AS request_status,
    r.blocking_session_id, r.wait_type, r.wait_time AS wait_time_ms,
    r.wait_resource, r.cpu_time AS cpu_time_ms,
    r.total_elapsed_time AS elapsed_ms,
    DB_NAME(COALESCE(r.database_id,s.database_id)) AS database_name,
    t.text AS current_or_last_batch,
    ib.event_info AS input_buffer_text
FROM sys.dm_exec_sessions AS s
LEFT JOIN sys.dm_exec_requests AS r ON s.session_id = r.session_id
LEFT JOIN sys.dm_exec_connections AS c ON s.session_id = c.session_id
OUTER APPLY sys.dm_exec_sql_text(COALESCE(r.sql_handle,c.most_recent_sql_handle)) AS t
OUTER APPLY sys.dm_exec_input_buffer(s.session_id, r.request_id) AS ib
WHERE s.is_user_process = 1
  AND (r.blocking_session_id <> 0
       OR EXISTS (SELECT 1 FROM sys.dm_exec_requests AS blocked
                  WHERE blocked.blocking_session_id = s.session_id))
ORDER BY CASE WHEN r.blocking_session_id = 0 OR r.blocking_session_id IS NULL
              THEN 0 ELSE 1 END, s.session_id;

-- Current waiting lock requests, including resource and request status.
SELECT request_session_id, resource_type, resource_database_id,
       resource_associated_entity_id, request_mode, request_status,
       request_owner_type
FROM sys.dm_tran_locks
WHERE request_status = 'WAIT'
ORDER BY request_session_id;
