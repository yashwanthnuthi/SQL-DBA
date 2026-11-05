/* DBA-022 | Run on each replica. SQL Server 2022. Read only.
   Check roles, synchronization, queues and connection health.
   Server-wide DMV access requires VIEW SERVER PERFORMANCE STATE in 2022.
   Never assume the server you connected to is the primary. */
SET NOCOUNT ON;
SELECT @@SERVERNAME AS connected_server, ag.name AS ag_name,
       ar.replica_server_name, ars.role_desc,
       ars.connected_state_desc, ars.synchronization_health_desc,
       ar.availability_mode_desc, ar.secondary_role_allow_connections_desc
FROM sys.availability_groups AS ag
JOIN sys.availability_replicas AS ar ON ar.group_id=ag.group_id
LEFT JOIN sys.dm_hadr_availability_replica_states AS ars
 ON ars.replica_id=ar.replica_id
WHERE ag.name=N'AG_SALES_PROD'
ORDER BY ar.replica_server_name;

SELECT @@SERVERNAME AS connected_server, DB_NAME(drs.database_id) AS database_name,
       ar.replica_server_name, drs.is_local, drs.synchronization_state_desc,
       drs.synchronization_health_desc, drs.is_suspended,
       drs.log_send_queue_size AS log_send_queue_kb,
       drs.redo_queue_size AS redo_queue_kb,
       drs.last_commit_time
FROM sys.dm_hadr_database_replica_states AS drs
JOIN sys.availability_replicas AS ar ON ar.replica_id=drs.replica_id
WHERE DB_NAME(drs.database_id)=N'SalesDB'
ORDER BY ar.replica_server_name;
