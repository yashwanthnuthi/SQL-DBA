/*
DBA-014 | File-level cumulative I/O since SQL Server startup.
Read-only; sys.dm_io_virtual_file_stats(NULL,NULL) covers all databases.
Latency averages can hide spikes; take interval snapshots for diagnosis.
*/
SET NOCOUNT ON;
SELECT DB_NAME(vfs.database_id) AS database_name,
       mf.name AS logical_file_name,
       mf.type_desc, mf.physical_name,
       vfs.num_of_reads, vfs.num_of_writes,
       CAST(vfs.num_of_bytes_read / 1048576.0 AS decimal(19,2)) AS mb_read,
       CAST(vfs.num_of_bytes_written / 1048576.0 AS decimal(19,2)) AS mb_written,
       CAST(vfs.io_stall_read_ms * 1.0 / NULLIF(vfs.num_of_reads,0)
            AS decimal(19,2)) AS avg_read_latency_ms,
       CAST(vfs.io_stall_write_ms * 1.0 / NULLIF(vfs.num_of_writes,0)
            AS decimal(19,2)) AS avg_write_latency_ms,
       CAST((vfs.io_stall_read_ms + vfs.io_stall_write_ms) * 1.0 /
            NULLIF(vfs.num_of_reads + vfs.num_of_writes,0)
            AS decimal(19,2)) AS avg_total_latency_ms,
       vfs.sample_ms
FROM sys.dm_io_virtual_file_stats(NULL,NULL) AS vfs
JOIN sys.master_files AS mf
  ON mf.database_id = vfs.database_id AND mf.file_id = vfs.file_id
ORDER BY avg_total_latency_ms DESC, database_name, logical_file_name;
