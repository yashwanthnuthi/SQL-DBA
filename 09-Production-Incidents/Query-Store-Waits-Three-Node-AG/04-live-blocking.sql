/* DBA-025 | Run on the replica serving the slow request.
   Current blocking only; an incident may have already ended.
   No KILL, DBCC CLEAR, or configuration changes.
*/
SET NOCOUNT ON;
SELECT @@SERVERNAME AS server_name,r.session_id,r.blocking_session_id,
       DB_NAME(r.database_id) AS database_name,r.status,r.wait_type,
       r.wait_time AS wait_ms,r.wait_resource,
       r.total_elapsed_time AS elapsed_ms,r.cpu_time AS cpu_ms,
       s.login_name,s.host_name,
       LEFT(t.text,2000) AS batch_text
FROM sys.dm_exec_requests AS r
JOIN sys.dm_exec_sessions AS s ON s.session_id=r.session_id
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) AS t
WHERE r.session_id<>@@SPID AND
      (r.blocking_session_id<>0 OR r.wait_type LIKE 'LCK_M_%')
ORDER BY r.wait_time DESC;
